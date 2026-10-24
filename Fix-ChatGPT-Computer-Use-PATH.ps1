# ============================================================================
# ChatGPT Computer Use / Codex App-Server - Windows PATH Fix
# ============================================================================
# Created by : Malek Alahmer
# Copyright  : (c) 2026 Malek Alahmer
# Website    : https://goldcatalyst-ea.com/
# Email      : support@goldcatalyst-ea.com
# WhatsApp   : https://wa.me/971555229072
#
# PURPOSE
# Free community troubleshooting script for the Windows error:
#   failed to launch codex app-server: program not found
#
# WHAT IT DOES
# - Detects an existing local Codex executable and checks its version.
# - Backs up the user's PATH before changing it.
# - Updates USER PATH only, keeping unrelated entries intact.
# - Does not download/install software or request Administrator rights.
# - Does not delete personal files or change Windows execution policy.
#
# SAFETY / DISCLAIMER
# This is an independent community contribution, NOT an official OpenAI tool.
# Review the source before running it. It makes a reversible PATH change.
# It may fix PATH-related launch failures, but is not a guaranteed solution
# for every Computer Use or app-server error. Run at your own discretion.
# Windows PowerShell 5.1 / PowerShell 7; normal (non-admin) user account.
# ============================================================================

Write-Host '============================================================' -ForegroundColor Cyan
Write-Host ' ChatGPT Computer Use - Codex PATH Fix | Malek Alahmer 2026' -ForegroundColor Cyan
Write-Host ' Website:  https://goldcatalyst-ea.com/'
Write-Host ' Support:  support@goldcatalyst-ea.com'
Write-Host ' WhatsApp: https://wa.me/971555229072'
Write-Host ' Free community fix - not an official OpenAI tool.'
Write-Host '============================================================' -ForegroundColor Cyan

$ErrorActionPreference = 'Stop'

try {
    $binRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin'
    if (-not (Test-Path -LiteralPath $binRoot -PathType Container)) {
        throw "Codex binary folder not found: $binRoot. Launch/update the desktop app first."
    }

    # Prefer the Codex binary actually running app-server, if one exists.
    $running = @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ExecutablePath -and
            $_.ExecutablePath.StartsWith($binRoot + '\', [StringComparison]::OrdinalIgnoreCase) -and
            $_.CommandLine -match '(^|\s)app-server(\s|$)' -and
            (Test-Path -LiteralPath $_.ExecutablePath -PathType Leaf)
        })

    if ($running.Count -gt 0) {
        $exe = $running[0].ExecutablePath
    } else {
        # Fallback for an app-server that is not running: newest local Codex binary.
        $files = @(Get-ChildItem -LiteralPath $binRoot -Directory -ErrorAction SilentlyContinue |
            ForEach-Object {
                $candidate = Join-Path $_.FullName 'codex.exe'
                if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                    Get-Item -LiteralPath $candidate
                }
            } | Sort-Object LastWriteTime -Descending)
        if ($files.Count -eq 0) {
            throw "No codex.exe found under $binRoot."
        }
        $exe = $files[0].FullName
    }

    # Verify the selected CLI responds before changing any PATH setting.
    $version = & $exe --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "The selected codex.exe did not pass the version check: $exe"
    }

    $dir = Split-Path -Path $exe -Parent
    $oldPath = [Environment]::GetEnvironmentVariable('Path', 'User')

    # Keep all unrelated PATH entries intact. Remove only old per-version
    # Codex paths from User PATH, then put the selected current one first.
    $codexEntryPattern = '^' + [regex]::Escape($binRoot.TrimEnd('\')) + '\\[^\\]+$'
    $otherEntries = @($oldPath -split ';' | Where-Object {
        $entry = $_.Trim().Trim('"').TrimEnd('\')
        $entry -and ($entry -notmatch $codexEntryPattern)
    })
    $newPath = $dir
    if ($otherEntries.Count -gt 0) {
        $newPath += ';' + ($otherEntries -join ';')
    }

    Write-Host "Codex executable: $exe"
    if ($newPath -ceq $oldPath) {
        Write-Host 'User PATH: already correctly configured.'
    } else {
        $backup = Join-Path $env:USERPROFILE ('codex-path-backup-{0}.txt' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
        [IO.File]::WriteAllText($backup, [string]$oldPath)
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Host "User PATH: UPDATED (backup: $backup)"
    }

    # Prioritize the selected Codex binary in this terminal for verification.
    $env:Path = $dir + ';' + $env:Path
    $resolved = Get-Command codex -ErrorAction SilentlyContinue
    Write-Host ('Found via PATH in this terminal: ' + [bool]$resolved)
    Write-Host ('Codex version: ' + ($version -join ' '))
    Write-Host 'NEXT: Fully quit ChatGPT, reopen it, select Work > On my computer, and retry Computer Use.'
    Write-Host 'If still broken, sign out of Windows and sign back in, then retry.'
}
catch {
    Write-Host ('FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'No additional fix was attempted. This PATH fix may not apply to your installation.'
}
