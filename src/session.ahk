/* to-do: documentation
*/
#include power.ahk
#include network.ahk
#include rdp.ahk

class session {
    static state := {initiated: 1, closed: 2}
}

class session_control {
    __new(power_control, network_control, rdp_session_map) {
        this.power := power_control
        this.network := network_control
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
        this.session_state := session.state.closed
    }

    initiate_remote_session() {
        if (this.network.is_active_profile_public()) {
            this.network.establish_vpn_connection()
        }
        this.establish_remote_connection()
        this.session_state := session.state.initiated
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
        return this.session_state == session.state.initiated
    }

    is_session_closed() {
        return this.session_state == session.state.closed
    }
}
