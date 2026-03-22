CursorShape
==================
This project patches PSReadLine 2.0.0 and 2.4.5 DLL's to support persistent custom cursor shapes
in Windows PowerShell 5.1 and PowerShell 7.x running in conhost (legacy console).

This tutorial is made for those who don't want to use Windows Terminal.

By default, conhost resets the cursor shape after every command and PSReadLine
does not re-emit the ANSI cursor sequence after each render. This patch fixes
that by modifying the ReallyRender() method in the PSReadLine DLL directly.

![demo](assets/Demo.PSReadLine2.4.5.gif)

CURSOR SHAPES AVAILABLE
-----------------------
The dll.x.x.x/ folder contains one patched DLL per cursor shape :

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

Choose which version of PSReadLine
---
Windows 10 comes with PSReadLine2.0.0; if you choose this option, go to PSReadLine 2.0.0 step   

You can also update it to PSReadline 2.4.5; if you choose this option, go to PSReadLine 2.4.5 step  

Note: Powershell 7.x work only with 2.4.5, it does not come with 2.0.0 by default.

Open a single administrator PowerShell window and keep it open through all steps until the Cursor setting step.

---
PSReadLine 2.0.0  
STEP 1 - Copy the patched DLL
------------------------------
Open a PowerShell in administrator.  

Choose your cursor shape from the dll2.0.0/ folder and copy it.  

Copy the chosen DLL and rename it to :

    Microsoft.PowerShell.PSReadLine.dll
 
Paste it into :

    C:\Program Files\WindowsPowerShell\Modules\PSReadline\2.0.0
    
Note: Rename the original to Microsoft.PowerShell.PSReadLine.main.dll before.

In PowerShell type 

    Unblock-File "C:\Program Files\WindowsPowerShell\Modules\PSReadline\2.0.0\Microsoft.PowerShell.PSReadLine.dll"
    
Note: To allow the execution of the dll.

STEP 2 - Cursor setting
--------------------------------------------
Close the open PowerShell windows and open a new one.
    
In the Properties of your PowerShell shortcut (right-click title bar -> Properties)
go to Options tab and set the cursor shape to match your chosen DLL.

Now your cursor shape is permanent; if you wish to change it, go to the step 1 and replace the .dll only.


---
PSReadLine  2.4.5  
STEP 1 - Install PSReadLine 2.4.5
----------------------------------
Open a PowerShell in administrator.  

Run :

    Install-Module PSReadLine -RequiredVersion 2.4.5 -Force -SkipPublisherCheck -AllowClobber -Scope CurrentUser
Note: If the Nuget provider is required, accept with y.
    
Or extract psreadline.2.4.5.zip, run :  
    
    Expand-Archive "psreadline.2.4.5.zip" -DestinationPath "$HOME\Documents\WindowsPowerShell\Modules\PSReadLine\2.4.5" -Force

Verify the installation :

    Get-Module PSReadLine -ListAvailable | Select-Object Version, Path

You should see version 2.4.5 in your user modules folder.


STEP 2 - Copy the patched DLL
------------------------------
Choose your cursor shape from the dll2.4.5/ folder and copy it.

FOR POWERSHELL 5.1 :

Copy the chosen DLL and rename it to :

    Microsoft.PowerShell.PSReadLine.dll
 
Paste it into :

    C:\Users\<YourName>\Documents\WindowsPowerShell\Modules\PSReadLine\2.4.5\
    
Note: Rename the original to Microsoft.PowerShell.PSReadLine.main.dll before.

In PowerShell type 

    Unblock-File "$HOME\Documents\WindowsPowerShell\Modules\PSReadLine\2.4.5\Microsoft.PowerShell.PSReadLine.dll"
    
Note: To allow the execution of the dll.


FOR POWERSHELL 7 :

Same step and Same DLL, paste it into :

    C:\Users\<YourName>\Documents\PowerShell\Modules\PSReadLine\2.4.5\
    
Note : Make sure PSReadLine 2.4.5 is installed (Step 1) before copying.


STEP 3 - Set up your PowerShell profile
----------------------------------------
FOR POWERSHELL 5.1 :  

Allow the execution of .ps1 script  

    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

Note: Type A for Yes to ALL.
    
Test if you have $PROFILE
        
    Test-Path $PROFILE

If return false type

    New-Item -Type File -Path $PROFILE -Force
    
Open your profile :
    
    notepad $PROFILE

Copy this line and save :

    Import-Module "$HOME\Documents\WindowsPowerShell\Modules\PSReadLine\2.4.5\PSReadLine.psd1" -Force


FOR POWERSHELL 7 :

Same step
Copy this line and save :
    
    Import-Module "$HOME\Documents\PowerShell\Modules\PSReadLine\2.4.5\PSReadLine.psd1" -Force


STEP 4 - Cursor setting
--------------------------------------------
Close the open PowerShell windows and open a new one.
    
In the Properties of your PowerShell shortcut (right-click title bar -> Properties)
go to Options tab and set the cursor shape to match your chosen DLL.

Now your cursor shape is permanent; if you wish to change it, go to the step 2 and replace the .dll only.

---

RESTORING THE ORIGINAL DLL
---------------------------

If something goes wrong, restore the original DLL :

    1. Copy dll/Microsoft.PowerShell.PSReadLine.dll - main
    2. Rename it to Microsoft.PowerShell.PSReadLine.dll
    3. Paste it back into your PSReadLine folder

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

LICENSE
-------
MIT License - feel free to use, modify and distribute.
