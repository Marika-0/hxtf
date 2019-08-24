package hxtf;

class Exit {
    static var status:Status = Passing;

    public static function elevate(code:Status) {
        if (eval(status) < eval(code)) {
            status = code;
        }
    }

    static function eval(x:Status) {
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
        Sys.exit(eval(status));
    }
}

enum Status {
    Passing;
    HxtfRuntimeFailure;
    TestRunAssertionFailure;
    TestRunRuntimeFailure;
    TestRunCompilationFailure;
}
