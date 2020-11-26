/* to-do: documentation
*/
#include ../enums/enums.ahk
#include ../network/network.ahk
#include ../system/power.ahk
#include ../system/rdp.ahk

class session_control {
__new(network_control, power_control, rdp_session_map) {
        this.network := network_control
        this.power := power_control
        this.rdp_sessions := rdp_session_map
    }

    control_remote_session() {
        this.select_active_session()

        if (this.active_session.window_handler.any_window_exists()) {
            if (this.network.icmp.is_host_reachable()) {
                this.close_remote_session()
                return
            } else {
                this.active_session.window_handler.close_all_windows()
            }
        }
        this.initiate_remote_session()
    }

    select_active_session() {
        this.network.update_active_profile()
        this.active_session
            := this.rdp_sessions[this.network.active_profile]
    }

    close_remote_session() {
        this.power.suspend_host()
        this.network.close_vpn_connection()
        this.active_session.window_handler.wait_for_closed_windows()
        this.session_state := enums.session_state.closed
    }

    initiate_remote_session() {
        if (this.network.is_active_profile_public()) {
            this.network.establish_vpn_connection()
        }
        this.establish_remote_connection()
        this.session_state := enums.session_state.initiated
    }

    establish_remote_connection(retry_limit := 24) {
        loop % retry_limit {
            if (this.network.icmp.is_host_reachable()) {
                this.active_session.rdp_handler.start_rdp_connections()
                return
            } else {
                this.power.wakeup_host()
            }
        }
        throw Exception(Format(
            + "Unable to establish remote connection :(`n`n"
            + "Host name: {}`nMAC address: {}"
            , this.network.icmp.host_name
            , this.power.host_mac_addr))
    }

    is_session_initiated() {
        return this.session_state == enums.session_state.initiated
    }

    is_session_closed() {
        return this.session_state == enums.session_state.closed
    }
}
