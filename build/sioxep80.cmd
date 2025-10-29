@echo off

set PLATFORM=4
call var-def.cmd

set ATR=sioxep80

call :compile_module relocator 3000
move %REL%\relocator*.* %REL%\%ATR%

call :compile_module h6000 6000
move %REL%\h6000*.* %REL%\%ATR%

call :compile_module h6100 6100
move %REL%\h6100*.* %REL%\%ATR%

if NOT %result%==0 goto ende

cd %REL%\%ATR%

copy ..\%RES%\XEP80_Boot_Disk-DX5087-PAL.atr %ATR%.atr

move h6000.com h6000.obj
move h6100.com h6100.obj
move relocator.com move.obj

..\%TOOLS%\xfddos -i %ATR%.atr h6000.obj
..\%TOOLS%\xfddos -i %ATR%.atr h6100.obj
..\%TOOLS%\xfddos -i %ATR%.atr move.obj

mkdir obj > nul 2> nul
mkdir lst > nul 2> nul

move *.lst lst > nul
move *.o obj > nul
move *.a obj > nul
move *.obj obj > nul

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