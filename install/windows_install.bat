:: DeepStack Windows install script
:: We assume we're in the /install directory.

@echo off
cls

:: If files are already present, then don't overwrite if this is false
set forceOverwrite=false
set pythonVersion=3.10

:: 0. Basic locations

set appName=CodeProject-Sense
set appDir=c:\CodeProject.Sense
set backendName=backend
set frontendName=server
set tempName=temp
set storeName=store

set pythonSourceDir=python

set backendDir=%appDir%\%backendName%

:: ===============================================================================================
:: 1. Put in place the utilities and back-end Python code for the intelligence layer

:: Create some directories
echo Creating Directories

if not exist %appDir% mkdir %appDir%
if not exist %appDir%\%tempName%\ mkdir %appDir%\%tempName%
if not exist %appDir%\%storeName%\ mkdir %appDir%\%storeName%
if not exist %backendDir% mkdir %backendDir%

:: Download, unzip, and move into place the Utilities and known Python version
echo Download utilities and models

set doDownload=%forceOverwrite%
if not exist %backendDir%\models               set doDownload=true
if not exist %backendDir%\redis                set doDownload=true
if not exist %backendDir%\venv                 set doDownload=true
:: if not exist %backendDir%\windows_packages_cpu set doDownload=true
:: if not exist %backendDir%\windows_packages_gpu set doDownload=true
:: if not exist %backendDir%\windows_setup     set doDownload=true

:: Only do the download if we need to
IF %doDownload%==true (

    if %forceOverwrite% == true (
        if exist models rmdir /s /q models
        if exist redis  rmdir /s /q redis
        if exist venv   rmdir /s /q venv
        REM if exist windows_packages_cpu rmdir /s /q windows_packages_cpu
        REM if exist windows_packages_gpu rmdir /s /q windows_packages_gpu
        REM if exist windows_setup rmdir /s /q windows_setup

        if exist %backendDir%\models rmdir /s /q %backendDir%\models
        if exist %backendDir%\redis  rmdir /s /q %backendDir%\redis
        if exist %backendDir%\venv   rmdir /s /q %backendDir%\env
        REM if exist %backendDir%\windows_packages_cpu rmdir /s /q %backendDir%\windows_packages_cpu
        REM if exist %backendDir%\windows_packages_gpu rmdir /s /q %backendDir%\windows_packages_gpu
        REM if exist %backendDir%\windows_setup rmdir /s /q %backendDir%\windows_setup
    )

    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'scripts\download_dependencies.ps1'"

    if exist models if not exist %backendDir%\models move /Y models %backendDir%\
    if exist redis  (
        if not exist %backendDir%\redis  move /Y redis\redis %backendDir%\
        rmdir /s /q redis
    )
    if exist venv (
        if not exist %backendDir%\venv   move /Y "venv\venv" %backendDir%\
        rmdir /s /q venv
    )

    REM if exist windows_packages_cpu (
    REM     if not exist %backendDir%\windows_packages_cpu    move /Y "windows_packages_cpu\windows_packages_cpu" %backendDir%\
    REM     rmdir windows_packages_cpu
    REM )
    REM if exist windows_packages_gpu (
    REM     if not exist %backendDir%\windows_packages_gpu    move /Y "windows_packages_gpu\windows_packages_gpu" %backendDir%\
    REM     rmdir windows_packages_gpu
    REM )
    REM if exist windows_setup (
    REM     if not exist %backendDir%\windows_setup    move /Y "windows_setup\windows_setup" %backendDir%\
    REM     rmdir windows_setup
    REM )
)

:: ===============================================================================================
:: 2. Create & Activate Virtual Environment from scratch (instead of the above download/unpack/copy)

::if exist %backendDir%\venv\ (
::	echo Virtual Environment Already Exists
::) else (
::	echo Creating Virtual Environment
::	python -m venv "%backendDir%\venv"
::)

echo Activating Virtual Environment
call %backendDir%\venv\Scripts\activate
if errorlevel 1 goto errorNoPythonVenv

:: Ensure Python Exists
python --version 3 > NUL
if errorlevel 1 goto errorNoPython
echo Python 3 is present

:: ===============================================================================================
:: 3. Installing Python packages
echo Installing Python Packages

:: Prepare to install dependencies
echo     Upgrading PIP 
python.exe -m pip install --upgrade pip -q -q

:: call pip3 install onnxruntime  :: ==0.4.0   
echo     PIP: Installing ONNX runtime
python.exe -m pip install onnxruntime   -q -q
echo     PIP: Installing Redis
python.exe -m pip install redis         -q -q
echo     PIP: Installing Python OpenCV
python.exe -m pip install opencv-python -q -q
echo     PIP: Installing Cython
python.exe -m pip install Cython        -q -q
echo     PIP: Installing Pillow
python.exe -m pip install pillow        -q -q
echo     PIP: Installing SciPy
python.exe -m pip install scipy         -q -q
echo     PIP: Installing TQDM
python.exe -m pip install tqdm          -q -q
echo     PIP: Installing TensorBoard
python.exe -m pip install tensorboard   -q -q
echo     PIP: Installing Torch
python.exe -m pip install torch         -q -q
echo     PIP: Installing TorchVision
python.exe -m pip install torchvision   -q -q
echo     PIP: Installing PyYAML
python.exe -m pip install PyYAML        -q -q
echo     PIP: Installing MatPlotLib
python.exe -m pip install Matplotlib    -q -q

:: ===============================================================================================
:: 4. Copy over the AI engine itself
echo Copying over backend Python Intelligence layer

:: /NFL : No File List - don't log file names.
:: /NDL : No Directory List - don't log directory names.
:: /NJH : No Job Header.
:: /NJS : No Job Summary.
:: /NP  : No Progress - don't display percentage copied.
:: /NS  : No Size - don't log file sizes.
:: /NC  : No Class - don't log file classes.

robocopy /e ..\backend\DeepStack %backendDir%\DeepStack /NFL /NDL /NJH /NJS /nc /ns

:: ===============================================================================================
:: 5. Build and copy over front end server
echo Preparing front end server

:: Check for Go Installation
go version > NUL
if errorlevel 1 goto errorNoGolang
echo Go is installed

:: Check for redis
setlocal enableextensions
Set redisOuput=""
for /f "usebackq tokens=1" %%P in (`redis-cli ping`) do ( set redisOuput=%%P ) 
if %redisOuput% NEQ PONG goto errorNoRedis
echo Redis is installed

:: Build the server executable and copy over
cd ..\server
go build -o %appName%.exe server.go
copy %appName%.exe %appDir%
if not exist %appDir%\templates mkdir %appDir%\templates
copy  templates %appDir%\templates

:: Set the port
set PORT=5000
set RULE_NAME="Open Port %PORT% for %appName%"

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if not ERRORLEVEL 1 (
    rem Rule %RULE_NAME% already exists.
    echo Port %PORT% is open and ready
) else (
    echo Opening port for %appName%
    netsh advfirewall firewall add rule name=%RULE_NAME% dir=in action=allow protocol=TCP localport=%PORT%
)


:: ===============================================================================================
:: 6. Let's do this!

echo STARTING SERVER

:: Environment variables
set PROFILE="windows_native"
set DATA_DIR="Data"
set TEMP_PATH="Temp"
set APPDIR=%appDir%

:: turn on some features
set VISION_FACE=true
set VISION_DETECTION=true
set VISION_SCENE=true

cd %appDir%
%appName%.exe

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
echo -----------------------------------------------------------------------------------
echo Error: Python not installed
echo Go to https://www.python.org/downloads/ for the latest version of Python
goto:eof

:errorNoPythonVenv
echo -----------------------------------------------------------------------------------
echo Error: Python Virtual Environment activation failed
echo Go to https://www.python.org/downloads/ for the latest version
goto:eof

:errorNoGolang
echo -----------------------------------------------------------------------------------
echo Error: Go not installed
echo Go to https://golang.org/doc/install#download for the latest version of Go

:errorNoRedis
echo -----------------------------------------------------------------------------------
echo Error: Redis not installed or not running
echo Go to https://github.com/dmajkic/redis/downloads for the latest version of Redis for Windows

:eof