/* to-do: documentation
*/
#include ../core/command.ahk
#include ../enums/enums.ahk
#include ../network/icmp.ahk
#include ../network/vpn.ahk

class network {
    is_wifi_connected() {
        static query_wlan_info := new command(
            + "netsh wlan show interfaces")
        static verify_active_wifi := new command(
            + "findstr /r /c:""^ *SSID *:""")
        static query_active_wifi := command
            .chain(query_wlan_info, "|", verify_active_wifi)
        return query_active_wifi.exec_cmd()
    }
}

class network_control {
    static active_profile := enums.network_profile.undefined

    __new(icmp_connection, vpn_connection) {
        this.icmp := icmp_connection
        this.vpn := vpn_connection
    }

    establish_vpn_connection() {
        if (not this.vpn.is_vpn_connected()) {
            this.vpn.create_vpn_tunnel()
            this.vpn.wait_for_vpn_connection()
        }
    }

    close_vpn_connection() {
        if (this.vpn.is_vpn_connected()) {
            this.vpn.close_vpn_tunnel()
        }
    }

    is_active_profile_public() {
        return network_control.active_profile 
            == enums.network_profile.public
    }

    is_active_profile_private() {
        return network_control.active_profile
            == enums.network_profile.private
    }

    update_active_profile() {
        network_control.active_profile
            := network.is_wifi_connected()
                ? enums.network_profile.public
                : enums.network_profile.private
    }
}
