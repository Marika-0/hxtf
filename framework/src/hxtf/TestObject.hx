package hxtf;

import haxe.CallStack;
import haxe.Timer.stamp;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import hxtf.Print.*;

class TestObject {
    static macro function addSuite(e:Expr):Expr {
        try {
            var type:TypePath;
            try {
                type = BuildTools.reifyTypePath(e);
            } catch (ex:Dynamic) {
                stderr('[3m${formatPosString(Context.currentPos())}${Std.string(ex)}[0m\n');
                return macro null;
            }
            return macro new $type();
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }

    static macro function addCase(e:Expr):Expr {
        try {
            var type:TypePath;
            try {
                type = BuildTools.reifyTypePath(e);
            } catch (ex:Dynamic) {
                stderr('[3m${formatPosString(Context.currentPos())}${Std.string(ex)}[0m\n');
                return macro null;
            }

            var name = ExprTools.toString(e);
            if (!BuildTools.useTestCase(name)) {
                return macro null;
            }

            return macro {
                var stamp = haxe.Timer.stamp();
                hxtf.Print.stdout('[37m${hxtf.Print.noAnsi ? " ~~ " : "~~  "}${name}...[0m\n');
                try {
                    hxtf.TestObject.Helper.evaluateCase(new $type(), $v{name}, stamp);
                } catch (ex:Dynamic) {
                    hxtf.TestObject.Helper.caseException(ex, $v{name}, stamp);
                }
            }
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}

@:access(hxtf.TestRun)
class Helper {
    public static function evaluateCase(test:TestCase, name:String, start:Float):Void {
        if (test.passed) {
            var time = formatTimeDelta(start, stamp());
            if (time != "") {
                time = " [96;1m" + time;
            }
            var path = name.split(".");
            var type = path.pop();

            stdout('[92m >> ${path.join(".")}.[1m$type[0m[92m passed$time[0m\n');
            TestRun.cache.set(name, true);
            TestRun.passedCases++;
        } else {
            caseFailure(name, start);
        }
    }

    @:access(haxe.CallStack)
    public static function caseException(ex:Dynamic, name:String, start:Float):Void {
        stderr('[41;1m${noAnsi ? "!-- " : "----"}$name exception: ${Std.string(ex)} [0m\n');
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
        caseFailure(name, start);
    }

    static function caseFailure(name:String, start:Float):Void {
        var time = formatTimeDelta(start, stamp());
        if (time != "") {
            time = " [93;1m" + time;
        }
        var path = name.split(".");
        var type = path.pop();

        stderr('[91m${noAnsi ? "!" : " "}>> ${path.join(".")}.[1m$type[0m[91m failed$time[0m\n');
        if (TestRun.cache.exists(name)) {
            TestRun.cache.set(name, false);
        }
        TestRun.failedCases++;
    }
}