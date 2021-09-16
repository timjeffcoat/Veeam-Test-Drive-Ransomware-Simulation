::	
::	This script has been written to support the Veeam Test Drive to Immutability course.
::	Run the script with the --help flag for more details.
::

@echo off

:: Get the current user's Documents directory from the Registry
setlocal ENABLEEXTENSIONS
:: Registry key to query
set KEY_NAME="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
set VALUE_NAME="Personal"
:: Find key in registry, and store it's value in RS_DocumentsPath variable
FOR /F "usebackq skip=2 tokens=2*" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set RS_DocumentsPath=%%B
)

if not defined RS_DocumentsPath (
    @echo %KEY_NAME%\%VALUE_NAME% not found.
	exit /b 1
	)

:: This appends an additional directory, and can be removed for the actual TDTV
set RS_DocumentsPath=%RS_DocumentsPath%\TDTV_Documents

set RS_WorkingDirectory=C:\Veeam
set RS_Payload="%RS_WorkingDirectory%\04_TriggerFiles.7z"
set RS_PayloadPath="%RS_WorkingDirectory%\TriggerFiles"
set RS_Background="%RS_WorkingDirectory%\background.png"
set RS_DocumentsArchive="%RS_WorkingDirectory%\03_Docs.7z"

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
set RS_Devmode="1"

:: use oef here so that multiple argument flags can be processed
Goto:eof

:RESET
:: Handle ransomware reset here
if defined RS_Devmode @echo Reset mode ON
if defined RS_Devmode @echo Documents Path is %RS_DocumentsPath%

if defined RS_Devmode @echo Removing existing files in %RS_DocumentsPath%
mkdir %TEMP%\cleanup
if defined RS_Devmode (
	robocopy "%RS_DocumentsPath%" "%TEMP%\cleanup" /move /e
	else (
	robocopy "%RS_DocumentsPath%" "%TEMP%\cleanup" /move /e > nul
	)
rmdir /s /q "%TEMP%\cleanup"

if defined RS_Devmode @echo Extracting the contents of %RS_DocumentsArchive% to %RS_DocumentsPath%
mkdir %RS_DocumentsPath%
if defined RS_Devmode (
	"%ProgramFiles%\7-Zip\7z.exe" x "%RS_DocumentsArchive%" -o"%RS_DocumentsPath%" *.* -r -aos
)	else (
	"%ProgramFiles%\7-Zip\7z.exe" x "%RS_DocumentsArchive%" -o"%RS_DocumentsPath%" *.* -r -aos > nul
	)
	
if defined RS_Devmode (del /s /q "%RS_PayloadPath%\*.*") else (del /s /q "%RS_PayloadPath%\*.*" > nul)
rmdir /s /q "%RS_PayloadPath%"


Goto:CLEANUP


:MAIN


if defined RS_Devmode @echo Starting script

IF "%~1"=="" (
	if defined RS_Devmode @echo No arguments passed
) else ( 
	if defined RS_Devmode @echo Arguments passed: %*
)

:: mkdir "%RS_DocumentsPath%\General"

for /r %%x in ("%RS_DocumentsPath%\*.*") do @echo File is "%%x" *_PleasePay.RAN
::for /r %%x in ("%RS_DocumentsPath%\*.*") do ren "%%x" *_PleasePay.RAN

if defined RS_Devmode (
	"%ProgramFiles%\7-Zip\7z.exe" x %RS_Payload% -o"%RS_PayloadPath%" *.* -r -aos
)	else (
	"%ProgramFiles%\7-Zip\7z.exe" x %RS_Payload% -o"%RS_PayloadPath%" *.* -r -aos > nul
	)
	


:CLEANUP
:: tidy up
if defined RS_DocumentsPath 	set RS_DocumentsPath	=""
if defined RS_BackgroundPath 	set RS_BackgroundPath	=""
if defined RS_PayloadPath 		set RS_PayloadPath		=""
if defined RS_Payload 			set RS_Payload			=""
if defined RS_Devmode 			set RS_Devmode			=""
if defined RS_DocumentsArchive 	set RS_DocumentsArchive	=""
Exit /b 0