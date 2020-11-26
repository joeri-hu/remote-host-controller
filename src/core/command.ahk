/* to-do: documentation
*/

class command {
    __new(ByRef code) {
        this.code := code
    }

    chain(left_cmd, ByRef operator, right_cmd) {
        return new command(Format("{}{}{}"
            , left_cmd.get_layout()
            , operator
            , right_cmd.get_layout()))
    }

    copy() {
        return new command(this.get_layout())
    }

    get_layout() {
        return this.layout ? this.layout : this.code
    }

    bind_copy(values*) {
        return this.copy().bind(values*)
    }

    bind(values*) {
        this.create_layout()
        this.code := Format(this.layout, values*)
        return this
    }

    bind_all(value) {
        this.create_layout()
        this.code := Format(StrReplace(this.layout
            , "{}", "{1}"), value)
        return this
    }

    create_layout() {
        if (not this.layout) {
            this.layout := this.code
        }
    }

    group() {
        this.code := Format("({})", this.code)
        return this
    }

    redirect(stream := 2, ByRef operator := ">", ByRef target := "nul") {
        this.code := Format("{} {}{}{}"
            , this.code, stream, operator, target)
        return this
    }

    exec() {
        return not this.exec_ext()
    }

    exec_ext() {
        RunWait, % this.code,, Hide
        return ErrorLevel
    }

    exec_cmd() {
        return not this.exec_cmd_ext()
    }

    exec_cmd_ext() {
        static interpreter := "cmd /q /c "
        RunWait, % interpreter . this.code,, Hide
        return ErrorLevel
    }

    co_exec() {
        Run, % this.code,, Hide
        return ErrorLevel
    }
}
