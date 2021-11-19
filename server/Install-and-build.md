# Building DeepStack Server

## To compile and run within VS Code

1.  Download and install VSCode https://code.visualstudio.com/download<br><br>

2.  Download and install Go https://golang.org/dl/. Choose default install locations (see GOPATH comment below)<br><br>

3.  Install the Go Extensions to VS Code (eg https://marketplace.visualstudio.com/items?itemName=golang.go)<br><br>

4.  Add the path to Go in the setting.json file for VS Code. Botton left of the VS Code Window is the settings button. Hit
    that, choose settings, Choose workspace (top of page, next to "User") scroll down till you see a "Edit in settings.json" 
    link, click it and add
    ```json
    "go.gopath": "C:\\Program Files\\Go",
    ```
    to the file. Save and close.

5.  Right-click on server.go and select "Run code". You may see:
    ```bash
    [Running] go run "c:\Dev\CodeProject\CodeProject.AI\DeepStack\server\server.go"
    go: could not create module cache: mkdir C:\Program Files\Go\pkg\mod: Access is denied.
    ```

9.  So go ahead and create the \pkg\mod directory, but also create \pkg\mod\cache and then \pkg\mod\cache\download.
    Or just cut to the chase and **set \Go\pkg as writeable by anyone and be done with this**<br><br>

10. Run server.go. You'll see directories being made, stuff being downloaded, and then
    ```bash
      cgo: C compiler "gcc" not found: exec: "gcc": executable file not found in %PATH%
    ```
    That's right. You need gcc installed to run this bitch.<br><br>

14. Download MSYS2 from https://github.com/msys2/msys2-installer/releases/download/2021-06-04/msys2-x86_64-20210604.exe. 
    Go to https://www.msys2.org/ and read the instructions. Bask in the glory of command line installations.'
    (There is an option for VS Code integration. Read https://code.visualstudio.com/docs/cpp/config-mingw but it's the 
    same steps more or less)<br>
    But in a nutshell:<br>
    - Download the  installer: msys2-x86_64-20210725.exe. Run the install and click next until it's done
    - A command window will open. Run "pacman -Syu", and select "Y" to "install packages". The window will then tell you it needs to close
    - Go to the directory you installed MSYS2 and run "MSYS2.exe". Run the command "pacman -Su" to install the rest of the packages
    - **Now we get to install gcc**. Run "pacman -S --needed base-devel mingw-w64-x86_64-toolchain" and hit Enter (default) when it asks, and "y" to "do you want to do the thing you've been trying  to do for the last hour?".
    - The webpage suggests you now run "MSYS.exe MinGW 64-bit". Don't. This doesn't work nor is it needed.
    - Add "C:\msys64\mingw64\bin" to your PATH environment variable (adjust if you installed in a non-default location). To do this Start -> type "environment" and choose "Edit the System  Environment variables" and it should make sense from there.<br><br>

15. Reboot your machine.<br><br>

16. **Alternative** Try https://jmeubank.github.io/tdm-gcc/download/<br><br>

15. Open a Command Prompt Terminal and try typing gcc --version and press Enter. If you get something like
    ```text
    gcc (MinGW.org GCC Build-2) 9.2.0
    Copyright (C) 2019 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions. 
    There is NO warranty; not even for MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.
    ```
    gcc has been successfully installed in your PC. You're all good to go, right?<br><br>

16. Maybe. You may still get something like:
    ```bash
    go run "c:\Dev\CodeProject\CodeProject.AI\DeepStack\server\server.go"
    # github.com/mattn/go-sqlite3
    cgo: C compiler "gcc" not found: exec: "gcc": executable file not found in %PATH%
    ```
    You may need to reboot your machine to ensure the environment ariables are being picked up

17. Right-click on server.go and select "Run code".

    Bask in your glory

Once you've completed these steps then your machine should be setup correctly. Next time you just load up the server project in VS Code and hit "Run" on the server.go file and it'll work. Probably.

## To build a standalone executable

```cmd
go build -o deepstack.exe server.go
```