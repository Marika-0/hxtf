package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Invocation;
import hxtf.cli.Printer.*;
import hxtf.sys.FSManager;

class Hxtf {
    public static var prePrinted = false;

    static function main() {
        Invocation.run();

        if (Flags.targets.length == 0) {
            stderr("[1mNo targets were passed to test for![0m\n");
            stdout("\n");
            Sys.exit(1);
        }

        Setup.setup();

        inline function skip(target:String) stderr('[3mSkipping target: $target[0m\n');
        inline function divide(line = false) {
            stdout("\n");
            if (line) {
                stdout("================================================================\n");
            }
        }

        divide(prePrinted);

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
                skip(target);
                divide();
                continue;
            }
            if (Flags.onlyCompiling) {
                divide();
                continue;
            }
            if (!Run.run(target)) {
                stderr('[3mTesting failed for target: $target[0m\n');
                if (!Flags.quickTestRuns && iterator.hasNext()) {
                    stdout('[3mPress any key to continue...[0m\n');
                    Sys.getChar(false);
                }
            }
            divide(iterator.hasNext());
        }

        FSManager.delete("./test.hxml");
    }
}
