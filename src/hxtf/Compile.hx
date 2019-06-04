package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Printer.*;
import sys.io.Process;

using hxtf.sys.Formatter;

class Compile {
	@:allow(hxtf.Hxtf)
	static function target(target:String) {
		compilingTarget(target);

		if (Flags.writeCompilationOutput) {
			if (Sys.command("haxe test.hxml") != 0) {
				compilationFailed(target);
				nl();
				return false;
			}
		} else {
			var process = new Process("haxe test.hxml");
			if (process.exitCode() != 0) {
				compilationFailed(target);
				nl();
				stderr("[41;1m" + process.stderr.readAll().toString().stripAnsi() + "[0m");
				nl();
				return false;
			}
		}

		return true;
	}
}
