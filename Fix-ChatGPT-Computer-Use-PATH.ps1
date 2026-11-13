# ChatGPT Computer Use - PATH Diagnostics and Legacy Recovery v2.0.0
# Created by Malek Alahmer | Copyright (c) 2026
# https://goldcatalyst-ea.com/ | support@goldcatalyst-ea.com
# Independent community tool, not an official OpenAI tool.
# Default: read-only diagnostics. Never adds a Codex folder to PATH.
[CmdletBinding()]
param(
    [ValidateSet('Interactive', 'Diagnose', 'UndoLegacy')]
    [string]$Mode = 'Interactive',
    [switch]$NoPause
)

$ErrorActionPreference = 'Stop'

function Get-LegacyPathPlan {
    param([AllowNull()][object]$PathValue, [Parameter(Mandatory)][string]$LocalData)
    if ($null -ne $PathValue -and $PathValue -isnot [string]) { throw 'PATH must be text or null.' }
    if (-not [IO.Path]::IsPathRooted($LocalData) -or $LocalData.Contains(';')) {
        throw 'LOCALAPPDATA is not an unambiguous absolute path. No changes made.'
    }
    $root = [IO.Path]::Combine($LocalData, 'OpenAI\Codex\bin').TrimEnd('\')
    $pattern = '^' + [regex]::Escape($root) + '(\\[^\\]+)?$'
    $kept = New-Object 'System.Collections.Generic.List[string]'
    $removed = New-Object 'System.Collections.Generic.List[string]'
    if ($null -ne $PathValue -and $PathValue.Length -gt 0) {
        foreach ($entry in ($PathValue -split ';')) {
            $normalized = [Environment]::ExpandEnvironmentVariables($entry.Trim().Trim('"')).TrimEnd('\')
            if ($normalized -match $pattern) { $removed.Add($entry) }
            else { $kept.Add($entry) }
        }
    }
    $next = $PathValue
    if ($removed.Count -gt 0) { $next = $kept -join ';' }
    [pscustomobject]@{ Before = $PathValue; After = $next; Removed = @($removed.ToArray()) }
}

function Read-UserPathState {
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $false)
    try {
        if ($null -eq $key -or @($key.GetValueNames()) -notcontains 'Path') {
            return [pscustomobject]@{ Exists = $false; Value = $null; Kind = $null }
        }
        $kind = $key.GetValueKind('Path')
        if ($kind -notin @([Microsoft.Win32.RegistryValueKind]::String, [Microsoft.Win32.RegistryValueKind]::ExpandString)) {
            throw 'User PATH has an unsupported registry type. No changes made.'
        }
        [pscustomobject]@{
            Exists = $true
            Value = [string]$key.GetValue('Path', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
            Kind = $kind.ToString()
        }
    } finally { if ($null -ne $key) { $key.Dispose() } }
}

function Write-UserPathState {
    param([Parameter(Mandatory)]$State, [Parameter(Mandatory)][AllowEmptyString()][string]$Value)
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment', $true)
    if ($null -eq $key) { throw 'User environment registry key is unavailable.' }
    try {
        $kind = [Microsoft.Win32.RegistryValueKind][Enum]::Parse([Microsoft.Win32.RegistryValueKind], $State.Kind)
        $key.SetValue('Path', $Value, $kind)
    } finally { $key.Dispose() }
}

function Save-RecoveryBackup {
    param([Parameter(Mandatory)]$State, [Parameter(Mandatory)]$Plan)
    $name = 'codex-path-recovery-{0}-{1}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss'), ([Guid]::NewGuid().ToString('N'))
    $file = Join-Path $env:USERPROFILE $name
    $record = [ordered]@{
        ToolVersion = '2.0.0'; CreatedUtc = [DateTime]::UtcNow.ToString('o')
        Scope = 'CurrentUser'; PathExisted = $State.Exists; RegistryKind = $State.Kind
        Before = $State.Value; After = $Plan.After; Removed = $Plan.Removed
    }
    [IO.File]::WriteAllText($file, ($record | ConvertTo-Json -Depth 4), (New-Object Text.UTF8Encoding($false)))
    return $file
}

function Show-Diagnostics {
    $state = Read-UserPathState
    $plan = Get-LegacyPathPlan -PathValue $state.Value -LocalData $env:LOCALAPPDATA
    Write-Host ''
    Write-Host 'READ-ONLY DIAGNOSTICS - no settings are changed.' -ForegroundColor Cyan
    $resolved = @(Get-Command -Name codex.exe -CommandType Application -ErrorAction SilentlyContinue)
    if ($resolved.Count -gt 0) {
        Write-Host ('This terminal resolves codex.exe to: ' + $resolved[0].Source)
        Write-Host 'This does NOT establish which executable ChatGPT uses or its compatibility.'
    } else {
        Write-Host 'codex.exe is not resolved in THIS terminal. ChatGPT may use a different environment or a bundled executable.' -ForegroundColor Yellow
    }
    Write-Host ('Legacy-shaped User PATH entries: ' + $plan.Removed.Count)
    foreach ($entry in $plan.Removed) { Write-Host ('  ' + $entry) }
    $root = Join-Path $env:LOCALAPPDATA 'OpenAI\Codex\bin'
    if (Test-Path -LiteralPath $root -PathType Container) {
        $candidates = @()
        $direct = Join-Path $root 'codex.exe'
        if (Test-Path -LiteralPath $direct -PathType Leaf) { $candidates += $direct }
        foreach ($folder in @(Get-ChildItem -LiteralPath $root -Directory)) {
            $candidate = Join-Path $folder.FullName 'codex.exe'
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $candidates += $candidate }
        }
        Write-Host ('Existing executables in the historical layout: ' + $candidates.Count)
        foreach ($candidate in $candidates) { Write-Host ('  ' + $candidate) }
    } else { Write-Host 'Historical Codex installation folder not found. Other layouts are not assessed.' }
    Write-Host ''
    Write-Host 'No Codex executable is selected, launched, installed, or added to PATH.'
    Write-Host 'For program not found: save work, fully exit and reopen ChatGPT, and check for an official app update.'
    Write-Host 'If it persists, use official support/app repair guidance. Do not pin an arbitrary Codex version.'
    Write-Host 'If you used the old PATH utility, choose U at startup to review its legacy PATH recovery.'
    Write-Host 'A version check or successful PATH lookup alone does not prove Computer Use is working.'
}

function Undo-LegacyPath {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param()
    $state = Read-UserPathState
    $plan = Get-LegacyPathPlan -PathValue $state.Value -LocalData $env:LOCALAPPDATA
    if ($plan.Removed.Count -eq 0) {
        Write-Host 'No matching legacy entries found. Nothing changed.' -ForegroundColor Green
        return
    }
    Write-Host ''
    Write-Host 'PROPOSED REMOVAL FROM USER PATH ONLY:' -ForegroundColor Yellow
    foreach ($entry in $plan.Removed) { Write-Host ('  ' + $entry) }
    Write-Host 'These match the old tool layout; their creator cannot be proven from PATH alone.'
    Write-Host 'Continue only if you used the old tool or want these entries removed.'
    Write-Host 'Other software relying on these PATH entries may stop finding Codex by name.'
    Write-Host 'This removes entries only. It does not delete Codex or change Machine PATH.'
    if (-not $PSCmdlet.ShouldProcess('Current account User PATH', 'Back up PATH and remove ONLY the listed legacy Codex entries')) { return }
    $backup = Save-RecoveryBackup -State $state -Plan $plan
    Write-Host ('Backup: ' + $backup)
    $fresh = Read-UserPathState
    if ($fresh.Exists -ne $state.Exists -or $fresh.Kind -cne $state.Kind -or $fresh.Value -cne $state.Value) {
        throw 'User PATH changed during review. No write performed; run again.'
    }
    Write-UserPathState -State $state -Value $plan.After
    $saved = Read-UserPathState
    if (-not $saved.Exists -or $saved.Value -cne $plan.After -or $saved.Kind -cne $state.Kind) {
        throw ('Saved PATH verification failed or another process changed it. Keep the backup and review User PATH manually: ' + $backup)
    }
    Write-Host 'Legacy entries removed. Saved User PATH and registry type VERIFIED.' -ForegroundColor Green
    Write-Host 'Save work, fully exit ChatGPT, then sign out of Windows and sign back in so apps receive the new environment.'
    Write-Host 'Retry Computer Use and check approval behavior. Recovery is not a guaranteed fix for either error.'
}

function Invoke-PathTool {
    param([string]$SelectedMode, [switch]$SkipPause)
    $result = 0
    Write-Host '============================================================' -ForegroundColor Green
    Write-Host ' ChatGPT Computer Use - PATH Diagnostics & Recovery v2.0.0' -ForegroundColor Green
    Write-Host ' Created by Malek Alahmer | Copyright (c) 2026' -ForegroundColor Green
    Write-Host ' https://goldcatalyst-ea.com/'
    Write-Host ' support@goldcatalyst-ea.com | https://wa.me/971555229072'
    Write-Host ' Independent community tool. Not an official OpenAI tool.'
    Write-Host ' No automatic permanent Codex PATH additions.'
    Write-Host '============================================================' -ForegroundColor Green
    try {
        if ($SelectedMode -eq 'Interactive') {
            Write-Host 'Enter = read-only diagnostics | U = review legacy PATH removal | Q = quit'
            $choice = Read-Host 'Choose'
            if ($choice -match '^[Qq]$') { return 0 }
            if ($choice -match '^[Uu]$') { $SelectedMode = 'UndoLegacy' }
            elseif ([string]::IsNullOrWhiteSpace($choice)) { $SelectedMode = 'Diagnose' }
            else { throw 'Unknown choice. Nothing changed.' }
        }
        if ($SelectedMode -eq 'UndoLegacy') { Undo-LegacyPath }
        else { Show-Diagnostics }
    } catch {
        $result = 1
        Write-Host ('FAILED: ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host 'Do not treat this run as a successful repair. No changes to approvals or security were attempted.'
    } finally {
        if (-not $SkipPause) { [void](Read-Host 'Press Enter to close') }
    }
    return $result
}

# Dot-source to load functions for isolated tests without running the tool.
if ($MyInvocation.InvocationName -ne '.') {
    exit (Invoke-PathTool -SelectedMode $Mode -SkipPause:$NoPause)
}
