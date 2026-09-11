# Chat & General

Everyday assistants, reasoning, and general-purpose conversation.

_Part of [moddle](../README.md). Machines: see the [hardware guide](../docs/hardware.md)._

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [Qwen3-14B](../models/chat.md) | 14B | Q5_K_M | 10.5 GB | 1.3 GB | Full | 35-55 |
| [Mistral Small 3.1 24B](../models/chat.md) | 24B | Q4_K_M | 14 GB | 1.3 GB | Tight | 28-40 |
| [Gemma 3 12B](../models/chat.md) | 12B | Q6_K | 10.2 GB | 3 GB | Full | 40-60 |
| [gpt-oss-20b](../models/chat.md) | 21B (3.6B active) | MXFP4 | 13 GB | 0.8 GB | Full | 70-110 |
| [Qwen3-30B-A3B](../models/chat.md) | 30B (3B active) | Q4_K_M | 17.5 GB | 1.5 GB | Offload | 60-100 |
| [DeepSeek-R1-Distill-Qwen-14B](../models/chat.md) | 14B | Q5_K_M | 10.5 GB | 1.3 GB | Full | 35-55 |
| [Llama 3.1 8B](../models/chat.md) | 8B | Q8_0 | 8.5 GB | 2 GB | Full | 60-90 |

## Models

### Qwen3-14B

Dense 14B generalist with switchable thinking mode and strong multilingual and reasoning performance.

**Why it's here:** The best all-round dense model that fits fully at Q5/Q6 on 16 GB. Punches far above its size.

- **Params:** 14B
- **Context:** 32,768 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Qwen/Qwen3-14B>
- **Speed (est.):** 35-55 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 8.5 GB | Fastest, small quality drop. |
| Q5_K_M | 10.5 GB | Sweet spot. Fits with 32K context. |
| Q6_K | 12.2 GB | Near-lossless; still fully resident. |
| Q8_0 | 15 GB | Tight; use short contexts or light offload. |

**Run it:**

_ollama_

```
ollama run qwen3:14b
```

_lmstudio_

```
Search "Qwen3 14B GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/Qwen_Qwen3-14B-GGUF:Q5_K_M -c 32768 -ngl 99
```

_vllm_

```
vllm serve Qwen/Qwen3-14B --max-model-len 32768
```

---

### Mistral Small 3.1 24B

24B instruction model with 128K context, tool calling, and vision support.

**Why it's here:** The largest dense model that still fits fully at Q4_K_M with room for a real context window.

- **Params:** 24B
- **Context:** 131,072 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Tight
- **Source:** <https://huggingface.co/mistralai/Mistral-Small-3.1-24B-Instruct-2503>
- **Speed (est.):** 28-40 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 14 GB | Fits fully with ~8-16K context. |
| Q4_K_S | 13.2 GB | More context headroom. |
| Q5_K_M | 16.5 GB | Needs light offload. |

**Run it:**

_ollama_

```
ollama run mistral-small3.1:24b
```

_lmstudio_

```
Search "Mistral Small 3.1 24B GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/mistralai_Mistral-Small-3.1-24B-Instruct-2503-GGUF:Q4_K_M -c 16384 -ngl 99
```

_vllm_

```
vllm serve mistralai/Mistral-Small-3.1-24B-Instruct-2503 --max-model-len 32768
```

---

### Gemma 3 12B

Google's 12B open model with vision and a 128K context window, tuned for helpful assistant behavior.

**Why it's here:** Great quality-per-gigabyte and multimodal out of the box. Comfortable at Q6_K.

- **Params:** 12B
- **Context:** 131,072 tokens
- **License:** gemma
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/google/gemma-3-12b-it>
- **Speed (est.):** 40-60 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 7.3 GB | Very light, lots of context room. |
| Q6_K | 10.2 GB | Recommended. |
| Q8_0 | 12.8 GB | Heavy KV; keep context modest. |

**Run it:**

_ollama_

```
ollama run gemma3:12b
```

_lmstudio_

```
Search "Gemma 3 12B GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/google_gemma-3-12b-it-GGUF:Q6_K -c 16384 -ngl 99
```

_vllm_

```
vllm serve google/gemma-3-12b-it --max-model-len 32768
```

---

### gpt-oss-20b

OpenAI's open-weight MoE designed to run in ~16 GB with MXFP4 and a 128K context.

**Why it's here:** Purpose-built for this class of hardware. MoE keeps it extremely fast while fitting fully.

- **Params:** 21B (3.6B active)
- **Context:** 131,072 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/openai/gpt-oss-20b>
- **Speed (est.):** 70-110 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| MXFP4 | 13 GB | Native format. Fits with long context. |
| Q8_0 | 22 GB | Offload required. |

**Run it:**

_ollama_

```
ollama run gpt-oss:20b
```

_lmstudio_

```
Search "gpt-oss-20b"
```

_llamacpp_

```
llama-cli -hf ggml-org/gpt-oss-20b-GGUF:MXFP4 -c 32768 -ngl 99
```

_vllm_

```
vllm serve openai/gpt-oss-20b --max-model-len 32768
```

---

### Qwen3-30B-A3B

MoE with only 3B active parameters, giving 30B-class quality at small-model speed.

**Why it's here:** The best quality-per-token on this list. Runs fast even when a few layers spill to system RAM.

- **Params:** 30B (3B active)
- **Context:** 32,768 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Offload
- **Source:** <https://huggingface.co/Qwen/Qwen3-30B-A3B>
- **Speed (est.):** 60-100 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 17.5 GB | Slight offload; still very fast. |
| Q3_K_M | 14.5 GB | Fits fully; small quality cost. |
| Q5_K_M | 21 GB | More offload, higher quality. |

**Run it:**

_ollama_

```
ollama run qwen3:30b-a3b
```

_lmstudio_

```
Search "Qwen3 30B A3B GGUF"
```

_llamacpp_

```
llama-cli -hf unsloth/Qwen3-30B-A3B-GGUF:Q4_K_M -c 32768 -ngl 40
```

_vllm_

```
vllm serve Qwen/Qwen3-30B-A3B --max-model-len 32768
```

---

### DeepSeek-R1-Distill-Qwen-14B

Distilled reasoning model that thinks step-by-step before answering.

**Why it's here:** Strong chain-of-thought reasoning that fits fully at Q5. Great for math and logic.

- **Params:** 14B
- **Context:** 65,536 tokens
- **License:** mit
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-14B>
- **Speed (est.):** 35-55 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 8.5 GB | Fast reasoning. |
| Q5_K_M | 10.5 GB | Recommended. |
| Q6_K | 12.2 GB | Max quality while resident. |

**Run it:**

_ollama_

```
ollama run deepseek-r1:14b
```

_lmstudio_

```
Search "DeepSeek R1 Distill Qwen 14B GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/DeepSeek-R1-Distill-Qwen-14B-GGUF:Q5_K_M -c 32768 -ngl 99
```

_vllm_

```
vllm serve deepseek-ai/DeepSeek-R1-Distill-Qwen-14B --max-model-len 32768
```

---

### Llama 3.1 8B

The dependable 8B baseline with a 128K context and a huge ecosystem.

**Why it's here:** Maximum headroom: run it at Q8 with a long context and still have VRAM to spare.

- **Params:** 8B
- **Context:** 131,072 tokens
- **License:** llama3.1
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct>
- **Speed (est.):** 60-90 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 4.9 GB | Ultra light and fast. |
| Q8_0 | 8.5 GB | Recommended. Near-lossless. |
| FP16 | 16 GB | Exactly at the limit; not worth it. |

**Run it:**

_ollama_

```
ollama run llama3.1:8b
```

_lmstudio_

```
Search "Llama 3.1 8B Instruct GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/Meta-Llama-3.1-8B-Instruct-GGUF:Q8_0 -c 32768 -ngl 99
```

_vllm_

```
vllm serve meta-llama/Llama-3.1-8B-Instruct --max-model-len 32768
```

---

