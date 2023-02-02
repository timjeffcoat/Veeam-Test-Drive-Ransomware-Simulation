::	
::	This script has been written to support the Veeam Ransomware Defence with Immutabile Backups Hands-on Lab.
::	Run the script with the --help flag for more details.
::

@echo off

set RS_DocumentsPath=%USERPROFILE%\Documents
set RS_WorkingDirectory=%CD%
set RS_Payload=%RS_WorkingDirectory%\04_Virus_Test_Trigger_Files.7z
set RS_PayloadPath=%RS_WorkingDirectory%\TriggerFiles
set RS_Background=%RS_WorkingDirectory%\Ransom Note\Ransom Note Background.jpg
set RS_DocumentsArchive=%RS_WorkingDirectory%\03_Docs.7z
set RS_RefreshCounter=0
set RS_Devmode=false
set RS_Resetmode=false

:: Check for command line arguments/flags passed when the script was called
if /i "%1"=="--help" 	goto HELP
if /i "%2"=="--help" 	goto HELP
if /i "%1"=="?" 		goto HELP
if /i "%2"=="?" 		goto HELP

if /i "%1"=="-d" 		call :DEVMODE
if /i "%2"=="-d" 		call :DEVMODE
if /i "%1"=="--dev" 	call :DEVMODE
if /i "%2"=="--dev" 	call :DEVMODE

if /i "%1"=="-r" 		goto :RESET
if /i "%2"=="-r" 		goto :RESET
if /i "%1"=="--reset" 	goto :RESET
if /i "%2"=="--reset" 	goto :RESET


Goto MAIN

:HELP
:: Display a help message, and then go to cleanup before exiting
	echo USAGE:
	echo. %~nx0% [optional flags]
    echo.
    echo.	?, --help       shows this help (optional)
    echo.	-d, --dev       enables debugging messages (optional)
    echo.	-r, --reset     resets envionment (optional)
    echo.
    echo.	
	echo. If called with no optional flags, script simulates ransomware, and will:
	echo.	- change the filename extension of all files in the executing user's 'Documents' folder
	echo.	  (e.g. %RS_DocumentsPath%)
	echo.	- extract the contents of payload.7z to:
	echo.	  %RS_PayloadPath%
	echo.	- change the desktop background image to %RS_BackgroundPath%
	echo.
	echo. This process will be reversed by calling the script with the --reset flag.

Goto:CLEANUP


:: The following line labels handle any argument flags that have been passed

:DEVMODE
:: this will show additional debugging commands
@echo Dev mode ON
set RS_Devmode=true

:: use oef here so that multiple argument flags can be processed
Goto:eof

:RESET
:: Handle ransomware reset here
set RS_Resetmode=true
if "%RS_Devmode%"=="true" @echo Reset mode ON
if "%RS_Devmode%"=="true" @echo Documents Path is %RS_DocumentsPath%

if "%RS_Devmode%"=="true" @echo Removing existing files in %RS_DocumentsPath%
mkdir %TEMP%\cleanup
if "%RS_Devmode%"=="true" (
	robocopy "%RS_DocumentsPath%" "%TEMP%\cleanup" /move /e > nul
)	else (
	robocopy "%RS_DocumentsPath%" "%TEMP%\cleanup" /move /e > nul
	)
rmdir /s /q "%TEMP%\cleanup"

if "%RS_Devmode%"=="true" @echo Extracting the contents of %RS_DocumentsArchive% to %RS_DocumentsPath%
mkdir %RS_DocumentsPath%
if "%RS_Devmode%"=="true" (
	"%ProgramFiles%\7-Zip\7z.exe" x "%RS_DocumentsArchive%" -o"%RS_DocumentsPath%" *.* -r -aos > nul
)	else (
	"%ProgramFiles%\7-Zip\7z.exe" x "%RS_DocumentsArchive%" -o"%RS_DocumentsPath%" *.* -r -aos > nul
	)

if exist %RS_PayloadPath% (
	if "%RS_Devmode%"=="true" @echo Removing %RS_PayloadPath%
	if "%RS_Devmode%"=="true" (del /s /q "%RS_PayloadPath%\*.*") else (del /s /q "%RS_PayloadPath%\*.*" > nul)
	rmdir /s /q "%RS_PayloadPath%"
	)
if "%RS_Devmode%"=="true" @echo Copying %RS_WorkingDirectory%\Simulation.lnk to %USERPROFILE%\Desktop\Ransomware.lnk
copy "%RS_WorkingDirectory%\Simulation.lnk" "%USERPROFILE%\Desktop\Ransomware.lnk" > nul 

set RS_OldBackground=%RS_WorkingDirectory%\OldBackgroundPath.txt

if not exist %RS_OldBackground% (
	@echo %RS_WorkingDirectory%\OldBackgroundPath.txt does not exist
	Goto:REFRESH
)

if "%RS_Devmode%"=="true" @echo Old background path is contained in file %RS_WorkingDirectory%\OldBackgroundPath.txt

set /p RS_OldBackground=<%RS_WorkingDirectory%\OldBackgroundPath.txt

if "%RS_Devmode%"=="true" @echo Old background path is %RS_OldBackground%

reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallPaper /t REG_SZ /d "%RS_OldBackground%" /f >nul

%SystemRoot%\System32\RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters

::	if "%RS_Devmode%"=="true" (
::		del /s /q "%RS_WorkingDirectory%\OldBackgroundPath.txt"
::	) else (
::		del /s /q "%RS_WorkingDirectory%\OldBackgroundPath.txt" > nul
::	)

if exist "%USERPROFILE%\Desktop\Ransom Note.lnk" (
	if "%RS_Devmode%"=="true" (
	del /s /q "%USERPROFILE%\Desktop\Ransom Note.lnk"
	) else (
	del /s /q "%USERPROFILE%\Desktop\Ransom Note.lnk" > nul
	)
)

@echo Ransomware simulation has been reset. Attempting to refresh wallpaper.

Goto:REFRESH


:MAIN

if "%RS_Devmode%"=="true" @echo Starting script

if "%~1"=="" (
	if "%RS_Devmode%"=="true" @echo No arguments passed
) else ( 
	if "%RS_Devmode%"=="true" @echo Arguments passed: %*
)


if "%RS_Devmode%"=="true" @echo RS_DocumentsPath is %RS_DocumentsPath%
if "%RS_Devmode%"=="true" @echo RS_Background is %RS_Background%
if "%RS_Devmode%"=="true" @echo RS_PayloadPath is %RS_PayloadPath%
if "%RS_Devmode%"=="true" @echo RS_Payload is %RS_Payload%
if "%RS_Devmode%"=="true" @echo RS_Devmode is %RS_Devmode%

set CurrentPath=%cd%

cd %RS_DocumentsPath%

for /r %%x in (*.*) do ren "%%x" *_PleasePay.RAN

if "%RS_Devmode%"=="true" @echo Extracting the contents of %RS_Payload% to %RS_PayloadPath%

 if "%RS_Devmode%"=="true" (
	"%ProgramFiles%\7-Zip\7z.exe" x %RS_Payload% -o"%RS_PayloadPath%" *.* -r -aos -p"Veeam123456!" > nul
 )	else (
	"%ProgramFiles%\7-Zip\7z.exe" x %RS_Payload% -o"%RS_PayloadPath%" *.* -r -aos -p"Veeam123456!" > nul
 	)
	
cd %CurrentPath%

set BackgroundHistoryPathCounter=0

:BACKGROUNDSEARCH

for /f "tokens=2* skip=2" %%a in ('reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" /v "BackgroundHistoryPath%BackgroundHistoryPathCounter%"') do (
	set RS_OldBackground=%%b
)

if "%RS_Devmode%"=="true" @echo Old path is %RS_OldBackground%
if "%RS_Devmode%"=="true" @echo Background is %RS_Background%
if "%RS_Devmode%"=="true" @echo Counter is %BackgroundHistoryPathCounter%

if "%RS_OldBackground%"=="%RS_Background%" (
       	set /a "BackgroundHistoryPathCounter=BackgroundHistoryPathCounter+1"
	if "%RS_Devmode%"=="true" @echo counter incremented is %BackgroundHistoryPathCounter%
    if %BackgroundHistoryPathCounter% lss 5 goto:BACKGROUNDSEARCH
)

@echo %RS_OldBackground% > %RS_WorkingDirectory%\OldBackgroundPath.txt

if "%RS_Devmode%"=="true" (
	copy %RS_OldBackground% %RS_WorkingDirectory%\Oldbackground.jpg
) else (
	copy %RS_OldBackground% %RS_WorkingDirectory%\Oldbackground.jpg > nul
)

 if "%RS_Devmode%"=="true" (
	reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallPaper /t REG_SZ /d "%RS_Background%" /f

 )	else (
	reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v WallPaper /t REG_SZ /d "%RS_Background%" /f > nul

 	)

if "%RS_Devmode%"=="true" (
del /s /q %USERPROFILE%\Desktop\Ransomware.lnk
) else (
del /s /q %USERPROFILE%\Desktop\Ransomware.lnk > nul
)

if "%RS_Devmode%"=="true" (
	copy "%RS_WorkingDirectory%\Ransom Note\Ransom Note.lnk" "%USERPROFILE%\Desktop\Ransom Note.lnk"
) else (
	copy "%RS_WorkingDirectory%\Ransom Note\Ransom Note.lnk" "%USERPROFILE%\Desktop\Ransom Note.lnk" > nul
)

:: echo MSGBOX "Pay the ransom to get your files back", vbCritical, "YOUR FILES HAVE BEEN ENCRYPTED" > %temp%\TEMPmessage.vbs
:: call %temp%\TEMPmessage.vbs
:: del %temp%\TEMPmessage.vbs /f /q


@echo Ransomware simulation is complete. Ransom note will open after wallpaper refresh.


:REFRESH

if "%RS_Devmode%"=="true" @echo Attempting to refresh desktop background

for /l %%x in (1, 1, 100) do (

   
   if "%RS_Devmode%"=="true" if temp equ 0 @echo Refresh attempt %%x
   :: nither of these commands seem to be particularly reliable, and experimentation hasn't helped determine which one to use.
   :: so let's just use both!
   %SystemRoot%\System32\RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters
   %SystemRoot%\System32\RUNDLL32.EXE USER32.DLL ,UpdatePerUserSystemParameters 1 ,True

   set /a "RS_RefreshCounter=%%x"

   :: pause for 1 second every [counter] loops
 
   set /a "remainder=RS_RefreshCounter %% 30"

	@echo Checkpoint 1

   	if %remainder% equ 0 (
		timeout /t 1 /nobreak > nul
		if "%RS_Devmode%"=="true" @echo Pausing
	)
)

@echo Wallpaper refresh loop completed %RS_RefreshCounter% times.

taskkill /im explorer.exe /f > nul
start explorer.exe

explorer %RS_DocumentsPath%

if "%RS_Resetmode%"=="true" if "%RS_Devmode%"=="true" explorer %RS_WorkingDirectory%

if not "%RS_Resetmode%"=="true" start "" "%USERPROFILE%\Desktop\Ransom Note.lnk"

:CLEANUP
:: tidy up
if "%RS_Devmode%"=="true" @echo Clearing environment variables

if defined RS_DocumentsPath set RS_DocumentsPath=""
if defined RS_Background set RS_Background=""
if defined RS_PayloadPath set RS_PayloadPath=""
if defined RS_Payload set RS_Payload=""
if defined RS_Devmode set RS_Devmode=""
if defined RS_DocumentsArchive set RS_DocumentsArchive=""
if defined RS_OldBackground set RS_OldBackground=""
if defined RS_RefreshCounter set RS_RefreshCounter=""
if "%RS_Devmode%"=="true" pause
Exit /b 0