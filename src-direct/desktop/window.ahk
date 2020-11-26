/* to-do: documentation
*/

class window {
    __new(ByRef title) {
        this.title := title
    }
}

class window_control {
    __new(windows, ByRef class_name, ByRef title_suffix := "") {
        this.windows := windows
        this.class_name := class_name
        this.title_suffix := title_suffix
    }

    all_windows_exist() {
        return not this.process_windows(window_commands
            .actions.nonexistent)
    }

    any_window_exists() {
        return this.process_windows(window_commands.actions.exists)
    }

    close_all_windows() {
        this.process_windows(window_commands.actions.close)
    }

    wait_for_closed_windows(timeout_s := 4) {
        this.process_windows(window_commands.actions.wait_close
            .bind(timeout_s / this.windows.length()))
    }

    process_windows(action) {
        search_criteria := this.title_suffix
            . "ahk_class" . this.class_name

        for index, window in this.windows {
            if (action.call(window.title . search_criteria)) {
                return true
            }
        }
        return false
    }
}

class window_commands {
    static actions := {close: Func("window_commands.close_window")
        , nonexistent: Func("window_commands.window_nonexistent")
        , exists: Func("window_commands.window_exists")
        , wait_close: Func("window_commands.wait_for_window_closure")}

    close_window(ByRef search_criteria) {
        WinClose, % search_criteria
        ;// check if this can be removed !! important !!
        return false
    }

    window_nonexistent(ByRef search_criteria) {
        return not window_commands.window_exists(search_criteria)
    }

    window_exists(ByRef search_criteria) {
        return WinExist(search_criteria)
    }

    wait_for_window_closure(timeout_s, ByRef search_criteria) {
        WinWaitClose, % search_criteria,, % timeout_s
    }
}
