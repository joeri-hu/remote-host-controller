/* to-do: documentation
*/
#include ../network/host.ahk
#include ../command/command.ahk

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
        this.suspend_host := new command(
            + "schtasks /run /s {} /tn {}")
            .bind(this.host_name, this.standby_task)
        this.wakeup_host := new command("{} /wakeup {}")
            .bind(this.wol_tool, this.host_mac_addr)
    }

    suspend_host() {
        if (not this.suspend_host.exec()) {
            throw Exception(Format(
                + "Unable to suspend host: {} :("
                , this.host_name))
        }
    }

    wakeup_host() {
        if (not this.wakeup_host.exec()) {
            throw Exception(Format(
                + "Unable to deliver magic packet: {} :("
                , this.host_mac_addr))
        }
    }

    set_host_name(ByRef host_name) {
        this.suspend_host.bind(host_name, this.standby_task)
        this.host_name := host_name
    }

    set_host_addr(ByRef mac_addr) {
        this.wakeup_host.bind(this.wol_tool, mac_addr)
        this.host_mac_addr := mac_addr
    }

    set_wol_tool(ByRef wol_tool) {
        this.wakeup_host.bind(wol_tool, this.host_mac_addr)
        this.wol_tool := wol_tool
    }

    set_standby_task(ByRef standby_task) {
        this.suspend_host.bind(this.host_name, standby_task)
        this.standby_task := standby_task
    }
}
