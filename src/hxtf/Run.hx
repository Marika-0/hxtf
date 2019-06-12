package hxtf;

import hxtf.cli.Printer.*;
import sys.io.File;

@:allow(hxtf.Hxtf)
class Run {
    static function run(target:String) {
        var raw:String;
        try {
            raw = File.getContent('$target.script');
        } catch (ex:Dynamic) {
            stderr('[42;1mFailed to get contents of script file for target: $target[0m\n');
            return false;
        }

        stdout('[1mTesting target: $target[0m\n');

        return Sys.command(raw) == 0;
    }
}
