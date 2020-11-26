/* to-do: documentation
*/

;// deprecated
class vpn_manual_service {
    static this := vpn_manual_service.__new(A_ProgramFiles "\openvpn"
        , "zulu.ovpn"
        , "CloseTunnelFlag")
 
    __new(dir, config, event) {
        program := "openvpn.exe"
        args := Format("--config {} --service {} --verb 0", config, event)
        this.cmd := Format("""{}\bin\{}"" {}", dir, program, args)
        this.dir := dir "\config"
        this.event := event
    }

    ;// matches IP address range: 192.168.1.10-60
    is_tunnel_active(vpn_addr_pool := "^192.168.1.([1-5][0-9]|60)$") {
        return RegExMatch(A_IPAddress1, vpn_addr_pool)
    }

    create_tunnel() {
        Run, % this.cmd, % this.dir,, pid
        this.pid := pid
    }

    close_tunnel() {
        handle := open_service_event()

        if handle {
            close_service(handle)
        } else {
            Process, Close, % this.pid
        }
    }

    open_service_event() {
        EVENT_MODIFY_STATE := 0x2
        SYNCHRONIZE := 0x100000
        return DllCall("OpenEventW"
            , "UInt", EVENT_MODIFY_STATE | SYNCHRONIZE
            , "Int", False
            , "Str", this.event)
    }

    close_service(handle) {
        DllCall("SetEvent", "Ptr", handle)
        DllCall("CloseHandle", "Ptr", handle)
    }
}
