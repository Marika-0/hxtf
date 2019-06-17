package hxtf;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
    This class is designed to be inherited from by test suites.
**/
@:allow(hxtf.TestRun)
class TestSuite {
    /**
        The number of test cases that have passed for this suite.
    **/
    public var passed(default, null):UInt = 0;
    /**
        The number of test cases that have failed for this suite.
    **/
    public var failed(default, null):UInt = 0;

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

            if (!Context.defined("hxtf__macro__SuiteHasCases_" + Context.getLocalClass().toString())) {
                Compiler.define("hxtf__macro__SuiteHasCases_" + Context.getLocalClass().toString());
                return macro {
                    hxtf.Print.stdout("\n### launching " + Type.getClassName(Type.getClass(this)) + "\n");
                    hxtf.TestRun.evaluateCase(this, new $type(), $v{name});
                };
            }

            return macro {
                hxtf.TestRun.evaluateCase(this, new $type(), $v{name});
            };
        } catch (ex:Dynamic) {
            Context.error('Error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}
