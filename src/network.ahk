/* to-do: documentation
*/
#include icmp.ahk
#include vpn.ahk
#include command.ahk

class network {
    static profile := {undefined: 0, public: 1, private: 2}

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
    static active_profile := network.profile.undefined

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
            == network.profile.public
    }

    is_active_profile_private() {
        return network_control.active_profile
            == network.profile.private
    }

    update_active_profile() {
        network_control.active_profile
            := network.is_wifi_connected()
                ? network.profile.public
                : network.profile.private
    }
}
