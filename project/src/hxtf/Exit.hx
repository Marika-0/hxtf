package hxtf;

/**
    Handles exiting HxTF with the appropriate elevated exit code.

    The code that HxTF exits with can vary depending on the result of run tests.
**/
class Exit {
    /**
        The current code to exit with.
    **/
    static var status:Code = SUCCESS;

    /**
        Elevates the code used to exit the process.
    **/
    public static function elevate(code:Code):Void {
        if (realise(status) < realise(code)) {
            status = code;
        }
    }

    @:allow(hxtf.Hxtf.main)
    static function exit() {
        Sys.exit(realise(status));
    }

    static function realise(code:Code):Int {
        return switch (code) {
            case SUCCESS: 0;
            case HXTF_RUNTIME_FAILURE | null: 1;
            case TEST_ASSERTION_FAILURE: 2;
            case TEST_RUNTIME_FAILURE: 3;
            case TEST_COMPILATION_FAILURE: 4;
        }
    }
}

/**
    Appropriate exit codes.
**/
enum Code {
    SUCCESS;
    HXTF_RUNTIME_FAILURE;
    TEST_ASSERTION_FAILURE;
    TEST_RUNTIME_FAILURE;
    TEST_COMPILATION_FAILURE;
}
