# Contributing to moddle

Thanks for helping the 16 GB VRAM community. This repo is data-driven: almost
everything you see (the README tables, the category pages, the website) is
generated from a single file:

```
data/models.json
```

Add or fix a model there, and the docs follow.

## Ways to contribute

- **Add a model** that runs well in ~16 GB VRAM (or clearly documents offload).
- **Correct a VRAM / quant / context number** with a source.
- **Add runtime commands** (Ollama, LM Studio, llama.cpp, vLLM/SGLang, ComfyUI).
- **Improve the docs** in `docs/`.
- **Improve the website** in `web/`.

## Adding a model

1. Fork the repo and create a branch: `git checkout -b add-model-<id>`.
2. Add an entry to the `models` array in `data/models.json`.
3. Run the generators:

   ```powershell
   ./scripts/build-docs.ps1
   ```

   This regenerates `README.md` and `models/*.md`. Commit the result.
4. Open a pull request using the **New model** issue template.

### Required fields

| Field | Notes |
| --- | --- |
| `id` | kebab-case, unique, e.g. `qwen3-14b` |
| `name` | Display name |
| `category` | One of the ids in `categories` |
| `params` | Human string, e.g. `14B`, `30B (3B active)` |
| `paramsB` | Total parameters in billions |
| `context` | Max context in tokens |
| `license` | SPDX id, e.g. `apache-2.0` |
| `source` | Hugging Face or project URL |
| `summary` | One sentence |
| `why` | Why it belongs on this list |
| `fit` | `full`, `tight`, or `offload` |
| `recommended` | `{ quant, vram, kv8k }` |
| `quants` | Array of `{ quant, vram, note }` |
| `runtimes` | Object of copy-ready commands |
| `tokps` | Estimated tokens/sec tier for a 16 GB card |

### Optional fields

- `kit` — a one-click installer for this model, as
  `{ "name", "url", "note" }`. Shown as a call-to-action on the model page.
- Per-quant `kvPerTokenMB` and `context` — override the model-level values when a
  quant (e.g. an EXL3 int4-KV build) has a very different memory profile.

### Accuracy policy

- VRAM numbers are **weights only** unless noted. State the quant.
- Mark estimates as estimates. Do not present marketing numbers as measured.
- If a model needs system-RAM offload on 16 GB, set `fit: "offload"` and say so.
- Prefer a source link (model card, benchmark) in the PR description.

## Generated files — do not edit by hand

`README.md` and everything in `models/` are generated from `data/models.json`.
Edit the JSON, then run `./scripts/build-docs.ps1`.

The website copies `data/models.json` and `docs/*.md` into `web/src/` at build
time. Do not edit the copies under `web/src/data/` or `web/src/content/`.

## Local development

```powershell
# Regenerate repo markdown
./scripts/build-docs.ps1

# Run the website locally
cd web
npm install
npm run dev
```

Requires Node 18+ for the site. The PowerShell scripts run on Windows
PowerShell 5.1+ and PowerShell 7+.

## Testing everything locally

Before opening a PR, run the full verification pass:

```powershell
./scripts/verify.ps1
```

This regenerates the docs, builds the site, asserts the expected pages and
content exist, boots `astro preview`, and checks the key routes over HTTP. It
exits non-zero on any failure. Add `-SkipPreview` to skip the HTTP checks.

CI runs the same build plus a check that the generated docs match
`data/models.json`.

## Code of conduct

Be kind, be accurate, cite your sources. We're all here to make local AI better.
