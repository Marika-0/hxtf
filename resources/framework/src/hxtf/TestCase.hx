package hxtf;

import haxe.PosInfos;
import haxe.Timer.stamp;
import hxtf.Print.*;

using StringTools;
using Type;

/**
    This is the base class that should be inherited from when creating test
    cases.

    It includes several methods for asserting runtime values.
**/
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
    public var timestamp(default, null) = stamp();

    /**
        If any assertion calls have failed for this test case.

        Used internally - modifying this value could cause unexpected behavior.
    **/
    public var passed(default, null) = true;

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
        stdout('~~  running ${this.id}...\n');
    }

    /**
        Asserts the given argument `x` and prints an error message if is
        `false`, optionally prepended with some text `msg`.
    **/
    function assert(x:Bool, ?msg:String, ?pos:PosInfos) {
        if (!x) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): assertion failure${msg == null ? "" : ' $msg'}[0m\n');
        }
        passed = passed && x;
        return x;
    }

    /**
        Asserts the equality of the given arguments `a` and `b` using a standard
        `a == b` equity check.

        Prints an error if this assertion evaluates to `false`, optionally
        prepended with some text `msg`.
    **/
    function assertImplicit(a:Dynamic, b:Dynamic, ?msg:String, ?pos:PosInfos) {
        if (a != b) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): implicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts the argument `x` with the function `f` using `f(x)`.

        Prints an error if this assertion evaluates to `false`, optionally
        prepended with some text `msg`.
    **/
    function assertExplicit<T>(x:T, f:T->Bool, ?msg:String, ?pos:PosInfos) {
        if (!f(x)) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): explicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    /**
        Asserts the equality of the given arguments `a` and `b` with the
        function `f` in the form `f(a, b)`.

        Prints an error if this assertion evaluates to `false`, optionally
        prepended with some text `msg`.
    **/
    function assertSpecific<A, B>(a:A, b:B, f:A->B->Bool, ?msg:String, ?pos:PosInfos) {
        if (!f(a, b)) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): specific assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }
}
