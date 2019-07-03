package hxtf;

import haxe.PosInfos;
import hxtf.Print.*;

using Reflect;
using Type;

class TestCase {
    public var passed(default, never) = true;

    function assert(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        if (!x) {
            Helper.fail(this, "assertion failure", msg, pos);
        }
        return x;
    }

    inline function assertF(x:Bool, ?msg:String, ?pos:PosInfos):Bool {
        return assert(!x, msg, pos);
    }

    function assertImplicit<T>(a:T, b:T, ?msg:String, ?pos:PosInfos):Bool {
        return if (!(a == b)) {
            Helper.fail(this, "implicit failure", msg, pos);
        } else {
            true;
        }
    }

    function assertExplicit<T>(x:T, f:T->Bool, ?msg:String, ?pos:PosInfos):Bool {
        return if (!f(x)) {
            Helper.fail(this, "explicit failure", msg, pos);
        } else {
            true;
        }
    }

    function assertSpecific<A, B>(a:A, b:B, f:A->B->Bool, ?msg:String, ?pos:PosInfos):Bool {
        return if (!f(a, b)) {
            Helper.fail(this, "explicit failure", msg, pos);
        } else {
            true;
        }
    }

    inline function assertUnreachable(?msg:String, ?pos:PosInfos):Bool {
        return Helper.fail(this, "unreachable failure", msg, pos);
    }

    function assertNull(v:Dynamic, ?msg:String, ?pos:PosInfos):Bool {
        return if (v != null) {
            Helper.fail(this, "not null", msg, pos);
        } else {
            true;
        }
    }

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

    function assertNExcept(f:Void->Void, ?msg:String, ?pos:PosInfos):Bool {
        try {
            f();
        } catch (ex:Dynamic) {
            return Helper.fail(this, "exception thrown", msg, pos);
        }
        return true;
    }

    inline function assertFinite(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(Math.isFinite(v), msg, pos);
    }

    inline function assertNaN(v:Float, ?msg:String, ?pos:PosInfos):Bool {
        return assert(Math.isNaN(v), msg, pos);
    }

    function softFail(msg:String, printPos = true, ?pos:PosInfos):Void {
        Helper.prompt(this, msg, printPos, pos);
    }

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
        stderr('[41;1m${Print.noAnsi ? "!!!!" : "----"}${test.getClass().getClassName()}${printPos ? ' (${formatPosInfos(pos)})' : ""}: $msg[0m\n');
    }
}
