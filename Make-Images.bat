@echo off
REM 9 PNG images created via "View/Save Frame..." from Altirra.
REM The 672x480 pixels are combined as 3x3 matrix into 1 full PNG image of 1010x683 pixels.

@echo off
call Make-Settings.bat
IF ERRORLEVEL 1 goto :dir_error

set TEMP_PNG=%TEMP%\SillyPack.png
set RELEASE_FILE=%RELEASE%

if not exist images goto :dir_error

echo Resizing frame images.
REM The first row has a smaller height of 200 pixels.
%MAGICK% images\1.png -scale 336x240 -crop 336x200+0+17 %TEMP%\1.png
%MAGICK% images\2.png -scale 336x240 -crop 336x200+0+20 %TEMP%\2.png
%MAGICK% images\3.png -scale 336x240 -crop 336x200+0+20 %TEMP%\3.png
%MAGICK% images\4.png -scale 336x240 %TEMP%\4.png
%MAGICK% images\5.png -scale 336x240 %TEMP%\5.png
%MAGICK% images\6.png -scale 336x240 %TEMP%\6.png
%MAGICK% images\7.png -scale 336x240 %TEMP%\7.png
%MAGICK% images\8.png -scale 336x240 %TEMP%\8.png
%MAGICK% images\9.png -scale 336x240 %TEMP%\9.png

echo Placing all 9 at the right position in the template.
%MAGICK% composite -geometry  +0+0     %TEMP%\1.png images\Template.png %TEMP_PNG%
%MAGICK% composite -geometry  +337+0   %TEMP%\2.png %TEMP_PNG%   %TEMP_PNG%
%MAGICK% composite -geometry  +674+0   %TEMP%\3.png %TEMP_PNG%   %TEMP_PNG%
%MAGICK% composite -geometry  +0+202   %TEMP%\4.png %TEMP_PNG%   %TEMP_PNG%
%MAGICK% composite -geometry  +337+202 %TEMP%\5.png %TEMP_PNG%   %TEMP_PNG%
%MAGICK% composite -geometry  +674+202 %TEMP%\6.png %TEMP_PNG%   %TEMP_PNG%
%MAGICK% composite -geometry  +0+443   %TEMP%\7.png %TEMP_PNG%   %TEMP_PNG%
%MAGICK% composite -geometry  +337+443 %TEMP%\8.png %TEMP_PNG%   %TEMP_PNG%
%MAGICK% composite -geometry  +674+443 %TEMP%\9.png %TEMP_PNG%   %TEMP_PNG%

echo Creating GIF of 336x226 pixels for the productions page preview (medium quality)
%MAGICK% %TEMP_PNG% -scale 336x226 %RELEASE_FILE%.gif

echo Creating PNG of 336x226 pixels for the download package (high quality)
%MAGICK% %TEMP_PNG% -scale 336x226 %RELEASE_FILE%.png

echo Creating JPG of 400x270 pixels for Pouet (that is the maximum width allowed)
%MAGICK% %TEMP_PNG% -scale 400x270 %RELEASE_FILE%.jpg
goto :eof

:dir_error
echo ERROR: Invalid working directory.
pause
exit

:magick:error
echo ERROR: ImageMagick failed.
pause
exit
