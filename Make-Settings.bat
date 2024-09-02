set BASE_DIR=%~dp0
set EXOMIZER=C:\jac\system\Windows\Tools\FIL\Exomizer\win32\exomizer.exe
set MADS=C:\jac\system\Atari800\Tools\ASM\MADS\mads.exe
set MAGICK="C:\Program Files\ImageMagick-7.1.0-Q16-HDRI\magick.exe"
set WINRAR=C:\jac\system\Windows\Tools\FIL\WinRAR\winrar.exe

set SITE_DIR=C:\jac\system\WWW\Sites\www.wudsn.com

for %%I in (%BASE_DIR%.) do set RELEASE=%%~nxI
set RELEASE_LOWERCASE=sillypack2k22se
setlocal enabledelayedexpansion
set RELEASE_LOWERCASE=%RELEASE%
call :lower_case RELEASE_LOWERCASE
goto :eof

:lower_case
set %~1=!%~1:a=a!
set %~1=!%~1:b=b!
set %~1=!%~1:c=c!
set %~1=!%~1:d=d!
set %~1=!%~1:e=e!
set %~1=!%~1:f=f!
set %~1=!%~1:g=g!
set %~1=!%~1:h=h!
set %~1=!%~1:i=i!
set %~1=!%~1:j=j!
set %~1=!%~1:k=k!
set %~1=!%~1:l=l!
set %~1=!%~1:m=m!
set %~1=!%~1:n=n!
set %~1=!%~1:o=o!
set %~1=!%~1:p=p!
set %~1=!%~1:q=q!
set %~1=!%~1:r=r!
set %~1=!%~1:s=s!
set %~1=!%~1:t=t!
set %~1=!%~1:u=u!
set %~1=!%~1:v=v!
set %~1=!%~1:w=w!
set %~1=!%~1:x=x!
set %~1=!%~1:y=y!
set %~1=!%~1:z=z!
goto:eof
