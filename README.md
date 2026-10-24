# ChatGPT Computer Use — Windows PATH Fix

**Created by Malek Alahmer · 2026**

A free community PowerShell helper for this Windows launch error:

```text
failed to launch codex app-server: program not found
```

This is an independent contribution, not an official OpenAI tool. It targets PATH-related failures; it does not fix every Computer Use or app-server issue.

## Download

**[Download the project as ZIP](https://github.com/mekil0rd/chatgpt-computer-use-path-fix/archive/refs/heads/main.zip)**

- [View and review the PowerShell script](./Fix-ChatGPT-Computer-Use-PATH.ps1)
- [Open the raw script](https://raw.githubusercontent.com/mekil0rd/chatgpt-computer-use-path-fix/main/Fix-ChatGPT-Computer-Use-PATH.ps1)

## Requirements

- Windows with Windows PowerShell 5.1 or PowerShell 7.
- An existing desktop app installation with its local Codex binary under `%LOCALAPPDATA%\OpenAI\Codex\bin`.
- A normal Windows user account; Administrator access is not needed.

## How to use

1. Download the ZIP above and extract it.
2. Open `Fix-ChatGPT-Computer-Use-PATH.ps1` in Notepad and review the code.
3. Open **Windows PowerShell** normally, without Administrator privileges.
4. Copy the complete script from Notepad and paste it into PowerShell. Press Enter if needed.
5. Read the result. If it reports that PATH was updated or is already configured, fully quit ChatGPT and reopen it, then retry Computer Use.
6. If the app still uses the old environment, sign out of Windows and sign back in before retrying.

The copy-and-paste method avoids changing PowerShell execution policy to run a downloaded file.

## What it does

- Finds an existing local `codex.exe`, preferring the binary currently running app-server.
- Checks that the selected executable responds to `--version`.
- Saves a backup of User PATH before changing it.
- Removes old per-version Codex folder entries from User PATH and puts the selected folder first.
- Preserves unrelated User PATH entries.
- Updates the current terminal's PATH for verification.

It does not install or download software, request Administrator privileges, change Machine PATH, or modify execution policy.

## Backup and recovery

When User PATH is changed, its previous value is saved in your Windows user folder as:

```text
codex-path-backup-YYYYMMDD-HHMMSS.txt
```

The backup location is printed in the terminal. Keep the backup. To undo the change, restore its exact contents to the **Path** value under **Environment Variables → User variables**, then sign out of Windows and sign back in. Do not replace Machine PATH.

## Limits

If the Codex folder or executable is missing, this script reports an error instead of installing anything. A successful version check confirms that the chosen binary responds; it does not guarantee that all Computer Use features work. A later app update can change the binary location and require checking PATH again.

## الشرح بالعربي

أداة مجانية لمعالجة حالات خطأ التشغيل المذكور أعلاه عندما تكون المشكلة مرتبطة بمسار **PATH** في ويندوز.

1. نزّل الملف المضغوط من **Download the project as ZIP** وفك الضغط.
2. افتح ملف السكربت بالمفكرة وراجع محتواه.
3. افتح **Windows PowerShell** بشكل عادي، بدون تشغيل كمسؤول.
4. انسخ الكود كاملًا من المفكرة والصقه في PowerShell.
5. اقرأ النتيجة، ثم أغلق ChatGPT بالكامل وافتحه مجددًا وجرّب التحكم بالكمبيوتر.
6. إذا استمرت المشكلة، سجّل الخروج من ويندوز ثم ادخل مجددًا.

يحفظ السكربت نسخة احتياطية من User PATH قبل تغييره. يعالج حالات PATH المناسبة، ولا يضمن حل جميع أسباب الخطأ. هذه مساهمة مستقلة وليست أداة رسمية من OpenAI.

## Author & contact

- **Malek Alahmer**
- Website: https://goldcatalyst-ea.com/
- Email: support@goldcatalyst-ea.com
- WhatsApp: https://wa.me/971555229072

Copyright © 2026 Malek Alahmer.
