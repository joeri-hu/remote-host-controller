/* to-do: documentation
*/
#include network.ahk
#include window.ahk
#include command.ahk

class rdp_session_map {
    __new(public_rdp_session, private_rdp_session) {
        this[network.profiles.public] := public_rdp_session
        this[network.profiles.private] := private_rdp_session
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
    __new(ByRef config_dir, rdp_configs) {
        this.config_dir := config_dir
        this.construct_config_commands(rdp_configs)
    }

    construct_config_commands(source_configs) {
        this.rdp_configs_copy := array()

        for index, config in source_configs {
            config_copy := config.clone()
            config_copy.connect_cmd
                := new command("mstsc ""{}\{}.rdp""")
                    .bind(this.config_dir, config.file_name)
            this.rdp_configs_copy.push(config_copy)
        }
    }

    start_rdp_connections() {
        for index, config in this.rdp_configs_copy {
            if (not config.connect_cmd.co_exec()) {
                throw Exception(Format(
                    + "Unable to start RDP connection: {} :("
                    , config.file_name))
            }
        }
    }

    set_config_directory(config_dir) {
        for index, config in this.rdp_configs_copy {
            config.connect_cmd.bind(config_dir, config.file_name)
        }
        this.config_dir := config_dir
    }

    set_rdp_configs(rdp_configs) {
        this.construct_config_commands(rdp_configs)
    }
}
