:: DeepStack Windows install script
:: We assume we're in the /install directory.

@echo off
cls

:: ENV DATA_DIR /datastore
:: ENV TEMP_PATH /deeptemp/
:: ENV PROFILE desktop_cpu

set appDir=c:\CodeProject.Sense
set backendName=intelligence
set frontendName=server
set tempName=temp
set storeName=store

set pythonSourceDir=python

:: Let's go.
if not exist %appDir% mkdir %appDir%
if not exist %appDir%\%tempName%\ mkdir %appDir%\%tempName%
if not exist %appDir%\%storeName%\ mkdir %appDir%\%storeName%


:: Start with the back end Python analysis code. This is all intepreted code and we'll use the
:: version of Python we have in this repo to setup a virtual environement using a known and tested
:: version (in this case 3.10)

set backendDir=%appDir%\%backendName%
if not exist %backendDir% mkdir %backendDir%

echo Download utilities and models ==========================================
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'scripts\download_dependencies.ps1'"

move models %backendDir%\
move redis %backendDir%\
move python-venv %backendDir%\
move windows_packages_cpu %backendDir%\
::move windows_packages_gpu %backendDir%\
::move windows_setup %backendDir%\

ren  %backendDir%\python-venv venv

:: Ensure Python Exists
::%pythonSourceDir%\python --version 3 > NUL
::if errorlevel 1 goto errorNoPython
::echo Python 3 is present ====================================================

:: Create Virtual Environment (instead of the above xcopy)
::if exist %backendDir%\venv\ (
::	echo Virtual Environment Already Exists =====================================
::) else (
::	echo Creating Virtual Environment ===========================================
::	python -m venv "%backendDir%\venv"
::)

echo Activating Virtual Environment =========================================
call %backendDir%\venv\Scripts\activate

echo Upgrading PIP ==========================================================
python.exe -m pip install --upgrade pip

echo Installing packages ====================================================
:: use command 2>nul - to pipe stdout to nul

:: call pip3 install onnxruntime  :: ==0.4.0   
call pip3 install onnxruntime   
call pip3 install redis
call pip3 install opencv-python
call pip3 install Cython
call pip3 install pillow
call pip3 install scipy
call pip3 install tqdm
call pip3 install tensorboard
call pip3 install torch
call pip3 install torchvision
call pip3 install PyYAML
call pip3 install Matplotlib

:: if errorlevel 1 (
::     set D_OPT=
:: ) else (
::     set D_OPT=/D%D_KEYWORD%
:: )



:: Now we move on to the server. The server is purely Golang, but also relies on Redis as the 
:: message queue.

:: Check for Go Installation
go version > NUL
if errorlevel 1 goto errorNoGolang
echo Go is installed ========================================================

:: Check for redis
setlocal enableextensions
Set redisOuput=""
for /f "usebackq tokens=1" %%P in (`redis-cli ping`) do ( set redisOuput=%%P ) 
if %redisOuput% NEQ PONG goto errorNoRedis
echo Redis is installed =====================================================

go build -o ..\..\server\CodeProject-Sense.exe ..\..\server\server.go

echo ========================================================================
echo DONE ===================================================================
echo ========================================================================

goto eof


:: COPY ./init.py /app 
:: EXPOSE 5000
:: WORKDIR /app/server
:: CMD ["/app/server/server"]

:Trim
SetLocal EnableDelayedExpansion
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
exit /b

:errorNoPython
echo .
echo Error: Python not installed
echo Go to https://www.python.org/downloads/ for the latest version
goto:eof

:errorNoGolang
echo .
echo Error: Go not installed
echo Go to https://golang.org/doc/install#download for the latest version of Go

:errorNoRedis
echo .
echo Error: Redis not installed or not running
echo Go to https://github.com/dmajkic/redis/downloads for the latest version of Redis for Windows

:eof