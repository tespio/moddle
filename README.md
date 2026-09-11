# moddle

**Because your GPU has 16 GB, not infinite.**

A curated guide to the best local AI models that actually fit **16 GB of VRAM** (RTX 4060 Ti / 4070 Ti Super / 4080 / 5070 Ti / 5080, Arc A770, RX 7800 XT, and friends), with 32 GB of RAM and an NVMe SSD - honest VRAM math, quants, and copy-ready commands.

[![License: MIT](https://img.shields.io/badge/code-MIT-blue.svg)](LICENSE) [![Content: CC BY 4.0](https://img.shields.io/badge/content-CC--BY--4.0-lightgrey.svg)](LICENSE-CONTENT)

**[Browse the website ->](https://tespio.github.io/moddle)**

> **HUGE THANKS to [Mia's AI Lab](https://github.com/MiaAI-Lab/Qwen3.8-27B-16gb-NVIDIA-GPUs-one-click-install) ([@MiaAI_lab](https://x.com/MiaAI_lab))** for building the Simplex one-click kit and the EXL3 2.0 bpw quant that make **Qwen3.8-27B run fully on a single 16 GB NVIDIA card** - the standout local-AI achievement this whole repo is built around. Go star their project.

## Target hardware

Anything with **16 GB of VRAM**, ideally ~32 GB of RAM and an SSD. Cards this covers:

| Card | Vendor | Bandwidth |
| --- | --- | --- |
| RTX 4060 Ti 16 GB | NVIDIA | 288 GB/s |
| RTX 5060 Ti 16 GB | NVIDIA | 448 GB/s |
| RTX 4070 Ti Super | NVIDIA | 672 GB/s |
| RTX 4080 / 4080 Super | NVIDIA | 717 GB/s |
| RTX 5070 Ti | NVIDIA | 896 GB/s |
| RTX 5080 | NVIDIA | 960 GB/s |
| Arc A770 16 GB | Intel | 560 GB/s |
| Radeon RX 7800 XT 16 GB | AMD | 624 GB/s |
| Radeon RX 9070 XT 16 GB | AMD | 645 GB/s |

- Budget about 14.5 GB usable after OS and display overhead.
- Bandwidth sets tokens per second. Reference: 672 GB/s; faster cards scale up, slower cards down.
- Assumes 32 GB DDR5 and NVMe SSD for offload and fast loads.

## Start here

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [Qwen3.8-27B](https://tespio.github.io/moddle/models/qwen3.8-27b/) | 27B | EXL3 2.5 bpw | 11 GB | 0.4 GB | Tight | 25-45 |
| [Qwen3.5-9B](https://tespio.github.io/moddle/models/qwen3.5-9b/) | 9B | Q6_K | 7.4 GB | 1 GB | Full | 55-85 |
| [Gemma 4 12B](https://tespio.github.io/moddle/models/gemma-4-12b/) | 12B | Q6_K | 10 GB | 2.8 GB | Full | 40-60 |
| [GLM-4.7-Flash](https://tespio.github.io/moddle/models/glm-4.7-flash/) | 30B (3B active) | Q4_K_M | 19 GB | 1.5 GB | Offload | 55-90 |
| [Devstral Small 2 24B](https://tespio.github.io/moddle/models/devstral-small-2-24b/) | 24B | Q4_K_M | 15 GB | 1.3 GB | Tight | 28-42 |
| [Qwen3-VL-8B](https://tespio.github.io/moddle/models/qwen3-vl-8b/) | 8B | Q8_0 | 9.5 GB | 1 GB | Full | 45-70 |
| [Qwen3-14B](https://tespio.github.io/moddle/models/qwen3-14b/) | 14B | Q5_K_M | 10.5 GB | 1.3 GB | Full | 35-55 |
| [gpt-oss-20b](https://tespio.github.io/moddle/models/gpt-oss-20b/) | 21B (3.6B active) | MXFP4 | 13 GB | 0.8 GB | Full | 70-110 |
| [Qwen3-30B-A3B](https://tespio.github.io/moddle/models/qwen3-30b-a3b/) | 30B (3B active) | Q4_K_M | 17.5 GB | 1.5 GB | Offload | 60-100 |
| [Qwen3-Coder-30B-A3B](https://tespio.github.io/moddle/models/qwen3-coder-30b-a3b/) | 30B (3B active) | Q4_K_M | 17.5 GB | 1.5 GB | Offload | 60-100 |
| [FLUX.1 [schnell]](https://tespio.github.io/moddle/models/flux-1-schnell/) | 12B | fp8 | 11.5 GB | - | Full | - |
| [Whisper large-v3-turbo](https://tespio.github.io/moddle/models/whisper-large-v3-turbo/) | 809M | int8 | 2 GB | - | Full | - |
| [BGE-M3](https://tespio.github.io/moddle/models/bge-m3/) | 568M | fp16 | 2 GB | - | Full | - |

## Categories

- **[Chat & General](models/chat.md)** - Everyday assistants, reasoning, and general-purpose conversation. _(18 models)_
- **[Coding](models/coding.md)** - Code generation, completion, refactoring, and local coding agents. _(6 models)_
- **[Vision & Multimodal](models/vision.md)** - Image understanding, OCR, screenshots, and document parsing. _(6 models)_
- **[Image & Video Generation](models/image-generation.md)** - Diffusion models for stills and short video via ComfyUI. _(6 models)_
- **[Voice (STT / TTS)](models/voice.md)** - Speech-to-text transcription and text-to-speech synthesis. _(5 models)_
- **[RAG & Embeddings](models/embeddings-rag.md)** - Embedding and reranker models for local document search. _(5 models)_

## Guides

- [Hardware & VRAM](docs/hardware.md) - the memory math that decides what fits.
- [Quantization](docs/quantization.md) - GGUF ladders, KV-cache quants, tradeoffs.
- [EXL3 & ExLlamaV3](docs/exl3.md) - best-in-class low-bit quants and one-click kits.
- [Offloading](docs/offloading.md) - run bigger models via CPU/RAM and MoE expert offload.
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

## Credits

This project would not exist without the people who actually build and quantize the models. In particular:

- **Mia's AI Lab (MiaAI-Lab)** (@MiaAI_lab) - Qwen3.8-27B on 16 GB - EXL3 quants + one-click installer. HUGE thanks. Mia's AI Lab built the Simplex serving kit and the 2.0 bpw EXL3 quant that make Qwen3.8-27B run fully on a single 16 GB NVIDIA card, with the 16 GB profile table and quality measurements this repo relies on.
- **turboderp** (@turboderp) - EXL3 quantization format and the ExLlamaV3 engine. Author of ExLlamaV3 and the EXL3 quants (2.5 bpw and up) used here.
- **model authors** - The open-weight models themselves. Qwen, Google DeepMind, Mistral AI, OpenAI, Meta, DeepSeek, Zhipu AI, Liquid AI, Stability AI, Black Forest Labs, BAAI, Nomic, OpenBMB and the rest.

**Mia's AI Lab:** <https://github.com/MiaAI-Lab/Qwen3.8-27B-16gb-NVIDIA-GPUs-one-click-install>

## Disclaimer

VRAM and speed figures are estimates for this hardware class, not guarantees. Always check the model license before commercial use.

## License

Code and scripts: [MIT](LICENSE). Content and dataset: [CC BY 4.0](LICENSE-CONTENT).

