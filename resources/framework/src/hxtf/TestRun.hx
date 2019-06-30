package hxtf;

import TestMain;
import haxe.Timer;
import haxe.Json;
import haxe.ds.BalancedTree;
import haxe.io.Path.addTrailingSlash;
import hxtf.Print.*;
import sys.io.File;

using StringTools;

/**
    The main entry class for test runs.
**/
class TestRun {
    /**
        A record of all test cases that have passed.

        Test cases are evaluated at compile-time when added to a test suite. If
        they've already passed, and retesting isn't being forced, then the test
        is excluded from compilation and not run.
    **/
    public static var cache:BalancedTree<String, Bool> = BuildTools.getCache();

    /**
        The working directory when hxtf was invoked.

        Test files are written to/read from this directory, so scripts can move
        around the filesystem without issue.
    **/
    public static var cwd(default, never):String = BuildTools.getCwd();

    /**
        Whether previously-passed tests are being run or not.
    **/
    public static var forcing(default, never):Bool = BuildTools.getForcing();

    /**
        The current target for testing.
    **/
    public static var target(default, never):String = BuildTools.getTarget();

    /**
        An array of regexes for test cases to exclude.

        Specified with the `-n` option of hxtf.
    **/
    public static var toExclude(default, never):Array<EReg> = BuildTools.getExcludes();

    /**
        An array of regexes for test cases to include.

        Specified with the `-y` option of hxtf.
    **/
    public static var toInclude(default, never):Array<EReg> = BuildTools.getIncludes();

    @:access(TestMain)
    static function main() {
        var run = new TestMain();

        if (run.failed == 0 && run.passed == 0) {
            stdout("\n  [3;4mNo Tests Were Run![0m\n");
            Sys.exit(0);
        }

        saveCache();

        var ansi = if (run.failed == 0) "[42;1m" else if (run.failed <= run.passed) "[43;1m" else "[41;1m";
        var diff = Math.round(Math.abs(Std.string(run.passed).length - Std.string(run.failed).length)) + 1;

        stdout('\n${noAnsi ? "  " : ""}[3mTesting complete![0m\n');
        stdout('${noAnsi ? "  " : ""}$ansi  Tests passed: ${"".lpad(" ", diff - Std.string(run.passed).length)}${run.passed} [0m\n');
        stdout('${noAnsi ? "  " : ""}$ansi  Tests failed: ${"".lpad(" ", diff - Std.string(run.failed).length)}${run.failed} [0m\n');

        if (run.failed != 0) {
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

    @:allow(hxtf.TestMain)
    static function evaluateSuite(main:TestMain, suite:TestSuite, name:String):Void {
        main.passed += suite.passed;
        main.failed += suite.failed;

        if (suite.failed == 0) {
            if (suite.passed != 0) {
                TestRun.cache.set(name, true);
            }
        } else if (TestRun.cache.exists(name)) {
            TestRun.cache.set(name, false);
        }
    }

    @:allow(hxtf.TestMain)
    static function suiteException(main:TestMain, exception:Dynamic, name:String) {
        main.failed++;
        stderr('[41;1m${noAnsi ? "!## " : "### "}$name unhandled suite exception: ${Std.string(exception)}[0m\n');
        printExceptionStackToStderr();
    }

    @:allow(hxtf.TestSuite)
    static function evaluateCase(suite:TestSuite, test:TestCase, name:String, start:Float):Void {
        if (test.passed) {
            suite.passed++;
            stdout('[32m >> ${test.id} passed (${formatTimeDelta(start, Timer.stamp())})[0m\n');
            TestRun.cache.set(name, true);
        } else {
            suite.failed++;
            stderr('[31;1m${noAnsi ? "!" : " "}>> ${test.id} failed (${formatTimeDelta(start, Timer.stamp())})[0m\n');
            if (TestRun.cache.exists(name)) {
                TestRun.cache.set(name, false);
            }
        }
    }

    @:allow(hxtf.TestSuite)
    static function caseException(suite:TestSuite, exception:Dynamic, name:String, stamp:Float) {
        suite.failed++;
        stderr('[41;1m${noAnsi ? "!-- " : "----"} $name unhandled case exception: ${Std.string(exception)}[0m\n');
        printExceptionStackToStderr();
        stderr('[31;1m${noAnsi ? "!" : " "}>> $name failed (${formatTimeDelta(stamp, Timer.stamp())})[0m\n');
    }
}
