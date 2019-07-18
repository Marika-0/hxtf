package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Printer.*;
import hxtf.sys.FSManager;
import sys.io.File;

/**
    This class handles setting up the test hxml file for compiling tests and
    checking if the required files exist for any given target.
**/
class Setup {
    /**
        A base hxml that prepends compilation.
    **/
    static var hxmlBase:Array<String>;

    /**
        Setup the base hxml (to be called after `hxtf.cli.Invocation.run` has
        been called).
    **/
    @:allow(hxtf.Hxtf)
    static function setup():Void {
        hxmlBase = [];
        hxmlBase.push("");
        hxmlBase.push("-main hxtf.TestRun");
        hxmlBase.push("");
        hxmlBase.push("--macro hxtf.Macro.setup()");
        hxmlBase.push("");
        if (Flags.disableAnsiFormatting) {
            hxmlBase.push("-D hxtf_ansi=0");
        } else {
            hxmlBase.push("-D hxtf_ansi=1");
        }
        hxmlBase.push("-D hxtf_cwd=" + Sys.getCwd());
        if (Flags.forceTestRerun) {
            hxmlBase.push("-D hxtf_force=1");
        } else {
            hxmlBase.push("-D hxtf_force=0");
        }
        if (Flags.testsToRun.length != 0) {
            hxmlBase.push("-D hxtf_y=" + Flags.testsToRun.join(":"));
        }
        if (Flags.testsToIgnore.length != 0) {
            hxmlBase.push("-D hxtf_n=" + Flags.testsToIgnore.join(":"));
        }
    }

    /**
        Checks if the required files exist for the given target.
    **/
    @:allow(hxtf.Hxtf)
    static function checkRunnable(target:String):Bool {
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

    /**
        Generates the test hxml file for the given target.
    **/
    @:allow(hxtf.Hxtf)
    static function generateRunHxml(target:String):Bool {
        var hxml = new Array<String>();

        hxml.push('-D hxtf_target=$target');

        hxml.push("");
        hxml.push('$target.hxml');
        hxml.push("");

        try {
            File.saveContent("./_.hxml", hxmlBase.concat(hxml).join("\n"));
        } catch (ex:Dynamic) {
            stderr('[3mFailed to save build hxml for target: $target[0m\n');
            return false;
        }
        return true;
    }
}
