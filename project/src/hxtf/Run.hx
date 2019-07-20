package hxtf;

import hxtf.cli.Printer.*;
import sys.io.File;

/**
    This class handles getting the contents of the target script file and
    running it.
**/
@:allow(hxtf.Hxtf)
class Run {
    /**
        Runs the script file for the given target `target` and returns if the
        run was successful.
    **/
    static function run(target:String):Bool {
        var raw:String;
        try {
            raw = File.getContent('$target.script');
        } catch (ex:Dynamic) {
            stderr('[42;1mFailed to get contents of script file for target: $target[0m\n');
            return false;
        }

        stdout('[1mTesting target: $target[0m\n\n');

        return Sys.command(raw) == 0;
    }
}
