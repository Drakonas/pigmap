@echo off

rem - Prepare the Command Processor
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION

cls

rem  == Configuration ==

rem  = Required =

rem - Overviewer folder Location
set PIGMAP=C:\Users\Drakonas\Downloads\Minecraft\Drakonas-pigmap

rem - World directory
set WORLD=C:\Users\Drakonas\AppData\Roaming\.minecraft\saves\World1

rem - Map output directory
set OUTPUT=C:\Users\Drakonas\Downloads\Minecraft\Drakonas-pigmap\tiles

rem - Base Zoom level block size (in pixels)
rem - (Just leave as default if you don't know what to do with this)
set BASEZOOM=6

rem - Tile multiplier, controls how many chunks wide a tile is (requires to be >= 1)
rem - (Again, leave as default if you don't know what to do)
set TILEMULTI=1

rem - Get current date
set mydate=%date:~4,2%%date:~7,2%%date:~10,4%


rem - Logfile (recommend only changing %LOGS% {the folder to store the logs in})
set LOGS=%PIGMAP%\logs
set LOGFILE=%LOGS%\%mydate%.log

rem  = Optional =

rem - Path to terrain.png and fire.png, etc. (all images)
rem - NOTICE!!: terrain.png from a texture pack or from minecraft.jar is required.
rem - I recommend Painterly Pack with the lighter, custom water texture for best experience
set TEXTURE=%PIGMAP%\terrain

rem - Number of threads to use (number of CPUs, i.e. 2 for Dual-core, 4 for quad-core, etc.)
set THREADS=1

rem - Finish Configuration

rem Setup environment

C:
chdir C:\cygwin\bin
set CYGWIN=nodosfilewarning

rem Check for existing paths

if not exist "%PIGMAP%" (
	echo pigmap not found...exiting
	pause
	exit
)
if not exist "%WORLD%" (
	echo World directory non-existent...exiting
	pause
	exit
)
if not exist "%OUTPUT%" (
	echo Output directory non-existent...exiting
	pause
	exit
)
if not exist "%LOGS%" (
	echo Log directory non-existent...exiting
	pause
	exit
)
if not exist "%TEXTURE%" (
	echo Texture directory non-existent...exiting
	pause
	exit
)
if not exist "%TEXTURE%\terrain.png" (
	echo terrain.png not in texture/terrain directory...exiting
	pause
	exit
)

echo Copying needed folders
xcopy /s/e/y "%PIGMAP%\web_assets\*" "%OUTPUT%"
copy "%PIGMAP%/template.html" "%OUTPUT%/index.html"

echo Generating map...
"%PIGMAP%\pigmap" -B "%BASEZOOM%" -T "%TILEMULTI%" -g "%TEXTURE%" -h "%THREADS%" -i "%WORLD%" -o "%OUTPUT%" >> "%LOGFILE%"

echo Finished Generating
pause