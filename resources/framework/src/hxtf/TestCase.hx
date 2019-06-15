package hxtf;

import haxe.PosInfos;
import haxe.Timer.stamp;
import hxtf.Print.*;

using Type;

class TestCase {
    public var id(default, null):String;
    public var timestamp(default, null) = stamp();
    public var passed(default, null) = true;

    function new(?id:String) {
        this.id = if (id != null && id != "") {
            id;
        } else {
            this.getClass().getClassName();
        }
        stdout('~~  running ${this.id}...\n');
    }

    function assert(x:Bool, ?msg:String, ?pos:PosInfos) {
        if (!x) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): assertion failure${msg == null ? "" : ' $msg'}[0m\n');
        }
        passed = passed && x;
        return x;
    }

    function assertImplicit(a:Dynamic, b:Dynamic, ?msg:String, ?pos:PosInfos) {
        if (a != b) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): implicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    function assertExplicit<T>(x:T, f:T->Bool, ?msg:String, ?pos:PosInfos) {
        if (!f(x)) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): explicit assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }

    function assertSpecific<A, B>(a:A, b:B, f:A->B->Bool, ?msg:String, ?pos:PosInfos) {
        if (!f(a, b)) {
            stderr('[41;1m----${this.id} (${formatPosInfos(pos)}): specific assertion failure${msg == null ? "" : ' $msg'}[0m\n');
            return passed = false;
        }
        return true;
    }
}
