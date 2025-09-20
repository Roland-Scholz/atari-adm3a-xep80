@echo off

set PLATFORM=4
call var-def.cmd


call :compile_module adm3ax80 2000
if NOT %result%==0 goto ende

call :compile_module runad 2e0
if NOT %result%==0 goto ende


cd %REL%
copy %RES%\dos25.atr .
copy /Y /B adm3ax80.com + runad.com adm3ax80.ar1

%TOOLS%\xfddos -i dos25.atr adm3ax80.ar1
%TOOLS%\xfddos -i dos25.atr C:\github\Sally-2\atari\autoterm.com	

rem %TOOLS%\xfddos -i dos25.atr adm3ax80.com
	
rem ..\%TOOLS%\xfddos -i boot.atr bootsec.com
rem echo on

mkdir obj > nul 2> nul
mkdir lst > nul 2> nul

move *.lst lst > nul
move *.o obj > nul
move *.a obj > nul

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