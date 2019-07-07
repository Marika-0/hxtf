package hxtf.cli;

import hxtf.cli.Printer.*;
import hxtf.pattern.HaxeModuleGlob;

using StringTools;

/**
    This class handles initial cli invocation and parses the given arguments,
    storing valid information in `hxtf.cli.Flags`.
**/
class Invocation {
    static var postRunStdErrs = new Array<String>();

    @:allow(hxtf.Hxtf)
    static function run():Void {
        var iterator = Sys.args().iterator();
        if (!iterator.hasNext()) {
            printUsage();
        }

        inline function invalidArgument(arg:String) {
            postRunStdErrs.push('[3mInvalid argument \'$arg\'[0m\n');
            hxtf.Hxtf.prePrintingOccurred = true;
        }

        inline function embeddedArgument(arg:String) {
            postRunStdErrs.push('[3mEmbedded argument \'$arg\' requires an argument and was ignored[0m\n');
            hxtf.Hxtf.prePrintingOccurred = true;
        }

        while (iterator.hasNext()) {
            var arg = iterator.next();

            if (arg.startsWith("-")) {
                arg = arg.substring(1);
                if (arg.startsWith("-")) {
                    switch (arg) {
                        case "-compile":
                            Flags.onlyCompiling = true;
                        case "-force":
                            Flags.forceTestRerun = true;
                        case "-quick":
                            Flags.quickTestRuns = true;
                        case "-reset":
                            Flags.deletePreviousRecords = true;
                        case "-no-ansi":
                            Flags.disableAnsiFormatting = true;
                        case "-write":
                            Flags.writeCompilationOutput = true;
                        case "-help":
                            printHelp();
                        case "-usage":
                            printUsage();
                        default:
                            invalidArgument('-$arg');
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
                        arg = arg.substr(0, arg.length - 1);
                    } else if (arg.endsWith("n")) {
                        for (module in iterator.next().split(":")) {
                            if (module.length != 0) {
                                try {
                                    Flags.testsToIgnore.push(new HaxeModuleGlob(module).raw);
                                } catch (ex:Dynamic) {
                                    stderr('[3mIgnored test object glob \'$module\'[0m\n');
                                    hxtf.Hxtf.prePrintingOccurred = true;
                                }
                            }
                        }
                        if (arg.length == 1) {
                            continue;
                        }
                        arg = arg.substr(0, arg.length - 1);
                    }
                    for (char in arg.split("")) {
                        switch (char) {
                            case "c":
                                Flags.onlyCompiling = true;
                            case "f":
                                Flags.forceTestRerun = true;
                            case "q":
                                Flags.quickTestRuns = true;
                            case "r":
                                Flags.deletePreviousRecords = true;
                            case "a":
                                Flags.disableAnsiFormatting = true;
                            case "w":
                                Flags.writeCompilationOutput = true;
                            case "h":
                                printHelp();
                            case "u":
                                printUsage();
                            case "y":
                                embeddedArgument("y");
                            case "n":
                                embeddedArgument("n");
                            default:
                                invalidArgument('-$char');
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

        hxtf.Hxtf.prePrintingOccurred = postRunStdErrs.length != 0;
        for (item in postRunStdErrs) {
            stderr(item);
        }
    }

    static function printHelp():Void {
        //          [------------------------------------80-chars------------------------------------]
        stdout("Usage: hxtf [OPTIONS...] TARGETS...\n");
        stdout("Run configurable unit tests for a haxe program.\n");
        stdout("\n");
        stdout("Options:\n");
        stdout("    -c, --compile   only run compilation for the specified targets\n");
        stdout("    -f, --force     force rerunning of previously-passed tests\n");
        stdout("    -q, --quick     do not wait for acknowledgement after a failed test run\n");
        stdout("    -r, --reset     delete the passed-test cache of each target\n");
        stdout("                      tests will not be invoked\n");
        stdout("    -a, --no-ansi   disable output ANSI formatting\n");
        stdout("    -w, --write     write haxe compiler outputs to stdout\n");
        stdout("                      output cannot be formatted to remove ANSI\n");
        stdout("\n");
        stdout("    -y TEST[:TEST]* run only these tests\n");
        stdout("    -n TEST[:TEST]* do not run these tests (overrides '-y')\n");
        stdout("\n");
        stdout("    -h, --help      print this help and exit\n");
        stdout("    -u, --usage     print usage information and exit\n");
        stdout("\n");
        stdout("Targets:\n");
        stdout("    A colon-separated list of targets to test (in order)\n");
        stdout("\n");
        Sys.exit(0);
    }

    static function printUsage():Void {
        stdout("Usage: hxtf [OPTIONS...] TARGETS...\n");
        stdout("\n");
        Sys.exit(0);
    }
}
