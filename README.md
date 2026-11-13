# ChatGPT Computer Use - Windows PATH Diagnostics & Recovery

**Created by Malek Alahmer | v2.0.0 | November 13, 2026**

Troubleshoot the Windows error `failed to launch codex app-server: program not found` and review PATH changes made by earlier versions of this community tool.

**Important update:** v2 replaces the old automatic PATH modification with **read-only diagnostics by default** and an **optional, confirmed legacy recovery**. It does not automatically repair a missing executable or guarantee a fix for repeated approval prompts. The historical filenames are retained so existing video/download links still work.

Independent community contribution. **Not an official OpenAI tool.**

## Download and run

**[Download the latest ZIP](https://github.com/mekil0rd/chatgpt-computer-use-path-fix/archive/refs/heads/main.zip)**

1. Download the latest ZIP and extract it into a normal folder. Review the source.
2. Double-click **`Fix-ChatGPT-Computer-Use-PATH.bat`** normally from the Windows account experiencing the issue. **Administrator privileges are not required.**
3. Choose an option:

| Choice | Result |
| --- | --- |
| Enter | Read-only diagnostics. No settings are changed. |
| U, then Enter | Preview legacy Codex entries in User PATH. A separate confirmation appears before any change. |
| Q, then Enter | Quit without changes. |

4. Read the output. Press Enter to close the window.

The BAT is standalone and contains the same readable PowerShell source as the separate [PS1 file](./Fix-ChatGPT-Computer-Use-PATH.ps1). It does not download scripts at runtime. Windows PowerShell 5.1 is used by the launcher. Organization-managed application controls may block it; do not disable protections to run it.

## New users seeing `program not found`

Start with diagnostics. The tool reports command discovery **in its own terminal**, matching User PATH entries, and existing executables under the historical `%LOCALAPPDATA%\OpenAI\Codex\bin` layout. Other installation layouts are not assessed.

It cannot establish which executable your ChatGPT app needs from a filename, modification date, or `--version` result. It therefore **does not choose a version or add a version folder to PATH**.

Save your work, fully exit ChatGPT, reopen it, and check for an official app update. If the error persists, follow official app repair/support guidance for your installation. No automatic repair for this launch error is provided in v2. Removing PATH entries can also make software that relies on them stop finding Codex by name.

## Used an earlier version of this tool?

Earlier releases permanently placed a selected Codex installation folder in User PATH. That could influence executable lookup after app updates. In the author's reported case, repeated approval prompts stopped after removing these entries and restarting. **The internal cause and general applicability have not been established.** Recovery is not a guaranteed fix for approval prompts or launch errors.

Choose **U** to preview removal of entries matching exactly:

```text
%LOCALAPPDATA%\OpenAI\Codex\bin
%LOCALAPPDATA%\OpenAI\Codex\bin\<one-folder>
```

Matching is case-insensitive and handles quoted entries, environment-variable references, and trailing backslashes. Deeper descendants and other accounts' paths are preserved. PATH alone cannot prove who added an entry: continue only if you used the old tool or deliberately want the listed entries removed. Entries are matched even if the folder no longer exists.

After confirmation, recovery:

- Saves a unique JSON backup in your Windows user folder **before writing**.
- Preserves unrelated entries, their order, empty entries, raw environment-variable references, and the registry value type.
- Checks for a changed User PATH before writing and stops if it detects one. This is a check, not a registry transaction; avoid concurrent environment edits.
- Removes only the previewed entries from **User PATH**, then reads the value back to verify it.
- Reports failures, including denied writes, without claiming successful recovery.

It does not delete Codex files, modify Machine PATH, or change permissions, approval rules, execution policy, antivirus settings, or app configuration. It does not stop apps or restart Windows.

After successful recovery, save your work, fully exit ChatGPT, **sign out of Windows and sign back in** so apps receive the refreshed environment. Retry Computer Use and check the approval behavior. A green recovery message verifies PATH storage, not end-to-end app behavior.

## Backups and manual recovery

The tool prints the exact backup path:

```text
%USERPROFILE%\codex-path-recovery-YYYYMMDD-HHMMSS-<unique-id>.json
```

The JSON records `Before`, `After`, `Removed`, and `RegistryKind`. Keep it locally; it may contain personal folder names. To undo this recovery, review `Before` and restore the intended entries under **Environment Variables > User variables > Path**. Do not replace Machine PATH or blindly overwrite environment changes made since the backup. Earlier `codex-path-backup-*.txt` files remain untouched; v2 does not automatically restore them because they may contain outdated unrelated settings.

## Source and tests

- [Standalone BAT](./Fix-ChatGPT-Computer-Use-PATH.bat)
- [PowerShell source](./Fix-ChatGPT-Computer-Use-PATH.ps1)
- [Isolated recovery tests](./tests/Test-Recovery.ps1)

The v2 test suite passed **20 isolated cases on Windows PowerShell 5.1**, including raw entry preservation, multiple legacy entries, quoted/Unicode paths, other account paths, repeated recovery, WhatIf, concurrent edits, backup failure, denied writes, and BAT/source equality. Registry write and backup operations in the recovery tests are mocked in memory. A separate real BAT launch checks the default diagnostic path without changing User PATH.

These checks validate the utility, not every Windows installation, future app update, or end-to-end ChatGPT approval behavior. Previous version test results do not certify v2.

For developers, dot-source the PS1 to load functions without opening the menu. `Undo-LegacyPath -WhatIf` previews recovery without writing; `Undo-LegacyPath` prompts before writing. Direct PS1 execution depends on your existing execution policy; the BAT is the intended launch file and does not change saved execution-policy settings.

## Video correction

The video demonstrates launching a BAT file. Download the **current** version and follow this README and its on-screen menu: older footage showing automatic PATH updates or an administrator launch no longer describes the current behavior. Diagnostics is now the default; legacy recovery is optional.

## Author and contact

- **Malek Alahmer**
- Website: https://goldcatalyst-ea.com/
- Email: support@goldcatalyst-ea.com
- WhatsApp: https://wa.me/971555229072

Copyright (c) 2026 Malek Alahmer.
