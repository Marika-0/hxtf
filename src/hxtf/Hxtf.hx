package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Invocation;
import hxtf.cli.Printer.*;

class Hxtf {
    static function main() {
        Invocation.run();

        if (Flags.targets.length == 0) {
            stderr("[1mNo targets were passed to test for![0m\n");
            stdout("\n");
            Sys.exit(1);
        }

        Setup.setup();

        inline function skip(target:String) stderr('[3mSkipping target: $target[0m\n');

        for (target in Flags.targets) {
            if (!Setup.checkRunnable(target)) {
                skip(target);
                stdout("\n");
                continue;
            }
            if (!Setup.generateRunHxml(target)) {
                skip(target);
                stdout("\n");
                continue;
            }
            if (!Compile.target(target)) {
                skip(target);
                stdout("\n");
                continue;
            }
            if (Flags.onlyCompiling) {
                stdout("\n");
                continue;
            }
            if (!Run.run(target)) {
                stderr('[3mTesting failed for target: $target[0m\n');
                stdout("\n");
                continue;
            }
            stdout("\n");
        }

        // FSManager.delete("./test.hxml");
    }
}
