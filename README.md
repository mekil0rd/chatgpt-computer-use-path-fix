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

1. Download the ZIP above and **extract it**. Run the extracted file, not the file inside the ZIP preview.
2. **Fully exit ChatGPT Desktop before running the fix.** Use **Exit/Quit** from its menu or system-tray icon when available. Closing the window with **X** may leave it running.
3. Open **Task Manager** with **Ctrl + Shift + Esc**. If **ChatGPT** is still running, select its app/process group and choose **End task**. Confirm its app processes have stopped.
4. Right-click **`Fix-ChatGPT-Computer-Use-PATH.ps1`** and choose **Run with PowerShell**. On Windows 11, use **Show more options** if needed to find the command.
5. A green welcome screen shows **Malek Alahmer**, the project name, and contact details. Read it, then press any key at **`Press any key to continue...`** to start.
6. Read the result. The window stays open at **`Press any key to exit...`** so you can inspect the output before closing it. This final pause also appears if the script reports an error.
7. Press any key to finish. Open ChatGPT Desktop again, select **Work → On my computer**, and retry Computer Use.
8. If the app still uses the old environment, save your work, sign out of Windows and sign back in, then reopen ChatGPT and retry.

Administrator privileges are not needed. In hosts without single-key input, the script falls back to an Enter prompt.

### If Windows blocks the script

The right-click command is subject to your computer's PowerShell execution policy. If Windows prevents the script from starting, the welcome screen and pauses cannot run. Read the Windows/PowerShell message; on a managed computer, ask the administrator. The script does not change execution policy. See [Microsoft's Run with PowerShell documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_run_with_powershell).

## Expected output

The welcome banner is green, the prompts are yellow, and status lines use green or cyan. After the welcome screen, a successful PATH update produces output similar to this:

```text
Press any key to continue...

Checking your Codex installation...
Codex executable: C:\Users\<WindowsUser>\AppData\Local\OpenAI\Codex\bin\<CodexFolder>\codex.exe
User PATH: UPDATED (backup: C:\Users\<WindowsUser>\codex-path-backup-YYYYMMDD-HHMMSS.txt)
Found via PATH in this terminal: True
Codex version: codex-cli 0.164.0-alpha.11.1
NEXT: Open ChatGPT again, select Work > On my computer, and retry Computer Use.
If still broken, sign out of Windows and sign back in, then retry.

Press any key to exit...
```

The username, folder, backup timestamp, and version are examples; they will differ between computers and app versions.

- **`User PATH: UPDATED`** means the script saved a backup and wrote the updated User PATH.
- **`Found via PATH in this terminal: True`** means PowerShell can find the Codex command in the current terminal.
- **`Codex version:`** shows the version returned by the selected executable.
- If PATH is already set, **`User PATH: already correctly configured.`** appears instead of the update/backup line. This is a valid result and does not create a new backup.
- If **`FAILED:`** appears, read the error; do not treat that run as a successful fix.

These messages confirm the script's checks. The final confirmation is that Computer Use works after reopening ChatGPT in **Work → On my computer**.

## What it does

- Finds an existing local `codex.exe`, preferring the binary currently running app-server when process inspection is available, otherwise checking installed files.
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

1. نزّل الملف المضغوط من **Download the project as ZIP** و**فك الضغط أولًا**. شغّل الملف المستخرج، وليس الملف داخل معاينة ZIP.
2. **أغلق ChatGPT Desktop بالكامل باستخدام Exit أو Quit قبل تشغيل السكربت** من قائمة البرنامج أو أيقونته بجانب الساعة إن كان الخيار متاحًا. إغلاق النافذة بعلامة **X** وحده قد يتركه يعمل بالخلفية.
3. افتح **Task Manager — مدير المهام** بالضغط على **Ctrl + Shift + Esc**. إذا بقي **ChatGPT** يعمل، حدّد مجموعة عمليات التطبيق واضغط **End task — إنهاء المهمة**. تأكد من توقف عملياته قبل المتابعة.
4. اضغط بالزر الأيمن على **`Fix-ChatGPT-Computer-Use-PATH.ps1`** واختر **Run with PowerShell**. في ويندوز 11 قد تحتاج إلى **Show more options — إظهار المزيد من الخيارات**.
5. ستظهر شاشة ترحيب خضراء باسم **Malek Alahmer** ومعلومات البرنامج والتواصل. اقرأها ثم اضغط أي زر عند **`Press any key to continue...`** لبدء الفحص والإصلاح.
6. اقرأ الناتج؛ ستبقى النافذة مفتوحة عند **`Press any key to exit...`** حتى تضغط أي زر للخروج. تظهر وقفة الخروج أيضًا إذا حدث خطأ.
7. افتح ChatGPT Desktop من جديد، واختر **Work → On my computer** ثم جرّب التحكم بالكمبيوتر.
8. إذا بقي التطبيق يستخدم البيئة القديمة، احفظ شغلك وسجّل الخروج من ويندوز ثم ادخل مجددًا وأعد المحاولة.

لا تحتاج إلى التشغيل كمسؤول. إذا كانت نافذة التشغيل لا تدعم ضغطة زر منفردة، سيطلب السكربت الضغط على Enter بدلًا منها.

### كيف تعرف نتيجة التشغيل؟

- ظهور **`User PATH: UPDATED`** يعني أن السكربت حفظ نسخة احتياطية وحدّث مسار المستخدم.
- ظهور **`Found via PATH in this terminal: True`** يعني أن PowerShell استطاع العثور على أمر Codex في النافذة الحالية.
- سطر **`Codex version:`** يعرض الإصدار الموجود على جهازك؛ الرقم في المثال توضيحي وقد يختلف.
- إذا ظهرت **`User PATH: already correctly configured.`** فالمسار مضبوط مسبقًا، وهذه نتيجة طبيعية ولا تُنشأ نسخة احتياطية جديدة في هذه الحالة.
- إذا ظهرت **`FAILED:`** فاقرأ الخطأ، ولا تعتبر المحاولة ناجحة. ستبقى النافذة مفتوحة حتى تضغط للخروج.

اسم المستخدم والمسار ورقم الإصدار وتاريخ النسخة الاحتياطية في المثال تختلف حسب الجهاز. هذه الرسائل تؤكد فحوص السكربت؛ والتأكد النهائي من حل المشكلة يكون بنجاح التحكم بالكمبيوتر بعد إعادة فتح ChatGPT في **Work → On my computer**.

إذا منع ويندوز تشغيل السكربت بسبب سياسة PowerShell، فلن يبدأ الكود ولن تظهر شاشة الترحيب. اقرأ رسالة النظام، وراجع مسؤول الجهاز إذا كان جهاز عمل مُدارًا. السكربت لا يغيّر سياسة تشغيل السكربتات.

يحفظ السكربت نسخة احتياطية من User PATH قبل تغييره. يعالج حالات PATH المناسبة، ولا يضمن حل جميع أسباب الخطأ. هذه مساهمة مستقلة وليست أداة رسمية من OpenAI.

## Author & contact

- **Malek Alahmer**
- Website: https://goldcatalyst-ea.com/
- Email: support@goldcatalyst-ea.com
- WhatsApp: https://wa.me/971555229072

Copyright © 2026 Malek Alahmer.
