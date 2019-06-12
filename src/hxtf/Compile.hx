package hxtf;

import hxtf.cli.Flags;
import hxtf.cli.Printer.*;
import hxtf.sys.Formatter.stripAnsi;
import sys.io.Process;

class Compile {
	@:allow(hxtf.Hxtf)
	static function target(target:String) {
		stdout('[1mCompiling target: $target[0m\n');

		if (Flags.writeCompilationOutput) {
			if (Sys.command("haxe test.hxml") != 0) {
				stderr('[3mCompilation failed for target: $target[0m\n');
				stdout("\n");
				return false;
			}
		} else {
			var process = new Process("haxe test.hxml");
			if (process.exitCode() != 0) {
				stderr('[3mCompilation failed for target: $target[0m\n');
				stderr("[41;1m" + stripAnsi(process.stderr.readAll().toString()) + "[0m");
				stdout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
				return false;
			}
		}

		return true;
	}
}
