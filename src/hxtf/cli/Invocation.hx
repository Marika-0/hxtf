package hxtf.cli;

import hxtf.cli.Printer.*;
import hxtf.pattern.HaxeModuleGlob;

using StringTools;

@:allow(hxtf.Hxtf)
class Invocation {
	static function run() {
		var iterator = Sys.args().iterator();
		if (!iterator.hasNext()) {
			printUsage();
		}

		inline function invalidArgument(arg:String) stderr('[3mInvalid ignored argument \'$arg\'[0m\n');

		while (iterator.hasNext()) {
			var arg = iterator.next();

			if (arg.startsWith("-")) {
				arg = arg.substring(1);
				if (arg.startsWith("-")) {
					switch (arg) {
						case "-compile": Flags.onlyCompiling = true;
						case "-force": Flags.forceTestRerun = true;
						case "-quick": Flags.quickTestRuns = true;
						case "-reset": Flags.deletePreviousRecords = true;
						case "-no-ansi": Flags.disableAnsiFormatting = true;
						case "-write": Flags.writeCompilationOutput = true;
						case "-help": printHelp();
						case "-usage": printUsage();
						default: invalidArgument('-$arg');
					}
				} else if (arg.length != 0) {
					if (arg.endsWith("y")) {
						for (module in iterator.next().split(":")) {
							if (module.length != 0) {
								try {
									Flags.testsToRun.push(new HaxeModuleGlob(module).raw);
								} catch (ex:Dynamic) {
									stderr('[3mInvalid ignored test object glob \'$module\'[0m\n');
								}
							}
						}
						if (arg.length == 1) {
							continue;
						}
					}
					if (arg.endsWith("n")) {
						for (module in iterator.next().split(":")) {
							if (module.length != 0) {
								try {
									Flags.testsToIgnore.push(new HaxeModuleGlob(module).raw);
								} catch (ex:Dynamic) {
									stderr('[3mInvalid ignored test object glob \'$module\'[0m\n');
								}
							}
						}
						if (arg.length == 1) {
							continue;
						}
					}
					for (char in arg.split("")) {
						switch (char) {
							case "c": Flags.onlyCompiling = true;
							case "f": Flags.forceTestRerun = true;
							case "q": Flags.quickTestRuns = true;
							case "r": Flags.deletePreviousRecords = true;
							case "a": Flags.disableAnsiFormatting = true;
							case "w": Flags.writeCompilationOutput = true;
							case "h": printHelp();
							case "u": printUsage();
							default: invalidArgument('-$arg');
						}
					}
				} else {
					invalidArgument("-");
				}
			} else {
				for (target in arg.split(":")) {
					Flags.targets.push(target);
				}
			}
		}
		return true;
	}

	static function printHelp() {
		//          [------------------------------------80-chars------------------------------------]
		stdout("Usage: hxtf [OPTIONS...] TARGETS...\n");
		stdout("Run configurable unit tests for a haxe program.\n");
		stdout("\n");
		stdout("Options:\n");
		stdout("    -c, --compile   only run compilation for the specified targets\n");
		stdout("    -f, --force     force rerunning of previously-passed tests\n");
		stdout("    -q, --quick     do not wait for acknowledgement after a failed test run\n");
		stdout("    -r, --reset     delete all passed-test records for each target\n");
		stdout("    -a, --no-ansi   disable output ANSI formatting\n");
		stdout("    -w, --write     write haxe compiler outputs to stdout\n");
		stdout("                      output cannot be formatted to remove ANSI\n");
		stdout("\n");
		stdout("    -y TEST[:TEST]* run only these tests\n");
		stdout("    -n TEST[:TEST]* do not run these tests (overridden by '-y')\n");
		stdout("\n");
		stdout("    -h, --help      print this help and exit\n");
		stdout("    -u, --usage     print usage information and exit\n");
		stdout("\n");
		stdout("Targets:\n");
		stdout("    A colon-separated list of targets to test (in order)\n");
        stdout("\n");
		Sys.exit(0);
	}

	static function printUsage() {
		stdout("Usage: hxtf [OPTIONS...] TARGETS...\n");
        stdout("\n");
		Sys.exit(0);
	}
}
