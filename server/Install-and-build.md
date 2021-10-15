# Building DeepStack Server

1. Download and install VSCode https://code.visualstudio.com/download<br><br>

2. Download and install Go https://golang.org/dl/. Choose default install locations (see GOPATH comment below)<br><br>

3. Install the Go Extensions to VS Code (eg https://marketplace.visualstudio.com/items?itemName=golang.go)<br><br>

4. Select the server.go file and hit "Run and Debug".
<br>It will fail. the extension will pop up a warning about not being able to find the path.<br><br>

5. You may see a popup at the bottom right asking you to install Go extensions that are needed. That will fail and eventually you'll be asked to ensure GOPATH is set in the settings. Either user or workspace. Choose Workspace so others get the benefit, but doing so will assume everyone has things installed in the same place. If you chose default settings and everyone's on the same OS this will be fine.<br><br>

6. When you click "Edit in settings" an empty settings.json file will be created and opened. Good luck! No help or guidance is provided. Enter
    ```json
        {
            "GOPATH": "C:\\Program Files\\Go"
        }
    ```
    and save the file<br><br>

8. Right-click on server.go and select "Run code". You may see:
    ```bash
    [Running] go run "c:\Dev\CodeProject\CodeProject.AI\DeepStack\server\server.go"
    go: could not create module cache: mkdir C:\Program Files\Go\pkg\mod: Access is denied.
    ```

9. So go ahead and create the \pkg\mod directory, but also create \pkg\mod\cache and then \pkg\mod\cache\download. Or just cut to the chase and **set \Go\pkg as writeable by anyone and be done with this**<br><br>

10. Run server.go. You'll see directories being made, stuff being downloaded, and then
    ```bash
      cgo: C compiler "gcc" not found: exec: "gcc": executable file not found in %PATH%
    ```
    That's right. You need gcc installed to run this bitch.<br><br>

11. [Don't do this] You can try http://win-builds.org/doku.php/download_and_installation_from_windows but it will do your head in. Win-builds installs itself in a local virtual store even though you tell it to install itself in, say, c:\Program Files\WinBuilds. And what it installs (at least for me) in the virtual store is empty directories.<br>
This is a dead end<br><br>

13. [Don't do this] You could also try https://sourceforge.net/projects/mingw/files/Installer/mingw-get-setup.exe/download and download that instead. Run the installer.After completion the setup manager will be shown. Out of the numerous check boxes presented to you on the right side, tick "mingw32-gcc-g++-bin". If you are prompted with a menu, click on Mark for Install. Then on the top left corner click on Installation > Apply Changes. And wait while it downloads a billion files and installs them.<br>
Except this won't work because that's the 32bit. You need. https://sourceforge.net/projects/mingw-w64/files/latest/download. Except that's the source code, not an installer<br><br>

14. Download MSYS2 from https://github.com/msys2/msys2-installer/releases/download/2021-06-04/msys2-x86_64-20210604.exe. Go to https://www.msys2.org/ and read the instructions. Bask in the glory of command line installations. (There is an option for VS Code integration. Read https://code.visualstudio.com/docs/cpp/config-mingw but it's the same steps more or less)<br>
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
    ```bash
    gcc (MinGW.org GCC Build-2) 9.2.0
    Copyright (C) 2019 Free Software Foundation, Inc.
    This is free software; see the source for copying conditions. 
    There is NO warranty; not even for MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.
    ```
    gcc has been successfully installed in your PC. You're all good to go, right?<br><br>

16. Wrong.
    ```bash
    go run "c:\Dev\CodeProject\CodeProject.AI\DeepStack\server\server.go"
    # github.com/mattn/go-sqlite3
    cgo: C compiler "gcc" not found: exec: "gcc": executable file not found in %PATH%
    ```
    You need to reboot your machine to ensure the environment ariables are being picked up

Once you've completed these steps then your machine should be setup correctly. Next time you just load up the server project in VS Code and hit "Run" on the server.go file and it'll work. Probably.