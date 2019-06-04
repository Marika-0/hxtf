package hxtf.cli;

import hxtf.pattern.HaxeModuleGlob;

using StringTools;

@:allow(hxtf.Hxtf)
class Invocation {
	static function run() {
		var iterator = Sys.args().iterator();
		if (!iterator.hasNext()) {
			Printer.printUsage();
		}
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
						case "-help": Printer.printHelp();
						case "-usage": Printer.printUsage();
						default: Printer.invalidArgument('-$arg');
					}
				} else if (arg.length != 0) {
					if (arg.endsWith("y")) {
						for (module in iterator.next().split(":")) {
							if (module.length != 0) {
								try {
									Flags.testsToRun.push(new HaxeModuleGlob(module).raw);
								} catch (ex:Dynamic) {
									Printer.invalidObjectGlob(module);
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
									Printer.invalidObjectGlob(module);
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
							case "h": Printer.printHelp();
							case "u": Printer.printUsage();
							default: Printer.invalidArgument('-$arg');
						}
					}
				} else {
					Printer.invalidArgument("-");
				}
			} else {
				for (target in arg.split(":")) {
					Flags.targets.push(target);
				}
			}
		}
		return true;
	}
}
