package hxtf.format;

/**
    Handles the formatting of ANSI escape sequences in strings.
**/
class AnsiFormat {
    /**
        Strips all ANSI escape sequences from the string `s` and returns it.
    **/
    public static function strip(s:String):String {
        return
            ~/[\x1b\x9b][\[\]()#;?]*((([a-zA-Z0-9]*(;[-a-zA-Z0-9\/#&.:=?%@~_]*)*)?\x07)|(([0-9][0-9]?[0-9]?[0-9]?(;[0-9]?[0-9]?[0-9]?[0-9]?)*)?[0-9A-PR-TZcf-ntqry=><~]))/g
            .split(s)
            .join("");
    }
}
