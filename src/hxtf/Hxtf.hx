package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Invocation;
import hxtf.cli.Printer.*;
import hxtf.sys.FSManager;

/**
    The main driver class for this program.
**/
class Hxtf {
    /**
        If `hxtf.cli.Invocation` printed anything. If `true`, an divider line
        will be printed before the first target compilation message.
    **/
    @:allow(hxtf.cli.Invocation) static var prePrintingOccurred:Bool = false;

    static function main():Void {
        Invocation.run();

        if (Flags.targets.length == 0) {
            if (Flags.deletePreviousRecords) {
                stderr("[0mNo targets were passed to clear the cache of!\n");
            } else {
                stderr("[1mNo targets were passed to test for![0m\n");
            }
            stdout("\n");
            Sys.exit(1);
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
                stderr("[1mNo cache files were deleted[0m\n");
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

        divide(prePrintingOccurred);

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
