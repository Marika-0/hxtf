package hxtf.sys;

using StringTools;

/**
    This class handles the formatting of things.
**/
class Formatter {
    static var ansiRegex = ~/[][[\]()#;?]*((([a-zA-Z0-9]*(;[-a-zA-Z0-9\/#&.:=?%@~_]*)*)?␇)|(([0-9][0-9]?[0-9]?[0-9]?(;[0-9]?[0-9]?[0-9]?[0-9]?)*)?[0-9A-PR-TZcf-ntqry=><~]))/g;

    /**
        Strip the ANSI escape sequences from the given string `s`.
    **/
    public static inline function stripAnsi(s:String):String {
        return ansiRegex.split(s).join("");
    }
}
