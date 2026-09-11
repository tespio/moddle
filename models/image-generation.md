# Image & Video Generation

Diffusion models for stills and short video via ComfyUI.

_Part of [moddle](../README.md). Machines: see the [hardware guide](../docs/hardware.md)._

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [SDXL / SDXL-Turbo](../models/image-generation.md) | 3.5B (UNet+text encoders) | fp16 | 7.5 GB | - | Full | - |
| [FLUX.1 [schnell]](../models/image-generation.md) | 12B | fp8 | 11.5 GB | - | Full | - |
| [FLUX.1 [dev]](../models/image-generation.md) | 12B | GGUF Q8 | 12.5 GB | - | Tight | - |
| [Stable Diffusion 3.5 Medium](../models/image-generation.md) | 2.5B | fp16 | 9 GB | - | Full | - |
| [Wan 2.1 T2V-1.3B](../models/image-generation.md) | 1.3B | fp16 | 8 GB | - | Full | - |
| [LTX-Video 2B](../models/image-generation.md) | 2B | fp16 | 8 GB | - | Full | - |

## Models

### SDXL / SDXL-Turbo

The workhorse 1024px image model with a massive ecosystem of LoRAs and ControlNets.

**Why it's here:** Fast and extremely flexible. Runs comfortably on 16 GB with room for high-res upscaling.

- **Params:** 3.5B (UNet+text encoders)
- **License:** openrail++
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 7.5 GB | Standard. Plenty of headroom. |
| fp8 | 4.5 GB | Even lighter. |

**Run it:**

_comfyui_

```
Load SDXL checkpoint + recommended workflows
```

_other_

```
A1111 / Forge / ComfyUI
```

---

### FLUX.1 [schnell]

Distilled 4-step FLUX variant with excellent prompt following and text rendering.

**Why it's here:** Near-FLUX quality in a few steps. Fits fully at fp8; the best fast image model here.

- **Params:** 12B
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/black-forest-labs/FLUX.1-schnell>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp8 | 11.5 GB | Recommended. |
| GGUF Q8 | 12.5 GB | ComfyUI GGUF nodes. |
| GGUF Q4 | 7 GB | Lighter, slight quality loss. |

**Run it:**

_comfyui_

```
FLUX.1-schnell fp8 checkpoint, 4 steps, euler
```

_other_

```
ComfyUI / diffusers
```

---

### FLUX.1 [dev]

The flagship open FLUX model with the best prompt adherence and realism.

**Why it's here:** Top-tier quality at Q8/tight. Use GGUF quants to fit and accept slower, bigger steps.

- **Params:** 12B
- **License:** flux-1-dev-non-commercial
- **Fit on 16 GB:** Tight
- **Source:** <https://huggingface.co/black-forest-labs/FLUX.1-dev>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp8 | 13.5 GB | Tight but works at 1024px. |
| GGUF Q8 | 12.5 GB | Recommended. |
| GGUF Q4 | 7 GB | Most headroom. |

**Run it:**

_comfyui_

```
FLUX.1-dev GGUF Q8 + t5xxl fp8 + clip_l
```

_other_

```
ComfyUI / diffusers
```

---

### Stable Diffusion 3.5 Medium

Balanced MMDiT model optimized for consumer hardware at 1024px.

**Why it's here:** Fast, high quality, and light. A great complement to SDXL when you want better text.

- **Params:** 2.5B
- **License:** stability-community
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/stabilityai/stable-diffusion-3.5-medium>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 9 GB | Recommended. |
| fp8 | 6 GB | Lighter. |

**Run it:**

_comfyui_

```
SD3.5 Medium checkpoint workflow
```

_other_

```
ComfyUI / diffusers
```

---

### Wan 2.1 T2V-1.3B

Lightweight text-to-video model that can run on consumer GPUs.

**Why it's here:** One of the few real video generators that fits 16 GB. Short clips at 480p.

- **Params:** 1.3B
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Wan-AI/Wan2.1-T2V-1.3B>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 8 GB | 480p, few-second clips. |

**Run it:**

_comfyui_

```
Wan 2.1 1.3B ComfyUI workflow
```

_other_

```
ComfyUI / diffusers
```

---

### LTX-Video 2B

Real-time-oriented video model that generates clips quickly.

**Why it's here:** Fast video on 16 GB with a lean footprint, good for experiments and img2vid.

- **Params:** 2B
- **License:** openrail
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/Lightricks/LTX-Video>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 8 GB | Recommended. |
| fp8 | 5 GB | Lighter. |

**Run it:**

_comfyui_

```
LTX-Video ComfyUI workflow
```

_other_

```
ComfyUI / diffusers
```

---

