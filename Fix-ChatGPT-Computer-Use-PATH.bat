@echo off
setlocal
title ChatGPT Computer Use - PATH Fix - Malek Alahmer
set "CHATGPT_PATH_FIX_BAT=%~f0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -Command "$ErrorActionPreference = 'Stop'; try { $source = [IO.File]::ReadAllText($env:CHATGPT_PATH_FIX_BAT); $marker = '#__PATH_FIX_POWERSHELL__'; $offset = $source.LastIndexOf($marker, [StringComparison]::Ordinal); if ($offset -lt 0) { throw 'Embedded PowerShell source was not found.' }; & ([scriptblock]::Create($source.Substring($offset + $marker.Length))) } catch { Write-Host ('LAUNCH FAILED: ' + $_.Exception.Message) -ForegroundColor Red; [void](Read-Host 'Press Enter to exit'); exit 1 }"
set "PATH_FIX_EXIT_CODE=%errorlevel%"
if not "%PATH_FIX_EXIT_CODE%"=="0" (
    echo.
    echo The launcher could not finish. Review the message above.
    echo Press any key to exit...
    pause >nul
)
exit /b %PATH_FIX_EXIT_CODE%
#__PATH_FIX_POWERSHELL__
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

$ErrorActionPreference = 'Stop'

function Wait-ForKey {
    param([string]$Message)
    Write-Host ''
    Write-Host $Message -ForegroundColor Yellow
    try {
        if ([Console]::IsInputRedirected) {
            [void][Console]::ReadLine()
        } else {
            [void]$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
    } catch {
        [void](Read-Host 'Press Enter')
    }
    Write-Host ''
}

Write-Host '============================================================' -ForegroundColor Green
Write-Host ' ChatGPT Computer Use - Windows PATH Fix' -ForegroundColor Green
Write-Host ' Created by Malek Alahmer | Copyright (c) 2026' -ForegroundColor Green
Write-Host ' Website:  https://goldcatalyst-ea.com/' -ForegroundColor Green
Write-Host ' Support:  support@goldcatalyst-ea.com' -ForegroundColor Green
Write-Host ' WhatsApp: https://wa.me/971555229072' -ForegroundColor Green
Write-Host '============================================================' -ForegroundColor Green
Write-Host ' Free community tool. Not an official OpenAI tool.' -ForegroundColor Cyan
Write-Host ' This checks an existing Codex installation and updates User PATH.' -ForegroundColor Cyan
Write-Host ' A backup is saved before any User PATH change.' -ForegroundColor Cyan
Write-Host ''
Write-Host ' Before continuing: Exit ChatGPT completely.' -ForegroundColor Yellow
Write-Host ' Check Task Manager and end remaining ChatGPT app processes.' -ForegroundColor Yellow
Write-Host ' Closing only the window may leave ChatGPT running.' -ForegroundColor Yellow

try {
    Wait-ForKey 'Press any key to continue...'

    Write-Host 'Checking your Codex installation...' -ForegroundColor Cyan
    $binRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin'
    if (-not (Test-Path -LiteralPath $binRoot -PathType Container)) {
        throw "Codex binary folder not found: $binRoot. Launch/update the desktop app first."
    }

    # Prefer the Codex binary actually running app-server, if one exists.
    $running = @()
    try {
        $running = @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction SilentlyContinue |
        Where-Object {
            $_.ExecutablePath -and
            $_.ExecutablePath.StartsWith($binRoot + '\', [StringComparison]::OrdinalIgnoreCase) -and
            $_.CommandLine -match '(^|\s)app-server(\s|$)' -and
            (Test-Path -LiteralPath $_.ExecutablePath -PathType Leaf)
        })
    } catch {
        # Process inspection is optional; use the installed-file fallback.
        $running = @()
    }

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
    # Windows PowerShell 5.1 can turn native stderr warnings into errors.
    # Judge the version check by its exit code and actual version line.
    $savedErrorPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $versionOutput = @(& $exe --version 2>&1)
        $versionExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $savedErrorPreference
    }
    if ($versionExitCode -ne 0) {
        throw "The selected codex.exe did not pass the version check: $exe"
    }
    $version = @($versionOutput | ForEach-Object { [string]$_ } |
        Where-Object { $_ -match '^codex-cli\s+' })
    if ($version.Count -eq 0) {
        throw "The selected codex.exe did not return a recognized version: $exe"
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

    Write-Host "Codex executable: $exe" -ForegroundColor Cyan
    if ($newPath -ceq $oldPath) {
        Write-Host 'User PATH: already correctly configured.' -ForegroundColor Green
    } else {
        $backup = Join-Path $env:USERPROFILE ('codex-path-backup-{0}.txt' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
        [IO.File]::WriteAllText($backup, [string]$oldPath)
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Host "User PATH: UPDATED (backup: $backup)" -ForegroundColor Green
    }

    # Prioritize the selected Codex binary in this terminal for verification.
    $env:Path = $dir + ';' + $env:Path
    $resolved = Get-Command codex -ErrorAction SilentlyContinue
    Write-Host ('Found via PATH in this terminal: ' + [bool]$resolved) -ForegroundColor $(if ($resolved) { 'Green' } else { 'Yellow' })
    Write-Host ('Codex version: ' + ($version -join ' ')) -ForegroundColor Cyan
    Write-Host 'NEXT: Open ChatGPT again, select Work > On my computer, and retry Computer Use.' -ForegroundColor Green
    Write-Host 'If still broken, sign out of Windows and sign back in, then retry.'
}
catch {
    Write-Host ('FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Review the error above. This PATH fix may not apply to your installation.' -ForegroundColor Yellow
}
finally {
    Wait-ForKey 'Press any key to exit...'
}
