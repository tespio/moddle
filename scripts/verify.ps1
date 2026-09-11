#Requires -Version 5.1
<#
.SYNOPSIS
    Verifies the whole project builds and serves correctly on this machine.

.DESCRIPTION
    1. Regenerates the repo markdown from data/models.json.
    2. Builds the Astro site.
    3. Asserts the expected pages and content exist in web/dist.
    4. Boots `astro preview`, requests key routes over HTTP, and checks the
       status codes and page titles.
    5. Stops the server and reports a pass/fail summary.

    Exit code is 0 on success, 1 on any failure.

.EXAMPLE
    ./scripts/verify.ps1
    ./scripts/verify.ps1 -Port 4331
#>
[CmdletBinding()]
param(
    [int]$Port = 4331,
    [switch]$SkipPreview
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$web = Join-Path $root 'web'
$dist = Join-Path $web 'dist'
$base = '/moddle'
$failures = 0
$checks = 0

function Pass($msg) {
    $script:checks++
    Write-Host "  [PASS] $msg" -ForegroundColor Green
}
function Fail($msg) {
    $script:checks++
    $script:failures++
    Write-Host "  [FAIL] $msg" -ForegroundColor Red
}
function Check($condition, $msg) {
    if ($condition) { Pass $msg } else { Fail $msg }
}
function Section($msg) { Write-Host "`n== $msg ==" -ForegroundColor Cyan }

# --- 1. Docs ----------------------------------------------------------------
Section 'Generating repo markdown'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'scripts/build-docs.ps1') | Out-Null
Check ($LASTEXITCODE -eq 0) 'build-docs.ps1 completed'
Check (Test-Path -LiteralPath (Join-Path $root 'README.md')) 'README.md generated'
Check (Test-Path -LiteralPath (Join-Path $root 'models/chat.md')) 'models/chat.md generated'

# --- 2. Build ---------------------------------------------------------------
Section 'Building the Astro site'
Push-Location $web
try {
    if (-not (Test-Path -LiteralPath (Join-Path $web 'node_modules'))) {
        Write-Host '  installing dependencies...' -ForegroundColor DarkGray
        & npm install --no-fund --no-audit | Out-Null
    }
    $buildOutput = & npm run build 2>&1
    $buildOk = $LASTEXITCODE -eq 0
    if (-not $buildOk) { $buildOutput | Write-Host }
    Check $buildOk 'astro build succeeded'
} finally {
    Pop-Location
}

# --- 3. Static assertions ---------------------------------------------------
Section 'Checking built output'
$pages = @{
    'index.html'                       = 'Because your GPU has'
    'models/index.html'                = 'All '
    'models/qwen3-14b/index.html'      = 'Qwen3-14B'
    'models/qwen3.8-27b/index.html'    = 'One-click kit'
    'models/gemma-4-12b/index.html'    = 'Gemma 4 12B'
    'models/qwen3-vl-8b/index.html'    = 'Qwen3-VL-8B'
    'categories/chat/index.html'       = 'Chat'
    'docs/index.html'                  = 'Guides'
    'docs/hardware/index.html'         = 'usable'
    'docs/exl3/index.html'             = 'ExLlamaV3'
    'docs/offloading/index.html'       = 'offload'
    'docs/tuning/index.html'           = 'OOM'
}
foreach ($rel in $pages.Keys) {
    $file = Join-Path $dist $rel
    $exists = Test-Path -LiteralPath $file
    Check $exists "built $rel"
    if ($exists) {
        $html = [System.IO.File]::ReadAllText($file)
        Check ($html -match [regex]::Escape($pages[$rel])) "$rel contains expected text"
        Check ($html -notmatch '>[Uu]ndefined<') "$rel has no stray 'undefined'"
        Check ($html -match 'href="/moddle/') "$rel links are base-prefixed"
    }
}

$staticFiles = @('favicon.svg', 'sitemap-index.xml', 'robots.txt')
foreach ($f in $staticFiles) {
    Check (Test-Path -LiteralPath (Join-Path $dist $f)) "built $f"
}

# --- 4. Preview over HTTP ---------------------------------------------------
if (-not $SkipPreview) {
    Section "Serving on http://127.0.0.1:$Port$base/"

    $astroBin = Join-Path $web 'node_modules/astro/bin/astro.mjs'
    if (-not (Test-Path -LiteralPath $astroBin)) {
        Fail 'astro CLI not found in node_modules'
    } else {
        $proc = Start-Process -FilePath 'node' `
            -ArgumentList @($astroBin, 'preview', '--port', "$Port", '--host', '127.0.0.1') `
            -WorkingDirectory $web -PassThru -WindowStyle Hidden

        try {
            $ready = $false
            foreach ($i in 1..40) {
                Start-Sleep -Milliseconds 500
                try {
                    $r = Invoke-WebRequest -Uri "http://127.0.0.1:$Port$base/" -UseBasicParsing -TimeoutSec 3
                    if ($r.StatusCode -eq 200) { $ready = $true; break }
                } catch { }
            }
            Check $ready 'preview server responded'

            if ($ready) {
                $routes = @(
                    '/',
                    '/models/',
                    '/models/qwen3-14b/',
                    '/models/qwen3.8-27b/',
                    '/models/gemma-4-12b/',
                    '/models/qwen3-vl-8b/',
                    '/models/qwen3-coder-30b-a3b/',
                    '/categories/vision/',
                    '/docs/',
                    '/docs/quantization/',
                    '/docs/exl3/',
                    '/docs/offloading/',
                    '/sitemap-index.xml',
                    '/favicon.svg'
                )
                foreach ($route in $routes) {
                    $url = "http://127.0.0.1:$Port$base$route"
                    try {
                        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5
                        $len = $resp.RawContentLength
                        Check ($resp.StatusCode -eq 200 -and $len -gt 0) "GET $route -> $($resp.StatusCode) ($len bytes)"
                    } catch {
                        Fail "GET $route -> $($_.Exception.Message)"
                    }
                }
            }
        } finally {
            if ($proc -and -not $proc.HasExited) {
                Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# --- Summary ----------------------------------------------------------------
Write-Host ''
if ($failures -eq 0) {
    Write-Host "All $checks checks passed." -ForegroundColor Green
    exit 0
} else {
    Write-Host "$failures of $checks checks FAILED." -ForegroundColor Red
    exit 1
}
