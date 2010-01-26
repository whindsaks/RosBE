::
:: PROJECT:     RosBE - ReactOS Build Environment for Windows
:: LICENSE:     GNU General Public License v2. (see LICENSE.txt)
:: FILE:        Root/RosBE.cmd
:: PURPOSE:     This script provides/sets up various build environments for
::              ReactOS. Currently it provides a GCC 4.4.3 build environment.
:: COPYRIGHT:   Copyright 2010 Daniel Reimer <reimer.daniel@freenet.de>
::                             Peter Ward <dralnix@gmail.com>
::                             Colin Finck <colin@reactos.org>
::

@echo off
if not defined _ROSBE_DEBUG set _ROSBE_DEBUG=0
if %_ROSBE_DEBUG% == 1 (
    @echo on
)

title ReactOS Build Environment %_ROSBE_VERSION%

:: For NT4 compatibility
if not defined APPDATA set APPDATA=%USERPROFILE%

:: Set defaults to work with and override them if edited by
:: the options utility.
if "%1" == "" (
    set ROS_ARCH=i386
) else (
    set ROS_ARCH=%1
)

set _ROSBE_BASEDIR=%~dp0
set _ROSBE_BASEDIR=%_ROSBE_BASEDIR:~0,-1%
set _ROSBE_VERSION=1.5
set _ROSBE_ROSSOURCEDIR=%CD%
set _ROSBE_SHOWTIME=1
set _ROSBE_WRITELOG=1
set _ROSBE_USECCACHE=0
set _ROSBE_LOGDIR=%CD%\RosBE-Logs
set _ROSBE_SHOWVERSION=0
set _ROSBE_HOST_MINGWPATH=%_ROSBE_BASEDIR%\i386
set _ROSBE_TARGET_MINGWPATH=%_ROSBE_BASEDIR%\%ROS_ARCH%
set _ROSBE_ORIGINALPATH=%_ROSBE_BASEDIR%;%_ROSBE_BASEDIR%\Tools;%PATH%

:: Fix Bison package path (just in case RosBE is installed in a path which contains spaces)
set BISON_PKGDATADIR=%~ds0%~sp0%i386\share\bison

:: Get the number of CPUs in the system so we know how many jobs to execute.
:: To modify the number used, see the cpucount usage for getting to know about the possible options
for /f "usebackq" %%i in (`"%_ROSBE_BASEDIR%\Tools\cpucount.exe" -x1`) do set _ROSBE_MAKEX_JOBS=%%i

set CCACHE_DIR=%APPDATA%\RosBE\.ccache
set C_INCLUDE_PATH=
set CPLUS_INCLUDE_PATH=
set LIBRARY_PATH=

if "%ROS_ARCH%" == "amd64" (
    color 0B
) else if "%ROS_ARCH%" == "arm" (
    color 09
)
:: Load the user's options if any
if "%ROS_ARCH%" == "i386" (
    if exist "%APPDATA%\RosBE\rosbe-options.cmd" (
        call "%APPDATA%\RosBE\rosbe-options.cmd"
    )
)

if exist "%APPDATA%\RosBE\rosbe-options-%1.cmd" (
    call "%APPDATA%\RosBE\rosbe-options-%1.cmd"
)

if exist "%APPDATA%\RosBE\RBUILDFLAGS.FLG" (
    for /f "usebackq tokens=* delims= " %%i in (`"type "%APPDATA%\RosBE\RBUILDFLAGS.FLG""`) do set ROS_RBUILDFLAGS=%%i
)

:: Check if RosBE data directory exists, if not, create it.
if not exist "%APPDATA%\RosBE\." (
    mkdir "%APPDATA%\RosBE" 1> NUL 2> NUL
)

call "%_ROSBE_BASEDIR%\rosbe-gcc-env.cmd"
doskey update="%_ROSBE_BASEDIR%\Tools\elevate.exe" "%_ROSBE_BASEDIR%\update.cmd" $*

cls
echo *******************************************************************************
echo *                                                                             *
echo *                        ReactOS Build Environment %_ROSBE_VERSION%                        *
echo *                                                                             *
echo *******************************************************************************
echo.

:: Load the base directory from srclist.txt and set it as the
:: new source directory.
if exist "%_ROSBE_BASEDIR%\scut.cmd" (
    call "%_ROSBE_BASEDIR%\scut.cmd"
)
if "%_ROSBE_SHOWVERSION%" == "1" (
    call "%_ROSBE_BASEDIR%\version.cmd"
)

:: Tell how to display the available commands.
echo.
echo For a list of all included commands, type: "help"
echo -------------------------------------------------
echo.

:: Look if the ReactOS source directory is empty. If so,
:: inform the user and mention 'ssvn create' (only if ssvn is installed).
setlocal enabledelayedexpansion
if exist "%_ROSBE_BASEDIR%\sSVN.cmd" (
    dir /b "%_ROSBE_ROSSOURCEDIR%" 2>nul | findstr "." >nul
    if !errorlevel! == 1 (
        echo No ReactOS source detected. Please use "ssvn create" to download it.
    )
)
endlocal
