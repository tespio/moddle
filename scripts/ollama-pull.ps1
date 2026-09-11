#Requires -Version 5.1
<#
.SYNOPSIS
    Pulls every Ollama-runnable model from data/models.json.

.DESCRIPTION
    Reads the dataset, extracts the `runtimes.ollama` command for each model,
    and pulls the corresponding model. By default it prints the commands
    (dry run). Use -Execute to actually run them.

.EXAMPLE
    ./scripts/ollama-pull.ps1
    ./scripts/ollama-pull.ps1 -Execute
    ./scripts/ollama-pull.ps1 -Execute -Category chat
#>
[CmdletBinding()]
param(
    [switch]$Execute,
    [ValidateSet('all', 'chat', 'coding', 'vision', 'image-generation', 'voice', 'embeddings-rag')]
    [string]$Category = 'all',
    [string]$DataPath
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $DataPath) { $DataPath = Join-Path $root 'data/models.json' }

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Error "ollama was not found on PATH. Install it from https://ollama.com first."
}

$json = [System.IO.File]::ReadAllText($DataPath, [System.Text.Encoding]::UTF8)
$data = $json | ConvertFrom-Json

$targets = @($data.models | Where-Object {
    $_.runtimes.ollama -and
    ($Category -eq 'all' -or $_.category -eq $Category)
})

if ($targets.Count -eq 0) {
    Write-Host "No Ollama models found for category '$Category'." -ForegroundColor Yellow
    return
}

$i = 0
foreach ($m in $targets) {
    $i++
    $tag = ([string]$m.runtimes.ollama).Trim() -replace '^ollama\s+run\s+', ''
    $tag = $tag.Trim()
    Write-Host ("[{0}/{1}] {2} " -f $i, $targets.Count, $m.name) -NoNewline -ForegroundColor Cyan
    Write-Host "(ollama pull $tag)" -ForegroundColor DarkGray
    if ($Execute) {
        ollama pull $tag
        if (-not $?) { Write-Warning "Failed to pull $tag" }
    }
}

Write-Host ''
if ($Execute) {
    Write-Host "Pulled $($targets.Count) models." -ForegroundColor Green
} else {
    Write-Host "Dry run. Re-run with -Execute to pull." -ForegroundColor Yellow
}
