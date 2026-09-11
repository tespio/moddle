# Vision & Multimodal

Image understanding, OCR, screenshots, and document parsing.

_Part of [moddle](../README.md). Machines: see the [hardware guide](../docs/hardware.md)._

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [Qwen2.5-VL-7B](../models/vision.md) | 7B | Q8_0 | 8.7 GB | 0.9 GB | Full | 45-70 |
| [Qwen2.5-VL-32B](../models/vision.md) | 32B | Q4_K_M | 19.0 GB | 4.0 GB | Offload | 12-22 |
| [Llama 3.2 11B Vision](../models/vision.md) | 11B | Q6_K | 9.5 GB | 1.25 GB | Full | 35-55 |
| [MiniCPM-V 2.6](../models/vision.md) | 8B | Q8_0 | 9.0 GB | 0.9 GB | Full | 45-70 |
| [Gemma 3 27B](../models/vision.md) | 27B | Q4_K_M | 16.0 GB | 3.9 GB | Tight | 18-30 |

## Models

### Qwen2.5-VL-7B

Compact vision-language model strong at documents, charts, and grounding.

**Why it's here:** Runs fully at Q8 with a long context. The default vision model for 16 GB.

- **Params:** 7B
- **Context:** 131,072 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct>
- **Speed (est.):** 45-70 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 5.0 GB | Light and fast. |
| Q6_K | 7.0 GB | Balanced. |
| Q8_0 | 8.7 GB | Recommended. |

**Run it:**

_ollama_

```
ollama run qwen2.5vl:7b
```

_lmstudio_

```
Search "Qwen2.5 VL 7B GGUF"
```

_llamacpp_

```
llama-mtmd-cli -hf ggml-org/Qwen2.5-VL-7B-Instruct-GGUF:Q8_0 --image photo.jpg
```

_vllm_

```
vllm serve Qwen/Qwen2.5-VL-7B-Instruct --max-model-len 32768
```

---

### Qwen2.5-VL-32B

Large vision-language model with top-tier document and chart reasoning.

**Why it's here:** The strongest vision model you can run with partial offload. Slow but capable.

- **Params:** 32B
- **Context:** 131,072 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Offload
- **Source:** <https://huggingface.co/Qwen/Qwen2.5-VL-32B-Instruct>
- **Speed (est.):** 12-22 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q3_K_M | 15.5 GB | Near-resident. |
| Q4_K_M | 19.0 GB | Recommended; moderate offload. |

**Run it:**

_ollama_

```
ollama run qwen2.5vl:32b
```

_lmstudio_

```
Search "Qwen2.5 VL 32B GGUF"
```

_llamacpp_

```
llama-mtmd-cli -hf ggml-org/Qwen2.5-VL-32B-Instruct-GGUF:Q4_K_M --image photo.jpg -ngl 40
```

_vllm_

```
vllm serve Qwen/Qwen2.5-VL-32B-Instruct --max-model-len 32768
```

---

### Llama 3.2 11B Vision

Meta's 11B multimodal model for image reasoning and captioning.

**Why it's here:** Fits fully at Q6 and pairs well with the Llama ecosystem and tooling.

- **Params:** 11B
- **Context:** 131,072 tokens
- **License:** llama3.2
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/meta-llama/Llama-3.2-11B-Vision-Instruct>
- **Speed (est.):** 35-55 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 6.8 GB | Light. |
| Q6_K | 9.5 GB | Recommended. |
| Q8_0 | 12.0 GB | Fits with a modest context. |

**Run it:**

_ollama_

```
ollama run llama3.2-vision:11b
```

_lmstudio_

```
Search "Llama 3.2 11B Vision GGUF"
```

_llamacpp_

```
llama-mtmd-cli -hf bartowski/Llama-3.2-11B-Vision-Instruct-GGUF:Q6_K --image photo.jpg
```

_vllm_

```
vllm serve meta-llama/Llama-3.2-11B-Vision-Instruct --max-model-len 32768
```

---

### MiniCPM-V 2.6

Compact vision model that excels at OCR and multi-image understanding.

**Why it's here:** Best-in-class OCR per gigabyte. Fits fully at Q8 and handles dense documents.

- **Params:** 8B
- **Context:** 32,768 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/openbmb/MiniCPM-V-2_6>
- **Speed (est.):** 45-70 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 5.5 GB | Very light. |
| Q6_K | 7.4 GB | Balanced. |
| Q8_0 | 9.0 GB | Recommended for OCR. |

**Run it:**

_ollama_

```
ollama run minicpm-v:8b
```

_lmstudio_

```
Search "MiniCPM-V 2.6 GGUF"
```

_llamacpp_

```
llama-mtmd-cli -hf openbmb/MiniCPM-V-2_6-gguf:Q8_0 --image doc.png
```

_vllm_

```
vllm serve openbmb/MiniCPM-V-2_6 --max-model-len 32768
```

---

### Gemma 3 27B

Google's 27B multimodal model with a 128K context and strong reasoning.

**Why it's here:** A capable multimodal generalist at Q4. Dense KV cache means context is a real constraint.

- **Params:** 27B
- **Context:** 131,072 tokens
- **License:** gemma
- **Fit on 16 GB:** Tight
- **Source:** <https://huggingface.co/google/gemma-3-27b-it>
- **Speed (est.):** 18-30 tok/s on a 4070 Ti Super

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q3_K_M | 13.5 GB | Fully resident option. |
| Q4_K_M | 16.0 GB | Very tight; short context. |

**Run it:**

_ollama_

```
ollama run gemma3:27b
```

_lmstudio_

```
Search "Gemma 3 27B GGUF"
```

_llamacpp_

```
llama-mtmd-cli -hf bartowski/google_gemma-3-27b-it-GGUF:Q3_K_M -c 8192 -ngl 99
```

_vllm_

```
vllm serve google/gemma-3-27b-it --max-model-len 16384
```

---

