package hxtf.cli;

/**
    This class stores the default and given values for cli settings.
**/
@:allow(hxtf.cli.Invocation)
class Flags {
    /**
        Don't block until user input after a failed test run?
    **/
    public static var blockOnTestFailure(default, null) = true;

    /**
        Delete the passed-test cache/s?
        Whether of not to delete previously-passed test records.
    **/
    public static var deleteCache(default, null) = false;

    /**
        Strip ANSI formatting from output?
    **/
    public static var disableAnsi(default, null) = false;

    /**
        Disable including this version of HxTF automatically?
    **/
    public static var disableAutomaticLibraryInclusion(default, null) = false;

    /**
        Force rerunning of previously-passed tests in cache?
    **/
    public static var forceTestRerun(default, null) = false;

    /**
        Create a default 'import.hx' file?
    **/
    public static var generateDefaultImport(default, null) = false;

    /**
        Only run compilation for the specified targets?
    **/
    public static var onlyCompile(default, null) = false;

    /**
        Cache passed tests?
    **/
    public static var saveCache(default, null) = true;

    /**
        The targets to run tests for.
    **/
    public static var targets(default, null) = new Array<String>();

    /**
        The globs of test objects to ignore.
    **/
    public static var testsToPull(default, null) = new Array<String>();

    /**
        The globs of test objects to run.
    **/
    public static var testsToPush(default, null) = new Array<String>();

    /**
        Show output of the compilation?
    **/
    public static var writeCompilationOutput(default, null) = false;
}
