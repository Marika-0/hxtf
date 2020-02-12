package hxtf.cli;

/**
    This class stores the configuration of HxTF from flags and arguments used in
    the command line.
**/
@:allow(hxtf.cli.Initialise.run)
class Config {
    /**
        Block compilation and running of tests when one fails (to compile or to
        complete it's tests).
    **/
    public static var BLOCK_TESTING_ON_FAILURE(default, null):Bool = false;

    /**
        Only try to compile each target.

        If this is `true`, tests will not be run.
    **/
    public static var COMPILE_ONLY(default, null):Bool = false;

    /**
        Delete the cache file for each target detailing the tests that passed
        in previous test runs?

        If this is `true`, tests will not be run.
    **/
    public static var DELETE_CACHE_FILES(default, null):Bool = false;

    /**
        Disable formatting of output using ANSI formatting?
    **/
    public static var DISABLE_ANSI_FORMATTING(default, null):Bool = false;

    /**
        Disable automatically including this version of hxtf in the super build
        file when running tests.
    **/
    public static var DISABLE_AUTOMATIC_LIBRARY_INCLUSION(default, null):Bool = false;

    /**
        Disable recording which tests have passed previously so they don't need
        to be rerun in the future?
    **/
    public static var DISABLE_PASSED_TEST_CACHING(default, null):Bool = false;

    /**
        Run all tests regardless of if the cache file lists tests as passing in
        previous test funs?
    **/
    public static var FORCE_RUNNING_ALL_TESTS(default, null):Bool = false;

    /**
        The maximum number of times a test case can fail before it is aborted.
        Defaults to 4.

        The user can input any signed 32-bit integer value from the command
        line, but it will be clamped within the non-negative range for being
        passed to the HxTF API. The HxTF API also clamps the value it interprets
        from the relevant compiler define within the same range.

        A value of 0 (any value less than 1 put in through the command line)
        disables this feature.
    **/
    public static var MAX_ASSERTION_FAILURES:Int = 4;

    /**
        The maximum number of tests to run in parallel. Defaults to 4.

        The user can input any signed 32-bit integer value from the command
        line, but it will be clamped within the positive range for being
        passed to the HxTF API. The HxTF API also clamps the value it interprets
        from the relevant compiler define within the same range.
    **/
    public static var MAX_TESTING_THREADS(default, null):Int = 4;

    /**
        The targets to run tests for.
    **/
    public static var TARGETS(default, null):List<String> = new List<String>();

    /**
        The globs of unit tests to ignore.
    **/
    public static var TEST_IGNORE_GLOBS(default, null):List<String> = new List<String>();

    /**
        The globs of unit tests to include.
    **/
    public static var TEST_INCLUDE_GLOBS(default, null):List<String> = new List<String>();

    /**
        Write Haxe compilation output to the user?
    **/
    public static var WRITE_COMPILATION_OUTPUT(default, null):Bool = false;
}
