$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
. (Join-Path $root 'Fix-ChatGPT-Computer-Use-PATH.ps1')
$script:Passed = 0
function Assert-Case($Name, [scriptblock]$Check) {
    & $Check
    $script:Passed++
    Write-Host ('PASS: ' + $Name)
}
function Equal($Actual, $Expected) {
    if ($Actual -cne $Expected) { throw "Mismatch. Expected [$Expected], got [$Actual]" }
}
$local = 'C:\Users\Example\AppData\Local'
$bin = $local + '\OpenAI\Codex\bin'
Assert-Case 'Null PATH preserved' { $p = Get-LegacyPathPlan $null $local; Equal $p.Before $null; Equal $p.After $null; Equal $p.Removed.Count 0 }
Assert-Case 'Empty PATH preserved' { Equal (Get-LegacyPathPlan '' $local).After '' }
Assert-Case 'Unrelated entries preserved byte for byte' { $v = ' C:\Python\ ;%USERPROFILE%\bin;;C:\npm;'; Equal (Get-LegacyPathPlan $v $local).After $v }
Assert-Case 'Versioned and direct entries removed' { $p = Get-LegacyPathPlan ($bin+'\abc;C:\Python;'+$bin) $local; Equal $p.After 'C:\Python'; Equal $p.Removed.Count 2 }
Assert-Case 'Trailing separator and quotes recognized' { Equal (Get-LegacyPathPlan ('"'+$bin+'\abc\";C:\Other') $local).After 'C:\Other' }
Assert-Case 'Case insensitive matching' { Equal (Get-LegacyPathPlan ($bin.ToUpperInvariant()+'\ABC;C:\Other') $local).After 'C:\Other' }
Assert-Case 'Deeper unrelated descendants preserved' { $v=$bin+'\abc\tools;'+$bin+'-other'; Equal (Get-LegacyPathPlan $v $local).After $v }
Assert-Case 'Other account untouched' { $v='C:\Users\Another\AppData\Local\OpenAI\Codex\bin\abc'; Equal (Get-LegacyPathPlan $v $local).After $v }
Assert-Case 'Empty entries and order preserved during removal' { Equal (Get-LegacyPathPlan (';C:\A;;'+$bin+'\abc;C:\B;') $local).After ';C:\A;;C:\B;' }
Assert-Case 'Repeated recovery is a no-op' { $first=Get-LegacyPathPlan ($bin+'\abc;C:\A') $local; Equal (Get-LegacyPathPlan $first.After $local).Removed.Count 0 }
Assert-Case 'Unicode and special characters' { $l='D:\Users\'+[char]0x0645+' & (test)\Local'; Equal (Get-LegacyPathPlan ($l+'\OpenAI\Codex\bin\abc;D:\A & B') $l).After 'D:\A & B' }
Assert-Case 'Ambiguous root rejected' { $caught=$false; try { Get-LegacyPathPlan 'C:\A' 'C:\Local;D:\Other' | Out-Null } catch { $caught=$true }; Equal $caught $true }
Assert-Case 'BAT and PS1 sources identical' { $bat=[IO.File]::ReadAllText((Join-Path $root 'Fix-ChatGPT-Computer-Use-PATH.bat')); $marker='#__PATH_RECOVERY_POWERSHELL__'; $payload=$bat.Substring($bat.LastIndexOf($marker)+$marker.Length).TrimStart([char[]]"`r`n"); $ps=[IO.File]::ReadAllText((Join-Path $root 'Fix-ChatGPT-Computer-Use-PATH.ps1')); Equal ($payload -replace '\r\n',"`n") ($ps -replace '\r\n',"`n") }

# All recovery I/O below is in memory. No real registry writes occur.
$script:RealRead = ${function:Read-UserPathState}
$script:RealWrite = ${function:Write-UserPathState}
$script:RealBackup = ${function:Save-RecoveryBackup}
$script:RealLocal = $env:LOCALAPPDATA
$env:LOCALAPPDATA = $local
function Read-UserPathState { $script:Reads++; if ($script:Race -and $script:Reads -gt 1) { return [pscustomobject]@{Exists=$true;Value='C:\Concurrent';Kind='ExpandString'} }; return $script:State }
function Save-RecoveryBackup { param($State,$Plan); if ($script:BackupDenied) { throw 'Backup denied (simulated)' }; $script:Backups++; return 'memory-only-backup.json' }
function Write-UserPathState { param($State,$Value); if ($script:WriteDenied) { throw 'Write denied (simulated)' }; $script:Writes++; $script:State=[pscustomobject]@{Exists=$true;Value=$Value;Kind=$State.Kind} }
function Reset-Fake {
    $script:State=[pscustomobject]@{Exists=$true;Value=($bin+'\old;C:\Other;;');Kind='ExpandString'}
    $script:Reads=0; $script:Backups=0; $script:Writes=0; $script:Race=$false; $script:BackupDenied=$false; $script:WriteDenied=$false
}
try {
    Assert-Case 'WhatIf never writes or backs up' { Reset-Fake; Undo-LegacyPath -WhatIf; Equal $script:Writes 0; Equal $script:Backups 0 }
    Assert-Case 'Confirmed recovery verifies filtered raw PATH and kind' { Reset-Fake; Undo-LegacyPath -Confirm:$false; Equal $script:State.Value 'C:\Other;;'; Equal $script:State.Kind 'ExpandString'; Equal $script:Writes 1; Equal $script:Backups 1 }
    Assert-Case 'Concurrent update prevents write' { Reset-Fake; $script:Race=$true; $caught=$false; try { Undo-LegacyPath -Confirm:$false } catch { $caught=$true }; Equal $caught $true; Equal $script:Writes 0 }
    Assert-Case 'Backup failure prevents write' { Reset-Fake; $script:BackupDenied=$true; $caught=$false; try { Undo-LegacyPath -Confirm:$false } catch { $caught=$true }; Equal $caught $true; Equal $script:Writes 0 }
    Assert-Case 'Denied registry write is surfaced' { Reset-Fake; $script:WriteDenied=$true; $caught=$false; try { Undo-LegacyPath -Confirm:$false } catch { $caught=$true }; Equal $caught $true; Equal $script:Writes 0; Equal $script:Backups 1 }
    Assert-Case 'No matching entries never writes or backs up' { Reset-Fake; $script:State.Value='C:\Other'; Undo-LegacyPath -Confirm:$false; Equal $script:Writes 0; Equal $script:Backups 0 }
    Assert-Case 'Diagnostics never invokes write or backup' { Reset-Fake; Show-Diagnostics; Equal $script:Writes 0; Equal $script:Backups 0 }
} finally {
    $env:LOCALAPPDATA=$script:RealLocal
    Set-Item Function:Read-UserPathState $script:RealRead
    Set-Item Function:Write-UserPathState $script:RealWrite
    Set-Item Function:Save-RecoveryBackup $script:RealBackup
}
Write-Host ('TOTAL: ' + $script:Passed + ' PASS, 0 FAIL')
