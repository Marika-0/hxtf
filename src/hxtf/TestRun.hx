package hxtf;

import haxe.ds.BalancedTree;
import haxe.io.Path.addTrailingSlash as slash;
import hxtf.Print.*;
import sys.io.File;

using StringTools;

/**
    The main class for compiling a test run and the runtime access class for
    test run configuration.
**/
class TestRun {
    /**
        The cache of TestCases.
    **/
    public static var cache(default, null):BalancedTree<String, Bool>;

    /**
        The directory the test run cache will be saved to.
    **/
    public static var cwd(default, null):String;

    /**
        `true` if test runs are being forced (rerun if they previously passed),
        `false` otherwise.
    **/
    public static var forcing(default, null):Bool;

    /**
        `true` if the passed tests for this test run are being saved to the
        cache, `false` otherwise.
    **/
    public static var savingCache(default, null):Bool;

    /**
        The target of this test run.
    **/
    public static var target(default, null):String;

    static var passedTestCount:UInt = 0;
    static var failedTestCount:UInt = 0;

    @:access(TestMain)
    static function main():Void {
        setup();

        new TestMain();

        if (passedTestCount == 0 && failedTestCount == 0) {
            stdout("  [3;4mNo Tests Were Run![0m\n");
            Sys.exit(0);
        }

        if (savingCache) {
            saveCache();
        }
        printResults();

        if (failedTestCount != 0) {
            Sys.exit(1);
        }
        Sys.exit(0);
    }

    @:access(hxtf.Print)
    static function setup():Void {
        cache = Build.getCache();
        cwd = Build.getCwd();
        forcing = Build.getForcing();
        savingCache = Build.getSavingCache();
        target = Build.getTarget();

        Print.ansi = Build.getAnsi();
    }

    static function saveCache():Void {
        var path = slash(cwd) + target + ".cache";
        var passedTests = new Array<String>();
        for (test in cache.keys()) {
            if (cache.get(test)) {
                passedTests.push(test);
            }
        }
        try {
            File.saveContent(path, passedTests.join("\n"));
        } catch (ex:Dynamic) {
            stderr('[31;1mFailed to save test cache $path[0m\n');
        }
    }

    static function printResults():Void {
        var preamble = if (failedTestCount == 0) {
            "[42;1m";
        } else if (failedTestCount <= passedTestCount) {
            "[43;1m";
        } else {
            "[41;1m";
        }

        var space = Math.round(Math.abs(Std.string(passedTestCount).length - Std.string(failedTestCount).length)) + 1;

        stdout("\n");
        stdout('${ansi ? "" : "  "}[3mTesting complete![0m\n');
        stdout('${ansi ? "" : "  "} $preamble Tests passed: ${"".lpad(" ", space - '$passedTestCount'.length)}${passedTestCount} [0m\n');
        stdout('${ansi ? "" : "  "} $preamble Tests failed: ${"".lpad(" ", space - '$failedTestCount'.length)}${failedTestCount} [0m\n');

        stdout('${ansi ? "" : "  "}[3mTesting passed for target: $target[0m\n');
    }
}
