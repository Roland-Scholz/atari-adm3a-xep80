@echo off

set PLATFORM=4
set ATR=adm3ax80
call var-def.cmd


call :compile_module adm3ax80 2000
if NOT %result%==0 goto ende

call :compile_module runad 2e0
if NOT %result%==0 goto ende

cd %REL%
copy %RES%\mydos90k.atr %ATR%.atr
copy /Y /B adm3ax80.com + runad.com adm3ax80.ar0

%TOOLS%\xfddos -i %ATR%.atr adm3ax80.ar0

cd %ATR%
rmdir /Q /S obj > nul 2> nul
rmdir /Q /S lst > nul 2> nul
mkdir obj > nul 2> nul
mkdir lst > nul 2> nul

move ..\%ATR%*.* . > nul 2> nul
move ..\runad*.* . > nul 2> nul

move *.lst lst > nul 2> nul
move *.o obj > nul 2> nul
move *.a obj > nul 2> nul
move *.com obj > nul 2> nul
move *.ar* obj > nul 2> nul

c:\atari\aspeqt7\aspeqt.exe
goto eof

:ende

pause
goto eof


:compile_module
%CC65%\ca65 -DPLATFORM=%PLATFORM% -l  %REL%\%1.lst %SRC%\%1.a65 -I %INC% -I %COMMON%\inc -o %REL%\%1.o
set result=%ERRORLEVEL%

if %result%==0 (

	%CC65%\ld65 -t none %REL%\%1.o -o %REL%\%1.a
rem 	%CC65%\bin2hex %REL%\%1.a %REL%\%1.hex -o %2
	java -jar %TOOLS%\Obj2Com\jar\ObjUtil.jar Obj2Com %REL%\%1.a %2
)

:eof