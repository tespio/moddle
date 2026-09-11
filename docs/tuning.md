# Tuning for 16 GB

A practical checklist for getting the most out of an RTX 4070 Ti Super. Most
"it doesn't fit" problems are actually a context, KV-cache, or overhead problem
— not a weights problem.

## The order of operations

1. **Fit the weights first.** Pick a quant whose weights leave ~2 GB for KV and
   overhead.
2. **Choose a context that fits.** Use the calculator on the website, or the
   `kvPerTokenMB` values in `data/models.json`.
3. **Quantize the KV cache** if you need more context than fits at f16.
4. **Offload the minimum.** If you must spill, offload as few layers as possible.
5. **Measure.** Change one thing at a time.

## Context length

Context is not free. Going from 8K to 32K can add several GB. For long-context
work:

- Prefer architectures with grouped-query attention and few KV heads.
- Enable KV-cache quantization (see `quantization.md`).
- Consider a model with native long-context support rather than stretching a
  short-context one.

## llama.cpp / Ollama flags

| Flag | What it does | Rule of thumb |
| --- | --- | --- |
| `-ngl N` | Layers on GPU | As high as fits; then tune down |
| `-c N` | Context size | Match your workload, don't max it |
| `--flash-attn` | Flash attention | On; lower memory, faster |
| `-ctk q8_0 -ctv q8_0` | Quantized KV cache | When context won't fit |
| `--no-mmap` | Don't memory-map weights | Can help RAM-starved systems |
| `-b N` / `-ub N` | Batch sizes | Lower if you hit OOM with long prompts |
| `--n-cpu-moe N` | MoE experts on CPU | Offload experts, keep attention on GPU |

For MoE models, `--n-cpu-moe` (llama.cpp) is often better than reducing `-ngl`:
it keeps the attention and shared layers on the GPU and parks only the experts
in system RAM.

## Ollama

Ollama chooses sensible defaults, but you can steer it:

```bash
# Keep a model resident so it isn't unloaded between requests
OLLAMA_KEEP_ALIVE=30m ollama run qwen3:14b

# Cap context (Ollama defaults to 4K for many models)
ollama run qwen3:14b --parameter num_ctx 16384

# Reduce GPU layers if you share the card with a display
ollama run qwen3:14b --parameter num_gpu 40
```

Use a `Modelfile` to bake in settings:

```dockerfile
FROM qwen3:14b
PARAMETER num_ctx 16384
PARAMETER num_gpu 99
```

## vLLM / SGLang

These servers assume you can dedicate most of the GPU. On 16 GB:

```bash
vllm serve Qwen/Qwen3-14B \
  --max-model-len 16384 \
  --gpu-memory-utilization 0.92 \
  --dtype auto
```

- Lower `--max-model-len` first; it directly controls KV-cache reservation.
- `--gpu-memory-utilization` is a ceiling; 0.90–0.95 is safe on a dedicated card.
- vLLM is best when you want batching/throughput, not a single chat session.

## ComfyUI

- Keep the model in VRAM between generations (disable aggressive unloading).
- Use fp8 or GGUF checkpoints for FLUX when fp16 doesn't fit.
- Reduce resolution before reducing steps; quality usually holds better.
- `--lowvram` only helps if you're truly out of memory. Prefer fp8/GGUF first.

## Speeding up a model that already fits

- **Turn on flash attention.**
- **Raise batch size** for prompt processing (prefill), lower it if you OOM.
- **Keep the model loaded** between requests.
- **Close other VRAM users** — a browser with hardware acceleration can hold
  a gigabyte or two.
- **Use the biggest quant that fits.** Higher quants are often *not* slower
  enough to matter but are meaningfully better.

## Diagnosing OOM

Symptom → likely cause:

| Symptom | Try |
| --- | --- |
| Fails at load | Lower quant, lower `-ngl`, smaller context |
| Loads, OOM after a long prompt | Lower `-b`/`-ub`, quantize KV |
| Works but crawls | Model is offloading; reduce layers on CPU or quant |
| Fine alone, OOM with a game/browser open | Free VRAM first |
| Random crashes under load | Driver/VRAM clock; reduce power limit or accept it |
