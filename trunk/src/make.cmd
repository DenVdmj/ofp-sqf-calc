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
    call :RegRead "gamepath" "%~1" "%~2" "%~3"
    if not "%gamepath%"=="" (
        echo install for %~3
        xcopy /Y "%TargetDir%\addons" "%gamepath%\%InstallDir%\addons\"
        xcopy /Y "%TargetDir%\bin" "%gamepath%\%InstallDir%\bin\"
    )
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

:RegRead
    for /F "tokens=1,2,*" %%i in ('reg query "%~2" /v "%~3"') do (
        if "%%i"=="%~3" (
            set %~1=%%k%~4
        )
    )
goto :eof
