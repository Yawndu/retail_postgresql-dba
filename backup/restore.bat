@echo off
REM ------------------------------------------------------------
REM restore.bat - restore a backup into a SEPARATE database
REM Usage:  restore.bat "D:\path\to\file.dump" [target_db_name]
REM Default target: retail_operations_restored
REM It refuses to restore into the live database.
REM Password is read from pgpass.conf (no password in this file).
REM ------------------------------------------------------------
setlocal

set "PGBIN=C:\Program Files\PostgreSQL\18\bin"
set "PGUSER=postgres"
set "PGHOST=localhost"
set "PGPORT=5432"

set "DUMP=%~1"
set "TARGET=%~2"
if "%TARGET%"=="" set "TARGET=retail_operations_restored"

if "%DUMP%"=="" goto :usage
if not exist "%DUMP%" goto :nofile
if /i "%TARGET%"=="retail_operations" goto :live

echo Creating database %TARGET% ...
"%PGBIN%\createdb.exe" -U %PGUSER% -h %PGHOST% -p %PGPORT% -w %TARGET%
if errorlevel 1 goto :createfail

echo Restoring %DUMP% ...
"%PGBIN%\pg_restore.exe" -U %PGUSER% -h %PGHOST% -p %PGPORT% -w -d %TARGET% "%DUMP%"
if errorlevel 1 goto :restorefail

echo Row counts in %TARGET%:
"%PGBIN%\psql.exe" -U %PGUSER% -h %PGHOST% -p %PGPORT% -w -d %TARGET% -c "SELECT 'customers' AS tbl, COUNT(*) FROM customers UNION ALL SELECT 'orders', COUNT(*) FROM orders UNION ALL SELECT 'order_items', COUNT(*) FROM order_items UNION ALL SELECT 'products', COUNT(*) FROM products ORDER BY 1;"

echo Restore complete into %TARGET%.
exit /b 0

:usage
echo Usage: restore.bat "D:\path\to\file.dump" [target_db_name]
exit /b 1

:nofile
echo File not found: %DUMP%
exit /b 1

:live
echo Refusing to restore into the live database. Choose another name.
exit /b 1

:createfail
echo Could not create database %TARGET%. See the error above. It may already exist.
exit /b 1

:restorefail
echo pg_restore reported errors. Check the output above.
exit /b 1
