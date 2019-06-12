package hxtf;

import haxe.PosInfos;
import haxe.Utf8;

using Std;
using StringTools;

class Print {
    public static var noAnsi(default, null):Bool = isAnsiDisabled();

    public static inline function formatPosInfos(pos:PosInfos) {
        return '${pos.className}.${pos.methodName}(${pos.lineNumber})';
    }

    public static function formatTimeDelta(a:Float, b:Float) {
        if (b - a <= 0) return "<= 1ms";

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

    public static inline function stdout(s:String) {
        Sys.stdout().writeString((noAnsi ? stripAnsi(s) : s));
    }

    public static inline function stderr(s:String) {
        Sys.stderr().writeString((noAnsi ? stripAnsi(s) : s));
    }

    static function stripAnsi(s:String) {
        var buf = new StringBuf();
        var blocking = false;
        var prev = -1;

        Utf8.iter(s, function(char) {
            if (blocking) {
                if (char == 'm'.code) {
                    blocking = false;
                }
            } else if (char == '['.code) {
                if (prev == ''.code) {
                    blocking = true;
                } else {
                    buf.addChar('['.code);
                }
            } else if (prev == ''.code) {
                buf.addChar(''.code);
                if (char != ''.code) {
                    buf.addChar(char);
                }
            } else if (char != ''.code) {
                buf.addChar(char);
            }
            prev = char;
        });

        if (prev == ''.code && !blocking) {
            buf.addChar(''.code);
        }
        return buf.toString();
    }

    static macro function isAnsiDisabled() {
        return macro $v{haxe.macro.Context.defined("hxtf_noansi")};
    }
}
