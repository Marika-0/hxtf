package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Invocation;
import hxtf.cli.Printer.*;
import hxtf.sys.FSManager;

using Lambda;
using StringTools;

/**
    The main driver class for this program.
**/
class Hxtf {
    static function main():Void {
        Invocation.run();

        if (Flags.targets.length == 0) {
            if (Flags.deletePreviousRecords) {
                stderr("[1mDelete all .json files with corresponding .hxml and .script files? [Y/n][0m ");

                var input = Sys.stdin().readLine().toLowerCase();
                if (input == "" || input == "y") {
                    var files = FSManager.readFiles("./");
                    files = files.filter(function(f) return f.endsWith(".json")
                        && f.length > 4
                        && files.has(f.substr(0, f.length - 4) + "hxml")
                        && files.has(f.substr(0, f.length - 4) + "script"));
                    files.sort(function(a, b) return Reflect.compare(a, b));

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
                    stderr("\n[1mNo targets were passed to test for![0m\n\n");
                } else {
                    stderr("[1mNo targets were passed to test for![0m\n\n");
                }
                Sys.exit(1);
            }
        }

        if (Flags.deletePreviousRecords) {
            var deleted = false;
            for (target in Flags.targets) {
                if (FSManager.delete('./$target.json')) {
                    stdout('[3mDeleted $target.json[0m\n');
                    deleted = true;
                }
            }
            if (!deleted) {
                stderr("[1mNo cache files were deleted![0m\n");
            }
            stdout("\n");
            Sys.exit(0);
        }

        Setup.setup();

        inline function skip(target:String) {
            stderr('[0m[3mSkipping target: $target[0m\n');
        }
        inline function divide(line = false) {
            stdout("\n");
            if (line) {
                stdout("[0m================================================================\n");
            }
        }

        divide(Invocation.prePrintingOccurred);

        var iterator = Flags.targets.iterator();
        for (target in iterator) {
            if (!Setup.checkRunnable(target)) {
                skip(target);
                divide();
                continue;
            }
            if (!Setup.generateRunHxml(target)) {
                skip(target);
                divide();
                continue;
            }
            if (!Compile.target(target)) {
                if (!Flags.writeCompilationOutput) {
                    skip(target);
                }
                divide();
                continue;
            }
            if (Flags.onlyCompiling) {
                if (!iterator.hasNext() || Flags.writeCompilationOutput) {
                    divide();
                }
                continue;
            }
            if (!Run.run(target)) {
                stderr('${Flags.disableAnsiFormatting ? "  " : ""}[3mTesting failed for target: $target[0m\n');
                if (!Flags.quickTestRuns && iterator.hasNext()) {
                    stdout("[3mPress any key to continue...[0m\n");
                    Sys.getChar(false);
                }
            }
            divide(iterator.hasNext());
        }

        FSManager.delete("./test.hxml");
    }
}
