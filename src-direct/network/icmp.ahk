/* to-do: documentation
*/
#include ../core/command.ahk
#include ../network/host.ahk

class icmp_connection {
    __new(host, request_limit := 2) {
        this.host := host
        this.request_limit := request_limit
        this.construct_commands()
    }

    construct_commands() {
        send_request := new command("ping /n {} /4 {}")
        verify_reply := new command(
            + "findstr /r /c:""[<=][^ ][0-9]""")
            .redirect()

        this.reach_host := command
            .chain(send_request, "|", verify_reply)
    }

    is_host_reachable() {
        return this.reach_host
            .bind(this.request_limit, this.host.name)
            .exec_cmd()
    }
}
