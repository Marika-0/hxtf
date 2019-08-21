package hxtf;

class Exit {
    static var code = Passing;

    public static function elevate(code:Code) {
        if (Exit.code < code) {
            Exit.code = code;
        }
    }

    @:allow(hxtf.Hxtf.main)
    static function exit() {
        Sys.exit(code);
    }
}

enum abstract ExitCode(Int) {
    Passing = 0;
    HxtfRuntimeFailure = 1;
    TestRunAssertionFailure = 2;
    TestRunRuntimeFailure = 3;
    TestRunCompilationFailure = 4;
}
