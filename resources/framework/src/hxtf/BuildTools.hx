package hxtf;

import haxe.Json;
import haxe.ds.BalancedTree;
import haxe.io.Path.addTrailingSlash;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using StringTools;

class BuildTools {
    public static macro function getCache() {
        inline function emptyTree() {
            return macro new BalancedTree<String, Bool>();
        }

        if (!Context.defined("hxtf_cwd") || !Context.defined("hxtf_target")) {
            return emptyTree();
        }

        var path = addTrailingSlash(Context.definedValue("hxtf_cwd")) + Context.definedValue("hxtf_target") + ".json";

        if (!FileSystem.exists(path) || FileSystem.isDirectory(path)) {
            return emptyTree();
        }

        var obj:Dynamic;
        try {
            obj = Json.parse(File.getContent(path));
        } catch (ex:Dynamic) {
            return emptyTree();
        }
        if (!Std.is(obj, Array)) {
            return emptyTree();
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

    public static macro function getCwd():ExprOf<String> {
        if (!Context.defined("hxtf_cwd")) return macro $v{null};
        return macro $v{Context.definedValue("hxtf_cwd")}
    }

    public static macro function getForcing():ExprOf<Bool> {
        return macro $v{Context.defined("hxtf_force")};
    }

    public static macro function getTarget():ExprOf<String> {
        if (!Context.defined("hxtf_target")) return macro $v{null};
        return macro $v{Context.definedValue("hxtf_target")}
    }

    public static macro function getExcludes():ExprOf<Array<EReg>> {
        if (!Context.defined("hxtf_n")) {
            return macro [];
        }

        var excludes = [for (regex in Context.definedValue("hxtf_n").split(":")) macro new EReg($v{regex}, "")];
        return macro $a{excludes};
    }

    public static macro function getIncludes():ExprOf<Array<EReg>> {
        if (!Context.defined("hxtf_y")) {
            return macro [];
        }

        var includes = [for (regex in Context.definedValue("hxtf_y").split(":")) macro new EReg($v{regex}, "")];
        return macro $a{includes};
    }

    public static macro function isAnsiDisabled():ExprOf<Bool> {
        return macro $v{Context.defined("hxtf_noansi")};
    }

    public static function reifyTypePath(e:Expr):TypePath {
        var path = followTypePath(e);
        if (path.length == 0) throw "Type path reification returned as empty";
        if (path.length == 1) return {pack: [], name: path[0]};

        inline function firstAlphaIsLowerCase(s:String) {
            var ret = false;
            var index = -1;
            while (++index < s.length) {
                var c = s.fastCodeAt(index);
                if (c != '_'.code) {
                    ret = true;
                    break;
                }
            }
            return ret;
        }

        if (firstAlphaIsLowerCase(path[path.length - 2])) {
            return {
                pack: path.slice(0, path.length - 1),
                name: path[path.length - 1]
            };
        }
        return {
            pack: path.slice(0, path.length - 2),
            name: path[path.length - 2],
            sub: path[path.length - 1]
        };
    }

    public static function toPackageArray(tp:TypePath) {
        return if (tp.sub == null) {
            tp.pack.concat([tp.name]);
        } else {
            tp.pack.concat([tp.name, tp.sub]);
        }
    }

    static function followTypePath(e:Expr):Array<String> {
        switch (e.expr) {
            case EConst(CIdent(s)): return [s];
            case EField(e, s): return followTypePath(e).concat([s]);
            default: throw "Type path reification followed to invalid expression";
        }
    }
/*
    public static inline function useTestObject(t:String) {
        var use = true;

        for (regex in TestRun.toExclude) {
            if (regex.match(t)) {
                use = false;
            }
        }

        if (use && TestRun.toInclude.length != 0) {
            for (regex in TestRun.toInclude) {
                if (regex.match(t)) {
                    use = false;
                    break;
                }
            }
        }

        if (use && TestRun.forcing) use = false;

        return use && !TestRun.cache.exists(t);
    }*/
}
