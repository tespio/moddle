#Requires -Version 5.1
<#
.SYNOPSIS
    Generates README.md and models/*.md from data/models.json.

.DESCRIPTION
    data/models.json is the single source of truth for this repository. This
    script renders the browsable GitHub documentation from it. Run it after
    editing the dataset.

.EXAMPLE
    ./scripts/build-docs.ps1
#>
[CmdletBinding()]
param(
    [string]$DataPath,
    [string]$OutDir,
    [string]$RepoUrl = 'https://github.com/tespio/moddle',
    [string]$SiteUrl = 'https://tespio.github.io/moddle'
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
if (-not $DataPath) { $DataPath = Join-Path $root 'data/models.json' }
if (-not $OutDir) { $OutDir = $root }

function Write-Text {
    param([string]$Path, [string]$Text)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $Text = $Text -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false)))
}

function Get-FitLabel {
    param([string]$Fit)
    switch ($Fit) {
        'full'    { return 'Full' }
        'tight'   { return 'Tight' }
        'offload' { return 'Offload' }
        default   { return $Fit }
    }
}

function Format-Number {
    param($Value)
    if ($null -eq $Value) { return '-' }
    return ('{0:n0}' -f [double]$Value)
}

function New-ModelTable {
    param($Models, [string]$LinkMode = 'category')
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('| Model | Params | Rec. quant | Weights | KV @ 8K | Fit | tok/s (est.) |')
    [void]$sb.AppendLine('| --- | --- | --- | --- | --- | --- | --- |')
    foreach ($m in $Models) {
        $kv = if ($null -ne $m.recommended.kv8k -and $m.recommended.kv8k -gt 0) { "$($m.recommended.kv8k) GB" } else { '-' }
        $tok = if ($m.tokps -and $m.tokps -ne 'n/a') { $m.tokps } else { '-' }
        if ($LinkMode -eq 'site') {
            $name = "[$($m.name)]($SiteUrl/models/$($m.id)/)"
        } else {
            $name = "[$($m.name)](../models/$($m.category).md)"
        }
        [void]$sb.AppendLine("| $name | $($m.params) | $($m.recommended.quant) | $($m.recommended.vram) GB | $kv | $(Get-FitLabel $m.fit) | $tok |")
    }
    return $sb.ToString()
}

function New-ModelDetails {
    param($m)
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("### $($m.name)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine($m.summary)
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("**Why it's here:** $($m.why)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("- **Params:** $($m.params)")
    if ([int]$m.context -gt 0) {
        [void]$sb.AppendLine("- **Context:** $(Format-Number $m.context) tokens")
    }
    [void]$sb.AppendLine("- **License:** $($m.license)")
    [void]$sb.AppendLine("- **Fit on 16 GB:** $(Get-FitLabel $m.fit)")
    [void]$sb.AppendLine("- **Source:** <$($m.source)>")
    if ($m.tokps -and $m.tokps -ne 'n/a') {
        [void]$sb.AppendLine("- **Speed (est.):** $($m.tokps) tok/s on a 4070 Ti Super")
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('**Quants:**')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('| Quant | Weights | Notes |')
    [void]$sb.AppendLine('| --- | --- | --- |')
    foreach ($q in $m.quants) {
        [void]$sb.AppendLine("| $($q.quant) | $($q.vram) GB | $($q.note) |")
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('**Run it:**')
    [void]$sb.AppendLine()
    foreach ($p in $m.runtimes.PSObject.Properties) {
        [void]$sb.AppendLine("_$($p.Name)_")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine('```')
        [void]$sb.AppendLine([string]$p.Value)
        [void]$sb.AppendLine('```')
        [void]$sb.AppendLine()
    }
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine()
    return $sb.ToString()
}

# --- Load -------------------------------------------------------------------
Write-Host "Reading $DataPath" -ForegroundColor Cyan
$json = [System.IO.File]::ReadAllText($DataPath, [System.Text.Encoding]::UTF8)
$data = $json | ConvertFrom-Json

# --- Category pages ---------------------------------------------------------
$modelsDir = Join-Path $OutDir 'models'
foreach ($cat in $data.categories) {
    $catModels = @($data.models | Where-Object { $_.category -eq $cat.id })
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# $($cat.name)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine($cat.blurb)
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("_Part of [moddle](../README.md). Machines: see the [hardware guide](../docs/hardware.md)._")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine((New-ModelTable -Models $catModels).TrimEnd())
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('## Models')
    [void]$sb.AppendLine()
    foreach ($m in $catModels) {
        [void]$sb.Append((New-ModelDetails -m $m))
    }
    $out = Join-Path $modelsDir "$($cat.id).md"
    Write-Text -Path $out -Text $sb.ToString()
    Write-Host "  wrote models/$($cat.id).md ($($catModels.Count) models)" -ForegroundColor DarkGray
}

# --- README -----------------------------------------------------------------
$topPickIds = @(
    'qwen3-14b',
    'mistral-small-3.1-24b',
    'gpt-oss-20b',
    'qwen3-30b-a3b',
    'qwen2.5-coder-14b',
    'qwen3-coder-30b-a3b',
    'qwen2.5-vl-7b',
    'minicpm-v-2.6',
    'flux-1-schnell',
    'sdxl',
    'whisper-large-v3-turbo',
    'kokoro-82m',
    'bge-m3'
)
$topPicks = @($data.models | Where-Object { $topPickIds -contains $_.id })

$r = New-Object System.Text.StringBuilder
[void]$r.AppendLine('# moddle')
[void]$r.AppendLine()
[void]$r.AppendLine("**$($data.meta.tagline)**")
[void]$r.AppendLine()
[void]$r.AppendLine("A curated guide to the best local AI models that actually fit an **RTX 4070 Ti Super 16 GB**, 32 GB DDR5, and NVMe storage - with honest VRAM math, quants, and copy-ready commands.")
[void]$r.AppendLine()
[void]$r.AppendLine('[![License: MIT](https://img.shields.io/badge/code-MIT-blue.svg)](LICENSE) [![Content: CC BY 4.0](https://img.shields.io/badge/content-CC--BY--4.0-lightgrey.svg)](LICENSE-CONTENT)')
[void]$r.AppendLine()
[void]$r.AppendLine("**[Browse the website ->]($SiteUrl)**")
[void]$r.AppendLine()
[void]$r.AppendLine('## Target hardware')
[void]$r.AppendLine()
[void]$r.AppendLine('| Component | Spec |')
[void]$r.AppendLine('| --- | --- |')
[void]$r.AppendLine("| GPU | $($data.hardware.gpu) |")
[void]$r.AppendLine("| VRAM | $($data.hardware.vramGB) GB (~$($data.hardware.usableVramGB) GB usable) |")
[void]$r.AppendLine("| Bandwidth | $($data.hardware.bandwidthGBs) GB/s |")
[void]$r.AppendLine("| System RAM | $($data.hardware.ramGB) GB $($data.hardware.ramType) |")
[void]$r.AppendLine("| Storage | $($data.hardware.storage) |")
[void]$r.AppendLine()
[void]$r.AppendLine('## If you only try ten things')
[void]$r.AppendLine()
[void]$r.AppendLine((New-ModelTable -Models $topPicks -LinkMode 'site').TrimEnd())
[void]$r.AppendLine()
[void]$r.AppendLine('## Categories')
[void]$r.AppendLine()
foreach ($cat in $data.categories) {
    $count = @($data.models | Where-Object { $_.category -eq $cat.id }).Count
    [void]$r.AppendLine("- **[$($cat.name)](models/$($cat.id).md)** - $($cat.blurb) _($count models)_")
}
[void]$r.AppendLine()
[void]$r.AppendLine('## Guides')
[void]$r.AppendLine()
[void]$r.AppendLine('- [Hardware & VRAM](docs/hardware.md) - the memory math that decides what fits.')
[void]$r.AppendLine('- [Quantization](docs/quantization.md) - GGUF ladders, KV-cache quants, tradeoffs.')
[void]$r.AppendLine('- [Tuning for 16 GB](docs/tuning.md) - context, offload, OOM troubleshooting.')
[void]$r.AppendLine('- [Runtimes](docs/runtimes.md) - Ollama, LM Studio, llama.cpp, vLLM/SGLang, ComfyUI.')
[void]$r.AppendLine()
[void]$r.AppendLine('## How this works')
[void]$r.AppendLine()
[void]$r.AppendLine('Everything here is generated from [`data/models.json`](data/models.json):')
[void]$r.AppendLine()
[void]$r.AppendLine('```powershell')
[void]$r.AppendLine('./scripts/build-docs.ps1            # regenerate this README + models/*.md')
[void]$r.AppendLine('./scripts/ollama-pull.ps1 -Execute  # pull every Ollama-runnable model')
[void]$r.AppendLine('```')
[void]$r.AppendLine()
[void]$r.AppendLine('Add or fix a model in the JSON, run the script, and the docs update.')
[void]$r.AppendLine('See [CONTRIBUTING.md](CONTRIBUTING.md) to help.')
[void]$r.AppendLine()
[void]$r.AppendLine('## Disclaimer')
[void]$r.AppendLine()
[void]$r.AppendLine('VRAM and speed figures are estimates for this hardware class, not guarantees. Always check the model license before commercial use.')
[void]$r.AppendLine()
[void]$r.AppendLine('## License')
[void]$r.AppendLine()
[void]$r.AppendLine('Code and scripts: [MIT](LICENSE). Content and dataset: [CC BY 4.0](LICENSE-CONTENT).')
[void]$r.AppendLine()

Write-Text -Path (Join-Path $OutDir 'README.md') -Text $r.ToString()
Write-Host "wrote README.md" -ForegroundColor Green
Write-Host "Done. $($data.models.Count) models across $($data.categories.Count) categories." -ForegroundColor Green
