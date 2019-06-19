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
        The time this test case was invoked.

        Used internally - modifying this value could cause unexpected behavior.
    **/
    public var timestamp(default, null):Float;

    /**
        If any assertion calls have failed for this test case.

        Used internally - modifying this value could cause unexpected behavior.
    **/
    public var passed(default, null):Bool;

    /**
        Creates a new instance of `this` test case.

        Designed to be used as a super constructor call in the constructor of
        derived classes, optionally specifying the ID of this test case.

        The super constructor call should be called before any assertions are
        made.
    **/
    function new(?id:String) {
        this.id = if (id != null && id.trim().length != 0) {
            id;
        } else {
            this.getClass().getClassName();
        }
        timestamp = haxe.Timer.stamp();
        passed = true;
        stdout('${Print.noAnsi ? " ~~ " : "~~  "}running ${this.id}...\n');
    }

    /**
        Asserts that the given value is `true`.

        Prints an error if this assertion fails, optionally with some text
        `msg`.
    **/
    function assert(x:Bool, ?msg:String, ?pos:PosInfos) {
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

        Prints an error if this assertion fails, optionally with some text
        `msg`.

        This function is equivalent to calling `assert(!x)`.
    **/
    function assertF(x:Bool, ?msg:String, ?pos:PosInfos) {
        if (x) {
            stderr('[41;1m${Print.noAnsi ? "!-- " : "----"}${this.id} (${formatPosInfos(pos)}): assertion failure${msg == null ? "" : ' $msg'}[0m\n');
        }
        passed = passed && !x;
        return x;
    }

    /**
        Asserts the equality of the given arguments `a` and `b` using a standard
        `a == b` equity check.

        Prints an error if this assertion evaluates to `false`, optionally with
        some text `msg`.
    **/
    function assertImplicit(a:Dynamic, b:Dynamic, ?msg:String, ?pos:PosInfos) {
        if (a != b) {
            stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): implicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts the argument `x` with the function `f` using `f(x)`.

        Prints an error if this assertion evaluates to `false`, optionally with
        some text `msg`.
    **/
    function assertExplicit<T>(x:T, f:T->Bool, ?msg:String, ?pos:PosInfos) {
        if (!f(x)) {
            stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): explicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts the equality of the given arguments `a` and `b` with the
        function `f` in the form `f(a, b)`.

        Prints an error if this assertion evaluates to `false`, optionally with
        some text `msg`.
    **/
    function assertSpecific<A, B>(a:A, b:B, f:A->B->Bool, ?msg:String, ?pos:PosInfos) {
        if (!f(a, b)) {
            stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): specific assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts that this point in the code is unreachable.

        Prints an error if this assertion is called, optionally with some text
        `msg`.
    **/
    function assertUnreachable(?msg:String, ?pos:PosInfos) {
        stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${this.id} (${formatPosInfos(pos)}): unreachable code failure${msg == null ? "" : ' $msg'}[0m\n');
        passed = false;
    }

    /**
        Asserts that the given value is `null`.

        Prints an error if this assertion fails, optionally with some text
        `msg`.

        This function is equivalent to calling `assert(v == null)`.
    **/
    inline function assertNull(v:Dynamic, ?msg:String, ?pos:PosInfos) {
        return assert(v == null, msg, pos);
    }

    /**
        Asserts that the given value is not `null`.

        Prints an error if this assertion fails, optionally with some text
        `msg`.

        This function is equivalent to calling `assert(v != null)`.
    **/
    inline function assertNNull(v:Dynamic, ?msg:String, ?pos:PosInfos) {
        return assert(v != null, msg, pos);
    }

    /**
        Asserts that the given value is not a number (`Math.NaN`).

        Prints an error if this assertion fails, optionally with some text
        `msg`.

        This function is equivalent to calling `assert(Math.isNaN(v))`.
    **/
    inline function assertNaN(v:Float, ?msg:String, ?pos:PosInfos) {
        return assert(Math.isNaN(v), msg, pos);
    }

    /**
        Asserts that the given value is a (possibly not finite) number.

        Prints an error if this assertion fails, optionally with some text
        `msg`.

        This function is equivalent to calling `assert(!Math.isNaN(v))`.
    **/
    inline function assertNNaN(v:Float, ?msg:String, ?pos:PosInfos) {
        return assert(!Math.isNaN(v), msg, pos);
    }

    /**
        Asserts that the given value is a finite number.

        Prints an error if this assertion fails, optionally with some text
        `msg`.

        This function is equivalent to calling `assert(Math.isFinite(v))`.
    **/
    inline function assertFinite(v:Float, ?msg:String, ?pos:PosInfos) {
        return assert(Math.isFinite(v), msg, pos);
    }
}
