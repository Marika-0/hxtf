package hxtf;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import hxtf.Print.*;

using StringTools;
using Type;

/**
    This class is designed to be inherited from by test suites.
**/
@:allow(hxtf.TestRun)
@:allow(hxtf.TestMain)
class TestSuite {
    /**
        The ID of this test case. If set, the ID will be printed to the console
        instead of the class path.
    **/
    public var id(default, null):String;

    /**
        The number of test cases that have passed for this suite.
    **/
    public var passed(default, null):UInt = 0;

    /**
        The number of test cases that have failed for this suite.
    **/
    public var failed(default, null):UInt = 0;

    /**
        Creates a new TestSuite.

        Designed to be used as a super constructor call in the constructor of
        derived classes, optionally specifying the ID of this test suite.

        The super constructor call should be called before any test cases are
        added.
    **/
    function new(?id:String) {
        this.id = if (id != null && id.trim().length != 0) {
            id;
        } else {
            this.getClass().getClassName();
        }
    }

    /**
        Adds the given test case to the test run.

        If the argument of this function is not of runtime type
        `Class<hxtf.TestCase>`, the result is unspecified.

        See `hxtf.BuildTools.reifyTypePath` for more information.
    **/
    macro function add(_:Expr, e:Expr) {
        try {
            var type = BuildTools.reifyTypePath(e);
            var name = BuildTools.toPackageArray(type).join(".");

            if (!BuildTools.useTestObject(name)) {
                return macro null;
            }

            if (!BuildTools.nonEmptySuites.exists(Context.getLocalClass().toString())) {
                BuildTools.nonEmptySuites.set(Context.getLocalClass().toString(), true);
                return macro {
                    hxtf.Print.stdout("\n" + (hxtf.Print.noAnsi ? " ## " : "### ") + "launching " + id + "\n");
                    try {
                        hxtf.TestRun.evaluateCase(this, new $type(), $v{name});
                    } catch (ex:Dynamic) {
                        failed++;
                        hxtf.Print.stderr("[41;1m" + (hxtf.Print.noAnsi ? "!-- " : "----") + $v{name} + " unhandled exception occurred: " + Std.string(ex) +
                            "[0m\n");
                    }
                };
            }

            return macro {
                try {
                    hxtf.TestRun.evaluateCase(this, new $type(), $v{name});
                } catch (ex:Dynamic) {
                    failed++;
                    hxtf.Print.stderr("[41;1m" + (hxtf.Print.noAnsi ? "!-- " : "----") + $v{name} + " unhandled exception occurred: " + Std.string(ex) +
                        "[0m\n");
                }
            };
        } catch (ex:Dynamic) {
            Context.error('Error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}
