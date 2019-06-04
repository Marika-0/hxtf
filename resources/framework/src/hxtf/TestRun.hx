package hxtf;

import hxtf.Print.*;

using Type;

class TestRun {
	var suites = new Array<Class<TestSuite>>();

	function add(c:Class<TestSuite>) {
		suites.push(c);
	}

	function run() {
		for (suite in suites) {
			try {
				suite.createInstance([]);
			} catch (ex:Dynamic) {
				stderr('[41;1mException: ${Std.string(ex)}[0m');
				stderr('[41;1mWhen instantiating suite: ${Std.string(suite)}[0m');
			}
		}
	}
}
