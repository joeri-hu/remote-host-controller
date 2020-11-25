/* to-do: documentation
*/
#include command.ahk

class vpn_connection {
    __new(ByRef service_name, ByRef addr_pool_regex) {
        this.service_name := service_name
        this.addr_pool_regex := addr_pool_regex
        this.construct_commands()
    }

    construct_commands() {
        start_vpn := new command("net start {}")
        stop_vpn := new command("net stop {}")
        query_vpn_info := new command("sc queryex {}")
        verify_inactive_service := new command(
            + "findstr /r /c:""^ *STATE *: 1 """)
        query_inactive_vpn := command
            .chain(query_vpn_info, "|", verify_inactive_service)

        this.stop_active_vpn := command
            .chain(query_inactive_vpn, "||", stop_vpn)
            .bind_all(this.service_name)
        this.restart_vpn := command
            .chain(this.stop_active_vpn, "&", start_vpn)
            .bind_all(this.service_name)
    }

    create_vpn_tunnel() {
        if (not this.restart_vpn.exec_cmd()) {
            throw Exception(Format(
                + "Unable to start service: {} :("
                , this.service_name))
        }
    }

    close_vpn_tunnel() {
        if (not this.stop_active_vpn.exec_cmd()) {
            throw Exception(Format(
                + "Unable to stop service: {} :("
                , this.service_name))
        }
    }

    wait_for_vpn_connection(query_limit := 96, interval_ms := 1000) {
        loop % query_limit {
            if (this.is_vpn_connected()) {
                return
            }
            Sleep, % interval_ms
        }
        throw Exception(Format(
            + "Unable to establish VPN connection :(`n`n"
            + "Service: {}`nIP range: {}"
            , this.service_name, this.addr_pool_regex))
    }

    ;// to-do: implement a robust way to detect the status
    ;//        of the vpn connection
    is_vpn_connected() {
        return RegExMatch(A_IPAddress1, this.addr_pool_regex)
    }

    set_service_name(ByRef service_name) {
        this.stop_active_vpn.bind_all(service_name)
        this.restart_vpn.bind_all(service_name)
        this.service_name := service_name
    }
}
