package hxtf;

import haxe.macro.Context;
import haxe.macro.Expr;

private #if (haxe-ver <= 3.407) @:final #else final #end class Build {
	static var includedObjects:Array<EReg> =

	@:allow(hxtf.TestRun)
	static macro function build_hxtf_TestRun():Array<Field> {
		var fields
	}
}
