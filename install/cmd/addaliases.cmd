:: Add DNS Aliases
::
:: File:     addaliases.cmd
:: Version:  0.2
::
:: Author:   Joeri Kok
:: Date:     September 2020
::
:: Description:
::   Adds one or more DNS aliases of a specified NetBIOS
::   host name to the 'hosts' file of the local system.
::
:: Syntax:
::   addaliases.cmd ip_address dns_alias [dns_aliases...]
::
::   ip_address ........ Target IP address to create an alias for.
::   dns_alias ......... Name of the DNS alias for the IP address.
::   dns_aliases ....... Additional DNS aliases which are optional.
::
:: Returns:
::   0 ..... Operation completed successfully.
::   1 ..... One or more parameters are missing.
::   2 ..... Current script-instance was not elevated.
::   3 ..... Target host name was not located on local network.
::   4 ..... DNS entry was not added to 'hosts' file of local system.
::
@echo off

if "%~2" == "" 1>&2 (
    echo Missing parameter^(s^) :^(
    exit /b 1
)
call :is_instance_elevated

if errorlevel 1 1>&2 (
    echo Insufficient access rights :^(
    echo Run with administrative privileges
    exit /b 2
)
setlocal DisableDelayedExpansion
call :get_ip_address "%~1" ip_addr

if errorlevel 1 1>&2 (
    echo Unable to contact target host: "%~1"
    exit /b 3
)
:: Warning: Only supports argument expansion of non-special characters.
set "args=%*"
call :add_dns_alias "%ip_addr%" "%args:* =%"

if errorlevel 1 1>&2 (
    echo Unable to add DNS entry to 'hosts' file :^(
    exit /b 4
)
echo DNS alias^(es^) added successfully :^)
exit /b 0

:: Function:  is_instance_elevated
::
:: Description:
::   Verifies if the current script-instance is
::   running with administrative privileges.
::
:: Parameters:
::   None
::
:: Returns:
::   0 ...... Current instance is elevated.
::   1 ...... Current instance is not elevated.
::
:is_instance_elevated {
    net session 1>nul 2>&1
    exit /b errorlevel
}

:: Function:  get_ip_address
::
:: Description:
::   Retrieves an IP address from a host name
::   by using the NetBIOS protocol.
::
:: Parameters:
::   - host_name
::       NetBIOS name of the target host to query.
::   - ip_addr
::       Variable that receives the obtained IP address.
::
:: Returns:
::   0 ...... Operation completed successfully.
::   1 ...... Host name not found on local network.
::
:get_ip_address (__in host_name, __out *ip_addr) {
    for /f "delims=[] tokens=2" %%e in (
        '"ping /n 1 /l 0 /w 0 /4 %~1"'
    ) do (
        set "%2=%%e"
        exit /b 0
    )
    exit /b 1
}

:: Function:  add_dns_alias
::
:: Description:
::   Adds one or more DNS aliases of a specified
::   IP address to the 'hosts' file of the local system.
::
:: Warning:
::   Only supports argument expansion of non-special characters.
::
:: Parameters:
::   - ip_addr
::       IP address of the host to alias.
::   - aliases
::       Quoted string that contains one or more DNS aliases
::       separated by spaces.
::
:: Returns:
::   0 ...... Operation completed successfully.
::   1 ...... Unable to write to 'hosts' file of local system.
::
:add_dns_alias (__in ip_addr, __in aliases...) {
    2>nul (
        (echo(%~1 %~2) 1>>"%WinDir%\system32\drivers\etc\hosts"
    ) && (
        exit /b 0
    ) || (
        exit /b 1
    )
}
