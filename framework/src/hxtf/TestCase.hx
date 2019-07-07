package hxtf;

import haxe.PosInfos;
import hxtf.Print.*;

using Reflect;
using Type;

/**
    Tertiary root for test runs - chains assertion calls.
**/
class TestCase {
    /**
        If any assertion calls for this test case have failed.

        Used internally.
    **/
    public var passed(default, never) = true;

    /**
        Asserts that the given value is `true`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assert(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (!x) {
            Helper.fail(this, "assertion failure", msg, pos);
        }
        return x;
    }

    /**
        Asserts that the given value is `false`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    inline function assertF(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        return assert(!x, msg, pos);
    }

    /**
        Asserts that the given values are equal through standard equity.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertImplicit<T>(a:T, b:T, ?msg:String, ?pos:PosInfos):Bool {
        return if (!(a == b)) {
            Helper.fail(this, "implicit failure", msg, pos);
        } else {
            true;
        }
    }

    /**
        Asserts that the given value `x` is true by passing it through `f(x)`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertExplicit<T>(x:T, f:T->Bool, ?msg:String, ?pos:PosInfos):Bool {
        return if (!f(x)) {
            Helper.fail(this, "explicit failure", msg, pos);
        } else {
            true;
        }
    }

    /**
        Asserts that the given values `a` and `b` are equal by passing it
        through `f(a, b)`.`

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertSpecific<A, B>(a:A, b:B, f:A->B->Bool, ?msg:String, ?pos:PosInfos):Bool {
        return if (!f(a, b)) {
            Helper.fail(this, "explicit failure", msg, pos);
        } else {
            true;
        }
    }

    /**
        Asserts that the assertion cannot be reached.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    inline function assertUnreachable(?msg:String, ?pos:PosInfos):Bool {
        return Helper.fail(this, "unreachable failure", msg, pos);
    }

    /**
        Asserts that the given value is null.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertNull(v:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        return if (v != null) {
            Helper.fail(this, "not null", msg, pos);
        } else {
            true;
        }
    }

    /**
        Asserts that the given value is not null.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertNNull(v:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        return if (v == null) {
            Helper.fail(this, "is null", msg, pos);
        } else {
            true;
        }
    }

    /**
        Asserts that calling the given function `f` throws an exception.

        If `type` is specified, also asserts that the thrown exception is of
        that type using `Std.is`.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertExcept(f:Void->Void, ?type:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        try {
            f();
        } catch (ex:Dynamic) {
            return if (type != null && !Std.is(ex, type)) {
                Helper.fail(this, "illegal exception type", msg, pos);
            } else {
                true;
            }
        }
        return Helper.fail(this, "no exception thrown", msg, pos);
    }

    /**
        Asserts that calling the given function `f` does not throw an exception.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    function assertNExcept(f:Void->Void, ?msg:String, ?pos:PosInfos):Bool {
        try {
            f();
        } catch (ex:Dynamic) {
            return Helper.fail(this, "exception thrown", msg, pos);
        }
        return true;
    }

    /**
        Asserts that the given value is finite.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    inline function assertFinite(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(Math.isFinite(v), msg, pos);
    }

    /**
        Asserts that the given value is not a number.

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    inline function assertNaN(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(Math.isNaN(v), msg, pos);
    }

    /**
        Asserts that the given value is a number (or +/- infinity).

        Prints to the standard error stream if the assertion fails, optionally
        with some text `msg`.
    **/
    inline function assertNNaN(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(!Math.isNaN(v), msg, pos);
    }

    /**
        Prints an error message that some unspecified error occurred.

        Calling this method does not fail the test case.
    **/
    function softFail(msg:String, printPos = true, ?pos:PosInfos):Void {
        Helper.prompt(this, msg, printPos, pos);
    }

    /**
        Prints an error message that some unspecified error occurred.

        Calling this method fails the test case.
    **/
    function hardFail(msg:String, printPos = true, ?pos:PosInfos):Void {
        Helper.prompt(this, msg, printPos, pos);
        this.setField("passed", false);
    }
}

private class Helper {
    public static function fail(test:TestCase, pre:String, msg:String, pos:PosInfos):Bool {
        stderr('[41;1m${noAnsi ? "!-- " : "----"}${test.getClass().getClassName()} (${formatPosInfos(pos)}):${pre == null ? "" : ' $pre'}${msg == null ? "" : ' $msg'}[0m\n');
        test.setField("passed", false);
        return false;
    }

    public static inline function prompt(test:TestCase, msg:String, printPos:Bool, pos:PosInfos):Void {
        stderr('[41;1m${Print.noAnsi ? "!---" : "----"}${test.getClass().getClassName()}${printPos ? ' (${formatPosInfos(pos)})' : ""}: $msg[0m\n');
    }
}
