@ECHO off
SETLOCAL

FOR %%i IN ("%~dp0..") DO SET CRANK_ROOT=%%~fi

CALL dart pub upgrade --directory=%CRANK_ROOT% > NUL

dart %CRANK_ROOT%\bin\crank.dart %*