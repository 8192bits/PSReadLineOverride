PSReadLineOverride
==================
Author  : 8192Bits  
Date    : 19/03/2026  

This project patches PSReadLine2.4.5 DLL's to support persistent custom cursor shapes
in Windows PowerShell 5.1 and PowerShell 7+ running in conhost (legacy console).

By default, conhost resets the cursor shape after every command and PSReadLine
does not re-emit the ANSI cursor sequence after each render. This patch fixes
that by modifying the ReallyRender() method in the PSReadLine DLL directly.

---

CURSOR SHAPES AVAILABLE
-----------------------
The dll/ folder contains one patched DLL per cursor shape :

    - main              Original unpatched DLL (backup)
    - SolidBox          Block cursor, steady
    - SolidBoxBlink     Block cursor, blinking
    - Underscore        Underscore cursor, steady
    - UnderscoreBlink   Underscore cursor, blinking
    - VerticalBar       Bar cursor, steady
    - VerticalBarBlink  Bar cursor, blinking (recommended)


REQUIREMENTS
------------
    - Windows PowerShell 5.1 or PowerShell 7+
    - conhost (legacy console)
    - PSReadLine 2.4.5

---
INSTALLATION
------------

STEP 1 - Enable Virtual Terminal (VT) in the registry
------------------------------------------------------

Run the appropriate .reg file from the registry/ folder :

    x64_PSVT.reg    for 64-bit Windows  (most common)
    x86_PSVT.reg    for 32-bit Windows

Double-click the file and confirm when prompted.
Then CLOSE and REOPEN your PowerShell window completely.

If you prefer to run it manually from PowerShell :

    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f
    reg add "HKCU\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f
    reg add "HKCU\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f



STEP 2 - Install PSReadLine 2.4.5
----------------------------------

Open PowerShell and run :

    Install-Module PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser

Verify the installation :

    Get-Module PSReadLine -ListAvailable | Select-Object Version, Path

You should see version 2.4.5 in your user modules folder.



STEP 3 - Copy the patched DLL
------------------------------

Choose your cursor shape from the dll/ folder and copy it.

FOR POWERSHELL 5.1 :

    Copy the chosen DLL and rename it to :
    Microsoft.PowerShell.PSReadLine.dll

    Paste it into :
    C:\Users\<YourName>\Documents\WindowsPowerShell\Modules\PSReadLine\2.4.5\

FOR POWERSHELL 7 :

    Same DLL, paste it into :
    C:\Users\<YourName>\Documents\PowerShell\Modules\PSReadLine\2.4.5\

    Note : Make sure PSReadLine 2.4.5 is installed (Step 2) before copying.



STEP 4 - Set up your PowerShell profile
---------------------------------------

FOR POWERSHELL 5.1 :

    Test if you have $PROFILE
        Test-Path $PROFILE

    If return false type
        New-Item -Type File -Path $PROFILE -Force
    
    Open your profile :
        notepad $PROFILE

    Copy the content from:
        profile/51/Microsoft.PowerShell_profile.ps1

    --
    At the beginning of the $PROFILE file, there is a command that runs:
    
    Clear-Host 
    Write-Host "Windows PowerShell"
    Write-Host "Copyright (C) Microsoft Corporation. All rights reserved."
    Write-Host ""

    This removes the "Try the new cross-platform PowerShell" message.
    (when you launch Powershell you can see 200ms lag but is nothing you can delete the 4 lines if you want)

FOR POWERSHELL 7 :

    Test if you have $PROFILE
        Test-Path $PROFILE

    if return false type
        New-Item -Type File -Path $PROFILE -Force
        
    Open your profile :
        notepad $PROFILE

    Copy the content from :
        profile/7x/Microsoft.PowerShell_profile.ps1

    Note : The Import-Module line is required to force PSReadLine 2.4.5 (patched)
           instead of the default 2.3.6 bundled with PowerShell 7.
           Make sure the path matches your actual install location.



STEP 5 - Recommended conhost cursor setting
--------------------------------------------

    In the Properties of your PowerShell shortcut (right-click title bar -> Properties)
    go to Options tab and set the cursor shape to match your chosen DLL.

    This avoids any visual conflict between the Win32 cursor and the ANSI cursor.

---

VERIFICATION
------------

After restarting PowerShell, you should have :

    Cursor shape    Persistent custom cursor that stays after every command
    Colors          Syntax highlighting with custom colors
    Autocomplete    Tab completion working normally
    Ctrl+R          History search working normally
    InlinePrediction Inline gray suggestions while typing


RESTORING THE ORIGINAL DLL
---------------------------

If something goes wrong, restore the original DLL :

    1. Copy dll/Microsoft.PowerShell.PSReadLine.dll - main
    2. Rename it to Microsoft.PowerShell.PSReadLine.dll
    3. Paste it back into your PSReadLine 2.4.5 folder

Or reinstall PSReadLine completely :

    Install-Module PSReadLine -Force -SkipPublisherCheck -Scope CurrentUser


HOW THE PATCH WORKS
--------------------

The patch adds 4 IL instructions at the end of the ReallyRender() method,
right after the line that sets CursorVisible = true :

    ldarg.0
    ldfld     class ...IConsole ...PSConsoleReadLine::_console
    ldstr     "\x1b[5 q"    (or the appropriate ANSI sequence)
    callvirt  instance void ...IConsole::Write(string)

This forces PSReadLine to re-emit the ANSI cursor sequence after every
render cycle, overriding the legacy Win32 cursor reset.


TECHNICAL BACKGROUND
--------------------

Why does this happen in conhost but not Windows Terminal ?

    Windows Terminal activates VT processing by default.
    PSReadLine detects VT and uses VirtualTerminal mode which re-emits
    ANSI sequences correctly on every render.

    conhost has VT disabled by default.
    PSReadLine falls back to LegacyWin32Console mode which filters out
    ANSI sequences and uses Win32 Console.CursorSize API instead.
    This API gets reset by Windows after every command execution.

Why not just use Set-PSReadLineOption -CursorShape ?

    This option does not exist in the official PSReadLine release.
    It would require recompiling PSReadLine from source with additional
    code changes across 3 files (Cmdlets.cs, Options.cs, Render.cs).
    The DLL patch is simpler, portable, and does not require a build chain,
    and I don't have time for that.


LICENSE
-------
MIT License - feel free to use, modify and distribute.
