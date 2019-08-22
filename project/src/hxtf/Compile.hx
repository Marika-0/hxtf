package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Printer.*;
import hxtf.sys.Formatter.stripAnsi;
import sys.io.Process;

/**
    Invokes the compilation of a given target and handles compilation errors.
**/
class Compile {
    @:allow(hxtf.Hxtf)
    static function target(target:String):Bool {
        stdout('[1mCompiling target: $target[0m\n');

        if (Flags.writeCompilationOutput) {
            var code = Sys.command("haxe _.hxml");
            if (code != 0) {
                stderr('\n[3mCompilation failed for target: $target[0m\n');
                stderr('[3mProcess exited with code: $code[0m\n');
                Exit.elevate(TestRunCompilationFailure);
                return false;
            }
        } else {
            var process = new Process("haxe _.hxml");
            var code = process.exitCode();
            if (code != 0) {
                stderr("[41;1m" + stripAnsi(process.stderr.readAll().toString()) + "[0m");
                stderr('[3mCompilation failed for target: $target[0m\n');
                stderr('[3mProcess exited with code: $code[0m\n');
                Exit.elevate(TestRunCompilationFailure);
                return false;
            }
            process.close();
        }

        return true;
    }
}
