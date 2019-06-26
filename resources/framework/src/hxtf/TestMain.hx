package hxtf;

import haxe.macro.Expr;
import haxe.macro.Context;

/**
    This class is inherited from by `TestMain` and hides functionality, letting
    the `TestMain` implementation appear minimal.

    Use the `add` function in `TestMain` to include Test Suites for testing.

    There seems to be a problem with inheriting fields while in macro context.
    `TestMain` is instantiated directly in `hxtf.TestRun`, while instances of
    `hxtf.TestSuite` are instantiated from expressions that have passed through
    macro context. For some reason, a compilation error "./src/TestMain.hx
    Unknown identifier : Add" appears when trying to use `add` non-statically.

    Due to this, the `add` function must be called with `hxtf.TestMain.add` in
    `TestMain`, but test suites can use their `add` function without issue.
**/
@:allow(hxtf.TestRun)
class TestMain {
    /**
        The total number of test cases that have passed.
    **/
    @:noCompletion public var passed(default, null):UInt = 0;

    /**
        The total number of test cases that have failed.
    **/
    @:noCompletion public var failed(default, null):UInt = 0;

    /**
        Adds the given test suite to the test run.

        If the argument of this function is not of runtime type
        `Class<hxtf.TestSuite>`, the result is unspecified.

        See `hxtf.BuildTools.reifyTypePath` for more information.
    **/
    static macro function add(e:Expr):Expr {
        try {
            var type = hxtf.BuildTools.reifyTypePath(e);
            var name = hxtf.BuildTools.toPackageArray(type).join(".");

            return macro {
                hxtf.TestRun.evaluateSuite(this, new $type(), $v{name});
            };
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }

        return macro null;
    }
}
