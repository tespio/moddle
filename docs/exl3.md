# EXL3 & ExLlamaV3

**EXL3** is the quantization format for **ExLlamaV3** by
[turboderp](https://github.com/turboderp-org/exllamav3). It is the highest-quality
low-bit format for NVIDIA GPUs, and it is why a 27B model can now live fully on a
16 GB card without the quality collapse you would get from a GGUF at the same
size.

If GGUF is the universal format, EXL3 is the one tuned for your 16 GB Nvidia card.

> **HUGE THANKS to [Mia's AI Lab](https://github.com/MiaAI-Lab/Qwen3.8-27B-16gb-NVIDIA-GPUs-one-click-install)
> ([@MiaAI_lab](https://x.com/MiaAI_lab)).** They built the **Simplex one-click
> installer** and the **2.0 bpw EXL3 quant** that make **Qwen3.8-27B run fully on
> a single 16 GB NVIDIA card**, and published the 16 GB profile table and quality
> measurements this guide is built on. If this page helps you, go star their
> project — they did the hard part.

## Why it matters here

A GGUF Q4 27B model is ~16 GB of weights — it does not fit, so you offload and
crawl. EXL3 stores the same model at **2.5 bits per weight (~9.7–11 GB)** with
int4 KV cache, which leaves room for a **176K-token context and the vision
tower** on a 16 GB board. That is the difference between "technically runs" and
"actually usable."

## The bit-per-weight (bpw) ladder

For **Qwen3.8-27B**, quality is measured as mean KL divergence against bf16
(lower is better):

| Quant | Mean KL | Quality | Fits 16 GB |
| --- | --- | --- | --- |
| EXL3 2.0 bpw | 0.35 | fair | Yes — ~229K ctx, with images |
| EXL3 2.5 bpw | 0.30 | good | Yes — ~176K ctx, with images |
| EXL3 3.0 bpw | 0.11 | better | Yes — ~118K ctx, with images |
| EXL3 3.5 bpw | 0.08 | very good | Yes — ~78K ctx, text only |
| EXL3 4.0 bpw | 0.05 | very good | 24 GB+ for long context |
| EXL3 5.0 bpw | 0.014 | excellent | 24 GB+ |
| EXL3 6.0 bpw | 0.007 | near-lossless | 24 GB+ |

On 16 GB the sweet spot is **2.5 bpw** — the best quality that still leaves a
realistic context window *and* image support. Drop to 3.0 bpw if you want better
text quality and can accept a shorter context.

## KV cache

EXL3 lets you quantize the KV cache independently. **int4 KV** is measured within
**0.001 KL** of fp16, with no special hardware requirement — so it is the default
for every profile. This is what makes long context affordable at low bpw. In this
repo, quant entries that specify `kvPerTokenMB` use the int4 figure, so the
website calculator matches the EXL3 reality.

## Requirements

- **NVIDIA** GPU, compute capability **7.5+** (Turing or newer); 16 GB is the
  sweet spot.
- Driver **570+** (the default PyTorch build is cu128).
- **Python 3.11+**, 64-bit. Node **22.19+** only if you want the bundled chat UI.
- Your card should have ~**14.7 GB free** after the driver for the baseline
  profile.

ExLlamaV3 itself is the engine (v1.4.4 for the quantized vision tower). It ships
prebuilt CUDA wheels, so you do not need the CUDA Toolkit or Visual Studio Build
Tools.

## The one-click kit (by Mia's AI Lab) — huge thanks

If you just want Qwen3.8-27B running on a 16 GB card, use **Simplex**, a serving
kit by Mia's AI Lab:

- <https://github.com/MiaAI-Lab/Qwen3.8-27B-16gb-NVIDIA-GPUs-one-click-install>

What it does:

- Detects your VRAM and **picks the EXL3 quant that fits** (2.5 bpw on 16 GB).
- Installs its own Python environment, downloads the weights (resumable), and
  needs no administrator rights.
- Serves an **OpenAI-compatible API** at `http://127.0.0.1:8888/v1` (any key;
  use `local`), and opens a chat UI.
- Windows and Linux, same behavior.

The 2.0 bpw quant is Mia's own upload; 2.5 bpw and up come from
[turboderp/Qwen3.8-27B-exl3](https://huggingface.co/turboderp/Qwen3.8-27B-exl3).

## Using EXL3 with other clients

Because the kit exposes a plain OpenAI endpoint, you can point Open WebUI,
Chatbox, Continue, Cursor's custom endpoint, the OpenAI SDK, or `curl` at it:

```
Base URL: http://127.0.0.1:8888/v1
API key:  local
Model:    whatever the kit loaded (e.g. qwen3.8-27b-exl3-2.5bpw)
```

Tool calling and image inputs (`image_url` content parts) are supported.

## EXL3 vs GGUF at a glance

| | EXL3 | GGUF |
| --- | --- | --- |
| Best for | NVIDIA GPUs, max quality per byte | Anything, portable |
| Runtime | ExLlamaV3 | llama.cpp / Ollama / LM Studio |
| Low bits | Excellent (2.0–3.5 bpw) | Degrades faster below Q4 |
| KV | int4, near-lossless | q8_0 / q4_0 |
| 27B on 16 GB | Fully resident at 2.5 bpw | Offload at Q4 |

Use EXL3 when the model is *almost* too big and you have an NVIDIA card. Use GGUF
when you want portability, CPU/macOS support, or the Ollama ecosystem.
