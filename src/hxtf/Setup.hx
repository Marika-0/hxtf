package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Printer.*;
import hxtf.sys.FSManager;
import sys.io.File;

class Setup {
    static var hxmlBase:Array<String>;

    @:allow(hxtf.Hxtf)
    static function setup() {
        hxmlBase = [];
        hxmlBase.push("-cp ./src");
        hxmlBase.push("");
        hxmlBase.push("-main hxtf.TestRun");
        hxmlBase.push("");
        hxmlBase.push("-D hxtf_cwd=" + Sys.getCwd());
        if (Flags.testsToRun.length != 0) {
            hxmlBase.push("-D hxtf_y=" + Flags.testsToRun.join(":"));
        }
        if (Flags.testsToIgnore.length != 0) {
            hxmlBase.push("-D hxtf_n=" + Flags.testsToIgnore.join(":"));
        }
        if (Flags.forceTestRerun) {
            hxmlBase.push("-D hxtf_force");
        }
        if (Flags.disableAnsiFormatting) {
            hxmlBase.push("-D hxtf_noansi");
        }
    }

    @:allow(hxtf.Hxtf)
    static function checkRunnable(target:String) {
        if (!FSManager.doesFileExist('./$target.hxml')) {
            stderr('[3mMissing build hxml for target: $target[0m\n');
            return false;
        }
        if (!FSManager.doesFileExist('./$target.script')) {
            stderr('[3mMissing run script for target: $target[0m\n');
            return false;
        }
        return true;
    }

    @:allow(hxtf.Hxtf)
    static function generateRunHxml(target:String) {
        var hxml = new Array<String>();

        hxml.push('-D hxtf_target=$target');

        if (Flags.deletePreviousRecords) {
            FSManager.delete('./$target.json');
        }

        hxml.push("");
        hxml.push('$target.hxml');
        hxml.push("");

        try {
            File.saveContent("./test.hxml", hxmlBase.concat(hxml).join("\n"));
        } catch (ex:Dynamic) {
            stderr('[3mFailed to save build hxml for target: $target[0m\n');
            return false;
        }
        return true;
    }
}
