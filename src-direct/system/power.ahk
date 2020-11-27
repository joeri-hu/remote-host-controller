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
        this.run_standby_task
            := new command("schtasks /run /s {} /tn {}")
        this.send_magic_packet := new command("{} /wakeup {}")
    }

    suspend_host() {
        this.run_standby_task.bind(this.host.name
            , this.standby_task.name)

        if (not this.run_standby_task.exec()) {
            throw Exception(Format(
                + "Unable to suspend host: {} :("
                , this.host.name))
        }
    }

    wakeup_host() {
        this.send_magic_packet.bind(this.wol_tool
            , this.host.mac_addr)

        if (not this.send_magic_packet.exec()) {
            throw Exception(Format(
                + "Unable to send magic packet: {} :("
                , this.host.mac_addr))
        }
    }
}
