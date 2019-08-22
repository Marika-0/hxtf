package hxtf;

class Exit {
    static var code:Code = Passing;

    public static function elevate(code:Code) {
        if (eval(Exit.code) < eval(code)) {
            Exit.code = code;
        }
    }

    @:using static function eval(x:Code) {
        return switch (x) {
            case Passing: 0;
            case HxtfRuntimeFailure: 1;
            case TestRunAssertionFailure: 2;
            case TestRunRuntimeFailure: 3;
            case TestRunCompilationFailure: 4;
            default: -1;
        }
    }

    @:allow(hxtf.Hxtf.main)
    static function exit() {
        Sys.exit(eval(code));
    }
}

enum Code {
    Passing;
    HxtfRuntimeFailure;
    TestRunAssertionFailure;
    TestRunRuntimeFailure;
    TestRunCompilationFailure;
}
