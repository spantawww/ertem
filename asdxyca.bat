@echo off
color A
title ARP Spoofing and Network Configuration Script
echo Running script... Please ensure you have administrative privileges.

setlocal EnableDelayedExpansion

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrative privileges.
    pause
    exit /b
)

:: Disable IPv6 and Network Discovery
echo Disabling IPv6 and Network Discovery...
netsh interface ipv6 uninstall >nul 2>&1
netsh advfirewall firewall set rule group="Network Discovery" new enable=no >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v DisabledComponents /t REG_DWORD /d 0xFFFFFFFF /f >nul

:: Clear ARP Cache
echo Clearing ARP cache...
arp -d >nul 2>&1

:: Reset Network Stack
echo Resetting network stack...
netsh winsock reset >nul
netsh int ip reset >nul

:: Randomize Key Settings
set "KEY_NAME=HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters"
set "RANDOM_DNS="
for /l %%i in (1,1,14) do (
    set /a byte=!random! %% 256
    set "hexValue=00!byte!"
    set "hexValue=!hexValue:~-2!"
    set "RANDOM_DNS=!RANDOM_DNS!!hexValue!"
)
reg add "%KEY_NAME%" /v Dhcpv6DNSServers /t REG_BINARY /d !RANDOM_DNS! /f >nul

:: Flush DNS and Renew IPs
echo Flushing DNS and renewing IP addresses...
ipconfig /flushdns >nul
ipconfig /release >nul
ipconfig /renew >nul

:: Disable/Enable Network Adapters
echo Disabling and re-enabling network adapters...
WMIC PATH WIN32_NETWORKADAPTER WHERE PHYSICALADAPTER=TRUE CALL DISABLE >nul
timeout /t 3 >nul
WMIC PATH WIN32_NETWORKADAPTER WHERE PHYSICALADAPTER=TRUE CALL ENABLE >nul

:: Countdown to Completion
echo Script execution complete. Exiting in 5 seconds...
for /l %%i in (5,-1,1) do (
    echo %%i
    timeout /nobreak /t 1 >nul
)

exit /b
