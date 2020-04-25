package hxtf;

import haxe.Timer;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;
#if target.threaded
import sys.thread.Thread;
#end

using StringTools;
using Lambda;

/**
    Contains fields and methods used internally by HxTF to run tests and record
    their results.
**/
class Driver {
    /**
        The number of test cases that have passed in this test run.
    **/
    static var passedTestCount:UInt = 0;

    /**
        The number of test cases that have failed in this test run.
    **/
    static var failedTestCount:UInt = 0;

    /**
        The total amount of time spent running unit tests.
    **/
    static var totalTestTime:Float = 0;

    #if target.threaded
    /**
        The threads of tests that are queued to be run in future.
    **/
    static var queuedThreads = new List<() -> Void>();
    #end

    @:noCompletion public static macro function addObject(e:Expr):Expr {
        // Determine if the expression is a (hopefully instantiable) type and,
        // if it is, get that types type name and module path.
        var typeName:String;
        var typePath:TypePath;
        switch (Context.typeof(e)) {
            case TType(ref, _):
                var defType = ref.get();
                if (!defType.name.startsWith("Class<")) {
                    Context.fatalError('Invalid type ${defType.name} (may not have been imported?)', Context.currentPos());
                }
                typeName = defType.module;
                var typeNameArray = typeName.split(".");
                typePath = {
                    pack: typeNameArray,
                    name: typeNameArray.pop(),
                    sub: null,
                }
                if (defType.name != 'Class<$typeName>') {
                    var sub = defType.name.substring(defType.name.lastIndexOf(".") + 1, defType.name.length - 1);
                    typeName += "." + sub;
                    typePath.sub = sub;
                }
            default:
                Context.fatalError("Given expression is not a type.", Context.currentPos());
        }

        // Check if the type extends `hxtf.TestObject`.
        var isTestObject = TypeTools.unify(ComplexTypeTools.toType(TPath(typePath)), ComplexTypeTools.toType(TPath({pack: ["hxtf"], name: "TestObject"})));
        if (isTestObject) {
            // Exclude the test if it has already passed, if it matches any of
            // the exclusion regexes, or if it doesn't match any of the
            // inclusion regexes.
            if (Config.CACHE.exists(typeName)) {
                return macro null;
            }
            if (!Config.EXCLUDE_REGEXES.foreach((ereg) -> !ereg.match(typeName))) {
                return macro null;
            }
            if (Config.INCLUDE_REGEXES.length != 0 && Config.INCLUDE_REGEXES.foreach((ereg) -> !ereg.match(typeName))) {
                return macro null;
            }
            if (Config.IS_THREADING_TESTS) {
                return macro hxtf.Driver.addTestingThread(() -> new $typePath()._assertionFailureCount, $v{typeName});
            } else {
                return macro hxtf.Driver.evaluateTestCase(() -> new $typePath()._assertionFailureCount, $v{typeName});
            }
        }
        return macro new $typePath();
    }

    #if target.threaded
    @:noCompletion public static function addTestingThread(run:() -> Int, testName:String):Void {
        queuedThreads.add(() -> evaluateTestCase(run, testName));
    }
    #end

    @:noCompletion public static function evaluateTestCase(run:() -> Int, testName:String):Void {
        if (Config.cache.exists(testName)) {
            return;
        }
        Config.cache.set(testName, false);

        var testPassed = false;
        Print.stdout(Print.Format.formatTestStartMessage(testName));
        var testTime = Timer.stamp();
        try {
            testPassed = run() == 0;
        } catch (ex:TestObject.MaximumAssertionFailuresReached) {
            Print.stderr(Print.Format.formatMaxAssertionsError(testName));
        } catch (ex:Dynamic) {
            Print.stderr(Print.Format.formatExceptionFailure(testName, ex));
        }

        testTime = Math.round(1000 * (Timer.stamp() - testTime)) / 1000;
        totalTestTime += testTime;
        if (testPassed) {
            passedTestCount++;
            Config.cache.set(testName, true);
        } else {
            failedTestCount++;
        }
        Print.stdout(Print.Format.formatTestCompletionMessage(testName, testPassed, testTime));
    }

    @:allow(hxtf.TestRun) static function run():Void {
        new TestMain();

        #if target.threaded
        if (Config.isThreadingTests) {
            var threadCount:UInt = 0;
            while (true) {
                Sys.sleep(0.01);
                if (threadCount < Config.maxTestingThreads && !queuedThreads.isEmpty()) {
                    threadCount++;
                    Thread.create(() -> {
                        queuedThreads.pop()();
                        threadCount--;
                    });
                }
                if (threadCount == 0 && queuedThreads.isEmpty()) {
                    break;
                }
            }
        }
        #end

        complete();
    }

    static function complete():Void {
        if (passedTestCount == 0 && failedTestCount == 0) {
            Print.stdout("  [3mNo tests were run[0m\n");
            Sys.exit(0);
        }

        var format:String;
        if (failedTestCount == 0) {
            format = "[42;1m";
        } else if (failedTestCount <= passedTestCount) {
            format = "[43;1m";
        } else {
            format = "[41;1m";
        }

        // Targets that only support floating-point numeric types can print the
        // passed/failed test count with a `.0`. We wrap all stringification of
        // numerics in `Std.int()` to force an integer representation.
        var padding = Math.round(Math.abs('${Std.int(passedTestCount)}'.length - '${Std.int(failedTestCount)}'.length)) + 1;
        Print.stdout('\n[3mTesting complete [0m[1m${Print.Format.formatTimeDelta(totalTestTime)}[0m\n');
        Print.stdout('$format => Tests passed: ${"".lpad(" ", padding - '${Std.int(passedTestCount)}'.length)}${Std.int(passedTestCount)} [0m\n');
        Print.stdout('$format => Tests failed: ${"".lpad(" ", padding - '${Std.int(failedTestCount)}'.length)}${Std.int(failedTestCount)} [0m\n');

        if (Config.writeCache) {
            var passedTests = new Array<String>();
            for (test => status in Config.cache) {
                if (status) {
                    passedTests.push(test);
                }
            }
            passedTests.sort(Helper.compareTypes);
            var path = haxe.io.Path.addTrailingSlash(Config.workingDirectory) + Config.target + ".cache";
            try {
                sys.io.File.saveContent(path, passedTests.join("\n"));
            } catch (ex:Dynamic) {
                Print.stderr('[3mFailed to save test cache $path[0m\n');
                Print.stderr('[3m  > ${Std.string(ex)}[0m\n');
            }
        }

        if (failedTestCount != 0) {
            Sys.exit(2);
        }
        Sys.exit(0);
    }
}

private class Helper {
    /**
        Compares the type paths of two types `a` and `b`.

        Returns a negative number if `a` should be ordered before `b`, a
        positive number if `b` should be ordered before `a`, or zero if `a` and
        `b` are equal.

        This function differes to sorting types alphabetically (e.g. `"a.B"` <
        `"___C"` alphabetically, but it should be the other way around when
        sorting types and packages).
    **/
    public static function compareTypes(a:String, b:String):Int {
        var aPath = a.split(".");
        var bPath = b.split(".");

        if (aPath.length < bPath.length) {
            return -1;
        }
        if (bPath.length < aPath.length) {
            return 1;
        }
        for (index in 0...aPath.length) {
            var comp = Reflect.compare(aPath[index], bPath[index]);
            if (comp != 0) {
                return comp;
            }
        }
        return 0;
    }
}
