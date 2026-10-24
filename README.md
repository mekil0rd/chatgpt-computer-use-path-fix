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
3. **Before running the script, fully exit ChatGPT Desktop.** Use **Exit/Quit** from its menu or system-tray icon when available. Closing the window with **X** may leave the app running in the background.
4. Open **Task Manager** with **Ctrl + Shift + Esc**. Check the Processes tab for **ChatGPT**. If it is still running, select its app/process group and choose **End task**. Confirm that the ChatGPT app processes have stopped before continuing.
5. Open **Windows PowerShell** normally, without Administrator privileges.
6. Copy the complete script from Notepad and paste it into PowerShell. Press Enter if needed.
7. Read the result and compare it with **Expected output** below.
8. Open ChatGPT Desktop again, select **Work → On my computer**, and retry Computer Use.
9. If the app still uses the old environment, save your work, sign out of Windows and sign back in, then reopen ChatGPT and retry.

The copy-and-paste method avoids changing PowerShell execution policy to run a downloaded file.

## Expected output

After the introductory banner, a successful PATH update produces output similar to this:

```text
Codex executable: C:\Users\<WindowsUser>\AppData\Local\OpenAI\Codex\bin\<CodexFolder>\codex.exe
User PATH: UPDATED (backup: C:\Users\<WindowsUser>\codex-path-backup-YYYYMMDD-HHMMSS.txt)
Found via PATH in this terminal: True
Codex version: codex-cli 0.164.0-alpha.11.1
NEXT: Fully quit ChatGPT, reopen it, select Work > On my computer, and retry Computer Use.
If still broken, sign out of Windows and sign back in, then retry.
```

The username, folder, backup timestamp, and version are examples; they will differ between computers and app versions.

- **`User PATH: UPDATED`** means the script saved a backup and wrote the updated User PATH.
- **`Found via PATH in this terminal: True`** means PowerShell can find the Codex command in the current terminal.
- **`Codex version:`** shows the version returned by the selected executable.
- If PATH is already set, **`User PATH: already correctly configured.`** appears instead of the update/backup line. This is a valid result and does not create a new backup.
- If **`FAILED:`** appears, read the error; do not treat that run as a successful fix.

These messages confirm the script's checks. The final confirmation is that Computer Use works after reopening ChatGPT in **Work → On my computer**.

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
3. **قبل تشغيل السكربت، أغلق ChatGPT Desktop بالكامل باستخدام Exit أو Quit** من قائمة البرنامج أو أيقونته بجانب الساعة إن كان الخيار متاحًا. إغلاق النافذة بعلامة **X** وحده قد يترك البرنامج يعمل بالخلفية.
4. افتح **Task Manager — مدير المهام** بالضغط على **Ctrl + Shift + Esc**. ابحث عن **ChatGPT** في تبويب العمليات. إذا بقي يعمل، حدّد مجموعة عمليات التطبيق واضغط **End task — إنهاء المهمة**. تأكد من توقف عمليات ChatGPT قبل المتابعة.
5. افتح **Windows PowerShell** بشكل عادي، بدون تشغيل كمسؤول.
6. انسخ الكود كاملًا من المفكرة والصقه في PowerShell، واضغط Enter عند الحاجة.
7. راجع الناتج الموضح في قسم **Expected output** أعلاه، واقرأ تفسير الرسائل أدناه.
8. افتح ChatGPT Desktop من جديد، واختر **Work → On my computer** ثم جرّب التحكم بالكمبيوتر.
9. إذا استمرت المشكلة بسبب بقاء البيئة القديمة، احفظ شغلك وسجّل الخروج من ويندوز ثم ادخل مجددًا، وافتح ChatGPT وجرّب مرة أخرى.

### كيف تعرف نتيجة التشغيل؟

- ظهور **`User PATH: UPDATED`** يعني أن السكربت حفظ نسخة احتياطية وحدّث مسار المستخدم.
- ظهور **`Found via PATH in this terminal: True`** يعني أن PowerShell استطاع العثور على أمر Codex في النافذة الحالية.
- سطر **`Codex version:`** يعرض الإصدار الموجود على جهازك؛ الرقم في المثال توضيحي وقد يختلف.
- إذا ظهرت **`User PATH: already correctly configured.`** فالمسار مضبوط مسبقًا، وهذه نتيجة طبيعية ولا تُنشأ نسخة احتياطية جديدة في هذه الحالة.
- إذا ظهرت **`FAILED:`** فاقرأ الخطأ، ولا تعتبر المحاولة ناجحة.

اسم المستخدم والمسار ورقم الإصدار وتاريخ النسخة الاحتياطية في المثال تختلف حسب الجهاز. هذه الرسائل تؤكد فحوص السكربت؛ والتأكد النهائي من حل المشكلة يكون بنجاح التحكم بالكمبيوتر بعد إعادة فتح ChatGPT في **Work → On my computer**.

يحفظ السكربت نسخة احتياطية من User PATH قبل تغييره. يعالج حالات PATH المناسبة، ولا يضمن حل جميع أسباب الخطأ. هذه مساهمة مستقلة وليست أداة رسمية من OpenAI.

## Author & contact

- **Malek Alahmer**
- Website: https://goldcatalyst-ea.com/
- Email: support@goldcatalyst-ea.com
- WhatsApp: https://wa.me/971555229072

Copyright © 2026 Malek Alahmer.
