package hxtf;

import haxe.CallStack;
import haxe.Timer.stamp;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import hxtf.Print.*;

/**
    Base class for containers of TestCases and other TestBrokers.
**/
class TestBroker {
    /**
        Adds the given TestBroker to the test run.
    **/
    static macro function addBroker(e:Expr):Expr {
        try {
            var type:TypePath;
            try {
                type = Build.reifyTypePath(e);
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

    /**
        Adds the given TestCase to the test run.
    **/
    static macro function addTest(e:Expr):Expr {
        try {
            var type:TypePath;
            try {
                type = Build.reifyTypePath(e);
            } catch (ex:Dynamic) {
                stderr('[3m${formatPosString(Context.currentPos())}${Std.string(ex)}[0m\n');
                return macro null;
            }

            var name = ExprTools.toString(e);
            if (!Build.useTest(name)) {
                return macro null;
            }

            return macro {
                var stamp = haxe.Timer.stamp();
                hxtf.Print.stdout('[37m${hxtf.Macro.ansi ? "~~  " : " ~~ "}${name}...[0m\n');
                try {
                    hxtf.TestBroker.Helper.evaluateCase(new $type(), $v{name}, stamp);
                } catch (ex:Dynamic) {
                    hxtf.TestBroker.Helper.caseException(ex, $v{name}, stamp);
                }
            }
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}

@:access(hxtf.TestRun)
@:access(hxtf.TestCase)
class Helper {
    public static function evaluateCase(test:TestCase, name:String, start:Float):Void {
        if (test._passed) {
            var time = formatTimeDelta(start, stamp());
            if (time != "") {
                time = " [96;1m" + time;
            }
            var path = name.split(".");
            var type = path.pop();

            stdout('[92m >> ${path.join(".")}.[1m$type[0m[92m passed$time[0m\n');
            if (!TestRun.cache.exists(name)) {
                TestRun.cache.set(name, true);
            }
            TestRun.passedTestCount++;
        } else {
            caseFailure(name, start);
        }
    }

    @:access(haxe.CallStack)
    public static function caseException(ex:Dynamic, name:String, start:Float):Void {
        stderr('[41;1m${ansi ? "----" : "!-- "}$name exception: ${Std.string(ex)} [0m\n');
        if (CallStack.exceptionStack().length == 0) {
            stderr("[41;1m      Exception stack unavailable [0m\n");
        } else {
            for (item in CallStack.exceptionStack()) {
                var buf = new StringBuf();
                CallStack.itemToString(buf, item);
                stderr('[41;1m      Called from ${buf.toString()} [0m\n');
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

        stderr('[91m${ansi ? " " : "!"}>> ${path.join(".")}.[1m$type[0m[91m failed$time[0m\n');
        if (TestRun.cache.exists(name)) {
            TestRun.cache.set(name, false);
        }
        TestRun.failedTestCount++;
    }
}
