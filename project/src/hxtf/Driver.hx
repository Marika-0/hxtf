package hxtf;

import hxtf.cli.Config;
import hxtf.cli.Initialise;
import hxtf.cli.Print;
import hxtf.format.AnsiFormat;
import hxtf.sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import sys.thread.Thread;

using Lambda;
using StringTools;

/**
    The main driver of HxTF.

    `hxtf.cli.Initialise.run` must be called before any of the functions
    contained in this class.
**/
class Driver {
    /**
        The base hxml template to build hxml files off of for specified targets.
    **/
    static var hxmlBase:Array<String> = null;

    /**
        The separator bar to print between tests for different targets.
    **/
    static final SEPARATER_BAR:String = "================================================================";

    /**
        Responds to the initialisation, acting on the user configuration and
        performing specified tasks, or returning an error if the user must
        specify additional information.
    **/
    @:allow(hxtf.Hxtf.main)
    static function handleInitialisation():Void {
        if (Config.DELETE_CACHE_FILES) {
            inline function printDeletedFile(file:String):Void {
                Print.stdout('[3mDeleted $file[0m\n');
            }

            inline function processFailedFileDeletions(files:Array<String>, failures:List<String>):Void {
                if (failures.length == 1) {
                    Print.stderr('[3mFailed to delete ${failures.first()}[0m\n');
                } else if (failures.length != 0) {
                    Print.stderr('[3mFailed to delete the following files:[0m\n');
                    for (failedDeletion in failures) {
                        Print.stderr('[3m  $failedDeletion[0m\n');
                    }
                }
                if (failures.length == files.length) {
                    Print.stderr("[3mNo cache files were deleted![0m\n");
                }
                if (failures.length != 0) {
                    Print.stdout("\n");
                    Sys.exit(1);
                }
            }

            if (Config.TARGETS.length == 0) {
                Print.stdout("[1mDelete all .cache files with corresponding .hxml and .script files? [Y/n][0m ");

                var response = Sys.stdin().readLine().toLowerCase();
                if (response == "" || response == "y") {
                    var files = FileSystem.readFiles("./");
                    files = files.filter(
                        fileName ->
                            fileName.endsWith(".cache")
                            && fileName != ".cache"
                            && files.has(fileName.substr(0, fileName.length - 5) + "hxml")
                            && files.has(fileName.substr(0, fileName.length - 5) + "script")
                    );
                    files.sort((a, b) -> Reflect.compare(a, b));

                    var failures = new List<String>();
                    for (file in files) {
                        try {
                            FileSystem.deleteFile(file);
                        } catch (ex:Dynamic) {
                            failures.add(file);
                            continue;
                        }
                        printDeletedFile(file);
                    }
                    processFailedFileDeletions(files, failures);
                } else {
                    Print.stdout("[3mAborted[0m\n");
                }
                Print.stdout("\n");
            } else {
                var failures = new List<String>();
                for (target in Config.TARGETS) {
                    try {
                        FileSystem.deleteFile('./$target.cache');
                    } catch (ex:Dynamic) {
                        failures.add(target);
                        continue;
                    }
                    printDeletedFile(target + ".cache");
                }
                processFailedFileDeletions(Config.TARGETS.map(target -> target + ".cache").array(), failures);
            }
            Sys.exit(0);
        }

        if (Config.TARGETS.length == 0) {
            Print.stderr("[1mNo targets were passed to test for![0m\n");
            Sys.exit(1);
        }
    }

    @:allow(hxtf.Hxtf.main)
    static function handleTestRuns():Void {
        Print.stdout("\n");
        if (Initialise.initialisationErrorsOccured) {
            Print.stdout('$SEPARATER_BAR\n');
        }

        inline function printSkippingTarget(target:String, separator:Bool):Void {
            Print.stderr('[3mSkipping target: $target[0m\n\n');
            if (separator) {
                Print.stdout('$SEPARATER_BAR\n');
            }
        }

        var iterator = Config.TARGETS.iterator();
        for (target in iterator) {
            if (!canTargetRunTests(target)) {
                printSkippingTarget(target, iterator.hasNext());
                continue;
            }
            if (!compileTestRun(target, getCompilationArguments(target))) {
                if (!Config.WRITE_COMPILATION_OUTPUT) {
                    printSkippingTarget(target, iterator.hasNext());
                }
                continue;
            }
            if (Config.COMPILE_ONLY) {
                if (!iterator.hasNext() || Config.WRITE_COMPILATION_OUTPUT) {
                    Print.stdout("\n");
                }
                continue;
            }
            if (!invokeTestRun(target)) {
                Print.stderr('${Config.DISABLE_ANSI_FORMATTING ? "  " : ""}[3mTesting failed for target: $target[0m\n');
                if (Config.BLOCK_TESTING_ON_FAILURE && iterator.hasNext()) {
                    Print.stdout("[3mPress any key to continue...[0m\n");
                    Sys.getChar(false);
                }
            }
            Print.stdout("\n");
            if (iterator.hasNext()) {
                Print.stdout('$SEPARATER_BAR\n');
            }
        }
    }

    /**
        Tests if the given target is able to run tests, based on if a build hxml
        and run script exist for that target.

        Prints errors to the standard output if the target cannot be tested.

        If we are only compiling test runs, the run script does not need to
        exist.
    **/
    static function canTargetRunTests(target:String):Bool {
        var runnable = true;
        if (!FileSystem.existsFile('./$target.hxml')) {
            Print.stderr('[3mMissing build hxml for target: $target[0m\n');
            runnable = false;
        }
        if (!Config.COMPILE_ONLY) {
            if (!FileSystem.existsFile('./$target.script')) {
                Print.stderr('[3mMissing run script for target: $target[0m\n');
                runnable = false;
            }
        }
        return runnable;
    }

    /**
        Creates a HxTF hxml file for the specified target.

        Returns `true` if the file was created successfully, or `false`
        otherwise.
    **/
    static function getCompilationArguments(target:String):Array<String> {
        if (hxmlBase == null) {
            hxmlBase = new Array<String>();
            hxmlBase = hxmlBase.concat(["--main", "hxtf.TestRun"]);
            if (!Config.DISABLE_AUTOMATIC_LIBRARY_INCLUSION) {
                hxmlBase = hxmlBase.concat(["--library", "hxtf:" + Macro.getBuild()]);
            }
            hxmlBase = hxmlBase.concat(["--macro", "hxtf.TestRun.setup()"]);
            hxmlBase = hxmlBase.concat([
                "--define",
                "hxtf.stripAnsi=" + (Config.DISABLE_ANSI_FORMATTING ? "true" : "false")
            ]);
            hxmlBase = hxmlBase.concat([
                "--define",
                "hxtf.readCache=" + (Config.FORCE_RUNNING_ALL_TESTS ? "false" : "true")
            ]);
            hxmlBase = hxmlBase.concat([
                "--define",
                "hxtf.writeCache=" + (Config.DISABLE_PASSED_TEST_CACHING ? "false" : "true")
            ]);
            hxmlBase = hxmlBase.concat(["--define", "hxtf.workingDirectory=" + Sys.getCwd()]);
            hxmlBase = hxmlBase.concat(["--define", "hxtf.maxTestingThreads=" + Config.MAX_TESTING_THREADS]);
            hxmlBase = hxmlBase.concat(["--define", "hxtf.maxAssertionFailures=" + Config.MAX_ASSERTION_FAILURES]);
            if (Config.TEST_INCLUDE_GLOBS.length != 0) {
                hxmlBase = hxmlBase.concat(["--define", "hxtf.includeTests=" + Config.TEST_INCLUDE_GLOBS.join(":")]);
            }
            if (Config.TEST_IGNORE_GLOBS.length != 0) {
                hxmlBase = hxmlBase.concat(["--define", "hxtf.excludeTests=" + Config.TEST_IGNORE_GLOBS.join(":")]);
            }
        }
        var hxml = hxmlBase.copy();
        hxml = hxml.concat(["--define", 'hxtf.target=$target']);
        hxml.push('$target.hxml');
        return hxml;
    }

    /**
        Compiles the specified target, piping compiler streams to appropriate
        output/error streams if the user configured to.

        Returns `true` if compilation was successful, or `false` otherwise.
    **/
    static function compileTestRun(target:String, args:Array<String>):Bool {
        Print.stdout('[1mCompiling target: $target[0m\n');

        var process = new Process("haxe", args);

        // A `std@process_exit` exception will be called if `process.exitCode()`
        // is called after the process finishes, so we must only call it once.
        var code:Int;

        if (Config.WRITE_COMPILATION_OUTPUT) {
            // stdoutPipe and stderrPipe are pipes from the stdout and stderr
            // streams of the created process passing lines through Print to
            // strip ANSI formatting if the user specified to.
            var stdoutPipe = Thread.create(() -> {
                while (true) {
                    try {
                        Print.stdout(process.stdout.readLine() + "\n");
                    } catch (ex:Dynamic) {
                        break;
                    }
                }
            });
            var stderrPipe = Thread.create(() -> {
                while (true) {
                    try {
                        Print.stdout("[41;1m" + AnsiFormat.strip(process.stderr.readLine()) + "[0m\n");
                    } catch (ex:Dynamic) {
                        break;
                    }
                }
            });

            // Call so that we're blocked until compilation ends.
            code = process.exitCode();
        } else {
            code = process.exitCode();
            if (code != 0) {
                Print.stderr("[41;1m" + AnsiFormat.strip(process.stderr.readAll().toString()) + "[0m\n");
            }
        }
        if (code != 0) {
            Print.stderr('[3mCompilation failed for target: $target (exited with code $code)[0m\n');
            Exit.elevate(TEST_COMPILATION_FAILURE);
            process.close();
            return false;
        }
        process.close();
        return true;
    }

    /**
        Runs the specified target test script by getting it's contents and
        running them in the command line.

        Returns `true` if testing was successful, or `false` otherwise.
    **/
    static function invokeTestRun(target:String):Bool {
        var script:String;
        try {
            script = File.getContent('$target.script');
        } catch (ex:Dynamic) {
            Print.stderr('[42;1mFailed to get contents of script file for target: $target[0m\n');
            Exit.elevate(HXTF_RUNTIME_FAILURE);
            return false;
        }

        Print.stdout('[1mTesting target: $target[0m\n');
        var status = Sys.command(script);

        if (status == 2) {
            Exit.elevate(TEST_ASSERTION_FAILURE);
        } else if (status != 0) {
            Exit.elevate(TEST_RUNTIME_FAILURE);
            return false;
        }
        return true;
    }
}
