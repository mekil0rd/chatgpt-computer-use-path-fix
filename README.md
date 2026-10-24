# ChatGPT Computer Use — Windows PATH Fix

**Created by Malek Alahmer · 2026**

A free Windows utility for PATH-related instances of:

```text
failed to launch codex app-server: program not found
```

**Recommended: extract the ZIP and double-click `Fix-ChatGPT-Computer-Use-PATH.bat`.**

This is an independent community contribution, not an official OpenAI tool. It does not fix every Computer Use or app-server issue.

## Download

**[Download ZIP](https://github.com/mekil0rd/chatgpt-computer-use-path-fix/archive/refs/heads/main.zip)**

- [Review the standalone BAT file](./Fix-ChatGPT-Computer-Use-PATH.bat)
- [Optional PowerShell source](./Fix-ChatGPT-Computer-Use-PATH.ps1)

The BAT contains its own readable PowerShell source. It does not need the separate PS1 file to run.

## How to use

1. Download the ZIP and **extract it** into a normal folder.
2. **Fully exit ChatGPT Desktop** using Exit/Quit from its menu or system-tray icon when available. Closing the window with X may leave the app running.
3. Press **Ctrl + Shift + Esc** to open Task Manager. If ChatGPT is still running, select its app/process group and choose **End task**. Confirm its app processes have stopped.
4. Double-click **`Fix-ChatGPT-Computer-Use-PATH.bat`** in the extracted folder. Review the source before running it.
5. A **green welcome screen** displays the project name, **Malek Alahmer**, and contact details.
6. At **`Press any key to continue...`**, press a key to start the checks.
7. Read the result. The window stays open at **`Press any key to exit...`**, including when the utility reports an error.
8. Press a key to finish, reopen ChatGPT Desktop, and select **Work → On my computer** to retry Computer Use.
9. If the app still uses the old environment, save your work, sign out of Windows, and sign back in before retrying.

No Administrator privileges are needed. In hosts without single-key input, the utility falls back to an Enter prompt.

## Expected output

After the green welcome banner, a successful update looks similar to:

```text
Press any key to continue...

Checking your Codex installation...
Codex executable: C:\Users\<WindowsUser>\AppData\Local\OpenAI\Codex\bin\<CodexFolder>\codex.exe
User PATH: UPDATED (backup: C:\Users\<WindowsUser>\codex-path-backup-YYYYMMDD-HHMMSS-mmm-<unique-id>.txt)
Found via PATH in this terminal: True
Saved User PATH: VERIFIED
Codex version: codex-cli 0.164.0-alpha.11.1
NEXT: Open ChatGPT again, select Work > On my computer, and retry Computer Use.
If still broken, sign out of Windows and sign back in, then retry.

Press any key to exit...
```

Usernames, paths, timestamps, and version numbers vary by computer.

| Message | Meaning |
| --- | --- |
| `User PATH: UPDATED` | The previous User PATH was backed up and the updated value was saved. |
| `User PATH: already correctly configured.` | The selected folder is already configured; no new backup is needed. |
| `Found via PATH in this terminal: True` | Codex can be found in the current terminal. |
| `Saved User PATH: VERIFIED` | The stored User PATH matches the intended value. |
| `Codex version:` | The selected executable returned a recognized version. |
| `FAILED:` | Read the error; do not treat the run as a successful fix. |

The final confirmation is that Computer Use works after reopening ChatGPT.

## Requirements

- Windows with the built-in **Windows PowerShell 5.1**.
- An existing desktop app installation using one of the supported paths listed below.
- Permission to run a batch file and PowerShell commands on the computer. Organization-managed application controls can still prevent execution.

## Supported installation paths

The utility uses each Windows account's own `LOCALAPPDATA`, `USERPROFILE`, and `SystemRoot` values. No username or Windows drive is hard-coded.

It checks these layouts:

```text
%LOCALAPPDATA%\OpenAI\Codex\bin\<version-folder>\codex.exe
%LOCALAPPDATA%\OpenAI\Codex\bin\codex.exe
```

When available, the running app-server's executable is tried first. Other candidates are tried by file modification time, newest first. An unusable candidate is skipped; each version check has a 10-second limit. If no usable executable is found, the utility stops before changing User PATH. Different installation layouts require separate investigation.

## What the utility does

- Finds and tests existing Codex executables in the supported locations, with fallback between candidates.
- Checks its exit code and version; native warning messages alone do not fail a valid version check.
- Backs up User PATH before changing it.
- Replaces old per-version Codex folder entries with the selected folder, preserving unrelated entries.
- Reads the saved User PATH back to verify it, and verifies that command discovery selects the chosen executable.
- On a post-write verification failure, restores the previous User PATH if its value still matches the utility's update. If another process changed it, automatic restoration is skipped to avoid overwriting that change.

It does not download or install software, modify Machine PATH, or request Administrator privileges.

## Why the BAT version is recommended

Direct **Run with PowerShell** on a PS1 file can be blocked before the script starts. Its own welcome screen and pauses cannot display when PowerShell refuses to load the file.

The BAT starts the built-in Windows PowerShell and invokes its readable embedded source as commands. It does not change saved execution-policy settings, use an ExecutionPolicy Bypass argument, or remove download security marks.

The separate PS1 file is available as source for users whose environment allows direct script execution. Do not use it as the default launch file.

## File names and language

All program messages and file names are in English. File Explorer's **Type** label is generated by Windows and its installed language resources. A translated Type label does not mean the file contents are Arabic. This package does not change Windows language or file associations.

## Backup and recovery

When User PATH changes, the old value is saved in your Windows user folder as:

```text
codex-path-backup-YYYYMMDD-HHMMSS.txt
```

The utility prints the exact backup location. To undo the change, restore the backup's exact contents to **Path** under **Environment Variables → User variables**, then sign out of Windows and sign back in. Do not replace Machine PATH.

## Limits

A missing or unsupported Codex installation must be resolved separately. The utility refuses ambiguous semicolon-containing installation paths and overly long User PATH values before writing. A successful version check does not guarantee all Computer Use features work. Future app updates can change the executable location and require checking PATH again.

## Validation

The reviewed version passed 16 isolated scenarios covering missing installations, special-character and Arabic paths, exact preservation of unrelated PATH entries, backups, repeated runs, multiple versions, failed version checks, timeouts, denied writes, and rollback after verification failure. Two additional checks covered the full BAT launcher from a special-character path and the version check against the installed real Codex binary.

These are controlled tests on Windows PowerShell 5.1, not certification across every Windows computer or future app release. No test modified the user's real saved PATH. Confirm Computer Use after restarting the desktop app.

## Author & contact

- **Malek Alahmer**
- Website: https://goldcatalyst-ea.com/
- Email: support@goldcatalyst-ea.com
- WhatsApp: https://wa.me/971555229072

Copyright © 2026 Malek Alahmer.
