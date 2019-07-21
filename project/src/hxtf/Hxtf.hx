package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Invocation;
import hxtf.cli.Printer.*;
import hxtf.sys.FSManager;

using Lambda;
using StringTools;

/**
    Main driver class for HxTF.
**/
class Hxtf {
    static function main():Void {
        Invocation.run();
        handleInvocation();

        Setup.setup();
        organizeTestRuns();

        FSManager.delete("./_.hxml");
    }

    static function handleInvocation():Void {
        if (Flags.targets.length == 0) {
            if (Flags.deleteCache) {
                stderr("[1mDelete all .cache files with corresponding .hxml and .script files? [Y/n][0m ");

                var input = Sys.stdin().readLine().toLowerCase();
                if (input == "" || input == "y") {
                    var files = FSManager.readFiles("./");
                    files = files.filter((f) -> f.endsWith(".cache")
                        && f.length > 5
                        && files.has(f.substr(0, f.length - 5) + "hxml")
                        && files.has(f.substr(0, f.length - 5) + "script"));
                    files.sort((a, b) -> Reflect.compare(a, b));

                    var deleted = false;
                    for (file in files) {
                        if (FSManager.delete(file)) {
                            stdout('[3mDeleted $file[0m\n');
                            deleted = true;
                        }
                    }
                    if (!deleted) {
                        stderr("[3mNo cache files were deleted![0m\n");
                    }
                } else {
                    stdout("[3mAborted[0m\n");
                }
                stdout("\n");
                Sys.exit(0);
            } else {
                if (Invocation.prePrintingOccurred) {
                    stderr("\n");
                }
                stderr("[1mNo targets were passed to test for![0m\n\n");
                Sys.exit(1);
            }
        }

        if (Flags.deleteCache) {
            var deleted = false;
            for (target in Flags.targets) {
                if (FSManager.delete('./$target.cache')) {
                    stdout('[3mDeleted $target.cache[0m\n');
                    deleted = true;
                }
            }
            if (!deleted) {
                stderr("[1mNo cache files were deleted![0m\n");
            }
            stdout("\n");
            Sys.exit(0);
        }
    }

    static function organizeTestRuns():Void {
        stdout("\n");
        if (Invocation.prePrintingOccurred) {
            stdout("[0m================================================================\n");
        }

        var iterator = Flags.targets.iterator();
        for (target in iterator) {
            if (!Setup.checkRunnable(target)) {
                stderr('[0m[3mSkipping target: $target[0m\n');
                stdout("\n");
                continue;
            }
            if (!Setup.generateRunHxml(target)) {
                stderr('[0m[3mSkipping target: $target[0m\n');
                stdout("\n");
                continue;
            }
            if (!Compile.target(target)) {
                if (!Flags.writeCompilationOutput) {
                    stderr('[0m[3mSkipping target: $target[0m\n');
                }
                stdout("\n");
                continue;
            }
            if (Flags.onlyCompile) {
                if (!iterator.hasNext() || Flags.writeCompilationOutput) {
                    stdout("\n");
                }
                continue;
            }
            if (!Run.run(target)) {
                stderr('${Flags.disableAnsi ? "  " : ""}[3mTesting failed for target: $target[0m\n');
                if (Flags.blockOnTestFailure && iterator.hasNext()) {
                    stdout("[3mPress any key to continue...[0m\n");
                    Sys.getChar(false);
                }
            }
            stdout("\n");
            if (iterator.hasNext()) {
                stdout("[0m================================================================\n");
            }
        }
    }
}
