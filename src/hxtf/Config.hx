package hxtf;

import haxe.ds.BalancedTree;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;

using StringTools;

/**
    Configuration information for this test run of this target.
**/
class Config {
    /**
        Is ANSI formatting being stripped from strings?
    **/
    public static var stripAnsi(default, null):Bool;

    /**
        Is the cache of this target being read to filter unit tests?
    **/
    public static var readCache(default, null):Bool;

    /**
        Are passing unit tests being cached for future test runs?
    **/
    public static var writeCache(default, null):Bool;

    /**
        The path to read/write cache files to/from.
    **/
    public static var workingDirectory(default, null):String;

    /**
        Is multithreading being used (based on the target and the specified
        number of threads).
    **/
    public static var isThreadingTests(default, null):Bool;

    /**
        The maximum number of simultaneous testing threads being used.
    **/
    public static var maxTestingThreads(default, null):Int;

    /**
        The maximum number of assertions failures before a unit test is
        aborted.
    **/
    public static var maxAssertionFailures(default, null):Int;

    /**
        The HxTF target being tested.
    **/
    public static var target(default, null):String;

    /**
        The unit tests that have passed, failed, or are in progress.

        This field starts off being populated with everything in this target's
        cache set to `true` (regardless of if the cache is meant to be read), so
        that if the cache is being ignored but still written we don't loose
        information.

        When a unit test starts its dot-path is set to `false`. When the test
        finishes, if it passed, it's dot-path entry is then set to `true`.
    **/
    public static var cache:BalancedTree<String, Bool>;

    #if macro
    public static var STRIP_ANSI:Bool;
    public static var READ_CACHE:Bool;
    public static var WRITE_CACHE:Bool;
    public static var WORKING_DIRECTORY:String;
    public static var IS_THREADING_TESTS:Bool;
    public static var MAX_TESTING_THREADS:Int;
    public static var MAX_ASSERTION_FAILURES:Int;
    public static var INCLUDE_REGEXES:List<EReg>;
    public static var EXCLUDE_REGEXES:List<EReg>;
    public static var TARGET:String;
    public static var CACHE:BalancedTree<String, Bool>;

    @:allow(hxtf.TestRun)
    static function setup():Void {
        inline function parseClampedInteger(str:String, defaultValue:Int, min:Int, max:Int):Int {
            var value = str == null ? defaultValue : Std.parseInt(str);
            if (Std.string(value) != str) {
                value = defaultValue;
            }
            return value < min ? min : max < value ? max : value;
        }

        inline function parseEregColonList(str:String, destination:List<EReg>):Void {
            for (ereg in str.split(":")) {
                if (ereg != "") {
                    try {
                        destination.add(new EReg(ereg, ""));
                    } catch (ex:Dynamic) {}
                }
            }
        }

        STRIP_ANSI = Context.definedValue("hxtf.stripAnsi") == "true";
        READ_CACHE = Context.definedValue("hxtf.readCache") == "true";
        WRITE_CACHE = Context.definedValue("hxtf.writeCache") == "true";
        WORKING_DIRECTORY = Context.definedValue("hxtf.workingDirectory").replace("\\", "/");
        MAX_TESTING_THREADS = parseClampedInteger(Context.definedValue("hxtf.maxTestingThreads"), 4, 1, 32);
        IS_THREADING_TESTS = Context.defined("target.threaded") && 1 < MAX_TESTING_THREADS;
        MAX_ASSERTION_FAILURES = parseClampedInteger(Context.definedValue("hxtf.maxAssertionFailures"), 4, 0, 2147483647);
        INCLUDE_REGEXES = new List<EReg>();
        for (key => value in Context.getDefines()) {
            if (key.startsWith("hxtf.includeTests")) {
                parseEregColonList(value, INCLUDE_REGEXES);
            }
        }
        EXCLUDE_REGEXES = new List<EReg>();
        for (key => value in Context.getDefines()) {
            if (key.startsWith("hxtf.excludeTests")) {
                parseEregColonList(value, EXCLUDE_REGEXES);
            }
        }
        TARGET = Context.definedValue("hxtf.target");
        CACHE = new BalancedTree<String, Bool>();
        if (READ_CACHE) {
            try {
                var cache = File.getContent('$WORKING_DIRECTORY/$TARGET.cache')
                    .split("\n")
                    .map((line) -> StringTools.trim(line))
                    .filter((line) -> line != "");
                for (item in cache) {
                    CACHE.set(item, true);
                }
            } catch (ex:Dynamic) {}
        }
    }
    #end

    @:allow(hxtf.TestRun.main)
    static function initialise():Void {
        stripAnsi = _stripAnsi();
        readCache = _readCache();
        writeCache = _writeCache();
        workingDirectory = _workingDirectory();
        isThreadingTests = _isThreadingTests();
        maxTestingThreads = _maxTestingThreads();
        maxAssertionFailures = _maxAssertionFailures();
        target = _target();
        cache = _cache();
    }

    static macro function _stripAnsi():Expr {
        return macro $v{STRIP_ANSI};
    }

    static macro function _writeCache():Expr {
        return macro $v{WRITE_CACHE};
    }

    static macro function _workingDirectory():Expr {
        return macro $v{WORKING_DIRECTORY};
    }

    static macro function _readCache():Expr {
        return macro $v{READ_CACHE};
    }

    static macro function _isThreadingTests():Expr {
        return macro $v{IS_THREADING_TESTS};
    }

    static macro function _maxTestingThreads():Expr {
        return macro $v{MAX_TESTING_THREADS};
    }

    static macro function _maxAssertionFailures():Expr {
        return macro $v{MAX_ASSERTION_FAILURES};
    }

    static macro function _target():Expr {
        return macro $v{TARGET};
    }

    static macro function _cache():Expr {
        var keys = new Array<Expr>();
        for (key in CACHE.keys()) {
            keys.push(macro $v{key});
        }
        var keysExpr = macro $a{keys};
        return macro {
            var tree = new BalancedTree<String, Bool>();
            for (item in $keysExpr) {
                tree.set(item, true);
            }
            tree;
        }
    }
}
