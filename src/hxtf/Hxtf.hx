package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Invocation;
import hxtf.cli.Printer.*;
import hxtf.sys.FSManager;

class Hxtf {
	static function main() {
		Invocation.run();

		if (Flags.targets.length == 0) {
			noTestFlagsPassed();
			Sys.exit(1);
		}

		Setup.setup();

		for (target in Flags.targets) {
			if (!Setup.checkRunnable(target)) {
				skippingTarget(target);
				nl();
				continue;
			}
			if (!Setup.generateRunHxml(target)) {
				skippingTarget(target);
				nl();
				continue;
			}
			if (!Compile.target(target)) {
				skippingTarget(target);
				nl();
				continue;
			}
			if (Flags.onlyCompiling) {
				nl();
				continue;
			}
			Run.run(target);
			nl();
		}

		// FSManager.delete("./test.hxml");
	}
}
