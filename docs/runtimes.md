# Runtimes

Five runtimes cover essentially everything on this hardware. Pick by what you
value: simplicity (Ollama), a GUI (LM Studio), control (llama.cpp), throughput
(vLLM/SGLang), or image generation (ComfyUI).

## Ollama — simplest for LLMs

Best for: fast setup, one-line model pulls, scripts, and background assistants.

```bash
# Install from https://ollama.com, then:
ollama run qwen3:14b
ollama run qwen3:30b-a3b
ollama pull bge-m3
```

- Pulls GGUF models and manages GPU offload automatically.
- Exposes an OpenAI-compatible API at `http://localhost:11434`.
- Great for RAG, editors, and local agents that speak the OpenAI API.

## LM Studio — GUI for exploring

Best for: browsing models, comparing quantizations, and non-terminal users.

- Search for a model name from this repo, pick a quant, download, chat.
- Lets you tune context, GPU offload, and KV cache with sliders.
- Ships a local server with an OpenAI-compatible API.

## llama.cpp — the control room

Best for: exact control over quant, context, KV cache, and layer offload.

```bash
# Build: https://github.com/ggml-org/llama.cpp
llama-cli -hf bartowski/Qwen_Qwen3-14B-GGUF:Q5_K_M -c 32768 -ngl 99 --flash-attn
```

- `llama-server` gives you an HTTP API with the same flags.
- `llama-mtmd-cli` is the path for vision models (Qwen-VL, Gemma, Llama Vision).
- Everything in `docs/tuning.md` applies here.

## vLLM / SGLang — throughput

Best for: serving multiple requests, batching, and evaluation.

```bash
pip install vllm
vllm serve Qwen/Qwen3-14B --max-model-len 16384 --gpu-memory-utilization 0.92
```

- Loads safetensors/HF checkpoints, not GGUF.
- Reserves VRAM up front based on `--max-model-len`; lower it to fit.
- Excellent when one model must serve several clients at once.

## ComfyUI — image and video

Best for: SDXL, FLUX, SD3.5, LTX-Video, and Wan.

- Install via the ComfyUI desktop app or the portable build.
- For FLUX on 16 GB, use **fp8** or **GGUF** checkpoints (ComfyUI-GGUF nodes).
- Video needs patience: 1.3B Wan and 2B LTX are the safe picks.

## Speech

- **Transcription:** `faster-whisper` (Python) or `whisper.cpp` (native).
- **TTS:** Kokoro (tiny, fast), XTTS-v2 / Chatterbox (voice cloning).
- All of these are small enough to run alongside a 7–8B LLM.

## Embeddings / RAG

- **Ollama** can serve embedders: `ollama pull bge-m3`.
- **sentence-transformers / FlagEmbedding** for embedding and reranking.
- A common local stack: `bge-m3` for retrieval + `bge-reranker-v2-m3` to
  rerank, with your LLM of choice generating the answer.

## Which should I pick?

| You want… | Use |
| --- | --- |
| Easiest start | Ollama |
| To click and explore | LM Studio |
| Full control / scripting | llama.cpp |
| Many concurrent users | vLLM / SGLang |
| Images and video | ComfyUI |
| Transcription or TTS | faster-whisper / whisper.cpp / Kokoro |
| Local RAG | Ollama + bge-m3 + a reranker |
