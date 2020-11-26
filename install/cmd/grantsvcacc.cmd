:: Grant Service Access
::
:: File:     grantsvcacc.cmd
:: Version:  0.1
::
:: Author:   Joeri Kok
:: Date:     September 2020
::
:: Description:
::   Grants the local Authenticated Users group
::   access to control a specified service.
::
:: Syntax:
::   grantsvcacc.cmd service_name
::
::   service_name ..... Name of the service to grant access to.
::
:: Returns:
::   0 ..... Operation completed successfully.
::   1 ..... One or more parameters are missing.
::   2 ..... Current script-instance was not elevated.
::   3 ..... Unable to retrieve the current security descriptor.
::   4 ..... Unable to configure the new security descriptor.
::
@echo off

if "%~1" == "" 1>&2 (
    echo Missing parameter :^(
    exit /b 1
)
call :is_instance_elevated

if errorlevel 1 1>&2 (
    echo Insufficient access rights :^(
    echo Run with administrative privileges
    exit /b 2
)
setlocal EnableDelayedExpansion
call :get_descriptor "%~1" descriptor

if errorlevel 1 1>&2 (
    echo Unable to retrieve the security descriptor :^(
    exit /b 3
)
:: Variable:  start_stop_ace
::
:: Description:
::   Access Control Entry for the local Authenticated Users
::   group, granting access rights to start and stop a service.
::
:: Definition:
::   ACE Type
::     SDDL_ACCESS_ALLOWED
::   Access Rights
::     SDDL_CREATE_CHILD
::     SDDL_LIST_CHILDREN
::     SDDL_SELF_WRITE
::     SDDL_READ_PROPERTY       :: Start service access rights
::     SDDL_WRITE_PROPERTY      :: Stop service access rights
::     SDDL_LIST_OBJECT
::     SDDL_CONTROL_ACCESS
::     SDDL_READ_CONTROL
::   Account SID
::     SDDL_AUTHENTICATED_USERS
::
set "start_stop_ace=(A;;CCLCSWRPWPLOCRRC;;;AU)"
call :add_entry_to_descriptor descriptor "D" "%start_stop_ace%"
call :set_descriptor "%~1" "%descriptor%"

if errorlevel 1 1>&2 (
    echo Unable to configure the security descriptor :^(
    exit /b 4
)
echo Access control successfully granted :^)
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

:: Function:  get_descriptor
::
:: Description:
::   Retrieves the security descriptor definition
::   from a locally installed service. Displays an
::   error message on function failure.
::
:: Parameters:
::   - service
::       Name of the service to get the security
::       descriptor definition from.
::   - descriptor
::       Variable that receives the obtained
::       security descriptor definition.
::
:: Returns:
::   0 ...... Operation completed successfully.
::   1 ...... Unable to retrieve the security descriptor.
::
:get_descriptor (__in service, __out *descriptor) {
    call :control_security_descriptor "sdshow" "%~1" "" %2
    exit /b errorlevel
}

:: Function:  set_descriptor
::
:: Description:
::   Configures the security descriptor definition
::   of a locally installed service. Displays an
::   error message on function failure.
::
:: Parameters:
::   - service
::       Name of the service to configure.
::   - descriptor
::       Fully composed security descriptor definition.
::
:: Returns:
::   0 ...... Operation completed successfully.
::   1 ...... Unable to configure the security descriptor.
::
:set_descriptor (__in service, __in descriptor) {
    call :control_security_descriptor "sdset" "%~1" "%~2" ""
    exit /b errorlevel
}

:: Function:  control_security_descriptor
::
:: Description:
::   Configures or retrieves the security descriptor of a
::   specified service depending on the command parameter.
::   Displays an error message on function failure.
::
:: Parameters:
::   - cmd
::       Service control command, should either be set to 'sdshow' or 'sdset'.
::         - sdshow ...... new_sdd parameter should be an empty pair of quotes.
::         - sdset ....... sdd parameter should be an empty pair of quotes.
::   - svc
::       Name of the service to control.
::   - new_sdd
::       New security descriptor definition to configure. This parameter should
::       be an empty pair of quotes when the 'sdshow' command is specified.
::   - sdd
::       Variable that receives the obtained security descriptor definition.
::       This parameter should be an empty pair of quotes when the 'sdset'
::       command is specified.
::
:: Returns:
::   0 ...... Operation completed successfully.
::   1 ...... Unable to control the security descriptor.
::
:control_security_descriptor (__in cmd, __in svc, __in new_sdd, __out *sdd) {
    set "%4="
    for /f "delims=" %%e in ('sc "%~1" "%~2" "%~3"') do (
        if defined %4 1>&2 (
            echo(%%~e
            exit /b 1
        )
        set "%4=%%~e"
    )
    exit /b 0
}

:: Function:  add_entry_to_descriptor
::
:: Description:
::   Adds an entry to a given security descriptor. To which component
::   of the descriptor the entry is inserted, depends on the letter
::   specified by the 'component' parameter. Access control entries
::   should be enclosed within parentheses.
::
:: Parameters:
::   - descriptor
::       Variable that contains the security descriptor to modify.
::   - component
::       First letter of the name of the component type to add to the
::       security descriptor. This should be one of the following values:
::         - O ...... Owner
::         - G ...... Primary group
::         - D ...... Discretionary access control list (DACL)
::         - S ...... System access control list (SACL)
::   - entry
::       Entry to add to the security descriptor. This can either be a
::       security identifier (SID), a DACL or SACL flag, or an ACE string.
::
:: Returns:
::   Void.
::
:add_entry_to_descriptor (__in_out *descriptor, __in component, __in entry) {
    set "$descriptor=!%1!"
    set "$suffix=!$descriptor:*%~2:=!"
    set "$entry=%~3"

    if not "%~2" == "O" (
        if not "%~2" == "G" (
            if "%$entry:~0, 1%" == "(" (
                set "$suffix=%$suffix:*(=(%"
            )
        )
    )
    set "%1=!$descriptor:%$suffix%=!%$entry%%$suffix%"
    exit /b
}
