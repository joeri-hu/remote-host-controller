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
    __new(host, standby_task, ByRef wol_tool) {
        this.host := host
        this.standby_task := standby_task
        this.wol_tool := wol_tool
        this.construct_commands()
    }

    construct_commands() {
        this.suspend_host
            := new command("schtasks /run /s {} /tn {}")
        this.wakeup_host := new command("{} /wakeup {}")
    }

    suspend_host() {
        this.suspend_host.bind(this.host.name
            , this.standby_task.name)

        if (not this.suspend_host.exec()) {
            throw Exception(Format(
                + "Unable to suspend host: {} :("
                , this.host_name))
        }
    }

    wakeup_host() {
        this.wakeup_host.bind(this.wol_tool, this.host.mac_addr)

        if (not this.wakeup_host.exec()) {
            throw Exception(Format(
                + "Unable to deliver magic packet: {} :("
                , this.host.mac_addr))
        }
    }
}
