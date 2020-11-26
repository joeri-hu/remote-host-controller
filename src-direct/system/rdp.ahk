/* to-do: documentation
*/
#include ../core/command.ahk
#include ../desktop/window.ahk
#include ../enums/enums.ahk

class rdp_session_map {
    __new(public_rdp_session, private_rdp_session) {
        this[enums.network_profile.public] := public_rdp_session
        this[enums.network_profile.private] := private_rdp_session
    }
}

class rdp_profile {
    __new(window, ByRef config_file) {
        this.window := window
        this.config := new rdp_config(config_file)
    }
}

class rdp_config {
    ;// __new(ByRef file_name, connect_cmd) {
    __new(ByRef file_name) {
        this.file_name := file_name
        ;// this.connect_cmd := connect_cmd
    }
}

class rdp_session {
    __new(ByRef config_dir, rdp_profiles*) {
        this.profiles := rdp_profiles
        this.window_handler := new window_control(
            + this.get_all_windows()
            , "TscShellContainerClass"
            , " - Remote Desktop Connection")
        this.rdp_handler := new rdp_control(
            + config_dir
            , this.get_all_configs())
    }

    get_all_configs() {
        return this.get_property_items("config")
    }

    get_all_windows() {
        return this.get_property_items("window")
    }

    get_property_items(ByRef property) {
        items := array()
        for index, profile in this.profiles {
            items.push(profile[property])
        }
        return items
    }
}

class rdp_control {
    __new(rdp_configs, ByRef config_dir) {
        this.configs := rdp_configs
        this.config_dir := config_dir
        this.construct_commands()
    }

    construct_commands() {
        for index, config in this.configs {
            config.connect_cmd := new command("mstsc ""{}\{}.rdp""")
        }
    }

    start_rdp_connections() {
        for index, config in this.configs {
            config.connect_cmd.bind(this.config_dir
                , config.file_name)

            if (not config.connect_cmd.co_exec()) {
                throw Exception(Format(
                    + "Unable to start RDP connection: {}\{} :("
                    , this.config_dir, config.file_name))
            }
        }
    }
}
