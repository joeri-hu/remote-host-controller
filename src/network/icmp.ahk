/* to-do: documentation
*/
#include ../command/command.ahk

class icmp_connection {
    __new(ByRef host_name, request_limit := 2) {
        this.host_name := host_name
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
            .bind(this.request_limit, this.host_name)
    }

    is_host_reachable() {
        return this.reach_host.exec_cmd()
    }

    set_host_name(ByRef host_name) {
        this.reach_host.bind(this.request_limit, host_name)
        this.host_name := host_name
    }

    set_requests(request_limit) {
        this.reach_host.bind(request_limit, this.host_name)
        this.request_limit := request_limit
    }
}
