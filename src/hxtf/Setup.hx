package hxtf;

import haxe.Json;
import hxtf.cli.Flags;
import hxtf.cli.Printer;
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
			Printer.missingBuildHxml(target);
			return false;
		}
		if (!FSManager.doesFileExist('./$target.hxtf')) {
			Printer.missingRunHxtf(target);
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
		} else if (!Flags.forceTestRerun) {
			if (FSManager.doesFileExist('./$target.json')) {
				try {
					var objects = new StringBuf();
					for (item in cast(Json.parse(File.getContent('./$target.json')), Array<Dynamic>)) {
						objects.add(cast(item, String));
						objects.addChar(':'.code);
					}
					if (objects.length != 0) {
						hxml.push('-D hxtf_passed=${objects.toString().substr(0, objects.length - 1)}');
					}
				} catch (ex:Dynamic) {
					Printer.failedToParseTestJson(target);
				}
			}
		}

		hxml.push("");
		hxml.push('$target.hxml');
		hxml.push("");

		try {
			File.saveContent("./test.hxml", hxmlBase.concat(hxml).join("\n"));
		} catch (ex:Dynamic) {
			Printer.cannotSaveRunHxml(target);
			return false;
		}
		return true;
	}
}