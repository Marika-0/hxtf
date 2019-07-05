package hxtf;

import TestMain;
import haxe.Json;
import haxe.Timer.stamp;
import haxe.ds.BalancedTree;
import haxe.io.Path.addTrailingSlash;
import haxe.macro.Expr;
import hxtf.Print.*;
import sys.io.File;

using StringTools;

@:access(TestMain)
class TestRun {
    public static var cwd(default, never):String = BuildTools.getCwd();
    public static var target(default, never):String = BuildTools.getTarget();
    public static var cache(default, never):BalancedTree<String, Bool> = BuildTools.getCache();
    public static var passedCases(default, null):UInt = 0;
    public static var failedCases(default, null):UInt = 0;

    static function main() {
        Print.stdout("\n");
        new TestMain();

        if (passedCases == 0 && failedCases == 0) {
            stdout("  [3;4mNo Tests Were Run![0m\n");
            Sys.exit(0);
        }

        saveCache();

        var ansi = failedCases == 0 ? "[42;1m" : failedCases <= passedCases ? "[43;1m" : "[41;1m";
        var diff = Math.round(Math.abs(Std.string(passedCases).length - Std.string(failedCases).length)) + 1;

        stdout('\n${noAnsi ? "  " : ""}[3mTesting complete![0m\n');
        stdout('${noAnsi ? "  " : ""}$ansi  Tests passed: ${"".lpad(" ", diff - Std.string(passedCases).length)}${passedCases} [0m\n');
        stdout('${noAnsi ? "  " : ""}$ansi  Tests failed: ${"".lpad(" ", diff - Std.string(failedCases).length)}${failedCases} [0m\n');

        if (failedCases != 0) {
            Sys.exit(1);
        }
        stdout('${noAnsi ? "  " : ""}[3mTesting passed for target: $target[0m\n');
        Sys.exit(0);
    }

    static function saveCache():Void {
        var cachePath = addTrailingSlash(cwd) + target + ".json";
        var passedTests = new Array<String>();
        for (test in cache.keys()) {
            if (cache.get(test)) {
                passedTests.push(test);
            }
        }
        try {
            File.saveContent(cachePath, Json.stringify(passedTests));
        } catch (ex:Dynamic) {
            stderr('[31;1mFailed to save test cache to $cachePath[0m\n');
        }
    }

    @:allow(hxtf.TestSuite)
    static function evaluateCase(test:TestCase, name:String, start:Float) {
        if (test.passed) {
            var time = formatTimeDelta(start, stamp());
            if (time != "") {
                time = " [96;1m" + time;
            }
            var path = name.split(".");
            var type = path.pop();

            stdout('[92m >> ${path.join(".")}.[1m$type[0m[92m passed$time[0m\n');
            cache.set(name, true);
            passedCases++;
        } else {
            caseFailure(name, start);
        }
    }

    @:allow(hxtf.TestSuite)
    static function caseException(ex:Dynamic, name:String, start:Float) {
        stderr('[41;1m${noAnsi ? "!-- " : "----"}$name exception: ${Std.string(ex)} [0m\n');
        Print.stderrExceptionStack();
        caseFailure(name, start);
    }

    static inline function caseFailure(name:String, start:Float) {
        var time = formatTimeDelta(start, stamp());
        if (time != "") {
            time = " [93;1m" + time;
        }
        var path = name.split(".");
        var type = path.pop();

        stderr('[91m${noAnsi ? "!" : " "}>> ${path.join(".")}.[1m$type[0m[91m failed$time[0m\n');
        if (cache.exists(name)) {
            cache.set(name, false);
        }
        failedCases++;
    }
}
