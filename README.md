# moddle

**Because your GPU has 16 GB, not infinite.**

A curated guide to the best local AI models that actually fit an **RTX 4070 Ti Super 16 GB**, 32 GB DDR5, and NVMe storage - with honest VRAM math, quants, and copy-ready commands.

[![License: MIT](https://img.shields.io/badge/code-MIT-blue.svg)](LICENSE) [![Content: CC BY 4.0](https://img.shields.io/badge/content-CC--BY--4.0-lightgrey.svg)](LICENSE-CONTENT)

**[Browse the website ->](https://tespio.github.io/moddle)**

## Target hardware

| Component | Spec |
| --- | --- |
| GPU | RTX 4070 Ti Super |
| VRAM | 16 GB (~14.75 GB usable) |
| Bandwidth | 672 GB/s |
| System RAM | 32 GB DDR5 |
| Storage | NVMe SSD |

## If you only try ten things

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [Qwen3-14B](https://tespio.github.io/moddle/models/qwen3-14b/) | 14B | Q5_K_M | 10.5 GB | 1.3 GB | Full | 35-55 |
| [Mistral Small 3.1 24B](https://tespio.github.io/moddle/models/mistral-small-3.1-24b/) | 24B | Q4_K_M | 14 GB | 1.3 GB | Tight | 28-40 |
| [gpt-oss-20b](https://tespio.github.io/moddle/models/gpt-oss-20b/) | 21B (3.6B active) | MXFP4 | 13 GB | 0.8 GB | Full | 70-110 |
| [Qwen3-30B-A3B](https://tespio.github.io/moddle/models/qwen3-30b-a3b/) | 30B (3B active) | Q4_K_M | 17.5 GB | 1.5 GB | Offload | 60-100 |
| [Qwen2.5-Coder-14B](https://tespio.github.io/moddle/models/qwen2.5-coder-14b/) | 14B | Q5_K_M | 10.5 GB | 3 GB | Full | 35-55 |
| [Qwen3-Coder-30B-A3B](https://tespio.github.io/moddle/models/qwen3-coder-30b-a3b/) | 30B (3B active) | Q4_K_M | 17.5 GB | 1.5 GB | Offload | 60-100 |
| [Qwen2.5-VL-7B](https://tespio.github.io/moddle/models/qwen2.5-vl-7b/) | 7B | Q8_0 | 8.7 GB | 0.9 GB | Full | 45-70 |
| [MiniCPM-V 2.6](https://tespio.github.io/moddle/models/minicpm-v-2.6/) | 8B | Q8_0 | 9 GB | 0.9 GB | Full | 45-70 |
| [SDXL / SDXL-Turbo](https://tespio.github.io/moddle/models/sdxl/) | 3.5B (UNet+text encoders) | fp16 | 7.5 GB | - | Full | - |
| [FLUX.1 [schnell]](https://tespio.github.io/moddle/models/flux-1-schnell/) | 12B | fp8 | 11.5 GB | - | Full | - |
| [Whisper large-v3-turbo](https://tespio.github.io/moddle/models/whisper-large-v3-turbo/) | 809M | int8 | 2 GB | - | Full | - |
| [Kokoro-82M](https://tespio.github.io/moddle/models/kokoro-82m/) | 82M | fp16 | 0.5 GB | - | Full | - |
| [BGE-M3](https://tespio.github.io/moddle/models/bge-m3/) | 568M | fp16 | 2 GB | - | Full | - |

## Categories

- **[Chat & General](models/chat.md)** - Everyday assistants, reasoning, and general-purpose conversation. _(7 models)_
- **[Coding](models/coding.md)** - Code generation, completion, refactoring, and local coding agents. _(5 models)_
- **[Vision & Multimodal](models/vision.md)** - Image understanding, OCR, screenshots, and document parsing. _(5 models)_
- **[Image & Video Generation](models/image-generation.md)** - Diffusion models for stills and short video via ComfyUI. _(6 models)_
- **[Voice (STT / TTS)](models/voice.md)** - Speech-to-text transcription and text-to-speech synthesis. _(5 models)_
- **[RAG & Embeddings](models/embeddings-rag.md)** - Embedding and reranker models for local document search. _(5 models)_

## Guides

- [Hardware & VRAM](docs/hardware.md) - the memory math that decides what fits.
- [Quantization](docs/quantization.md) - GGUF ladders, KV-cache quants, tradeoffs.
- [Tuning for 16 GB](docs/tuning.md) - context, offload, OOM troubleshooting.
- [Runtimes](docs/runtimes.md) - Ollama, LM Studio, llama.cpp, vLLM/SGLang, ComfyUI.

## How this works

Everything here is generated from [`data/models.json`](data/models.json):

```powershell
./scripts/build-docs.ps1            # regenerate this README + models/*.md
./scripts/ollama-pull.ps1 -Execute  # pull every Ollama-runnable model
```

Add or fix a model in the JSON, run the script, and the docs update.
See [CONTRIBUTING.md](CONTRIBUTING.md) to help.

## Disclaimer

VRAM and speed figures are estimates for this hardware class, not guarantees. Always check the model license before commercial use.

## License

Code and scripts: [MIT](LICENSE). Content and dataset: [CC BY 4.0](LICENSE-CONTENT).

