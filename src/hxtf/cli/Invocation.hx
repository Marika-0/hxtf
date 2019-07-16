package hxtf.cli;

import hxtf.cli.Printer.*;
import hxtf.pattern.HaxeModuleGlob;

using StringTools;

/**
    This class handles initial cli invocation and parses the given arguments,
    storing valid information in `hxtf.cli.Flags`.
**/
class Invocation {
    /**
        Set to `true` if any printing occurred due to invalid flags or
        arguments.
    **/
    public static var prePrintingOccurred(default, null) = false;

    static var postRunErrors = new List<String>();

    @:allow(hxtf.Hxtf)
    static function run():Void {
        var iterator = Sys.args().iterator();
        if (!iterator.hasNext()) {
            printUsage();
        }

        inline function invalidArgument(arg:String) {
            postRunErrors.add('[3mInvalid flag \'$arg\'[0m\n');
        }

        inline function embeddedArgument(arg:String) {
            postRunErrors.add('[3mEmbedded flag \'$arg\' requires an argument[0m\n');
        }

        inline function missingArgument(arg:String) {
            postRunErrors.add('[3mFlag \'$arg\' requires an argument[0m\n');
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
                        var val = iterator.next();
                        if (val == null) {
                            missingArgument("-y");
                        } else {
                            for (module in val.split(":")) {
                                if (module.length != 0) {
                                    try {
                                        Flags.testsToRun.push(new HaxeModuleGlob(module).raw);
                                    } catch (ex:Dynamic) {
                                        postRunErrors.add('[3mInvalid ignored test object glob \'$module\'[0m\n');
                                    }
                                }
                            }
                        }
                        if (arg.length == 1) {
                            continue;
                        }
                        arg = arg.substr(0, arg.length - 1);
                    } else if (arg.endsWith("n")) {
                        var val = iterator.next();
                        if (val == null) {
                            missingArgument("-n");
                        } else {
                            for (module in val.split(":")) {
                                if (module.length != 0) {
                                    try {
                                        Flags.testsToIgnore.push(new HaxeModuleGlob(module).raw);
                                    } catch (ex:Dynamic) {
                                        stderr('[3mIgnored test object glob \'$module\'[0m\n');
                                    }
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

        prePrintingOccurred = postRunErrors.length != 0;
        for (item in postRunErrors) {
            stderr(item);
        }
    }

    // @formatter:off
    static function printHelp():Void {
        //  [------------------------------------80 chars------------------------------------]
        stdout([
            "usage: hxtf [OPTIONS...] TARGETS...",
            "",
            "Run configurable unit tests for Haxe targets",
            "with access to Sys and the system package",
            "",
            "Options:",
            "    -c, --compile   only run compilation for the specified targets",
            "    -f, --force     force rerunning of previously-passed tests",
            "    -q, --quick     do not wait for acknowledgement after a failed test run",
            "    -r, --reset     delete the passed-test cache of each target",
            "                      tests will not be invoked",
            "    -a, --no-ansi   disable output ANSI formatting",
            "    -w, --write     write haxe compiler outputs to stdout",
            "                      output cannot be formatted to remove ANSI",
            "",
            "    -y TEST[:TEST]* only compile/run these tests",
            "    -n TEST[:TEST]* exclude these tests (overrides '-y')",
            "",
            "    -h, --help      print this help and exit",
            "    -u, --usage     print usage information and exit",
            "",
            "Targets:",
            "    A colon or space-separated list of targets to test (in order)",
            "",
            ""
        ].join("\n"));
        Sys.exit(0);
    }

    // @formatter:off
    static function printUsage():Void {
        //  [------------------------------------80 chars------------------------------------]
        stdout([
            "usage: hxtf [OPTIONS...] TARGETS...",
            "",
            "Use 'hxtf --help' for more information.",
            "",
            ""
        ].join("\n"));
        Sys.exit(0);
    }
}
