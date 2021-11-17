REM DeepStack Windows install script
@echo off

rem This file is UTF-8 encoded, so update the current code page while executing it
for /f "tokens=2 delims=:." %%a in ('"%SystemRoot%\System32\chcp.com"') do (
    set _OLD_CODEPAGE=%%a
)
if defined _OLD_CODEPAGE (
    "%SystemRoot%\System32\chcp.com" 65001 > nul
)

cls

REM Check for Python Installation
python --version 3 > NUL
if errorlevel 1 goto errorNoPython
echo Python 3 is installed ==================================================

REM Check for Go Installation
go version > NUL
if errorlevel 1 goto errorNoGolang
echo Go is installed ========================================================

REM Create Virtual Environment
if exist venv\ (
	echo Virtual Environment Already Exists =====================================
) else (
	echo Creating Virtual Environment ===========================================
	py -m venv venv
)

echo Activating Virtual Environment =========================================

call .\venv\Scripts\activate

echo Python Executables are at ==============================================
where python
echo ========================================================================

echo Creating directories ===================================================

cd backend

if not exist deeptemp\ (
	mkdir deeptemp
)
if not exist datastore\ (
	mkdir datastore
)

PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& 'C:\Users\SE\Desktop\ps.ps1'"
rem ENV DATA_DIR /datastore
rem ENV TEMP_PATH /deeptemp/
rem ENV PROFILE desktop_cpu

echo Upgrading PIP ==========================================================
python.exe -m pip install --upgrade pip

echo Installing packages ====================================================
REM call pip3 install onnxruntime  REM ==0.4.0
call pip3 install onnxruntime
call pip3 install redis
call pip3 install opencv-python
call pip3 install Cython
call pip3 install pillow
call pip3 install scipy
call pip3 install tqdm
call pip3 install tensorboard
call pip3 install PyYAML
call pip3 install Matplotlib

echo ========================================================================
echo DONE ===================================================================
echo ========================================================================

/*
		RUN mkdir /app/sharedfiles
		COPY ./sharedfiles/yolov5m.pt /app/sharedfiles/yolov5m.pt
		COPY ./sharedfiles/face.pt /app/sharedfiles/face.pt
		COPY ./sharedfiles/facerec-high.model /app/sharedfiles/facerec-high.model
		COPY ./sharedfiles/scene.pt /app/sharedfiles/scene.pt
		COPY ./sharedfiles/categories_places365.txt /app/sharedfiles/categories_places365.txt

		RUN mkdir /app/server
		COPY ./server /app/server

		RUN mkdir /app/intelligencelayer
		COPY ./intelligencelayer /app/intelligencelayer

		COPY ./init.py /app 

		EXPOSE 5000

		WORKDIR /app/server

		CMD ["/app/server/server"]
*/

goto:eof

:: Reaching here means Python is installed.
:: Execute stuff...

:: All done
goto:eof

:errorNoPython
echo .
echo Error: Python not installed
echo Go to 
goto:eof

:errorNoGolang
echo .
echo Error: Go not installed
echo Go to https://golang.org/doc/install#download for the latest version of Go

:eof

if defined _OLD_CODEPAGE (
    "%SystemRoot%\System32\chcp.com" %_OLD_CODEPAGE% > nul
    set _OLD_CODEPAGE=
)