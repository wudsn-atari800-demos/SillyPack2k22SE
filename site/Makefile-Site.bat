@echo off
cd %~dp0
call ..\Make-Settings.bat
IF ERRORLEVEL 1 goto :dir_error

cd %BASE_DIR%

echo Starting site build.

REM Regenerate images
call Make-Images.bat

REM Target directory
set TARGET_DIR=%SITE_DIR%\productions\atari800\%RELEASE_LOWERCASE%
if not exist %TARGET_DIR% mkdir %TARGET_DIR%

REM Target file name prefix
set TARGET_NAME=%TARGET_DIR%\%RELEASE_LOWERCASE%

REM Make target.zip
set TARGET=%TARGET_NAME%.zip
call Makefile.bat
del /Q asm\*.lst asm\*.lab asm\*.atdbg
if exist site\%RELEASE%\Altirra\*.rom del /Q site\%RELEASE%\Altirra\*.rom

copy %RELEASE%.atr site\%RELEASE%\%RELEASE%.atr
copy %RELEASE%.nfo site\%RELEASE%\%RELEASE%.nfo
copy %RELEASE%.png site\%RELEASE%\%RELEASE%.png
copy %RELEASE%.nfo %TARGET_NAME%.nfo
copy %RELEASE%.gif %TARGET_NAME%.gif
copy %RELEASE%.jpg %TARGET_NAME%.jpg
echo [url=https://www.wudsn.com/productions/atari800/%RELEASE_LOWERCASE%/%RELEASE_LOWERCASE%.zip]download[/url]       >%TARGET_DIR%\pouet.txt
echo [url=https://www.wudsn.com/productions/atari800/%RELEASE_LOWERCASE%/%RELEASE_LOWERCASE%-source.zip]source[/url] >>%TARGET_DIR%\pouet.txt
echo [url=https://www.wudsn.com/productions/atari800/%RELEASE_LOWERCASE%/%RELEASE_LOWERCASE%.nfo]nfo[/url]           >>%TARGET_DIR%\pouet.txt
echo [url=https://www.wudsn.com/productions/atari800/%RELEASE_LOWERCASE%/%RELEASE_LOWERCASE%.jpg]screenshot[/url]   >>%TARGET_DIR%\pouet.txt


if not exist site\%RELEASE% mkdir site\%RELEASE%
cd site\%RELEASE%
if exist %TARGET% del %TARGET%
%WINRAR% a -r -afzip %TARGET% *.*
cd ..\..
REM start %TARGET%

REM Make target-source.zip
set TARGET=%TARGET_NAME%-source.zip

cd..
if exist %TARGET% del %TARGET%
%WINRAR% a -afzip -x*.atr %TARGET% %RELEASE%\*.* %RELEASE%\asm %RELEASE%\atr %RELEASE%\images %RELEASE%\menu %RELEASE%\site\Makefile-Site.bat
REM start %TARGET%
cd %RELEASE%\site
start %TARGET_DIR%
goto :eof


:dir_error
echo ERROR: Invalid working directory.
pause
exit
