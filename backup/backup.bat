@echo off
REM ------------------------------------------------------------
REM backup.bat - dated custom-format backup of retail_operations
REM Also saves roles (pg_dumpall --globals-only), verifies the
REM dump, writes a log, and removes dumps older than RETAIN_DAYS.
REM No password is stored here: it is read from pgpass.conf.
REM ------------------------------------------------------------
setlocal

set "PGBIN=C:\Program Files\PostgreSQL\18\bin"
set "DBNAME=retail_operations"
set "PGUSER=postgres"
set "PGHOST=localhost"
set "PGPORT=5432"
set "BACKUP_DIR=D:\for resume\retail_backups"
set "RETAIN_DAYS=14"

if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HHmm"') do set "STAMP=%%i"
set "DUMP=%BACKUP_DIR%\%DBNAME%_%STAMP%.dump"
set "ROLES=%BACKUP_DIR%\globals_%STAMP%.sql"
set "LOG=%BACKUP_DIR%\backup_log.txt"

echo [%date% %time%] START backup of %DBNAME% >> "%LOG%"

REM -w = never prompt for a password (a scheduled task would hang)
"%PGBIN%\pg_dump.exe" -U %PGUSER% -h %PGHOST% -p %PGPORT% -w -Fc -f "%DUMP%" %DBNAME%
if errorlevel 1 (
    echo [%date% %time%] FAILED pg_dump >> "%LOG%"
    if exist "%DUMP%" del "%DUMP%"
    exit /b 1
)

"%PGBIN%\pg_dumpall.exe" -U %PGUSER% -h %PGHOST% -p %PGPORT% -w --globals-only -f "%ROLES%"
if errorlevel 1 (
    echo [%date% %time%] WARNING roles export failed >> "%LOG%"
)

REM Verify the dump is non-empty and readable
for %%F in ("%DUMP%") do set "SIZE=%%~zF"
if "%SIZE%"=="0" (
    echo [%date% %time%] FAILED dump is 0 bytes >> "%LOG%"
    exit /b 1
)
"%PGBIN%\pg_restore.exe" --list "%DUMP%" > nul
if errorlevel 1 (
    echo [%date% %time%] FAILED dump is not readable by pg_restore >> "%LOG%"
    exit /b 1
)

echo [%date% %time%] OK %DUMP% (%SIZE% bytes) >> "%LOG%"

REM Remove dumps and role files older than RETAIN_DAYS
forfiles /p "%BACKUP_DIR%" /m *.dump /d -%RETAIN_DAYS% /c "cmd /c del @path" 2>nul
forfiles /p "%BACKUP_DIR%" /m globals_*.sql /d -%RETAIN_DAYS% /c "cmd /c del @path" 2>nul

echo Backup complete: %DUMP% (%SIZE% bytes)
endlocal
