@ECHO OFF
ECHO This tool is only to be used on a host OS when using Server Essentials as host OS with a single VM as DC
ECHO silsvc causes shutdown of the server after a number of days if it doesn't become the DC, but as HOST it cannot be a DC
ECHO You must be a member of the local Administrators group to perform this task
ECHO This script must also be run as admin (i'll automate this in a later version)
ECHO Requires SUBINACL to be installed before running
ECHO Download here: https://web.archive.org/web/20190830103837/https://download.microsoft.com/download/1/7/d/17d82b72-bc6a-4dc8-bfaa-98b37b22b367/subinacl.msi
ECHO If any part fails, you can run it a second time to give it another chance to access the areas it needs to
ECHO Set subinaclpath variable
ECHO pwnsilsvc v2022.06.23.001
ECHO 2022.06.23.001 Added SBS 2003 removal and instead of failing looped back to try again fromt the start, more of a brute force, this needs finessing,
ECHO                the windows protection will try to restore the file after it's been deleted. Security subkey in registry remained as SYSTEM perm only preventing removal of SBCore
ECHO Created by Phil Ellis pellis@fullerinfotech.com
set "sia=C:\Program Files\Windows Resource Kits\Tools\subinacl.exe"
pause
ECHO Begin log file  > pwnlog.txt 2>&1
:START
ECHO Pwning sbscrexe.exe (sbs 2003)
ECHO Pwning sbscrexe.exe (sbs 2003) >> pwnlog.txt 2>&1
takeown /F C:\windows\system32\sbscrexe.exe  >> pwnlog.txt 2>&1
icacls c:\windows\system32\sbscrexe.exe /grant Administrators:F >> pwnlog.txt 2>&1
attrib -h -s C:\windows\system32\sbscrexe.exe >> pwnlog.txt 2>&1
del /q C:\windows\system32\sbscrexe.exe.backup >> pwnlog.txt 2>&1
ren C:\windows\system32\sbscrexe.exe sbscrexe.exe.backup >> pwnlog.txt 2>&1

ECHO Pwning silsvc.exe
ECHO Pwning silsvc.exe >> pwnlog.txt 2>&1
takeown /F C:\windows\system32\silsvc.exe  >> pwnlog.txt 2>&1
icacls c:\windows\system32\silsvc.exe /grant Administrators:F >> pwnlog.txt 2>&1
attrib -h -s C:\windows\system32\silsvc.exe >> pwnlog.txt 2>&1
del /q C:\windows\system32\silsvc.exe.backup >> pwnlog.txt 2>&1
ren C:\windows\system32\silsvc.exe silsvc.exe.backup >> pwnlog.txt 2>&1

ECHO Pwning silnotify.exe
ECHO Pwning silnotify.exe >> pwnlog.txt 2>&1
takeown /F C:\windows\system32\silnotify.exe >> pwnlog.txt 2>&1
icacls c:\windows\system32\silnotify.exe /grant Administrators:F >> pwnlog.txt 2>&1
attrib -h -s C:\windows\system32\silnotify.exe >> pwnlog.txt 2>&1
del /q C:\windows\system32\silnotify.exe.backup >> pwnlog.txt 2>&1
ren C:\windows\system32\silnotify.exe silnotify.exe.backup >> pwnlog.txt 2>&1

ECHO Killing sbscrexe.exe (sbs 2003)
ECHO Killing sbscrexe.exe (sbs 2003) >> pwnlog.txt 2>&1
taskkill -f -im sbscrexe.exe >> pwnlog.txt 2>&1
ECHO Killing silsvc.exe
ECHO Killing silsvc.exe >> pwnlog.txt 2>&1
taskkill -f -im silsvc.exe >> pwnlog.txt 2>&1
ECHO Killing silnotify.exe
ECHO Killing silnotify.exe >> pwnlog.txt 2>&1
taskkill -f -im silnotify.exe >> pwnlog.txt 2>&1
ECHO Pausing 10 seconds
ECHO Pausing 10 seconds >> pwnlog.txt 2>&1
PING localhost -n 10 >NUL

ECHO Modifying Service Entry in ControlSet001 and ControlSet002 (sbs 2003)
ECHO Modifying Service Entry in ControlSet001 and ControlSet002 (sbs 2003) >> pwnlog.txt 2>&1
"%sia%" /keyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SBCore" /setowner=administrators >> pwnlog.txt 2>&1
"%sia%" /keyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SBCore" /grant=administrators=f >> pwnlog.txt 2>&1
"%sia%" /keyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SBCore" /grant=SYSTEM=f >> pwnlog.txt 2>&1


ECHO Modifying Service Entry in ControlSet001 and ControlSet002
ECHO Modifying Service Entry in ControlSet001 and ControlSet002 >> pwnlog.txt 2>&1
"%sia%" /keyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\silsvc" /setowner=administrators >> pwnlog.txt 2>&1
"%sia%" /keyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\silsvc" /grant=administrators=f >> pwnlog.txt 2>&1
"%sia%" /keyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\silsvc" /grant=SYSTEM=f >> pwnlog.txt 2>&1

ECHO Set service to Disable
ECHO Set service to Disable >> pwnlog.txt 2>&1
SC CONFIG SBCore start= disabled >> pwnlog.txt 2>&1
SC CONFIG silsvc start= disabled >> pwnlog.txt 2>&1
ECHO Removing service
ECHO Removing service >> pwnlog.txt 2>&1
sc delete SBCore >> pwnlog.txt 2>&1
reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SBCore /f >> pwnlog.txt 2>&1
sc delete silsvc >> pwnlog.txt 2>&1
reg delete HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\silsvc /f >> pwnlog.txt 2>&1
ECHO Now we'll see if the items have been removed
ECHO Now we'll see if the items have been removed >> pwnlog.txt 2>&1
ECHO Pausing 2 seconds
ECHO Pausing 2 seconds >> pwnlog.txt 2>&1
PING localhost -n 2 >NUL
ECHO Registry Check
ECHO Registry Check >> pwnlog.txt 2>&1
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SBCore
if %ERRORLEVEL% NEQ 0 goto REGGONE
ECHO Registry Check
ECHO Registry Check >> pwnlog.txt 2>&1
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\silsvc
if %ERRORLEVEL% NEQ 0 goto REGGONE
ECHO Registry still exists
ECHO Registry still exists >> pwnlog.txt 2>&1
GOTO START
:REGGONE
ECHO Registry key pwned!
ECHO Registry key pwned! >> pwnlog.txt 2>&1
:REGCONT

ECHO Service Check
ECHO Service Check >> pwnlog.txt 2>&1
sc query SBCore > nul 2>&1
if %ERRORLEVEL% NEQ 0 goto SVCGONE
sc query silsvc > nul 2>&1
if %ERRORLEVEL% NEQ 0 goto SVCGONE
ECHO Service still exists
ECHO Service still exists >> pwnlog.txt 2>&1
GOTO START
:SVCGONE
ECHO Registry key pwned!
ECHO Registry key pwned! >> pwnlog.txt 2>&1
:SVCCONT

ECHO File Check
ECHO File Check >> pwnlog.txt 2>&1
if exist C:\windows\system32\sbscrexe.exe (
    ECHO sbscrexe.exe (sbs 2003) still exists
    ECHO sbscrexe.exe (sbs 2003) still exists >> pwnlog.txt 2>&1
    GOTO START
) else (
    ECHO sbscrexe.exe (sbs 2003) pwned!
    ECHO sbscrexe.exe (sbs 2003) pwned! >> pwnlog.txt 2>&1
)
if exist C:\windows\system32\silnotify.exe (
    ECHO silnotify.exe still exists
    ECHO silnotify.exe still exists >> pwnlog.txt 2>&1
    GOTO START
) else (
    ECHO silnotify.exe pwned!
    ECHO silnotify.exe pwned! >> pwnlog.txt 2>&1
)
if exist C:\windows\system32\silsvc.exe (
    ECHO silsvc.exe still exists
    ECHO silsvc.exe still exists >> pwnlog.txt 2>&1
    GOTO START
) else (
    ECHO silsvc.exe pwned!
    ECHO silsvc.exe pwned! >> pwnlog.txt 2>&1
)

ECHO silPWNED!
ECHO silPWNED! >> pwnlog.txt 2>&1