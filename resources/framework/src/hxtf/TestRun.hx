package hxtf;

import TestMain;
import haxe.Json;
import haxe.ds.BalancedTree;
import haxe.io.Path.addTrailingSlash;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class TestRun {
    public static var cache:BalancedTree<String, Bool> = BuildTools.getCache();
    public static var cwd(default, never):String = BuildTools.getCwd();
    public static var forcing(default, never):Bool = BuildTools.getForcing();
    public static var target(default, never):String = BuildTools.getTarget();
    public static var toExclude(default, never):Array<EReg> = BuildTools.getExcludes();
    public static var toInclude(default, never):Array<EReg> = BuildTools.getIncludes();

    @:access(TestMain)
    static function main() {
        var run = new TestMain();

        if (run.failed == 0 && run.passed == 0) {
            Print.stdout("\n  [3;4mNo Tests Were Run![0m\n");
            Sys.exit(0);
        }

        saveCache();

        var ansi = if (run.failed == 0) "[42;1m" else if (run.failed <= run.passed) "[43;1m" else "[41;1m";
        var diff = Math.round(Math.abs(Std.string(run.passed).length - Std.string(run.failed).length)) + 1;

        Print.stdout("\n[3mTesting complete![0m\n");
        Print.stdout('$ansi  Test passed: ${"".lpad(" ", diff - Std.string(run.passed).length)}${run.passed} [0m\n');
        Print.stdout('$ansi  Test failed: ${"".lpad(" ", diff - Std.string(run.failed).length)}${run.failed} [0m\n');

        if (run.failed != 0) {
            Sys.exit(1);
        }
        Print.stdout('[3mTesting passed for target: $target[0m\n');
        Sys.exit(0);
    }

    static function saveCache() {
        var cachePath = addTrailingSlash(cwd) + target + ".json";
        var passedTests = new Array<String>();
        for (test in cache.keys()) {
            if (cache.get(test)) {
                passedTests.push(test);
            }
        }
        try {
            File.saveContent(cachePath, haxe.Json.stringify(passedTests));
        } catch (ex:Dynamic) {
            Print.stderr('[31;1mFailed to save test cache to $cachePath[0m\n');
        }
    }

    public static function evaluateCase(suite:TestSuite, test:TestCase, name:String) {
        if (test.passed) {
            Print.stdout("[32m >> " + test.id + " succeeded (" + hxtf.Print.formatTimeDelta(test.timestamp, haxe.Timer.stamp()) + ")[0m\n");
            TestRun.cache.set(name, true);
            suite.passed++;
        } else {
            Print.stderr("[31;1m >> " + test.id + " failed (" + hxtf.Print.formatTimeDelta(test.timestamp, haxe.Timer.stamp()) + ")[0m\n");
            if (TestRun.cache.exists(name)) {
                TestRun.cache.set(name, false);
            }
            suite.failed++;
        }
    }

    public static function evaluateSuite(main:TestMain, suite:TestSuite, name:String) {
        main.passed += suite.passed;
        main.failed += suite.failed;
        if (suite.failed == 0) {
            if (suite.passed == 0) return;
            TestRun.cache.set(name, true);
        } else {
            if (TestRun.cache.exists(name)) {
                TestRun.cache.set(name, false);
            }
        }
    }
}
