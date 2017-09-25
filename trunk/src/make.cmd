@echo off
@setlocal enabledelayedexpansion

@set SourceDir=%~dp0
@set TargetDir=%~dp0..\@\sqfcalc
@set InstallDir=@\sqfcalc
@set WorkPlace=%~dp0..\tmp

@set ToolDir=%~dp0\make
@set ToolMakepbo="%ToolDir%\bin\cpbo.exe" -y -p
@set ToolPerl="%ToolDir%\bin\perl.exe" -I"%~dp0make\lib"
@set ToolOptcpp=%ToolPerl% "%ToolDir%\lib\opt-conf.pl"
@set ToolScriptPacker=%ToolPerl% "%ToolDir%\lib\sqf-to-sqs-packer.pl" "%ToolDir%\bin"
@set ToolRapify="%ToolDir%\bin\rapify.exe" -o


call:CopyDir "bin" "%SourceDir%" "%WorkPlace%"
cd "%WorkPlace%\bin"
%ToolOptcpp% "resource.cpp" "resource.opt.cpp" > "log-resource"
%ToolRapify% "resource.opt.cpp" "resource.bin"
xcopy /Y "resource.bin" "%TargetDir%\bin\"

@set addon=addons\vdmj_sqfcalc

call:CopyDir "%addon%" "%SourceDir%" "%WorkPlace%"

cd "%WorkPlace%\%addon%"

%ToolScriptPacker% "eval.sqf" "eval.sqs"
%ToolRapify% "config.cpp" "config.bin"

del /Q "config.cpp" > nul
mkdir "%TargetDir%\addons" > nul
del /Q "%TargetDir%\%addon%.pbo" > nul
%ToolMakepbo% "%WorkPlace%\%addon%" "%TargetDir%\%addon%.pbo"

call :CopyAddonsToGameFolder "HKLM\SOFTWARE\Codemasters\Operation Flashpoint" "MAIN"
call :CopyAddonsToGameFolder "HKLM\SOFTWARE\Bohemia Interactive Studio\ColdWarAssault" "MAIN"

goto:eof

:CopyAddonsToGameFolder
    setlocal
    set gamepath=
    echo.
    echo.--RegRead--------------------
    call :RegRead "gamepath" "%~1" "%~2" "%~3"
    echo.-----------------------------
    if not "%gamepath%"=="" (
        echo Install for %~3
        xcopy /Y "%TargetDir%\addons" "%gamepath%\%InstallDir%\addons\"
        xcopy /Y "%TargetDir%\bin" "%gamepath%\%InstallDir%\bin\"
    ) else (
        echo Not found: "%~1"
    )
    echo.
    echo.-----------------------------
    endlocal
goto:eof

:CopyDir
    if exist "%~3\%~1" (
        del /Q /F "%~3\%~1\*" > nul
    ) else (
        mkdir "%~3\%~1" > nul
    )
    xcopy "%~2\%~1" "%~3\%~1"
goto:eof

:RegReadTry
    for /F "tokens=1,2,* delims=()" %%i in ('%reg% query "%~2" /v "%~3" /z') do (
        if "%%i"=="    %~3    REG_SZ " (
            set %~1=%%k
            set %~1=!%~1:    =!
            goto:eof
        )
    )
goto:eof

:RegRead
    setlocal
    if defined PROCESSOR_ARCHITEW6432 (
        set reg="%systemroot%\sysnative\reg.exe"
    ) else (
        set reg=reg
    )
    set software_key=%~2
    call:RegReadTry "result" "%software_key%" "%~3" 2>nul
    if "%RESULT%"=="" (
        set software_key=!software_key:HKLM\SOFTWARE=HKLM\SOFTWARE\Wow6432Node!
        set software_key=!software_key:HKCU\SOFTWARE=HKCU\SOFTWARE\Wow6432Node!
        call:RegReadTry "result" "!software_key!" "%~3"
    )
    endlocal & set %~1=%result%
goto:eof

