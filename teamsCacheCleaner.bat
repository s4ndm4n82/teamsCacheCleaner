@ECHO OFF
:: Setting the command prompt title.
TITLE Teams Catche Cleaner
:: Setting the command prompt color to look like Matrix ;-).
COLOR 02
CLS

:: Variables
SETLOCAL EnableDelayedExpansion
SET currentDirectory="%~dp0"
SET testTeamsPath="%LOCALAPPDATA%\Microsoft"
:: SET testTeamsPath="%LOCALAPPDATA%\Microsoft\Logs"
SET downloadDirectory="%USERPROFILE%\Downloads"
SET getFile=curl -# "https://statics.teams.cdn.office.net/production-windows-x64/1.4.00.22976/Teams_windows_x64.exe" -o %downloadDirectory%\Teams_windows_x64.exe

:: Folder paths
SET mainCache="%APPDATA%\Microsoft\Teams\Cache"
SET blobStorag="%APPDATA%\Microsoft\Teams\blob_storage"
SET dataBases="%APPDATA%\Microsoft\Teams\databases"
SET gpuCache="%APPDATA%\Microsoft\Teams\GPUCache"
SET indexedDB="%APPDATA%\Microsoft\Teams\IndexedDB"
SET localStorage="%APPDATA%\Microsoft\Teams\Local Storage"
SET TMP="%APPDATA%\Microsoft\Teams\tmp"

:: Getting Admin right for the batch file.
::----------------------------------------------------
:: Permission check.
  IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
    >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
  ) ELSE (
    >nul 2>&1 "%SYSTEMROOT%\System32\cacls.exe" "%SYSTEMROOT%\System32\config\system"
  )

:: If error flag is 1 then we are not Admin.
  IF '%ERRORLEVEL%' NEQ '0' (
    ECHO Need to be Administrator to run ....
    GOTO getUACPrompt
  ) ELSE ( GOTO runCode)

  :getUACPrompt
    ECHO SET UAC = CreateObject^("Shell.Application"^) > "%TEMP%\getadmin.vbs"
    SET PARAMS= %*
    ECHO UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%TEMP%\getadmin.vbs"

    "%TEMP%\getadmin.vbs"
    DEL "%TEMP%\getadmin.vbs"
    EXIT /B

:runCode
:: Set the current working directory istead if C:\Windows\Systems32.
PUSHD %currentDirectory%
CD /D %currentDirectory%

:: Test if Microsoft Teams exits.
WHERE /Q /R %testTeamsPath% Teams.exe 2> NUL
CLS
IF ERRORLEVEL 1 (
  :: If Teams does not exisit this will take the user to download page.
  ECHO.
  ECHO  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ECHO  + Teams not seems to be installed on this system.          +
  ECHO  + Program will now take you to install menu in 5 seconds.  +
  ECHO  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ECHO.
  ECHO Switching to installer menu .... !
  TIMEOUT /T 5 /NOBREAK > NUL
  GOTO installMenu
) ELSE (
  :: If Team exisits this will continue to the cleaning section.
  GOTO mainMenu
)

:: Start of main menu area.
:mainMenu
:: Variable to check the entered options.
SET checkOption=false

CALL :mainMenuBanner
ECHO        1) Clean Teams Cache  2) Install Teams 3) Exit Cleaner
ECHO  ------------------------------------------------------------------
ECHO.
SET /P cleanerChoice="Enter your choice [1 or 2 or 3]: "

:: Checking the entered choice to see if it's valid.
:: If valid the right action will be taken.
IF %cleanerChoice% EQU 1 (
  SET checkOption=true
  GOTO startCleaner
)

IF %cleanerChoice% EQU 2 (
  SET checkOption=true
  GOTO downloadTeams
)

IF %cleanerChoice% EQU 3 (
  SET checkOption=true
  GOTO exitCleaner
)

:: If not accepted throws back to the main installation menu.
IF %checkOption% EQU false (
  ECHO.
  ECHO Not a valid choice .... Please try again.
  TIMEOUT /T 3 /NOBREAK > NUL
  GOTO mainMenu
)
EXIT /B
:: End of main menu

:: Start of cleaner area.
:startCleaner
CALL :mainMenuBanner
ECHO.
ECHO Checking if teams running or not ....
TIMEOUT /T 4 /NOBREAK > NUL
ECHO.
QPROCESS "Teams.exe" 2> NUL

IF %ERRORLEVEL% EQU 0 (
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Found teams running and closing it now ....
  ECHO.
  TASKKILL /T /F /FI "IMAGENAME eq teams.exe" /IM teams.exe
  ECHO.
  ECHO Done.
  TIMEOUT /T 3 /NOBREAK > NUL
  GOTO folderClean
) ELSE (
  CALL :mainMenuBanner
  ECHO.
  ECHO Checking Teams foleder location .....
  WHERE /Q /R %testTeamsPath% Teams.exe 2> NUL  
  IF %ERRORLEVEL% EQU 1 (
    CLS
    CALL :mainMenuBanner
    ECHO.
    ECHO Folders found starting the clean process ....
    TIMEOUT /T 3 /NOBREAK > NUL
    GOTO folderClean
  ) ELSE (
    CLS
    CALL :mainMenuBanner
    ECHO.
    ECHO Nothing found returning to main menu and recomend installing first ....
    TIMEOUT /T 3 /NOBREAK > NUL
    GOTO mainMenu
  )
)
EXIT /B
:: End of cleaner area.

:: Starting folder cleaning area.
:folderClean
:: Variable for checking the folder empty or not.
SET checkEmpty=true

CLS
CALL :mainMenuBanner
ECHO.
ECHO Checking folder for content ....
FOR /F %%i IN ('DIR /B /A %mainCache%') DO (
    SET checkEmpty=false
)

IF %checkEmpty% EQU false (
    PUSHD %mainCache%
    CD /D %mainCache%
    ECHO Cleaning %mainCache% ....
    DEL /F /S /Q *
    RD /S /Q . 2> NUL
    PAUSE
    TIMEOUT /T 2 /NOBREAK > NUL
    SET checkEmpty=true    
    CLS
) ELSE (  
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Folder is empty .... !
  TIMEOUT /T 2 /NOBREAK > NUL
  CLS
)

CALL :mainMenuBanner
ECHO.
FOR /F %%i IN ('DIR /B /A %blobStorag%') DO (
    SET checkEmpty=false
)

IF %checkEmpty% EQU false (
    PUSHD %blobStorag%
    CD /D %blobStorag%
    ECHO Cleaning %blobStorag% ....
    DEL /F /S /Q *
    RD /S /Q . 2> NUL
    TIMEOUT /T 2 /NOBREAK > NUL
    SET checkEmpty=true
    CLS
) ELSE (  
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Foler is empty .... !
  TIMEOUT /T 2 /NOBREAK > NUL
  CLS
)

CALL :mainMenuBanner
ECHO.
FOR /F %%i IN ('DIR /B /A %dataBases%') DO (
    SET checkEmpty=false    
)

IF %checkEmpty% EQU false (
    PUSHD %dataBases%
    CD /D %dataBases%
    ECHO Cleaning %dataBases% ....
    DEL /F /S /Q *
    RD /S /Q . 2> NUL
    TIMEOUT /T 2 /NOBREAK > NUL
    SET checkEmpty=true
    CLS
) ELSE (  
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Foler is empty .... !
  TIMEOUT /T 2 /NOBREAK > NUL
  CLS
)

CALL :mainMenuBanner
ECHO.
FOR /F %%i IN ('DIR /B /A %gpuCache%') DO (
    SET checkEmpty=false
)

IF %checkEmpty% EQU false (
    PUSHD %gpuCache%
    CD /D %gpuCache%
    ECHO Cleaning %gpuCache% ....
    DEL /F /S /Q *
    RD /S /Q . 2> NUL
    TIMEOUT /T 2 /NOBREAK > NUL
    SET checkEmpty=true
    CLS
) ELSE (
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Foler is empty .... !
  TIMEOUT /T 2 /NOBREAK > NUL
  CLS
)

CALL :mainMenuBanner
ECHO.
FOR /F %%i IN ('DIR /B /A %indexedDB%') DO (
    SET checkEmpty=false
)

IF %checkEmpty% EQU false (
    PUSHD %indexedDB%
    CD /D %indexedDB%
    ECHO Cleaning %indexedDB% ....
    DEL /F /S /Q *
    RD /S /Q . 2> NUL
    TIMEOUT /T 2 /NOBREAK > NUL
    SET checkEmpty=true
    CLS
) ELSE (
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Foler is empty .... !
  TIMEOUT /T 2 /NOBREAK > NUL
  CLS
)

CALL :mainMenuBanner
ECHO.
FOR /F %%i IN ('DIR /B /A %localStorage%') DO (
    SET checkEmpty=false
)

IF %checkEmpty% EQU false (
    PUSHD %localStorage%
    CD /D %localStorage%
    ECHO Cleaning %localStorage% ....
    DEL /F /S /Q *
    RD /S /Q . 2> NUL
    TIMEOUT /T 2 /NOBREAK > NUL
    SET checkEmpty=true
    CLS
) ELSE (
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Foler is empty .... !
  TIMEOUT /T 2 /NOBREAK > NUL
  CLS
)

CALL :mainMenuBanner
ECHO.
FOR /F %%i IN ('DIR /B /A %TMP%') DO (
    SET checkEmpty=false
)

IF %checkEmpty% EQU false (
    PUSHD %TMP%
    CD /D %TMP%
    ECHO Cleaning %TMP% ....
    DEL /F /S /Q *
    RD /S /Q . 2> NUL
    TIMEOUT /T 2 /NOBREAK > NUL
    SET checkEmpty=true
    CLS
) ELSE (
  CLS
  CALL :mainMenuBanner
  ECHO.
  ECHO Foler is empty .... !
  TIMEOUT /T 2 /NOBREAK > NUL
  CLS
)

CALL :mainMenuBanner
PUSHD %currentDirectory%
CD /D %currentDirectory%
ECHO.
ECHO Done cleaning all the folders. Returning to main menu .... !
ECHO.
TIMEOUT /T 3 /NOBREAK > NUL
GOTO mainMenu 
EXIT /B
:: End of folder cleaning area.

:: Installe menu.
:installMenu
:: Variable to check the entered option is equal to 1 or 2.
SET optionCheck=false

CALL :installBanner
ECHO        1) Continue to Teams installation   2) I wish to exit.
ECHO  ------------------------------------------------------------------
ECHO.
SET /P installChoice="Enter your choice [1 or 2]: "

:: Check the entered choice if to see it's valide or not.
:: If valid the right action will be taken.
IF %installChoice% EQU 1 (
  SET optionCheck=true
  GOTO downloadTeams
)

IF %installChoice% EQU 2 (
  SET optionCheck=true
  GOTO exitCleaner
)

:: If not accepted throws back to the main installation menu.
IF %optionCheck% EQU false (
  ECHO.
  ECHO Not a valide choice .... Please try again.
  TIMEOUT /T 3 /NOBREAK > NUL
  GOTO installMenu
)
EXIT /B

:downloadTeams
CLS
WHERE /Q /R %downloadDirectory% Teams_windows_x64.exe 2> NUL
IF ERRORLEVEL 1 (
  CALL :installBanner
  ECHO.
  ECHO Downloading Teams .... !
  %getFile%
  IF %ERRORLEVEL% NEQ 1 (
    CLS
    CALL :installBanner
    ECHO.
    ECHO Something went wrong tying again .... !
    %getFile%
    IF %ERRORLEVEL% NEQ 1 (
      CLS
      CALL :installBanner
      ECHO.
      ECHO Didn't work ... Time to exit.
      TIMEOUT /T 5 /NOBREAK > NUL
      GOTO mainMenu
    )
  ) ELSE (
    GOTO installTeams
  )
) ELSE (
  GOTO installTeams
)

:installTeams
CLS
CALL :installBanner
ECHO.
ECHO Starting Teams Installer .... !
START /B /W /D %downloadDirectory% Teams_windows_x64.exe
TIMEOUT /T 5 /NOBREAK > NUL
  IF %ERRORLEVEL% EQU 0 (
    CLS
    CALL :installBanner
    ECHO.
    ECHO Teams installer started successfully. Returning to main menu .... !
    TIMEOUT /T 3 /NOBREAK > NUL
    GOTO mainMenu
  ) ELSE (
    CLS
    ECHO.
    CALL :installBanner
    ECHO Trying one last time .... !
    START /B /WAIT /D %downloadDirectory% Teams_windows_x64.exe
      IF %ERRORLEVEL% EQU 0 (
        CLS
        CALL :installBanner
        ECHO.
        ECHO Teams installer started successfully. Returning to main menu .... !
        TIMEOUT /T 3 /NOBREAK > NUL
        GOTO mainMenu
      ) ELSE (
        CLS
        CALL :installBanner
        ECHO.
        ECHO Didn't work .... Time to exit ...!
        TIMEOUT /T 3 /NOBREAK > NUL
        GOTO exitCleaner
      )
  )
EXIT /B

:: Banner Section (Just for banners)
:mainMenuBanner
CLS
ECHO.
ECHO               ++++++++++++++++++++++++++++++++++++++++
ECHO               ++                                    ++
ECHO               ++        Teams Catche Cleaner        ++
ECHO               ++                                    ++
ECHO               ++  Version: 0.1.0.1                  ++
ECHO               ++++++++++++++++++++++++++++++++++++++++
ECHO.
ECHO  ------------------------------------------------------------------
EXIT /B

:installBanner
CLS
ECHO.
ECHO               ++++++++++++++++++++++++++++++++++
ECHO               ++                              ++
ECHO               ++  Installing Microsoft Teams  ++
ECHO               ++                              ++
ECHO               ++++++++++++++++++++++++++++++++++
ECHO.
ECHO  ------------------------------------------------------------------
EXIT /B

:exitCleaner
CALL :mainMenuBanner
ECHO.
ECHO Exiting the cleaner. Thank you .... !
ECHO.
TIMEOUT /T 3 /NOBREAK > NUL
EXIT > NUL