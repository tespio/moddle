# RAG & Embeddings

Embedding and reranker models for local document search.

_Part of [moddle](../README.md). Machines: see the [hardware guide](../docs/hardware.md)._

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [BGE-M3](../models/embeddings-rag.md) | 568M | fp16 | 2 GB | - | Full | - |
| [Qwen3-Embedding-4B](../models/embeddings-rag.md) | 4B | fp16 | 8 GB | 1.5 GB | Full | - |
| [nomic-embed-text v1.5](../models/embeddings-rag.md) | 137M | fp16 | 0.5 GB | - | Full | - |
| [BGE Reranker v2-m3](../models/embeddings-rag.md) | 568M | fp16 | 2 GB | - | Full | - |
| [Qwen3-Reranker-4B](../models/embeddings-rag.md) | 4B | Q8_0 | 4.3 GB | 1.5 GB | Full | - |

## Models

### BGE-M3

Multilingual, multi-granularity embedder supporting dense, sparse, and ColBERT retrieval.

**Why it's here:** One model for dense + lexical + late-interaction retrieval. The RAG default.

- **Params:** 568M
- **Context:** 8,192 tokens
- **License:** mit
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/BAAI/bge-m3>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 2 GB | Recommended. |
| fp32 | 3 GB | CPU-friendly too. |

**Run it:**

_ollama_

```
ollama pull bge-m3
```

_other_

```
FlagEmbedding / sentence-transformers / LangChain
```

---

### Qwen3-Embedding-4B

High-ranking text embedder with instruction-following and 100+ languages.

**Why it's here:** Top retrieval accuracy for hard corpora, with a long 32K context.

- **Params:** 4B
- **Context:** 32,768 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Qwen/Qwen3-Embedding-4B>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 8 GB | Recommended. |
| Q8_0 | 4.3 GB | Frees VRAM for the LLM. |

**Run it:**

_ollama_

```
ollama pull qwen3-embedding:4b
```

_other_

```
sentence-transformers / vLLM
```

---

### nomic-embed-text v1.5

Compact 8192-context embedder with Matryoshka dimensions.

**Why it's here:** Tiny, fast, and good enough for most RAG. Ideal when VRAM is at a premium.

- **Params:** 137M
- **Context:** 8,192 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/nomic-ai/nomic-embed-text-v1.5>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 0.5 GB | Negligible. |

**Run it:**

_ollama_

```
ollama pull nomic-embed-text
```

_other_

```
sentence-transformers / LangChain / LlamaIndex
```

---

### BGE Reranker v2-m3

Multilingual cross-encoder reranker that sharply improves RAG precision.

**Why it's here:** Cheap to run and one of the biggest quality wins you can add to a local RAG stack.

- **Params:** 568M
- **Context:** 8,192 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/BAAI/bge-reranker-v2-m3>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 2 GB | Recommended. |

**Run it:**

_other_

```
FlagEmbedding / sentence-transformers CrossEncoder
```

---

### Qwen3-Reranker-4B

Instruction-aware reranker with strong multilingual and long-context precision.

**Why it's here:** Frontier reranking quality locally, and it shares the Qwen3 stack with your embedder.

- **Params:** 4B
- **Context:** 32,768 tokens
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Qwen/Qwen3-Reranker-4B>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 8 GB | Best quality. |
| Q8_0 | 4.3 GB | Recommended. Frees VRAM. |

**Run it:**

_other_

```
sentence-transformers / vLLM / FlagEmbedding
```

---

