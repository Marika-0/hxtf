package hxtf;

import haxe.PosInfos;
import haxe.Utf8;

using Std;
using StringTools;

/**
    This class contains various function to assist with formatting output, as
    well as writing that output to streams.
**/
class Print {
    /**
        If the flag to remove ANSI formatting from output was set.
    **/
    public static var noAnsi(default, never):Bool = BuildTools.isAnsiDisabled();

    /**
        Formats the given position information `pos` into a `String`.

        Used by hxtf to reduce code-reuse.
    **/
    public static inline function formatPosInfos(pos:PosInfos) {
        return 'line ${pos.lineNumber}';
    }

    /**
        Format's the given difference in times into a `String`.

        If `b` is less than or equal to `a`, or the evaluated time is less-than
        or equal-to 0, `"<= 1ms"` is returned.

        Otherwise the difference if formatted into `"%dd %Hh %Mm %Ss %fms"` (in
        `strftime` format), with leading zero entries removed.
    **/
    public static function formatTimeDelta(a:Float, b:Float) {
        if (b <= a) return "<= 1ms";

        var diff = DateTools.parse(1000 * (b - a));
        var str = "";

        inline function space(str:String, s:String) {
            return (!str.endsWith(" ") && str.length != 0 ? " " : "") + s;
        }

        if (0 < diff.days) str += space(str, diff.days.string() + "d");
        if (0 < diff.hours) str += space(str, diff.hours.string() + "h");
        if (0 < diff.minutes) str += space(str, diff.minutes.string() + "m");
        if (0 < diff.seconds) str += space(str, diff.seconds.string() + "s");
        if (0 < diff.ms.int()) str += space(str, diff.ms.int().string() + "ms");

        return str.length == 0 ? "<= 1ms" : str;
    }

    /**
        Writes the given string `s` to the standard output stream, removing ANSI
        formatting if required.
    **/
    public static inline function stdout(s:String) {
        Sys.stdout().writeString(noAnsi ? stripAnsi(s) : s);
    }

    /**
        Writes the given string `s` to the standard error stream, removing ANSI
        formatting if required.
    **/
    public static inline function stderr(s:String) {
        Sys.stderr().writeString(noAnsi ? stripAnsi(s) : s);
    }

    /**
        Strips ANSI formatting from the given string `s`.
    **/
    public static function stripAnsi(s:String) {
        var buf = new StringBuf();
        var blocking = false;
        var prev = -1;

        Utf8.iter(s, function(char) {
            if (blocking) {
                if (char == "m".code) {
                    blocking = false;
                }
            } else if (char == "[".code) {
                if (prev == "".code) {
                    blocking = true;
                } else {
                    buf.addChar("[".code);
                }
            } else if (prev == "".code) {
                buf.addChar("".code);
                if (char != "".code) {
                    buf.addChar(char);
                }
            } else if (char != "".code) {
                buf.addChar(char);
            }
            prev = char;
        });

        if (prev == "".code && !blocking) {
            buf.addChar("".code);
        }
        return buf.toString();
    }

}
