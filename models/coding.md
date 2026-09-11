# Coding

Code generation, completion, refactoring, and local coding agents.

_Part of [moddle](../README.md). Machines: see the [hardware guide](../docs/hardware.md)._

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [Devstral Small 2 24B](../models/coding.md) | 24B | Q4_K_M | 15 GB | 1.3 GB | Tight | 28-42 |
| [Qwen2.5-Coder-14B](../models/coding.md) | 14B | Q5_K_M | 10.5 GB | 3 GB | Full | 35-55 |
| [Qwen3-Coder-30B-A3B](../models/coding.md) | 30B (3B active) | Q4_K_M | 17.5 GB | 1.5 GB | Offload | 60-100 |
| [DeepSeek-Coder-V2-Lite](../models/coding.md) | 16B (2.4B active) | Q5_K_M | 11.5 GB | 0.8 GB | Full | 55-85 |
| [Codestral 22B](../models/coding.md) | 22B | Q4_K_M | 13 GB | 2.5 GB | Full | 28-42 |
| [Qwen2.5-Coder-7B](../models/coding.md) | 7B | Q8_0 | 7.6 GB | 0.9 GB | Full | 60-90 |

## Models

### Devstral Small 2 24B

A coding-agent model built to explore codebases, edit multiple files, and use tools.

**Why it's here:** The best local software-engineering agent in this class. Tight at Q4, but worth it for agentic coding.

- **Params:** 24B
- **Context:** 393,216 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Tight
- **Source:** <https://ollama.com/library/devstral-small-2>
- **Speed (est.):** 28-42 tok/s on a 16 GB card

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 15 GB | Recommended; keep context modest. |
| Q4_K_S | 14 GB | A little more headroom. |

**Run it:**

_ollama_

```
ollama run devstral-small-2:24b
```

_lmstudio_

```
Search "Devstral Small 2 24B GGUF"
```

_llamacpp_

```
llama-cli -hf mistralai/Devstral-Small-2-24B-GGUF:Q4_K_M -c 32768 -ngl 99
```

_vllm_

```
vllm serve mistralai/Devstral-Small-2-24B-Instruct --max-model-len 32768
```

---

### Qwen2.5-Coder-14B

Dedicated coding model with strong fill-in-the-middle and repo-level ability.

**Why it's here:** The best fully-resident coding model on 16 GB. Ideal for editor copilots and agents.

- **Params:** 14B
- **Context:** 32,768 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Qwen/Qwen2.5-Coder-14B-Instruct>
- **Speed (est.):** 35-55 tok/s on a 16 GB card

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 8.5 GB | Fast completion. |
| Q5_K_M | 10.5 GB | Recommended. |
| Q6_K | 12.2 GB | Keep context <= 16K. |

**Run it:**

_ollama_

```
ollama run qwen2.5-coder:14b
```

_lmstudio_

```
Search "Qwen2.5 Coder 14B GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/Qwen2.5-Coder-14B-Instruct-GGUF:Q5_K_M -c 32768 -ngl 99
```

_vllm_

```
vllm serve Qwen/Qwen2.5-Coder-14B-Instruct --max-model-len 32768
```

---

### Qwen3-Coder-30B-A3B

MoE coding model with agentic tool use and a huge native context.

**Why it's here:** Near-frontier coding quality at 3B active speed. The best coding agent you can self-host here.

- **Params:** 30B (3B active)
- **Context:** 262,144 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Offload
- **Source:** <https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct>
- **Speed (est.):** 60-100 tok/s on a 16 GB card

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 17.5 GB | Slight offload; very fast. |
| Q3_K_M | 14.5 GB | Fully resident, small quality cost. |
| Q5_K_M | 21 GB | Higher quality, more offload. |

**Run it:**

_ollama_

```
ollama run qwen3-coder:30b
```

_lmstudio_

```
Search "Qwen3 Coder 30B A3B GGUF"
```

_llamacpp_

```
llama-cli -hf unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF:Q4_K_M -c 65536 -ngl 40
```

_vllm_

```
vllm serve Qwen/Qwen3-Coder-30B-A3B-Instruct --max-model-len 65536
```

---

### DeepSeek-Coder-V2-Lite

MoE coding model that fits fully and supports 338 programming languages.

**Why it's here:** Excellent coding quality while staying entirely in VRAM at Q5. Great long-context repo work.

- **Params:** 16B (2.4B active)
- **Context:** 131,072 tokens
- **License:** deepseek
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct>
- **Speed (est.):** 55-85 tok/s on a 16 GB card

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 9.6 GB | Recommended for speed. |
| Q5_K_M | 11.5 GB | Fully resident, more context. |
| Q8_0 | 17 GB | Offload required. |

**Run it:**

_ollama_

```
ollama run deepseek-coder-v2:16b
```

_lmstudio_

```
Search "DeepSeek Coder V2 Lite GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/DeepSeek-Coder-V2-Lite-Instruct-GGUF:Q5_K_M -c 32768 -ngl 99
```

_vllm_

```
vllm serve deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct --max-model-len 32768
```

---

### Codestral 22B

Mistral's code specialist with strong completion and 80+ language coverage.

**Why it's here:** Fits fully at Q4 and produces clean, idiomatic code across many languages.

- **Params:** 22B
- **Context:** 32,768 tokens
- **License:** mnc-research
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/mistralai/Codestral-22B-v0.1>
- **Speed (est.):** 28-42 tok/s on a 16 GB card

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 13 GB | Recommended. Fits with context. |
| Q4_K_S | 12.2 GB | A bit more room. |
| Q5_K_M | 15.3 GB | Tight; short contexts only. |

**Run it:**

_ollama_

```
ollama run codestral:22b
```

_lmstudio_

```
Search "Codestral 22B GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/Codestral-22B-v0.1-GGUF:Q4_K_M -c 16384 -ngl 99
```

_vllm_

```
vllm serve mistralai/Codestral-22B-v0.1 --max-model-len 16384
```

---

### Qwen2.5-Coder-7B

Lightweight coding model that leaves VRAM free for long contexts and other tools.

**Why it's here:** Perfect for always-on editor autocomplete or when you want to run a second model alongside.

- **Params:** 7B
- **Context:** 32,768 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct>
- **Speed (est.):** 60-90 tok/s on a 16 GB card

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| Q4_K_M | 4.4 GB | Trivial to run. |
| Q6_K | 6.2 GB | Great balance. |
| Q8_0 | 7.6 GB | Recommended. Tons of headroom. |

**Run it:**

_ollama_

```
ollama run qwen2.5-coder:7b
```

_lmstudio_

```
Search "Qwen2.5 Coder 7B GGUF"
```

_llamacpp_

```
llama-cli -hf bartowski/Qwen2.5-Coder-7B-Instruct-GGUF:Q8_0 -c 32768 -ngl 99
```

_vllm_

```
vllm serve Qwen/Qwen2.5-Coder-7B-Instruct --max-model-len 32768
```

---

