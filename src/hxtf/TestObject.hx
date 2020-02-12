package hxtf;

import haxe.PosInfos;

using Type;

/**
    A HxTF testing object.

    Unit tests should extend this class for access to assertion methods and
    proper handling of printing.
**/
class TestObject {
    /**
        The number of assertions that have failed for this instance of this test
        case.

        Used internally.
    **/
    @:noCompletion public var _assertionFailureCount(default, null):Int = 0;

    /**
        Asserts that the given value is `true`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assert(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (!x) {
            Helper.handleAssertionFailure(this, "assertion failure", msg, pos);
        }
        return x;
    }

    /**
        Asserts that the given value is `false`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertF(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        return assert(!x, msg, pos);
    }

    /**
        Asserts that the given values are equal through standard equity.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertImplicit<T>(a:T, b:T, ?msg:String, ?pos:PosInfos):Bool {
        if (a == b) {
            return true;
        }
        Helper.handleAssertionFailure(this, "implicit assertion failure", msg, pos);
        return false;
    }

    /**
        Asserts that the given value `x` is correct using the function `f(x)`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertExplicit<T>(x:T, f:(T) -> Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (f(x)) {
            return true;
        }
        Helper.handleAssertionFailure(this, "explicit assertion failure", msg, pos);
        return false;
    }

    /**
        Asserts that the given values `a` and `b` are equal using the function
        `f(a, b)`.`

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertSpecific<A, B>(a:A, b:B, f:(A, B) -> Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (f(a, b)) {
            return true;
        }
        Helper.handleAssertionFailure(this, "specific assertion failure", msg, pos);
        return false;
    }

    /**
        Asserts that this assertion cannot be reached.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertUnreachable(?msg:String, ?pos:PosInfos):Void {
        Helper.handleAssertionFailure(this, "unreachable code failure", msg, pos);
    }

    /**
        Asserts that the given value is null.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertNull(v:Null<Dynamic>, ?msg:String, ?pos:PosInfos):Bool {
        if (v == null) {
            return true;
        }
        Helper.handleAssertionFailure(this, "given value is not null", msg, pos);
        return false;
    }

    /**
        Asserts that the given value is not null.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertNNull(v:Null<Dynamic>, ?msg:String, ?pos:PosInfos):Bool {
        if (v != null) {
            return true;
        }
        Helper.handleAssertionFailure(this, "given value is null", msg, pos);
        return false;
    }

    /**
        Asserts that calling the given function `f()` throws an exception.

        If `type` is specified, also asserts that the thrown exception is of
        that type using `Std.is`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertExcept(f:() -> Void, ?type:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        try {
            f();
        } catch (ex:Dynamic) {
            if (type != null && !Std.is(ex, type)) {
                Helper.handleAssertionFailure(this, "illegal exception type thrown", msg, pos);
                return false;
            }
            return true;
        }
        Helper.handleAssertionFailure(this, "no exception was thrown", msg, pos);
        return false;
    }

    /**
        Asserts that calling the given function `f` does not throw an exception.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertNExcept(f:() -> Void, ?msg:String, ?pos:PosInfos):Bool {
        try {
            f();
        } catch (ex:Dynamic) {
            Helper.handleAssertionFailure(this, "an exception was thrown", msg, pos);
            return false;
        }
        return true;
    }

    /**
        Prints a message to stdout using standard HxTF formatting.

        Calling this method will not fail the test case.
    **/
    function prompt(msg:String, printPos = true, ?pos:PosInfos):Void {
        Print.stdout(Print.Format.formatPromptMessage(this.getClass().getClassName(), msg, printPos, pos));
    }
}

private class Helper {
    @:access(hxtf.TestObject._assertionFailureCount)
    public static function handleAssertionFailure(test:TestObject, reason:String, description:String, pos:PosInfos):Void {
        Print.stderr(Print.Format.formatAssertionFailureMessage(test.getClass().getClassName(), reason, description, pos));
        test._assertionFailureCount++;
        if (Config.maxAssertionFailures != 0 && Config.maxAssertionFailures <= test._assertionFailureCount) {
            throw new MaximumAssertionFailuresReached();
        }
    }

    public static function getPath(test:TestObject):String {
        return "";
    }
}

class MaximumAssertionFailuresReached {
    public function new() {}
}
