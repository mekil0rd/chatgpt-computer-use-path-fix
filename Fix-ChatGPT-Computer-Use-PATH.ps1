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


function Get-VerifiedCodexVersion {
    param([string]$Executable)
    $process = New-Object System.Diagnostics.Process
    try {
        $process.StartInfo.FileName = $Executable
        $process.StartInfo.Arguments = '--version'
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.CreateNoWindow = $true
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        if (-not $process.Start()) { throw 'The executable could not be started.' }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit(10000)) {
            try { $process.Kill() } catch {}
            throw 'Version check timed out after 10 seconds.'
        }
        if (-not $stdout.Wait(1000) -or -not $stderr.Wait(1000)) {
            throw 'Version output could not be read in time.'
        }
        if ($process.ExitCode -ne 0) { throw 'The executable returned a failed version check.' }
        $versionLines = @(($stdout.Result + "`n" + $stderr.Result) -split '\r?\n' |
            Where-Object { $_ -match '^codex-cli\s+\S+' })
        if ($versionLines.Count -eq 0) { throw 'No recognized Codex version was returned.' }
        return $versionLines[0].Trim()
    } finally {
        $process.Dispose()
    }
}

function Get-UserPath {
    return [Environment]::GetEnvironmentVariable('Path', 'User')
}

function Set-UserPath {
    param([AllowNull()][object]$Value)
    [Environment]::SetEnvironmentVariable('Path', $Value, 'User')
}

function Save-UserPathBackup {
    param([AllowNull()][string]$Value)
    $filename = 'codex-path-backup-{0}-{1}.txt' -f (Get-Date -Format 'yyyyMMdd-HHmmss-fff'), ([Guid]::NewGuid().ToString('N'))
    $location = Join-Path $env:USERPROFILE $filename
    [IO.File]::WriteAllText($location, [string]$Value, (New-Object Text.UTF8Encoding($false)))
    return $location
}

# Run the interactive fix.
$pathWasWritten = $false
$oldPath = $null
$newPath = $null
$backup = $null
try {
    Wait-ForKey 'Press any key to continue...'
    Write-Host 'Checking your Codex installation...' -ForegroundColor Cyan
    $binRoot = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin'
    if (-not (Test-Path -LiteralPath $binRoot -PathType Container)) {
        throw "Codex binary folder not found: $binRoot. Launch/update the desktop app first."
    }

    $running = @()
    try {
        $running = @(Get-CimInstance Win32_Process -Filter "Name='codex.exe'" -ErrorAction Stop |
            Where-Object {
                $_.ExecutablePath -and
                $_.ExecutablePath.StartsWith($binRoot + '\', [StringComparison]::OrdinalIgnoreCase) -and
                $_.CommandLine -match '(^|\s)app-server(\s|$)' -and
                (Test-Path -LiteralPath $_.ExecutablePath -PathType Leaf)
            } | Select-Object -ExpandProperty ExecutablePath)
    } catch {
        # Process inspection is optional; installed files are checked below.
        $running = @()
    }
    $installed = @()
    $directExecutable = Join-Path $binRoot 'codex.exe'
    if (Test-Path -LiteralPath $directExecutable -PathType Leaf) {
        $installed += Get-Item -LiteralPath $directExecutable
    }
    $installed += @(Get-ChildItem -LiteralPath $binRoot -Directory -ErrorAction Stop |
        ForEach-Object {
            $candidate = Join-Path $_.FullName 'codex.exe'
            if (Test-Path -LiteralPath $candidate -PathType Leaf) {
                Get-Item -LiteralPath $candidate
            }
        })
    $candidates = @(@($running) + @($installed | Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -ExpandProperty FullName) | Select-Object -Unique)
    if ($candidates.Count -eq 0) { throw "No codex.exe found under $binRoot." }

    $exe = $null
    foreach ($candidate in $candidates) {
        try {
            $version = Get-VerifiedCodexVersion $candidate
            $exe = $candidate
            break
        } catch {
            Write-Host ("Skipping unusable Codex candidate: {0} ({1})" -f $candidate, $_.Exception.Message) -ForegroundColor Yellow
        }
    }
    if (-not $exe) { throw 'No usable Codex executable passed the version check. User PATH was not changed.' }

    $dir = Split-Path -Path $exe -Parent
    if ($dir.Contains(';')) {
        throw 'The Codex folder contains a semicolon and cannot be safely added as one PATH entry.'
    }
    $oldPath = Get-UserPath
    $codexEntryPattern = '^' + [regex]::Escape($binRoot.TrimEnd('\')) + '(\\[^\\]+)?$'
    $otherEntries = @()
    if ($null -ne $oldPath -and $oldPath.Length -gt 0) {
        $otherEntries = @($oldPath -split ';' | Where-Object {
            $entry = [Environment]::ExpandEnvironmentVariables($_.Trim().Trim('"')).TrimEnd('\')
            $entry -notmatch $codexEntryPattern
        })
    }
    $newPath = $dir
    if ($otherEntries.Count -gt 0) { $newPath += ';' + ($otherEntries -join ';') }
    if ($newPath.Length -ge 32767) { throw 'The updated User PATH would be too long. No change was made.' }

    Write-Host "Codex executable: $exe" -ForegroundColor Cyan
    if ($newPath -ceq $oldPath) {
        Write-Host 'User PATH: already correctly configured.' -ForegroundColor Green
    } else {
        $backup = Save-UserPathBackup $oldPath
        if ((Get-UserPath) -cne $oldPath) {
            throw 'User PATH changed in another process. No update was made; run the utility again.'
        }
        Set-UserPath $newPath
        $pathWasWritten = $true
        if ((Get-UserPath) -cne $newPath) {
            throw 'The saved User PATH did not match the requested value.'
        }
        Write-Host "User PATH: UPDATED (backup: $backup)" -ForegroundColor Green
    }

    $env:Path = $dir + ';' + $env:Path
    $resolved = Get-Command -Name codex.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1
    if (-not [string]::Equals($resolved.Source, $exe, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Command discovery did not resolve to the selected Codex executable.'
    }
    Write-Host 'Found via PATH in this terminal: True' -ForegroundColor Green
    Write-Host 'Saved User PATH: VERIFIED' -ForegroundColor Green
    Write-Host ('Codex version: ' + $version) -ForegroundColor Cyan
    Write-Host 'NEXT: Open ChatGPT again, select Work > On my computer, and retry Computer Use.' -ForegroundColor Green
    Write-Host 'If still broken, sign out of Windows and sign back in, then retry.'
} catch {
    Write-Host ('FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    if ($pathWasWritten) {
        try {
            if ((Get-UserPath) -ceq $newPath) {
                Set-UserPath $oldPath
                if ((Get-UserPath) -cne $oldPath) { throw 'Restoration could not be verified.' }
                Write-Host 'User PATH: RESTORED to its previous value.' -ForegroundColor Yellow
            } else {
                Write-Host 'User PATH changed unexpectedly; automatic restoration was skipped to avoid overwriting another change.' -ForegroundColor Yellow
            }
        } catch {
            Write-Host ('Automatic restoration failed: ' + $_.Exception.Message) -ForegroundColor Red
        }
        Write-Host ("Keep the backup for recovery: {0}" -f $backup) -ForegroundColor Yellow
    }
    Write-Host 'Review the error above. This PATH fix may not apply to your installation.' -ForegroundColor Yellow
} finally {
    Wait-ForKey 'Press any key to exit...'
}
