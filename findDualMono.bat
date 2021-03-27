@echo off


if [%1]==[/?] (
    echo findDualMono.bat v. 2.0 ^(c^) kamilbaranski.com
    echo.
    echo.
    echo Usage:
    echo   cd path_of_WAV_files ^&^& findDualMono_path\findDualMono.bat
    echo.
    echo.
    echo Finds dual mono files and allows to convert them to mono
    echo ^(stripping one channel using sox^)
    echo.
    echo.
    echo Please send any bug reports and all your money to kamilbaranski.com.
    echo.

    rem -----------------------------------------------------------------------------
    rem INSTALL:
    rem - download SoX (install, set path below, don't use spaces in _soxExe!)
    rem - move finddualmono.bat to SoX directory
    rem - ready. launch by typing:
    rem     cd directoryWithWavFiles
    rem     c:\progra~2\sox-14-4-2\finddualmono.bat
    rem 
    rem *nothing guaranteed, use at your own risk :)
    rem -----------------------------------------------------------------------------

	exit /B
)


set _soxExe=c:\progra~2\sox-14-4-2\sox.exe

rem this might differ in various SoX versions:
set _zero=0.000000

setlocal enabledelayedexpansion
set _wavPath=%CD%
set _soxPath=%~dp0
set _temporaryFile=!_wavPath!\_leftequalsright.tmp.txt

rem unfortunately the following doesn't work as it should - (calling the 
rem     "soxExe" "wavfile"
rem confuses CMD (doublequotes/quotes/backticks)
rem set _soxExe="!_soxPath!sox.exe"



rem ------------------------------------------------------------------------------------------------------------
rem DO NOT EDIT BELOW THIS LINE
rem ------------------------------------------------------------------------------------------------------------

rem goto conversionTest rem (for debuging)

if exist "!_temporaryFile!" (
	echo "(Deleting the temporary file.)"
	del "!_temporaryFile!"
)

echo.
echo ---------------[ Analysing: ]-----------------

for %%F IN ("!_wavPath!\*.wav") do (
	set _file=%%F
	echo Analysing: !_file!

	set _command='!_soxExe! "!_file!" -n remix 1,2i stat 2^>^&1 ^| findstr /R /C:"Maximum amplitude"'
    rem echo COMMAND: !_command!

	rem unset vars
	set _amplitudeLine=0
	set _amplitude=0

	for /f "tokens=*" %%i in (!_command!) do (
		rem echo %%i
		set _amplitudeLine=%%i
		set _amplitude=!_amplitudeLine:~-8%!
	)

	rem echo _PLIK: !_file!
	rem echo _AMPL: !_amplitude!
	rem echo.

	IF "!_amplitudeLine:~0,1!"=="M" (		rem if there's "Maximum amplitude" line (otherwise the file might be mono)
		IF !_amplitude!==!_zero! (			rem if L=R
			rem echo !_file!
			echo !_file! >> "!_temporaryFile!"
		)
	)
)

:conversionTest

rem todo: tell user there's nothing to do if _temporaryFile doesn't exists
rem (if we can assume there's no problem with creating the file)
rem we can (should!) also count the dual mono files during analyse stage.

echo.
echo ------[ Dual mono files (left = right) ]------
type "!_temporaryFile!"

:question

echo.
echo ----------------------------------------------
echo Convert these files to mono?
echo ----------------------------------------------

choice

rem echo %ERRORLEVEL%

IF %ERRORLEVEL% EQU 2 (
	del "!_temporaryFile!"
	EXIT /B
)

for /F "tokens=* usebackq" %%L in ("!_temporaryFile!") DO (
	set _stereoFile=%%L
	set _basenameFile=!_stereoFile:~0,-5%!
	set _monoFile=!_basenameFile!_mono.wav

	rem todo: check if we won't overwrite any _mono file!
	rem (as we potentially might overwrite some different precious files?...)
	rem or maybe we should just add the counter etc.

	set _command="!_soxExe!" "!_stereoFile!" "!_monoFile!" remix 1
    rem echo !_command!
	!_command!

	rem todo: checking do we say truth :)
	echo Created file: !_monoFile!

	rem todo: stereo file rename?
	rem set _basenameFileWithoutPath=!_stereoFile~n!
	rem	echo ren !_stereoFile! *_stereo.wav
	rem	ren !_stereoFile! *_stereo.wav
)

rem todo: ask user if we should delete converted stereo files.
rem BUT ONLY if all the files were created succesfully!
rem (maybe even check their size...)

del "!_temporaryFile!"

echo ----------------------------------------------
echo Finished!
echo Send all the money to kamilbaranski.com
echo ----------------------------------------------
