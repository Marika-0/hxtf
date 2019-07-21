package hxtf.cli;

/**
    This class stores the default and given values for cli settings.
**/
@:allow(hxtf.cli.Invocation)
class Flags {
    /**
        Whether or not we are _only_ compiling for the specified targets.
    **/
    public static var onlyCompile(default, null) = false;

    /**
        Whether or not rerunning previously-passed tests is being forced.
    **/
    public static var forceTestRerun(default, null) = false;

    /**
        Whether or not to wait for user input on a failed test run.
    **/
    public static var blockOnTestFailure(default, null) = true;

    /**
        Whether of not to delete previously-passed test records.
    **/
    public static var deleteCache(default, null) = false;

    /**
        Whether or not standard output/error can be formatted with ANSI.
    **/
    public static var disableAnsi(default, null) = false;

    /**
        Whether or not compilation output should be shown.
    **/
    public static var writeCompilationOutput(default, null) = false;

    /**
        Whether or not passed tests should be cached.
    **/
    public static var saveCache(default, null) = true;

    /**
        The globs of test objects to run.
    **/
    public static var testsToPush(default, null) = new Array<String>();

    /**
        The globs of test objects to ignore.
    **/
    public static var testsToPull(default, null) = new Array<String>();

    /**
        The targets to run tests for.
    **/
    public static var targets(default, null) = new Array<String>();
}
