@ECHO off
SETLOCAL

FOR %%i IN ("%~dp0..") DO SET CRANK_ROOT=%%~fi

dart %CRANK_ROOT%\bin\crank.dart %*