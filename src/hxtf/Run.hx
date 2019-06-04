package hxtf;

import hxtf.cli.Printer.*;

@:allow(hxtf.Hxtf)
class Run {
	static function run(target:String) {
		testingTarget(target);

		var code = Sys.command('sh $target.sh');

		if (code != 0) {
			testingFailed(target);
			nl();
		}

		return code == 0;
	}
}
