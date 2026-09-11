# Hardware & VRAM

This project targets one very specific, very popular configuration:

| Component | Spec |
| --- | --- |
| GPU | NVIDIA RTX 4070 Ti Super |
| VRAM | 16 GB GDDR6X |
| Memory bandwidth | 672 GB/s |
| System RAM | 32 GB DDR5 |
| Storage | NVMe SSD |

Bandwidth is the number that decides tokens per second. For a model that fits
entirely in VRAM, throughput is roughly:

```
tokens/sec ≈ memory bandwidth ÷ model size in VRAM
```

A 10 GB model on this card is therefore in the tens of tokens per second.
Once a model spills into system RAM, throughput collapses to DDR5 speeds.

## The usable-VRAM budget

You do not get all 16 GB. Reserve roughly **1.0–1.5 GB** for Windows, the
desktop, and the runtime's own overhead. Plan on **~14.75 GB usable**.

Every VRAM number in this repo is one of:

- **Weights** — the model file loaded into memory.
- **KV cache** — the attention cache, which grows with context length.
- **Activations & buffers** — a few hundred MB, usually folded into overhead.

## VRAM math you can do in your head

### Weights

Approximate size of a quantized model (billion params × GB/param):

| Quant | GB per B params | Notes |
| --- | --- | --- |
| Q2_K | ~0.42 | Noticeably degraded; last resort |
| Q3_K_M | ~0.50 | Usable for 30B+ on 16 GB |
| Q4_K_M | ~0.58 | The community sweet spot |
| Q4_K_S | ~0.55 | Slightly smaller Q4 |
| Q5_K_M | ~0.70 | High quality |
| Q6_K | ~0.82 | Near-lossless |
| Q8_0 | ~1.08 | Effectively lossless |
| FP16 | ~2.00 | Reference |

Example: a 14B model at Q5_K_M ≈ 14 × 0.70 ≈ **9.8 GB** of weights.

### KV cache

KV cache is the hidden budget killer. It scales linearly with context:

```
KV GB ≈ kvPerTokenMB × contextTokens ÷ 1024
```

`kvPerTokenMB` depends on the architecture (layers, KV heads, head dim). Each
model entry in `data/models.json` carries this value, so the website calculator
and the tables can compute KV for any context.

Rough impact:

- 8K context: usually 1–3 GB
- 32K context: often 4–8 GB on dense models with many KV heads
- 128K context: can exceed the weights entirely on some architectures

**Levers:** use a smaller context, enable KV-cache quantization (Q8/Q4),
and prefer models with grouped-query attention and few KV heads.

## Fit verdicts

Each model gets a verdict for this exact hardware:

| Verdict | Meaning |
| --- | --- |
| **Full** | Weights + a useful context fit entirely in VRAM. |
| **Tight** | Fits, but only with a modest context or a smaller quant. |
| **Offload** | Some layers run on CPU/RAM. Still usable when the model is MoE. |

## Why MoE models punch above their weight

Mixture-of-Experts models (Qwen3-30B-A3B, gpt-oss-20b, Qwen3-Coder-30B-A3B)
activate only a fraction of their parameters per token. On this hardware that
means:

- They can be **larger in total** than a dense model would allow.
- They generate **much faster** than their total size suggests.
- If a few layers spill to system RAM, the penalty is far smaller than for a
  dense model, because only the active experts matter per token.

This is why an MoE with 30B total parameters can be more practical here than a
dense 24B model.

## Quick reference: what fits fully on 16 GB

| Size | Comfortable quant | Headroom |
| --- | --- | --- |
| 7–8B | Q8_0 | Large — long context, many parallel tasks |
| 12–14B | Q5_K_M → Q6_K | Good |
| 20–24B | Q4_K_M | Small — keep context modest |
| 30B+ dense | Q3_K_M at best | Offload likely |
| 20–30B MoE | Q4_K_M | Offload friendly, still fast |
| 32B+ | Q3_K_M / Q4 with offload | Slow but capable |

## System RAM and offload

Your 32 GB DDR5 is a useful overflow, not a substitute for VRAM. When offloading:

- Keep as many layers on the GPU as possible (`-ngl` in llama.cpp).
- Expect a large speed drop once weights stream over PCIe.
- MoE models tolerate offload far better than dense models.
- Close other GPU consumers (browser, games, another runtime) first.
