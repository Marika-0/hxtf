package hxtf;

using Std;

/**
    Formatting and writing to the standard output/error streams.
**/
class Print {
    /**
        `true` if the flag to disable ANSI printing was not set, `false`
        otherwise.
    **/
    public static var ansi(default, null):Bool;

    static var ansiRegex = ~/[][[\]()#;?]*((([a-zA-Z0-9]*(;[-a-zA-Z0-9\/#&.:=?%@~_]*)*)?␇)|(([0-9][0-9]?[0-9]?[0-9]?(;[0-9]?[0-9]?[0-9]?[0-9]?)*)?[0-9A-PR-TZcf-ntqry=><~]))/g;

    /**
        Writes the given string `s` to the standard output stream, stripping
        ANSI formatting if `ansi` is true.
    **/
    public static inline function stdout(s:String):Void {
        Sys.stdout().writeString(ansi ? s : stripAnsi(s));
    }

    /**
        Writes the given string `s` to the standard error stream, stripping
        ANSI formatting if `ansi` is true.
    **/
    public static inline function stderr(s:String):Void {
        Sys.stderr().writeString(ansi ? s : stripAnsi(s));
    }

    /**
        Formats the position `pos` uniformly for hxtf.
    **/
    public static inline function formatPosInfos(pos:haxe.PosInfos):String {
        return 'line ${pos.lineNumber}';
    }

    /**
        Formats the difference between times `a` and `b` uniformly for hxtf.
    **/
    public static function formatTimeDelta(a:Float, b:Float):String {
        if (b <= a) {
            return "";
        }

        var diff = DateTools.parse(1000 * (b - a));
        var str = "";

        if (0 < diff.days) {
            str += diff.days.string() + "d ";
        }
        if (0 < diff.hours) {
            str += diff.hours.string() + "h ";
        }
        if (0 < diff.minutes) {
            str += diff.minutes.string() + "m ";
        }
        if (0 < diff.seconds) {
            str += diff.seconds.string() + "s ";
        }
        if (0 < diff.ms.int()) {
            str += diff.ms.int().string() + "ms ";
        }

        return str == "" ? "" : '[${StringTools.trim(str)}]';
    }

    /**
        Formats the given position expression `pos` uniformly for hxtf.
    **/
    public static function formatPosString(pos:haxe.macro.Expr.Position):String {
        var str = Std.string(pos);
        return str.substring(5, str.length - 1) + " : ";
    }

    /**
        Strips ANSI formatting from the given string `s` by splitting it with an
        EReg and joining the result with an empty string.
    **/
    public static inline function stripAnsi(s:String):String {
        return ansiRegex.split(s).join("");
    }
}
