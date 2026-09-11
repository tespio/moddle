# Offloading

Offloading means keeping part of a model out of VRAM — in system RAM, or on the
CPU — so a model that does not fit can still run. Done right it costs you a
little speed. Done wrong it turns a fast model into a slideshow. This guide is
about doing it right on a 16 GB card with 32 GB of RAM.

## The one rule

**VRAM bandwidth is roughly 10–20× system RAM bandwidth** (your card: ~672 GB/s;
DDR5: ~50–90 GB/s). Every token must read all *active* weights. So:

- Weights in VRAM: fast.
- Weights streamed from RAM over PCIe every token: slow.
- **But** if only a few active parameters live in RAM, and the rest — especially
  attention — stays on the GPU, the penalty can be small.

That last point is the whole game for MoE models.

## What you can offload

| Thing | Offload it? | Notes |
| --- | --- | --- |
| Transformer layers (dense) | Last resort | Big speed hit, roughly linear with layers moved |
| MoE **expert** weights | **Yes, first choice** | Only active experts matter per token |
| Attention / KV cache | Usually keep on GPU | KV is read every step |
| Vision tower | Sometimes | Turn off images before hurting text speed |
| KV cache precision | Always worth trying | int8/int4 KV can free several GB |
| Batch/compute buffers | Tune, not offload | Lower `-b`/`-ub` to save memory |

## Why MoE offload is different

A Mixture-of-Experts model (Qwen3-30B-A3B, gpt-oss-20b, Gemma 4 26B, GLM-4.7-Flash,
LFM2-24B-A2B) has ~30B weights but activates only ~3B per token. Most of the
weights are *inactive experts* that are not read on a given token.

So you can park the experts in RAM and keep the attention, router, and shared
layers on the GPU. The GPU reads only the small active set from RAM — a fraction
of a dense model's cost — so throughput stays high. A dense 24B with half its
layers offloaded will feel far worse than a 30B MoE with *all* experts in RAM.

**Order of operations for MoE:** keep `-ngl` maxed, then offload experts.

## llama.cpp

The reference implementation for offload control.

| Flag | What it does |
| --- | --- |
| `-ngl N` / `--gpu-layers N` | Layers on GPU. Start at 99, lower until it loads. |
| `-ncmoe N` / `--n-cpu-moe N` | Keep MoE experts of N layers on CPU. The MoE lever. |
| `--cpu-moe` | Force *all* MoE experts to CPU (extreme). |
| `-ot "regex=CPU"` / `--override-tensor` | Assign tensors to a buffer by regex. Surgical. |
| `-ctk q8_0 -ctv q8_0` | Quantize the KV cache (also `q4_0`). |
| `-fa` / `--flash-attn` | Flash attention: less memory, faster. |
| `-b N` / `-ub N` | Logical/physical batch. Lower if long prompts OOM. |
| `-t N` / `--threads N` | CPU threads for the offloaded part (≈ physical cores). |
| `-ts 12,4` / `--tensor-split` | Per-GPU VRAM split. |
| `--no-mmap` | Do not memory-map weights (can help on RAM-starved boxes). |
| `--mlock` | Lock weights in RAM. Use with care. |

**Dense model, just under the line** — keep as many layers on GPU as fit:

```bash
llama-server -hf unsloth/Qwen3.8-27B-GGUF:Q4_K_M -c 16384 -ngl 40 -fa
```

**MoE model, full quality, fast** — all layers' attention on GPU, experts in RAM:

```bash
llama-server -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M \
  -c 32768 -ngl 99 -ncmoe 24 -fa
```

Nudge `-ncmoe` up until it fits; each step trades a little speed for a lot of
VRAM. If text is fine but long prompts OOM, drop `-ub` to 128 or 256.

## Ollama

Ollama wraps llama.cpp and decides offload for you, but you can steer it.

```bash
# Layers on GPU (0 = all CPU, 99 = all GPU)
ollama run qwen3:30b --parameter num_gpu 99

# Context and batch
ollama run qwen3:30b --parameter num_ctx 16384 --parameter num_batch 256

# CPU threads for the offloaded part
ollama run qwen3:30b --parameter num_thread 8
```

A `Modelfile` bakes it in:

```dockerfile
FROM qwen3:30b
PARAMETER num_gpu 99
PARAMETER num_ctx 16384
PARAMETER num_batch 256
```

Server-level environment variables (set before starting `ollama serve`):

| Variable | Effect |
| --- | --- |
| `OLLAMA_KEEP_ALIVE=30m` | Don't unload the model between requests |
| `OLLAMA_MAX_LOADED_MODELS=1` | Stop two models fighting for VRAM |
| `OLLAMA_NUM_PARALLEL=1` | One request at a time (less KV reserved) |
| `OLLAMA_FLASH_ATTENTION=1` | Enable flash attention |
| `OLLAMA_KV_CACHE_TYPE=q8_0` | Quantize the KV cache |
| `OLLAMA_GPU_OVERHEAD=1000000000` | Reserve ~1 GB for the desktop |

## LM Studio

GUI equivalents of the same knobs, per model:

- **GPU Offload** slider — the `-ngl` equivalent. Drag right until load fails,
  then back off one or two.
- **Force Model Onto GPU** — keep as much resident as possible.
- **Context Length** — halve it before reducing offload; context is often cheaper
  to give up than weights.
- **KV Cache Quantization** — set to Q8_0 or Q4_0 when context is tight.
- **Flash Attention** — on.
- **CPU Thread Pool Size** — match physical cores for the offloaded part.

## vLLM

vLLM reserves VRAM up front and offloads at the *layer* level.

```bash
vllm serve Qwen/Qwen3-14B \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.92 \
  --cpu-offload-gb 4 \
  --swap-space 8 \
  --kv-cache-dtype fp8
```

| Flag | Effect |
| --- | --- |
| `--gpu-memory-utilization 0.92` | VRAM ceiling. Lower it first. |
| `--max-model-len` | Directly controls KV reservation. The big lever. |
| `--cpu-offload-gb N` | Offload N GB of weights to RAM/CPU. |
| `--swap-space N` | Host swap for KV blocks. |
| `--kv-cache-dtype fp8` | Compress the KV cache. |
| `--enforce-eager` | Skip CUDA graphs; saves memory, costs a little speed. |
| `--max-num-seqs N` | Fewer concurrent sequences → less KV. |

## SGLang

```bash
python -m sglang.launch_server --model-path Qwen/Qwen3-14B \
  --mem-fraction-static 0.85 --context-length 16384 --cpu-offload-gb 4
```

- `--mem-fraction-static` — VRAM budget.
- `--context-length` — cap KV.
- `--cpu-offload-gb` — offload weights to RAM.
- `--disable-radix-cache` — saves memory in some workloads.

## ExLlamaV3 (EXL3)

The Simplex kit exposes offload through `.env` rather than flags:

| Key | Effect |
| --- | --- |
| `GPU_MEM_GB` | Process VRAM budget. Lower it to force more into RAM. |
| `CONTEXT_SIZE` | Tokens of KV to allocate. The main VRAM lever. |
| `CACHE_QUANT` | `4`, `8,4`, or `none` — int4 KV is near-lossless. |
| `VISION` | `off` skips the vision tower if it won't fit. |
| `DRAFT=mtp` | Speculative decoding head; ~50 MB extra. Set `none` to save. |

Because EXL3 quants are small, a 27B usually runs **fully resident** at 2.5 bpw —
offload is rarely needed. See [EXL3 & ExLlamaV3](exl3.md).

## ComfyUI (image & video)

- `--lowvram` — move models in and out of VRAM as needed.
- `--novram` — aggressive; for very small cards.
- `--reserve-vram 1.0` — leave ~1 GB for the system.
- `--cpu-vae` — run VAE decode on CPU (frees VRAM at the end).
- `--disable-smart-memory` — unload after each generation.
- Prefer **fp8 / GGUF** checkpoints over offloading fp16; it is usually better
  quality per byte.

## Windows-specific warnings

Windows is not like Linux here:

- If VRAM runs out, the driver **silently spills into "shared GPU memory"
  (system RAM)** instead of failing. The model "loads" and then runs many times
  slower. If it feels wrong, it probably is — check the numbers.
- **Free VRAM before loading.** Browsers, Discord, games, and other AI tools hold
  hundreds of MB to a few GB. Check with `nvidia-smi` or Task Manager →
  Performance → GPU.
- Turn off browser hardware acceleration if you need the last gigabyte.
- `--reserve-vram` (ComfyUI) and `OLLAMA_GPU_OVERHEAD` (Ollama) both help leave
  room for the desktop.

## How to measure

1. `nvidia-smi -l 1` (or Task Manager) while generating. If VRAM is pinned at max
   and RAM use is high, you're offloading.
2. Compare tokens/sec before and after each change — one change at a time.
3. `llama-bench` for llama.cpp; `ollama run --verbose` prints eval rates.

## Recipes for 16 GB

| Situation | Recipe |
| --- | --- |
| 7–14B dense, want max context | Keep fully on GPU; `-ctk q8_0 -ctv q8_0 -fa` |
| 24–32B dense at Q4 | `-ngl` just below the fail point; KV q8_0; cap context |
| 30B MoE at Q4 | `-ngl 99 -ncmoe 20-28 -fa`; keep attention on GPU |
| 27B EXL3 | No offload: 2.5 bpw + int4 KV fits fully (see [EXL3](exl3.md)) |
| Long prompt OOM at load | Lower `-ub` to 128–256, then `-b` |
| Was fast, now crawling | Something else is holding VRAM, or you're spilling to shared memory |

## The golden rules

1. **Prefer a smaller quant over heavy offload.** Offload is for when even Q4 is too big.
2. **Prefer a smaller context over fewer resident layers.** Context is often the cheaper sacrifice.
3. **Quantize the KV cache before offloading weights.** q8_0 KV is nearly free quality-wise.
4. **For MoE, offload experts, never attention.**
5. **On Windows, free VRAM first** — offloading into shared memory is the worst of both worlds.
