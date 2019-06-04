package hxtf.cli;

import hxtf.cli.Flags.disableAnsiFormatting;

using hxtf.sys.Formatter;

class Printer {
	@:allow(hxtf.cli.Invocation)
	static function printHelp() {
		//          [------------------------------------80-chars------------------------------------]
		Sys.println("Usage: hxtf [OPTIONS...] TARGETS...");
		Sys.println("Run configurable unit tests for a haxe program.");
		Sys.println("");
		Sys.println("Options:");
		Sys.println("	-c, --compile   only run compilation for the specified targets");
		Sys.println("	-f, --force     force rerunning of previously-passed tests");
		Sys.println("	-q, --quick     do not wait for acknowledgement after a failed test run");
		Sys.println("	-r, --reset     delete all passed-test records for each target");
		Sys.println("	-a, --no-ansi   disable output ANSI formatting");
		Sys.println("	-w, --write     write haxe compiler outputs to stdout");
		Sys.println("	                  output cannot be formatted to remove ANSI");
		Sys.println("");
		Sys.println("	-y TEST[:TEST]* run only these tests");
		Sys.println("	-n TEST[:TEST]* do not run these tests (overridden by '-y')");
		Sys.println("");
		Sys.println("	-h, --help      print this help and exit");
		Sys.println("	-u, --usage     print usage information and exit");
		Sys.println("");
		Sys.println("Targets:");
		Sys.println("	A colon-separated list of targets to test (in order)");
		Sys.exit(0);
	}

	@:allow(hxtf.cli.Invocation)
	static inline function printUsage() {
		Sys.println("Usage: hxtf [OPTIONS...] TARGETS...");
		Sys.exit(0);
	}

	@:allow(hxtf.cli.Invocation)
	static inline function invalidArgument(arg:String) {
		stderr('[3mInvalid ignored argument \'$arg\'[0m\n');
	}

	@:allow(hxtf.cli.Invocation)
	static inline function invalidObjectGlob(glob:String) {
		stderr('[3mInvalid ignored test object glob \'$glob\'[0m\n');
	}

	@:allow(hxtf.Hxtf)
	static inline function noTestFlagsPassed() {
		stderr("[1mNo targets were passed to test for[0m\n");
	}

	@:allow(hxtf.Setup)
	static inline function missingBuildHxml(target:String) {
		stderr('[3mMissing build hxml for \'$target\'[0m\n');
	}

	@:allow(hxtf.Setup)
	static inline function missingRunHxtf(target:String) {
		stderr('[3mMissing run hxtf for \'$target\'[0m\n');
	}

	@:allow(hxtf.Setup)
	static inline function failedToParseTestJson(target:String) {
		stderr('[3mFailed to parse passing test cache json for \'$target\'[0m\n');
	}

	@:allow(hxtf.Setup)
	static inline function cannotSaveRunHxml(target:String) {
		stderr('[3mFailed to save build hxml for \'$target\'[0m\n');
	}

	@:allow(hxtf.Compile)
	static inline function compilingTarget(target:String) {
		stdout('[1mCompiling \'$target\'[0m\n');
	}

	@:allow(hxtf.Compile)
	static inline function compilationFailed(target:String) {
		stderr('[3mCompilation failed for \'$target\'[0m\n');
	}

	@:allow(hxtf.Run)
	static inline function testingTarget(target:String) {
		stdout('[1mTesting \'$target\'[0m\n');
	}

	@:allow(hxtf.Hxtf)
	static inline function skippingTarget(target:String) {
		stderr('[3mSkipping \'$target\'[0m\n');
	}

	@:allow(hxtf.Hxtf)
	static inline function skippingTestsForTarget(target:String) {
		stderr('[3mSkipping tests for \'$target\'[0m\n');
	}

	@:allow(hxtf.Run)
	static inline function testingFailed(target:String) {
		stderr('[3mCompilation failed for \'$target\'[0m\n');
	}

	public static inline function nl() {
		stdout("\n");
	}

	public static inline function stdout(str:String) {
		Sys.stdout().writeString(disableAnsiFormatting ? str.stripAnsi() : str);
	}

	public static inline function stderr(str:String) {
		Sys.stderr().writeString(disableAnsiFormatting ? str.stripAnsi() : str);
	}
}
