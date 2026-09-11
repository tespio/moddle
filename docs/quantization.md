# Quantization

Quantization shrinks model weights by storing them with fewer bits. It is the
single biggest lever for fitting a model on 16 GB. Done well, the quality loss
is tiny; done aggressively, the model gets noticeably dumber.

## The formats you'll meet

- **GGUF** — the llama.cpp / Ollama / LM Studio format. One file, CPU + GPU
  friendly, wide quant range (`Q2_K` … `Q8_0`, plus `IQ` variants).
- **EXL2 / AWQ / GPTQ** — GPU-oriented formats popular in ExLlamaV2 and vLLM.
- **MXFP4** — the native 4-bit format for `gpt-oss` weights.
- **fp8 / fp16** — used by diffusion models, embeddings, and speech models in
  PyTorch-based runtimes.

## GGUF quant ladder

| Quant | ~GB / B | Quality | When to use |
| --- | --- | --- | --- |
| Q8_0 | 1.08 | Effectively lossless | Small models you want pristine |
| Q6_K | 0.82 | Near-lossless | Best quality that still fits medium models |
| Q5_K_M | 0.70 | Excellent | The default recommendation |
| Q4_K_M | 0.58 | Very good | Best size/quality tradeoff; the community standard |
| Q4_K_S | 0.55 | Good | A little extra headroom |
| Q3_K_M | 0.50 | Noticeable | Squeezing 30B+ dense onto 16 GB |
| Q2_K | 0.42 | Degraded | Last resort only |

### K-quants vs IQ-quants

- **K-quants** (`Q4_K_M`, `Q5_K_M`, …) are the well-tested baseline. `_M` mixes
  precision across tensors for a better result than `_S`.
- **IQ-quants** (`IQ4_XS`, `IQ3_XXS`) use imatrix calibration to get better
  quality at very low bitrates. Great when you must go below Q4, but slower to
  produce and slightly more runtime-dependent.

## EXL3 (ExLlamaV3)

[EXL3](exl3.md) is a NVIDIA-focused quant format for the ExLlamaV3 engine. It
holds up far better than GGUF below 4 bits, which matters most on a 16 GB card:

- **2.0–3.5 bpw** quants of a 27B model fit in 16 GB while keeping a long context
  and the vision tower.
- **int4 KV cache** is near-lossless (measured within 0.001 KL of fp16) and is the
  default in the recommended profiles.
- Quality is tracked as mean KL versus bf16, so you can pick a bpw deliberately.

If you have an NVIDIA 16 GB card and a model that is just too big for GGUF, reach
for EXL3 first.

## Practical rules

1. **Start at Q4_K_M.** If it fits with the context you want, you're done.
2. **Move up, not down.** If you have VRAM left, try Q5_K_M or Q6_K. Quality
   gains are real and the cost is only space.
3. **Only go below Q4 to fit.** Q3/Q2 trade quality fast. Prefer a smaller model
   at Q5 over a bigger model at Q2.
4. **Quantize KV cache separately.** `Q8_0` or `Q4_0` KV cache can reclaim
   several GB at long context for a small quality cost — often a better trade
   than dropping the weights a whole quant level.

## KV-cache quantization

Two independent decisions: how the **weights** are stored, and how the
**attention KV cache** is stored. At long context the cache can rival the
weights.

| KV type | Size | Notes |
| --- | --- | --- |
| f16 (default) | 100% | Reference |
| q8_0 | ~50% | Almost no perceptible loss |
| q4_0 | ~25% | Small loss; great for long context |

On a 16 GB card, `q8_0` KV is usually the first thing to try when a model is
just barely too big at your desired context.

## Diffusion and non-LLM models

Image, video, speech, and embedding models are qantized differently:

- **fp16 → fp8** roughly halves size with minor quality impact; standard for
  FLUX on 16 GB.
- **GGUF quants for diffusion** (via ComfyUI-GGUF) let you run FLUX.1-dev at Q4
  when fp8 is too tight.
- Speech and embedding models are small enough that fp16 is rarely a problem.

## A note on accuracy

Quantization benchmarks vary by model, task, and runtime. Numbers in this repo
are starting points, not verdicts. If an answer looks wrong, try one quant
higher before blaming the model.
