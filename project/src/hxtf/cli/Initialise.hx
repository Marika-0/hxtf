package hxtf.cli;

import hxtf.format.Glob;

using StringTools;

/**
    This class parses through the comand line arguments of HxTF, storing user
    configuration in `hxtf.cli.Config`, and prints help, usage, and version
    information when requested.
**/
class Initialise {
    /**
        `true` if errors occured during initialisation that were printed to the
        standard error output. `false` otherwise, and if `run` hasn't yet been
        called.
    **/
    public static var initialisationErrorsOccured(default, null):Bool = false;

    @:allow(hxtf.Hxtf.main)
    static function run():Void {
        // Delay printing of errors until after all flags have been parsed (so
        // that error printing will have ANSI stripped if configured to).
        var initialisationErrors = new List<String>();

        var iterator = Sys.args().iterator();

        // Remove the trailing working directory argument if launched from haxelib.
        if (Sys.getEnv("HAXELIB_RUN") == "1") {
            var args = Sys.args();
            Sys.setCwd(args.pop());
            iterator = args.iterator();
        }

        if (!iterator.hasNext()) {
            printDefaultInfo();
        }

        /**
            Parses a string `argument` as a list of colon-separated unix glob
            expressions into Haxe EReg strings, and stores them in `list`.
        **/
        inline function parseGlobColonList(flag:String, argument:String, list:List<String>) {
            if (argument == null) {
                initialisationErrors.add('[3mFlag \'-$flag\' requires an argument[0m\n');
            } else {
                for (glob in argument.split(":")) {
                    if (glob.length != 0) {
                        try {
                            list.add(new Glob(glob).eregString);
                        } catch (ex:Dynamic) {
                            initialisationErrors.add('[3mInvalid ignored test object glob \'$glob\': ${Std.string(ex)}[0m\n');
                        }
                    }
                }
            }
        }

        /**
            Parses a string `str` as an integer with default value and clamped
            in the range `[min, max]`.
        **/
        inline function parseClampedInteger(str:String, defaultValue:Int, min:Int, max:Int):Int {
            var value = str == null ? defaultValue : Std.parseInt(str);
            if (Std.string(value) != str) {
                value = defaultValue;
            }
            return value < min ? min : max < value ? max : value;
        }

        while (iterator.hasNext()) {
            var flag:String = iterator.next();
            if (flag.startsWith("-")) {
                if (flag == "-" || flag == "--") {
                    initialisationErrors.add('[3mInvalid flag \'$flag\'[0m\n');
                    continue;
                }
                var isLongFlag = flag.startsWith("--");
                var flags = flag.startsWith("--") ? [flag] : flag.substr(1).split("");
                for (part in flags) {
                    switch (part) {
                        case "f" | "--force":
                            Config.FORCE_RUNNING_ALL_TESTS = true;
                        case "b" | "--block":
                            Config.BLOCK_TESTING_ON_FAILURE = true;
                        case "c" | "--compile":
                            Config.COMPILE_ONLY = true;
                        case "w" | "--write":
                            Config.WRITE_COMPILATION_OUTPUT = true;
                        case "a" | "--no-ansi":
                            Config.DISABLE_ANSI_FORMATTING = true;
                        case "l" | "--no-lib":
                            Config.DISABLE_AUTOMATIC_LIBRARY_INCLUSION = true;
                        case "z" | "--no-cache":
                            Config.DISABLE_PASSED_TEST_CACHING = true;
                        case "y" | "--push":
                            parseGlobColonList("y", iterator.hasNext() ? iterator.next() : null, Config.TEST_INCLUDE_GLOBS);
                        case "n" | "--pull":
                            parseGlobColonList("n", iterator.hasNext() ? iterator.next() : null, Config.TEST_IGNORE_GLOBS);
                        case "t" | "--max-threads":
                            Config.MAX_TESTING_THREADS = parseClampedInteger(iterator.hasNext() ? iterator.next() : null, 4, 1, 32);
                        case "m" | "--max-failures":
                            Config.MAX_ASSERTION_FAILURES = parseClampedInteger(iterator.hasNext() ? iterator.next() : null, 4, 0, 2147483647);
                        case "h" | "--help":
                            printHelpInfo();
                        case "v" | "--version":
                            printVersionInfo();
                        case "u" | "--usage":
                            printUsageInfo();
                        case "r" | "--reset":
                            Config.DELETE_CACHE_FILES = true;
                        default:
                            initialisationErrors.add('[3mInvalid flag \'${isLongFlag ? "" : "-"}$part\'[0m\n');
                    }
                }
            } else {
                for (target in flag.split(":")) {
                    if (target.length != 0) {
                        Config.TARGETS.add(target);
                    }
                }
            }
        }

        initialisationErrorsOccured = initialisationErrors.length != 0;
        for (description in initialisationErrors) {
            Print.stderr(description);
        }
    }

    /**
        Prints default information to the user when no flags were given.
    **/
    static function printDefaultInfo():Void {
        //  [------------------------------------80 chars------------------------------------]
        Print.stdout([
            "HxTF version " + hxtf.Macro.getBuild(),
            "Usage: hxtf [OPTIONS...] TARGETS...",
            "Try 'hxtf --help' for more information.",
            ""
        ].join("\n"));
        Sys.exit(0);
    }

    /**
        Prints version information to the user when requested.
    **/
    static function printVersionInfo():Void {
        //  [------------------------------------80 chars------------------------------------]
        Print.stdout([
            // @formatter:off
            "HxTF version " + hxtf.Macro.getBuild(),
            ""
            // @formatter:on
        ].join("\n"));
        Sys.exit(0);
    }

    /**
        Prints usage information to the user when requested.
    **/
    static function printUsageInfo():Void {
        //  [------------------------------------80 chars------------------------------------]
        Print.stdout([
            // @formatter:off
            "Usage: hxtf [-h | --help] [-v | --version] [-u | --usage] [-f | --force]",
            "            [-b | --block] [-c | --compile] [-w | --write] [-a | --no-ansi]",
            "            [-l | --no-lib] [-z | --no-cache] [(-t | --max-threads) <N>]",
            "            [(-m | --max-failures) <N>] [(-y | --push) <TEST>[:<TEST>]*]",
            "            [(-n | --pull) <TEST>[:<TEST>]*] [-r | --reset] <TARGET>[:<TARGET>]*",
            ""
            // @formatter:on
        ].join("\n"));
        Sys.exit(0);
    }

    /**
        Prints help information to the user when requested.
    **/
    static function printHelpInfo():Void {
        //  [------------------------------------80 chars------------------------------------]
        Print.stdout([
            // @formatter:off
            "HxTF version " + hxtf.Macro.getBuild(),
            "Run unit tests for Haxe targets with access to the system environment.",
            "",
            "Usage: hxtf [OPTIONS...] TARGETS...",
            "",
            "Options:",
            "    -f, --force       Force rerunning of previously-passed unit tests.",
            "    -b, --block       Block when a test run fails (during compiling or when run)",
            "                        until a key is pressed.",
            "    -c, --compile     Only compile the specified target/s.",
            "    -w, --write       Pipe Haxe Compiler output to stdout.",
            "    -a, --no-ansi     Strip ANSI formatting from all outputs.",
            "    -l, --no-lib      Disable automatically including the HxTF library.",
            "    -z, --no-cache    Disable caching passing unit tests.",
            "",
            "    -t, --max-threads N     Maximum number of testing threads to use (defaults",
            "                              to 4, clamped within [1,32]).",
            "    -m, --max-failures N    Maximum number of assertion failures before a unit",
            "                              test is aborted (defaults to 4, use 0 to disable).",
            "",
            "    -y, --push TEST[:TEST]*    Run only these unit tests.",
            "    -n, --pull TEST[:TEST]*    Exclude these unit tests (overrides '-y').",
            "",
            "    -h, --help       Print this help information and exit.",
            "    -v, --version    Print version information and exit.",
            "    -u, --usage      Print usage information and exit.",
            "    -r, --reset      Delete the passed-test cache of the specified target/s.",
            "",
            "Targets:",
            "    A colon and/or space-separated list of targets to test.",
            ""
            // @formatter:on
        ].join("\n"));
        Sys.exit(0);
    }
}
