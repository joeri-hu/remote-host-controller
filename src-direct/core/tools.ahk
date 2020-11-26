/* to-do: documentation
*/

class tool_map {
    __new(ByRef dir, binary_files) {
        this.dir := dir
        this.base := this.insert_directory_path(binary_files)
    }

    insert_directory_path(binary_files) {
        for tool, file in binary_files {
            binary_files[tool] := Format("""{}\{}""", this.dir, file)
        }
        return binary_files
    }
}
