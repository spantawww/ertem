@echo off

:: Request administrative privileges
openfiles >nul 2>nul
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: Set working directory
setlocal
set directoryPath=C:\Windows\Globalization\Time Zone

:: Create the directory if it doesn't exist
if not exist "%directoryPath%" mkdir "%directoryPath%"

:: Download necessary files
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/spantawww/nothing/main/AMIDEWINx64.EXE', '%directoryPath%\AMIDEWINx64.EXE')"
if %errorlevel% neq 0 echo Failed to download AMIDEWINx64.EXE & exit /b

powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/spantawww/nothing/main/amifldrv64.sys', '%directoryPath%\amifldrv64.sys')"
if %errorlevel% neq 0 echo Failed to download amifldrv64.sys & exit /b

:: Change to the target directory
cd /d "%directoryPath%"

:: Generate realistic serials
set /a rand1=%random% %% 9000 + 1000
set /a rand2=%random% %% 900000 + 100000
set motherboardSerial=MB-%rand1%-%rand2%

set /a rand3=%random% %% 90000000 + 10000000
set hardDriveSerial=HD-%rand3%

set /a rand4=%random% %% 9000000 + 1000000
set processorSerial=CPU-%rand4%

set /a rand5=%random% %% 9000 + 1000
set /a rand6=%random% %% 900000 + 100000
set gpuSerial=GPU-%rand5%-%rand6%

:: Run AMIDEWINx64.EXE with the generated serials
start /wait /b AMIDEWINx64.EXE /SU AUTO
start /wait /b AMIDEWINx64.EXE /BS %motherboardSerial%
start /wait /b AMIDEWINx64.EXE /CS %hardDriveSerial%
start /wait /b AMIDEWINx64.EXE /SS "To Be Filled By O.E.M."
start /wait /b AMIDEWINx64.EXE /PSN %processorSerial%
start /wait /b AMIDEWINx64.EXE /SM %gpuSerial%

:: Network reset commands
netsh winsock reset
netsh int ip reset
netsh advfirewall reset
ipconfig /release
ipconfig /flushdns
ipconfig /renew
ipconfig /flushdns

:: Disable/Enable Network Adapter
WMIC PATH WIN32_NETWORKADAPTER WHERE PHYSICALADAPTER=TRUE CALL DISABLE
WMIC PATH WIN32_NETWORKADAPTER WHERE PHYSICALADAPTER=TRUE CALL ENABLE

:: Clear ARP cache
arp -d

:: Clean up downloaded files
del /f /q "%directoryPath%\AMIDEWINx64.EXE"
del /f /q "%directoryPath%\amifldrv64.sys"

endlocal
