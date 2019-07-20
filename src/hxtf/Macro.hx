package hxtf;

import haxe.ds.BalancedTree;
import haxe.io.Path.addTrailingSlash as slash;
import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
    Handles macro-context initializations.
**/
class Macro {
    /**
        `true` if the flag to disable ANSI printing was not set, `false`
        otherwise.
    **/
    public static var ansi(default, null):Bool;

    /**
        The contents of the `<test>.cache` file (passing tests).
    **/
    public static var cache(default, null):BalancedTree<String, Bool>;

    /**
        The working directory that hxtf was invoked from.
    **/
    public static var cwd(default, null):String;

    /**
        `true` if test runs are being forced (rerun if they previously passed),
        `false` otherwise.
    **/
    public static var forcing(default, null):Bool;

    /**
        Tests being excluded from this test run.
    **/
    public static var pulledTests(default, null):Array<EReg>;

    /**
        Tests this test run is specifically for.
    **/
    public static var pushedTests(default, null):Array<EReg>;

    /**
        `true` if the passed tests for this test run are being saved to the
        cache, `false` otherwise.
    **/
    public static var savingCache(default, null):Bool;

    /**
        The target of this test run.
    **/
    public static var target(default, null):String;

    #if eval
    /**
        Initialization macro for setting up variables needed in macro context.
    **/
    static macro function setup():Void {
        ansi = Context.definedValue("hxtf_ansi") == "1";
        cwd = Context.defined("hxtf_cwd") ? Context.definedValue("hxtf_cwd") : null;
        forcing = Context.definedValue("hxtf_force") == "1";
        savingCache = Context.definedValue("hxtf_cache") == "1";
        target = Context.defined("hxtf_target") ? Context.definedValue("hxtf_target") : null;

        loadCache();
        loadExcludes();
        loadIncludes();
    }

    /**
        Gets each line of the <target>.cache file and adds it as a `true` entry
        to `cache`. Entries start off `true` so that if a test case has a
        soft-failure it can set it's entry to `false` and that entry won't be
        written to the cache at the end of the test run.

        `hxtf.TestBroker.Helper.evaluateCase` must check to see if the test case
        already exists in `cache` and not set it to `true`, so that soft
        failure's aren't overwritten
    **/
    static function loadCache():Void {
        cache = new BalancedTree<String, Bool>();

        if (forcing || cwd == null || target == null) {
            return;
        }

        var path = slash(cwd) + target + ".cache";
        if (!FileSystem.exists(path) || FileSystem.isDirectory(path)) {
            return;
        }

        var file = File.read(path);
        try {
            while (true) {
                var entry = file.readLine().trim();
                if (entry.length != 0) {
                    cache.set(entry, true);
                }
            }
        } catch (ex:Dynamic) {}
    }

    static function loadExcludes():Void {
        pulledTests = [];
        if (Context.defined("hxtf_n")) {
            for (raw in Context.definedValue("hxtf_n").split(":")) {
                pulledTests.push(new EReg(raw, ""));
            }
        }
        if (Context.defined("hxtf_pull")) {
            for (raw in Context.definedValue("hxtf_pull").split(":")) {
                try {
                    pulledTests.push(new EReg(raw, ""));
                } catch (ex:Dynamic) {
                    Context.warning('invalid pulled test regex: $ex', Context.currentPos());
                }
            }
        }
    }

    static function loadIncludes():Void {
        pushedTests = [];
        if (Context.defined("hxtf_y")) {
            for (raw in Context.definedValue("hxtf_y").split(":")) {
                pushedTests.push(new EReg(raw, ""));
            }
        }
        if (Context.defined("hxtf_push")) {
            for (raw in Context.definedValue("hxtf_push").split(":")) {
                try {
                    pushedTests.push(new EReg(raw, ""));
                } catch (ex:Dynamic) {
                    Context.warning('invalid pushed test regex: $ex', Context.currentPos());
                }
            }
        }
    }
    #end
}
