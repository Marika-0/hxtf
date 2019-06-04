package hxtf;

import DateTools.parse;
import StringTools.lpad;
import haxe.Timer.stamp;
import hxtf.Print.*;

using Type;

class TestSuite {
	var tests = new Array<Class<TestCase>>();

	function add(c:Class<TestCase>) {
		tests.push(c);
	}

	function run() {
		for (test in tests) {
			try {
				var t = test.createInstance([]);
				if (t._passed) {
					stdout('[32m${t._id} succeeded (${formatTimeDelta(t._stamp, stamp())})[0m');
				} else {
					stderr('[31;1m${t._id} failed (${formatTimeDelta(t._stamp, stamp())})[0m');
				}
			} catch (ex:Dynamic) {
				stderr('[41;1mException occurred when instantiating test: ${Std.string(test)}[0m');
			}
		}
	}
}
