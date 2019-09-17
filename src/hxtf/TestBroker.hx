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

/**
    Helper functions that shouldn't normally be accessed by Test Brokers.
**/
@:access(hxtf.TestRun)
@:access(hxtf.TestCase)
class Helper {
    /**
        Evaluates the given test case and records if it passed or failed.
    **/
    public static function evaluateCase(test:TestCase, name:String, start:Float):Void {
        if (test._passed) {
            stdout(formatCasePrinting(name, true, start));
            if (!TestRun.cache.exists(name)) {
                TestRun.cache.set(name, true);
            }
            TestRun.passedTestCount++;
        } else {
            caseFailure(name, start);
        }
    }

    /**
        Prints stack trace information for an unhandled exception.
    **/
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
        stderr(formatCasePrinting(name, false, start));
        if (TestRun.cache.exists(name)) {
            TestRun.cache.set(name, false);
        }
        TestRun.failedTestCount++;
    }

    static function formatCasePrinting(name:String, passed:Bool, start:Float):String {
        var time = formatTimeDelta(start, stamp());
        if (time != "") {
            if (passed) {
                time = " [96;1m" + time;
            } else {
                time = " [93;1m" + time;
            }
        }

        var path = name.split(".");
        var type = path.pop();
        if (path.length != 0) {
            path.push("");
        }

        return if (passed) {
            '[92m >> ${path.join(".")}[1m$type[0m[92m passed$time[0m\n';
        } else {
            '[91m${ansi ? " " : "!"}>> ${path.join(".")}[1m$type[0m[91m failed$time[0m\n';
        }
    }
}
