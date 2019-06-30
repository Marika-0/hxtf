package hxtf;

import haxe.PosInfos;
import hxtf.Print.*;

using StringTools;
using Type;

/**
    This is the base class that should be inherited from when creating test
    cases.

    It includes several methods for asserting runtime values.
**/
@:allow(hxtf.TestSuite)
class TestCase {
    /**
        The ID of this test case. If set, the ID will be printed to the console
        instead of the class path.
    **/
    public var id(default, null):String;

    /**
        If any assertion calls have failed for this test case.

        Used internally - modifying this value could cause unexpected behavior.
    **/
    public var passed(default, null):Bool;

    /**
        Creates a new instance of `this` test case.

        Designed to be used as a super constructor call in the constructor of
        derived classes, optionally specifying the ID of this test case.

        The super constructor must be called before any assertions are made.
    **/
    function new(?id:String) {
        this.id = if (id != null && id.trim().length != 0) {
            id;
        } else {
            this.getClass().getClassName();
        }
        passed = true;
        stdout('${Print.noAnsi ? " ~~ " : "~~  "}running ${this.id}...\n');
    }

    /**
        Asserts that the given value is `true`.

        Prints an error if the assertion fails, optionally with some text `msg`.
    **/
    function assert(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (!x) {
            stderr('[41;1m${Print.noAnsi ? "!-- " : "----"}${this.id} (${formatPosInfos(pos)}): assertion failure${msg == null ? "" : ' $msg'}[0m\n');
        }
        passed = passed && x;
        return x;
    }

    /**
        Asserts that the given value is not `true`.

        In particular, `null` is evaluated as `false` such that `assertF(false)`
        `assertF(null)` both succeed.

        Prints an error if the assertion fails, optionally with some text `msg`.

        This function is equivalent to calling `assert(!x)`.
    **/
    function assertF(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (x) {
            stderr('[41;1m${Print.noAnsi ? "!-- " : "----"}${this.id} (${formatPosInfos(pos)}): assertion failure${msg == null ? "" : ' $msg'}[0m\n');
        }
        passed = passed && !x;
        return x;
    }

    /**
        Asserts the equality of the given arguments `a` and `b` using a standard
        `a == b` equity check.

        Prints an error if the assertion fails, optionally with some text `msg`.
    **/
    function assertImplicit(a:Dynamic, b:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        if (a != b) {
            stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): implicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts the argument `x` with the function `f` using `f(x)`.

        Prints an error if the assertion fails, optionally with some text `msg`.
    **/
    function assertExplicit<T>(x:T, f:T->Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (!f(x)) {
            stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): explicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts the equality of the given arguments `a` and `b` with the
        function `f` in the form `f(a, b)`.

        Prints an error if the assertion fails, optionally with some text `msg`.
    **/
    function assertSpecific<A, B>(a:A, b:B, f:A->B->Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (!f(a, b)) {
            stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): specific assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts that this point in the code is unreachable.

        Prints an error if the assertion fails, optionally with some text `msg`.
    **/
    function assertUnreachable(?msg:String, ?pos:PosInfos):Bool {
        stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): unreachable code failure${msg == null ? "" : ' $msg'}[0m\n');
        return passed = false;
    }

    /**
        Asserts that the given value is `null`.

        Prints an error if the assertion fails, optionally with some text `msg`.

        This function is equivalent to calling `assert(v == null)`.
    **/
    inline function assertNull(v:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        return assert(v == null, msg, pos);
    }

    /**
        Asserts that the given value is not `null`.

        Prints an error if the assertion fails, optionally with some text `msg`.

        This function is equivalent to calling `assert(v != null)`.
    **/
    inline function assertNNull(v:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        return assert(v != null, msg, pos);
    }

    /**
        Asserts that the given value is not a number (`Math.NaN`).

        Prints an error if the assertion fails, optionally with some text `msg`.

        This function is equivalent to calling `assert(Math.isNaN(v))`.
    **/
    inline function assertNaN(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(Math.isNaN(v), msg, pos);
    }

    /**
        Asserts that the given value is a (possibly not finite) number.

        Prints an error if the assertion fails, optionally with some text `msg`.

        This function is equivalent to calling `assert(!Math.isNaN(v))`.
    **/
    inline function assertNNaN(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(!Math.isNaN(v), msg, pos);
    }

    /**
        Asserts that the given value is a finite number.

        Prints an error if the assertion fails, optionally with some text `msg`.

        This function is equivalent to calling `assert(Math.isFinite(v))`.
    **/
    inline function assertFinite(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(Math.isFinite(v), msg, pos);
    }

    /**
        Asserts that running the given function `f` throws an exception.

        Prints an error if the assertion fails, optionally with some text `msg`.

        if `type` is specified, will also assert that the thrown exception is of
        type with `Std.is`.
    **/
    function assertExcept(f:Void->Void, ?type:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        try {
            f();
        } catch (ex:Dynamic) {
            if (type != null && !Std.is(ex, type)) {
                stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): incorrect exception type failure${msg == null ? "" : ' $msg'}[0m\n');
                return passed = false;
            }
            return true;
        }
        stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): no exception thrown failure${msg == null ? "" : ' $msg'}[0m\n');
        return passed = false;
    }

    /**
        Asserts that running the given function `f` does not throw an exception.

        Prints an error if the assertion fails with the `Std.string` form of the
        thrown exception if `show` is `true`.
    **/
    function assertNExcept(f:Void->Void, ?show = true, ?pos:PosInfos):Bool {
        try {
            f();
        } catch (ex:Dynamic) {
            stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): thrown exception failure${show ? Std.string(ex) : ""}[0m\n');
            return passed = false;
        }
        return true;
    }
}
