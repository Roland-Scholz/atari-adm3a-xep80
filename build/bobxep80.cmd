@echo off

set PLATFORM=4
set ATR=bobxep80

call var-def.cmd


call :compile_module bobxep80 4000
call :compile_module bobxep80_runad 02e0

if NOT %result%==0 goto ende

cd %REL%
copy %RES%\%ATR%.atr .

rem copy %RES%\module1.btm .
copy /Y /B bobxep80.com + bobxep80_runad.com module1.btm

%TOOLS%\xfddos -i %ATR%.atr module1.btm

cd %ATR%

rmdir /S /Q obj > nul 2> nul
rmdir /S /Q lst > nul 2> nul
mkdir obj > nul 2> nul
mkdir lst > nul 2> nul

move ..\%ATR%*.* . > nul 2> nul

move *.lst lst > nul 2> nul
move *.o obj > nul 2> nul
move *.a obj > nul 2> nul
move *.com obj > nul 2> nul
move ..\module1.btm obj > nul 2> nul

C:\Program Files (x86)\Aspeqt\AspeQt.exe"
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