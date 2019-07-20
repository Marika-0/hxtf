package hxtf;

import haxe.ds.BalancedTree;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

using StringTools;

/**
    Bridges macro context and variable initializations to prevent macro-in-macro
    errors.
**/
class Build {
    static var typePathRegex(default, never) = ~/^(([a-z0-9_][a-zA-Z0-9_]*[.])*)(_*[A-Z0-9][a-zA-Z0-9_]*)([.](_*[A-Z0-9][a-zA-Z0-9_]*))?$/;

    /**
        Returns the value of `hxtf.Macro.ansi`.
    **/
    public static macro function getAnsi():ExprOf<Bool> {
        var ansi = Macro.ansi;
        return macro $v{ansi}
    }

    /**
        Returns an expression to recreate the value of `hxtf.Macro.cache`.
    **/
    public static macro function getCache():ExprOf<BalancedTree<String, Bool>> {
        var entries = [for (item in Macro.cache.keys()) macro $v{item}];
        return macro {
            var tree = new BalancedTree<String, Bool>();
            for (entry in $a{entries}) {
                tree.set(entry, true);
            }
            tree;
        }
    }

    /**
        Returns the value of `hxtf.Macro.cwd`.
    **/
    public static macro function getCwd():ExprOf<String> {
        var cwd = Macro.cwd;
        return macro $v{cwd}
    }

    /**
        Returns the value of `hxtf.Macro.forcing`.
    **/
    public static macro function getForcing():ExprOf<Bool> {
        var forcing = Macro.forcing;
        return macro $v{forcing}
    }

    /**
        Returns the value of `hxtf.Macro.savingCache`.
    **/
    public static macro function getSavingCache():ExprOf<Bool> {
        var savingCache = Macro.savingCache;
        return macro $v{savingCache};
    }

    /**
        Returns the value of `hxtf.Macro.target`.
    **/
    public static macro function getTarget():ExprOf<String> {
        var target = Macro.target;
        return macro $v{target};
    }

    #if eval
    /**
        Returns if the test `test` is used in this test run.

        If a test:

        - is specified by the `hxtf_n` define to be excluded, or
        - is not specified by the `hxtf_y` define to be included (and `hxtf_y`
          has at least one entry), or
        - is in the cache and retesting isn't being forced.

        then the test is being excluded, otherwise it is being included.
    **/
    public static function useTest(test:String):Bool {
        for (regex in Macro.pulledTests) {
            if (regex.match(test)) {
                return false;
            }
        }

        if (Macro.pushedTests.length != 0) {
            for (regex in Macro.pushedTests) {
                if (regex.match(test)) {
                    return true;
                }
            }
            return false;
        }

        return !Macro.cache.exists(test);
    }
    #end

    /**
        Verifies that the given expression is of the form such that it refers to
        a type, and returns the `haxe.macro.Expr.TypePath` object of that type.
    **/
    public static function reifyTypePath(e:Expr):TypePath {
        var str = ExprTools.toString(e);
        if (!typePathRegex.match(str)) {
            throw 'invalid type path: $str';
        }
        return {
            pack: typePathRegex.matched(1).substring(0, typePathRegex.matched(1).length - 1).split("."),
            name: typePathRegex.matched(3),
            sub: typePathRegex.matched(5)
        }
    }
}
