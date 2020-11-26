/* Remote Host Control
 *
 * Description:
 *   Wakes up a host, waits for a response, and initiates
 *   a remote desktop connection by pressing [Win + W].
 *       On an active session, a remote scheduled task
 *   is run to suspend the remote and local host instead.
*/
#persistent
#singleinstance
#noenv

#include ./core/
#include ../core/session.ahk
#include ../core/tools.ahk
#include ../desktop/
#include ../desktop/window.ahk
#include ../network/
#include ../network/host.ahk
#include ../network/icmp.ahk
#include ../network/network.ahk
#include ../network/vpn.ahk
#include ../system/
#include ../system/power.ahk
#include ../system/rdp.ahk
#include ../system/service.ahk
#include ../system/task.ahk

class remote_host_control {
    static server := new host("sierra", "bc:5f:f4:d7:0b:03")
    static tools := new tool_map("c:\tools", {wol: "wol.exe"})
    static standby_task := new scheduled_task("initiate_standby")
    static power_handler
        := new power_control(server, standby_task.name, tools.wol)
    static server_connection := new icmp_connection(server)
    static openvpn_service := new service("OpenVPNService")
    static openvpn_addr_pool := "^192.168.1.([1-5][0-9]|60)$"
    static openvpn_connection
        := new vpn_connection(openvpn_service, openvpn_addr_pool)
    static network_handler
        := new network_control(server_connection, openvpn_connection)
    static main_window := new window(server.name . "_main")
    static media_window := new window(server.name . "_media")
    static main_profile
        := new rdp_profile(main_window, server.name . "_main")
    static media_profile
        := new rdp_profile(media_window, server.name . "_media")
    static main_vpn_profile
        := new rdp_profile(main_window, server.name . "_main_vpn")
    static media_vpn_profile
        := new rdp_profile(media_window, server.name . "_media_vpn")
    static public_session
        := new rdp_session(tools.dir, main_profile, media_profile)
    static private_session
        := new rdp_session(tools.dir, main_vpn_profile, media_vpn_profile)
    static rdp_sessions
        := new rdp_session_map(public_session, private_session)
    static session_handler
        := new session_control(network_handler, power_handler, rdp_sessions)

    main() {
        session_handler.control_remote_session()

        if (session_handler.is_session_closed()) {
            power.initiate_standby()
        }
    }
}

#w::
    try {
        remote_host_control.main()
    } catch exception {
        app_title := "Remote Host Control"
        info_icon := 0x40
        MsgBox, % info_icon, % app_title, % exception.message
    }
    return
