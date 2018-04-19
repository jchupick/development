@ECHO OFF
IF "%1 " == " " goto usage
SET SERVER=%1

IF NOT EXIST \\%SERVER%\C$\Windows\System32\cmd.exe goto badserver

FOR /F "skip=2 tokens=2*" %%a in ('reg query "\\%SERVER%\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" /v PATH') DO SET CURRENTSYSPATH=%%b

@ECHO %CURRENTSYSPATH%
@ECHO.

SET "LOCLINE=%CURRENTSYSPATH%"
SETLOCAL EnableDelayedExpansion

FOR %%a in ("!LOCLINE:;=";"!") do (
    SET RESULT=%%~a
    IF !NOTFIRSTTIME! == "NO" (
        SET FULLRESULT=!FULLRESULT!;!RESULT!
    ) ELSE (
        SET FULLRESULT=!RESULT!
        SET NOTFIRSTTIME="NO"
    )
    @ECHO !FULLRESULT!
)
SETLOCAL DisableDelayedExpansion

@ECHO.
IF NOT "%2 " == " " (
    @ECHO --------- Dump of full MODIFIED system PATH for \\%SERVER% below: ---------
) ELSE (
    @ECHO --------- Dump of full system PATH below: ---------
)
@ECHO %FULLRESULT%;%2

:: Write it back to the registry
::
::
::

:: Show usage if no params
::
IF NOT "%2 " == " " goto end

:usage

@ECHO.
@ECHO Usage:
@ECHO.
@ECHO    %0 [server] [new dir to add to PATH]
@ECHO.
@ECHO Note: if path param is not specified then this will just dump the existing System PATH
@ECHO.
goto end

:badserver
@ECHO.
@ECHO Server %SERVER% does NOT exist (or is NOT there)
goto usage

:end

ENDLOCAL
