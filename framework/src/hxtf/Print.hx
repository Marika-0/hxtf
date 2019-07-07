package hxtf;

import haxe.CallStack;

using Std;

/**
    Functions for writing to the standard output & error streams and formatting.
**/
class Print {
    public static var noAnsi(default, never):Bool = BuildTools.isAnsiDisabled();

    public static inline function stdout(s:String):Void {
        Sys.stdout().writeString(noAnsi ? stripAnsi(s) : s);
    }

    public static inline function stderr(s:String):Void {
        Sys.stderr().writeString(noAnsi ? stripAnsi(s) : s);
    }

    public static inline function formatPosInfos(pos:haxe.PosInfos):String {
        return 'line ${pos.lineNumber}';
    }

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

    public static function formatPosString(pos:haxe.macro.Expr.Position):String {
        var str = Std.string(pos);
        return str.substring(5, str.length - 1) + " : ";
    }

    public static inline function stripAnsi(s:String):String {
        return
            ~/[][[\]()#;?]*((([a-zA-Z0-9]*(;[-a-zA-Z0-9\/#&.:=?%@~_]*)*)?␇)|(([0-9][0-9]?[0-9]?[0-9]?(;[0-9]?[0-9]?[0-9]?[0-9]?)*)?[0-9A-PR-TZcf-ntqry=><~]))/g.split(s)
            .join("");
    }

    @:access(haxe.CallStack)
    @:allow(hxtf.TestRun)
    static function stderrExceptionStack():Void {
        if (CallStack.exceptionStack().length == 0) {
            stderr("[41;1m      Exception stack not available [0m\n");
        } else {
            for (item in CallStack.exceptionStack()) {
                var buf = new StringBuf();
                CallStack.itemToString(buf, item);
                if (noAnsi) {
                    Sys.stderr().writeString('      Called from ${buf.toString()}\n');
                } else {
                    Sys.stderr().writeString('[41;1m      Called from ${buf.toString()} [0m\n');
                }
            }
        }
    }
}
