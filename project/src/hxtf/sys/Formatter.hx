package hxtf.sys;

using StringTools;

/**
    Handles formatting.
**/
class Formatter {
    /**
        Strip the ANSI escape sequences from the given string `s`.
    **/
    public static function stripAnsi(s:String):String {
        return
            ~/[\x1b\x9b][[\]()#;?]*((([a-zA-Z0-9]*(;[-a-zA-Z0-9\/#&.:=?%@~_]*)*)?\x07)|(([0-9][0-9]?[0-9]?[0-9]?(;[0-9]?[0-9]?[0-9]?[0-9]?)*)?[0-9A-PR-TZcf-ntqry=><~]))/g.split(s)
            .join("");
    }
}
