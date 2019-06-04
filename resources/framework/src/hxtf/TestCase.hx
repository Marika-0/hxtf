package hxtf;

import haxe.PosInfos;
import haxe.Timer.stamp;
import hxtf.Print.*;

using Type;

class TestCase {
	public var _id(default, null):String;
	public var _stamp(default, null) = stamp();
	public var _passed(default, null) = true;

	function new(?id:String) {
		_id = if (id != null && id != "") id else this.getClass().getClassName();
		stdout('running $_id...');
	}

	function assert(x:Bool, ?msg:String, ?pos:PosInfos) {
		if (!x) {
			stderr('[41;1m${formatPosInfos(pos)} assertion failure${msg == null ? "" : ' $msg'}[0m');
		}
		return _flag(x);
	}

	function assertImplicit(a:Dynamic, b:Dynamic, ?msg:String, ?pos:PosInfos) {
		if (a != b) {
			stderr('[41;1m${formatPosInfos(pos)} implicit assertion failure${msg == null ? "" : ' $msg'}[0m');
			return _flag(false);
		}
		return _flag(true);
	}

	function assertExplicit<T>(x:T, f:T->Bool, ?msg:String, ?pos:PosInfos) {
		if (!f(x)) {
			stderr('[41;1m${formatPosInfos(pos)} explicit assertion failure${msg == null ? "" : ' $msg'}[0m');
			return _flag(false);
		}
		return _flag(true);
	}

	function assertSpecific<A, B>(a:A, b:B, f:A->B->Bool, ?msg:String, ?pos:PosInfos) {
		if (!f(a, b)) {
			stderr('[41;1m${formatPosInfos(pos)} specific assertion failure${msg == null ? "" : ' $msg'}[0m');
			return _flag(false);
		}
		return _flag(true);
	}

	inline function _flag(x:Bool) {
		_passed = _passed && x;
		return x;
	}
}
