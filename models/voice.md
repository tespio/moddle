# Voice (STT / TTS)

Speech-to-text transcription and text-to-speech synthesis.

_Part of [moddle](../README.md). Machines: see the [hardware guide](../docs/hardware.md)._

| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |
| --- | --- | --- | --- | --- | --- | --- |
| [Whisper large-v3-turbo](../models/voice.md) | 809M | int8 | 2.0 GB | - | Full | - |
| [Whisper large-v3](../models/voice.md) | 1.55B | int8 | 3.0 GB | - | Full | - |
| [Kokoro-82M](../models/voice.md) | 82M | fp16 | 0.5 GB | - | Full | - |
| [XTTS-v2](../models/voice.md) | 467M | fp16 | 2.5 GB | - | Full | - |
| [Chatterbox](../models/voice.md) | 500M | fp16 | 2.5 GB | - | Full | - |

## Models

### Whisper large-v3-turbo

Distilled Whisper with near-large accuracy at 8x the speed.

**Why it's here:** The best speed/accuracy tradeoff for local transcription. Tiny VRAM footprint.

- **Params:** 809M
- **License:** mit
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/openai/whisper-large-v3-turbo>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| int8 | 2.0 GB | Recommended. |
| fp16 | 3.0 GB | Slightly better accuracy. |

**Run it:**

_other_

```
faster-whisper / whisper.cpp / WhisperX
```

_llamacpp_

```
whisper-cli -m ggml-large-v3-turbo.bin -f audio.wav
```

---

### Whisper large-v3

The reference open speech-to-text model with strong multilingual accuracy.

**Why it's here:** When accuracy matters most. Runs via faster-whisper well within 16 GB.

- **Params:** 1.55B
- **License:** mit
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/openai/whisper-large-v3>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| int8 | 3.0 GB | Recommended. |
| fp16 | 5.0 GB | Higher accuracy. |

**Run it:**

_other_

```
faster-whisper / whisper.cpp / WhisperX
```

_llamacpp_

```
whisper-cli -m ggml-large-v3.bin -f audio.wav
```

---

### Kokoro-82M

Tiny, high-quality text-to-speech with multiple voices and fast synthesis.

**Why it's here:** Best-in-class TTS per byte. Leaves almost all your VRAM free for other models.

- **Params:** 82M
- **License:** apache-2.0
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/hexgrad/Kokoro-82M>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 0.5 GB | Negligible footprint. |

**Run it:**

_other_

```
kokoro-onnx / kokoro pipeline
```

_comfyui_

```
ComfyUI Kokoro TTS nodes
```

---

### XTTS-v2

Multilingual TTS with voice cloning from a short reference clip.

**Why it's here:** Great voice cloning and 17 languages, and it fits easily in VRAM.

- **Params:** 467M
- **License:** coqui-public
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/coqui/XTTS-v2>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 2.5 GB | Recommended. |

**Run it:**

_other_

```
Coqui TTS / AllTalk
```

_comfyui_

```
ComfyUI TTS nodes
```

---

### Chatterbox

Expressive open TTS with emotion control and zero-shot voice cloning.

**Why it's here:** Lifelike, emotive speech that fits comfortably and is easy to run locally.

- **Params:** 500M
- **License:** mit
- **Fit on 16 GB:** Full
- **Source:** <https://huggingface.co/ResembleAI/chatterbox>

**Quants:**

| Quant | Weights | Notes |
| --- | --- | --- |
| fp16 | 2.5 GB | Recommended. |

**Run it:**

_other_

```
chatterbox-tts Python package
```

_comfyui_

```
ComfyUI Chatterbox nodes
```

---

