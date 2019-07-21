package hxtf.cli;

import hxtf.cli.Printer.*;
import hxtf.pattern.Glob;

using StringTools;

/**
    Handles parsing CLI flags and arguments; printing invalid flag errors;
    prompting help/usage information; and creating the default import file.
**/
class Invocation {
    /**
        If `true`, the call to `hxtf.cli.Invocation.run()` printed errors.

        If this value is read before `hxtf.cli.Invocation.run()` is called, the
        result is unspecified.
    **/
    public static var prePrintingOccurred(default, null):Bool;

    /**
        A list of string to print to stderr after parsing CLI flags and
        arguments.

        Allows parsing of the 'no ansi' flag if it's provided before printing
        errors.
    **/
    static var invocationErrors = new List<String>();

    /**
        Parses invocation flags and arguments, printing error and help
        information as appropriate.

        If this function is called more that once, the result is unspecified.
    **/
    @:allow(hxtf.Hxtf)
    static function run():Void {
        var iterator = Sys.args().iterator();

        // Remove the final working directory argument if launched from haxelib.
        if (Sys.getEnv("HAXELIB_RUN") == "1") {
            var args = Sys.args();
            Sys.setCwd(args.pop());
            iterator = args.iterator();
        }

        if (!iterator.hasNext()) {
            printNoFlagsUsage();
        }

        while (iterator.hasNext()) {
            var flag = iterator.next();
            if (flag.startsWith("-")) {
                if (flag == "-" || flag == "--") {
                    invocationErrors.add('[3mInvalid flag \'$flag\'[0m\n');
                    continue;
                }
                var flags = flag.startsWith("--") ? [flag] : flag.substr(1).split("");
                for (part in flags) {
                    switch (part) {
                        case "c" | "--compile":
                            Flags.onlyCompiling = true;
                        case "f" | "--forcing":
                            Flags.forceTestRerun = true;
                        case "q" | "--quick":
                            Flags.quickTestRuns = true;
                        case "a" | "--no-ansi":
                            Flags.disableAnsiFormatting = true;
                        case "w" | "--write":
                            Flags.writeCompilationOutput = true;
                        case "z" | "--no-cache":
                            Flags.saveCache = false;
                        case "y" | "--push":
                            var argument = iterator.next();
                            if (argument == null) {
                                invocationErrors.add("[3mFlag '-y' requires an argument[0m\n");
                            } else {
                                for (glob in argument.split(":").filter((s) -> s.length != 0)) {
                                    try {
                                        Flags.testsToRun.push(new Glob(glob).raw);
                                    } catch (ex:Dynamic) {
                                        invocationErrors.add('[3mInvalid ignored test object glob \'$glob\': ${Std.string(ex)}[0m\n');
                                    }
                                }
                            }
                        case "n" | "--pull":
                            var argument = iterator.next();
                            if (argument == null) {
                                invocationErrors.add("[3mFlag '-n' requires an argument[0m\n");
                            } else {
                                for (glob in argument.split(":").filter((s) -> s.length != 0)) {
                                    try {
                                        Flags.testsToIgnore.push(new Glob(glob).raw);
                                    } catch (ex:Dynamic) {
                                        invocationErrors.add('[3mInvalid ignored test object glob \'$glob\': ${Std.string(ex)}[0m\n');
                                    }
                                }
                            }
                        case "h" | "--help":
                            printHelp();
                        case "u" | "--usage":
                            printUsage();
                        case "r" | "--reset":
                            Flags.deletePreviousRecords = true;
                        case "--default-import":
                            createDefaultImport();
                        default:
                            invocationErrors.add('[3mInvalid flag \'$flag\'[0m\n');
                    }
                }
            } else {
                Flags.targets.concat(flag.split(":").filter((s) -> s.length != 0));
            }
        }

        prePrintingOccurred = !invocationErrors.isEmpty();
        for (item in invocationErrors) {
            stderr(item);
        }
    }

    // @formatter:off

    /**
        Prints help information and exits.
    **/
    static function printHelp():Void {
        //  [------------------------------------80 chars------------------------------------]
        stdout([
            "Usage: hxtf [OPTIONS...] TARGETS...",
            "",
            "Run configurable unit tests for Haxe targets",
            "with access to Sys and the system package",
            "",
            "Options:",
            "    -c, --compile       only run compilation for the specified targets",
            "    -f, --force         force rerunning of previously-passed tests",
            "    -q, --quick         do not wait for acknowledgement after a failed test run",
            "    -a, --no-ansi       disable output ANSI formatting",
            "    -w, --write         write haxe compiler outputs to stdout",
            "                          output cannot be formatted to remove ANSI",
            "    -z, --no-cache      disable caching of passed tests",
            "",
            "    -y, --push (TEST[:TEST]*)  compile/run only these tests",
            "    -n, --pull (TEST[:TEST]*)  exclude these tests (overrides '-y')",
            "",
            "    -h, --help          print this help and exit",
            "    -u, --usage         print usage information and exit",
            "    -r, --reset         delete the passed-test cache of each target",
            "    --default-import    create a default import.hx file in the working directory",
            "",
            "Targets:",
            "    A colon or space-separated list of targets to test (in order)",
            ""
        ].join("\n"));
        Sys.exit(0);
    }

    /**
        Prints usage information and a prompt to help information, then exits.
    **/
    static function printNoFlagsUsage():Void {
        //  [------------------------------------80 chars------------------------------------]
        stdout([
            "Usage: hxtf [OPTIONS...] TARGETS...",
            "Try 'hxtf --help' for more information.",
            ""
        ].join("\n"));
        Sys.exit(0);
    }

    /**
        Prints usage information and exits.
    **/
    static function printUsage():Void {
        //  [------------------------------------80 chars------------------------------------]
        stdout([
            "Usage: hxtf [OPTIONS...] TARGETS...",
            ""
        ].join("\n"));
        Sys.exit(0);
    }

    // @formatter:on

    /**
        Creates a default 'import.hx' file for HxTF and exits.

        If an 'import.hx' file already exists, prompts the user if they want it
        overwritten.
    **/
    static function createDefaultImport():Void {
        if (sys.FileSystem.exists(Sys.getCwd() + "/import.hx")) {
            stderr("[1mOverwrite existing 'import.hx'? [y/N][0m ");
            if (Sys.stdin().readLine().toLowerCase() != "y") {
                Sys.exit(0);
            }
            if (sys.FileSystem.isDirectory(Sys.getCwd() + "/import.hx")) {
                sys.FileSystem.deleteDirectory(Sys.getCwd() + "/import.hx");
            }
        }
        sys.io.File.saveContent(Sys.getCwd() + "/import.hx", haxe.Resource.getString("ImportFile"));
        stdout("[3mCreated default HxTF import.hx file[0m\n\n");
        Sys.exit(0);
    }
}
