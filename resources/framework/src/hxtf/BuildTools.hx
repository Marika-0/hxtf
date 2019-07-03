package hxtf;

import haxe.ds.BalancedTree;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import sys.FileSystem;

class BuildTools {
    public static var typePathRegex(default, never) = ~/^(([a-z0-9_][a-zA-Z0-9_]*[.])*)(_*[A-Z0-9][a-zA-Z0-9_]*)([.](_*[A-Z0-9][a-zA-Z0-9_]*))?$/;

    static var forcing:Bool = getForcing();
    static var includeCases:Array<EReg> = getIncludes();
    static var excludeCases:Array<EReg> = getExcludes();

    public static macro function isAnsiDisabled():ExprOf<Bool> {
        return macro $v{Context.defined("hxtf_noansi")};
    }

    public static macro function getCwd():ExprOf<String> {
        if (!Context.defined("hxtf_cwd")) return macro $v{null};
        return macro $v{Context.definedValue("hxtf_cwd")};
    }

    public static macro function getTarget():ExprOf<String> {
        if (!Context.defined("hxtf_target")) return macro $v{null};
        return macro $v{Context.definedValue("hxtf_target")};
    }

    public static macro function getCache():ExprOf<BalancedTree<String, Bool>> {
        if (!Context.defined("hxtf_cwd") || !Context.defined("hxtf_target")) {
            return macro new BalancedTree<String, Bool>();
        }

        var path = haxe.io.Path.addTrailingSlash(Context.definedValue("hxtf_cwd")) + Context.definedValue("hxtf_target") + ".json";
        if (!FileSystem.exists(path) || FileSystem.isDirectory(path)) {
            return macro new BalancedTree<String, Bool>();
        }

        var obj:Dynamic;
        try {
            obj = haxe.Json.parse(sys.io.File.getContent(path));
        } catch (ex:Dynamic) {
            return macro new BalancedTree<String, Bool>();
        }
        if (!Std.is(obj, Array)) {
            return macro new BalancedTree<String, Bool>();
        }

        var items = [for (item in (obj : Array<String>)) macro $v{Std.string(item)}];
        return macro {
            var tree = new BalancedTree<String, Bool>();
            for (item in $a{items}) {
                tree.set(item, true);
            }
            tree;
        };
    }

    public static function reifyTypePath(e:Expr):TypePath {
        var str = ExprTools.toString(e);
        if (!typePathRegex.match(str)) {
            throw 'Invalid type path: ${ExprTools.toString(e)}';
        }
        return {
            pack: typePathRegex.matched(1).substring(0, typePathRegex.matched(1).length - 1).split("."),
            name: typePathRegex.matched(3),
            sub: typePathRegex.matched(5)
        };
    }

    public static function useTestCase(t:String):Bool {
        for (regex in excludeCases) {
            if (regex.match(t)) {
                return false;
            }
        }

        if (includeCases.length != 0) {
            for (regex in includeCases) {
                if (regex.match(t)) {
                    return true;
                }
            }
            return false;
        }

        return forcing || !TestRun.cache.exists(t);
    }

    static macro function getIncludes():ExprOf<Array<EReg>> {
        if (!Context.defined("hxtf_y")) {
            return macro [];
        }
        var includes = [for (raw in Context.definedValue("hxtf_y").split(":")) macro new EReg($v{raw}, "")];
        return macro $a{includes};
    }

    static macro function getExcludes():ExprOf<Array<EReg>> {
        if (!Context.defined("hxtf_n")) {
            return macro [];
        }
        var excludes = [for (raw in Context.definedValue("hxtf_n").split(":")) macro new EReg($v{raw}, "")];
        return macro $a{excludes};
    }

    static macro function getForcing():ExprOf<Bool> {
        return macro $v{Context.defined("hxtf_force")};
    }
}
