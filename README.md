PSReadLineOverride
==================
Author  : 8192Bits  
Date    : 19/03/2026  

This project patches PSReadLine2.4.5 DLL's to support persistent custom cursor shapes
in Windows PowerShell 5.1 and PowerShell 7+ running in conhost (legacy console).

By default, conhost resets the cursor shape after every command and PSReadLine
does not re-emit the ANSI cursor sequence after each render. This patch fixes
that by modifying the ReallyRender() method in the PSReadLine DLL directly.

![demo](assets/Demo.PSReadLine2.4.5.gif)

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
---
INSTALLATION
------------

STEP 1 - Enable Virtual Terminal (VT) in the registry
------------------------------------------------------

Run the .reg file from the registry/ folder :

    console_PSVT.reg

If you prefer to run it manually from Administrator PowerShell or cmd :

    reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f


STEP 2 - Install PSReadLine 2.4.5
----------------------------------

Open PowerShell and run :

    Install-Module PSReadLine -RequiredVersion 2.4.5 -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser
If the Nuget provider is required, accept with y
    
Or else extract the Modules folder on PSReadLineOverride\PSReadLine-2.4.5\Modules  
into C:\Users\<YourName>\Documents\WindowsPowerShell\  
(create the folder WindowsPowerShell if not exist.)

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
    
(Replace the original or archive it)

In PowerShell type 

    Unblock-File "$HOME\Documents\WindowsPowerShell\Modules\PSReadLine\2.4.5\Microsoft.PowerShell.PSReadLine.dll"
    
(to allow the execution of the dll)



FOR POWERSHELL 7 :

Same step and Same DLL, paste it into :

    C:\Users\<YourName>\Documents\PowerShell\Modules\PSReadLine\2.4.5\
    
Note : Make sure PSReadLine 2.4.5 is installed (Step 2) before copying.


STEP 4 - Set up your PowerShell profile
---------------------------------------

FOR POWERSHELL 5.1 :  

Allow the execution of .ps1 script  

    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

(type A for Yes to ALL)
    
Test if you have $PROFILE
        
    Test-Path $PROFILE

If return false type

    New-Item -Type File -Path $PROFILE -Force
    
Open your profile :
    
    notepad $PROFILE

Copy the content from:

    PSReadLineOverride/profile/51/Microsoft.PowerShell_profile.ps1

or replace juste the file



FOR POWERSHELL 7 :

Same step
Copy the content from :
    
    PSReadLineOverride/profile/7x/Microsoft.PowerShell_profile.ps1


STEP 5 - Cursor setting
--------------------------------------------

Close all open PowerShell windows and open a new one.
    
In the Properties of your PowerShell shortcut (right-click title bar -> Properties)
go to Options tab and set the cursor shape to match your chosen DLL.

Now your cursor shape is permanent; if you wish to change it, go to the step 3 and replace the .dll only.

---

RESTORING THE ORIGINAL DLL
---------------------------

If something goes wrong, restore the original DLL :

    1. Copy dll/Microsoft.PowerShell.PSReadLine.dll - main
    2. Rename it to Microsoft.PowerShell.PSReadLine.dll
    3. Paste it back into your PSReadLine 2.4.5 folder

Or reinstall PSReadLine completely :

    Install-Module PSReadLine -RequiredVersion 2.4.5 -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser


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

LICENSE
-------
MIT License - feel free to use, modify and distribute.
