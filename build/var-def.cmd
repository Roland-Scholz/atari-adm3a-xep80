set TOOLS=..\..\atari-tools
set CC65=%TOOLS%\cc65\bin
set SRC=..\src
set INC=..\inc
set BIN=..\bin
set RELBASE=..\release
rem set REL=%RELBASE%\%PLATFORM%
set REL=%RELBASE%
set RES=..\res
set COMMON=..\..\atari-common
set MY65816=..\..\atari-my65816

mkdir %RELBASE% > nul 2> nul
rem rmdir /S /Q %REL% > nul 2> nul
rem mkdir %REL%

