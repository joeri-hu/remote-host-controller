/* to-do: documentation
*/
#include ../core/command.ahk
#include ../network/host.ahk

class power {
    initiate_standby() {
        static suspend_system := new command("psshutdown /d /t 0")

        if (not suspend_system.exec()) {
            throw Exception("Unable to initiate system standby :(")
        }
    }
}

class power_control {
    __new(host, ByRef wol_tool, ByRef standby_task) {
        this.host_name := host.name
        this.host_mac_addr := host.mac_addr
        this.wol_tool := wol_tool
        this.standby_task := standby_task
        this.construct_commands()
    }

    construct_commands() {
        this.run_standby_task := new command(
            + "schtasks /run /s {} /tn {}")
            .bind(this.host_name, this.standby_task)
        this.send_magic_packet := new command("{} /wakeup {}")
            .bind(this.wol_tool, this.host_mac_addr)
    }

    suspend_host() {
        if (not this.run_standby_task.exec()) {
            throw Exception(Format(
                + "Unable to suspend host: {} :("
                , this.host_name))
        }
    }

    wakeup_host() {
        if (not this.send_magic_packet.exec()) {
            throw Exception(Format(
                + "Unable to send magic packet: {} :("
                , this.host_mac_addr))
        }
    }

    set_host_name(ByRef host_name) {
        this.run_standby_task.bind(host_name, this.standby_task)
        this.host_name := host_name
    }

    set_host_addr(ByRef mac_addr) {
        this.send_magic_packet.bind(this.wol_tool, mac_addr)
        this.host_mac_addr := mac_addr
    }

    set_wol_tool(ByRef wol_tool) {
        this.send_magic_packet.bind(wol_tool, this.host_mac_addr)
        this.wol_tool := wol_tool
    }

    set_standby_task(ByRef standby_task) {
        this.run_standby_task.bind(this.host_name, standby_task)
        this.standby_task := standby_task
    }
}
