package hxtf;

import haxe.Json;
import haxe.ds.BalancedTree;
import haxe.io.Path.addTrailingSlash;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

using StringTools;

/**
    `BuildTools` contains a collection of various tools used internally by hxtf
    when compiling a test run.
**/
@:dce
class BuildTools {
    public static var nonEmptySuites = new BalancedTree<String, Bool>();

    /**
        Gets the contents of the _&lt;test>.json_ file and parses it into a
        balanced binary search tree.

        The tree has String entries bound to Bool values all defaulted to
        `true`. Setting the value of an entry to `false` will exclude that entry
        from the output _&lt;test>.json_.

        An empty tree will be returned if an error occurs.
    **/
    public static macro function getCache():ExprOf<BalancedTree<String, Bool>> {
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

    /**
        Returns the current working directory given by the `"hxtf_cwd"` compiler
        define, or null if that define does not exist.

        This should allow run scripts to move around the filesystem, while
        ensuring that the _&lt;test>.json_ is always read/written to/from the
        same location.
    **/
    public static macro function getCwd():ExprOf<String> {
        if (!Context.defined("hxtf_cwd")) return macro $v{null};
        return macro $v{Context.definedValue("hxtf_cwd")};
    }

    /**
        Returns if the `-f` or `--force` flag was set when the testing framework
        was invoked.

        This value is stored as the compiler define `"hxtf_force"`
    **/
    public static macro function getForcing():ExprOf<Bool> {
        return macro $v{Context.defined("hxtf_force")};
    }

    /**
        Returns the current testing target given by the `"hxtf_target"` compiler
        define, or null if that define does not exist.
    **/
    public static macro function getTarget():ExprOf<String> {
        if (!Context.defined("hxtf_target")) return macro $v{null};
        return macro $v{Context.definedValue("hxtf_target")};
    }

    /**
        Returns the test exclusion regexes given by the `"hxtf_n"` compiler
        define, or an empty array if that define does not exist.

        `"hxtf_n"` is expected to be a colon-separated list of raw Haxe regular
        expression strings capable of matching module paths (eg
        `"$.*MathTests^:$.*StringTests^"`).
    **/
    public static macro function getExcludes():ExprOf<Array<EReg>> {
        if (!Context.defined("hxtf_n")) {
            return macro [];
        }

        var excludes = [for (raw in Context.definedValue("hxtf_n").split(":")) macro new EReg($v{raw}, "")];
        return macro $a{excludes};
    }

    /**
        Returns the test inclusion regexes given by the `"hxtf_y"` compiler
        define, or an empty array if that define does not exist.

        `"hxtf_y"` is expected to be a colon-separated list of raw Haxe regular
        expression strings capable of matching module paths (eg
        `"$.*MathTests^:$.*StringTests^"`).
    **/
    public static macro function getIncludes():ExprOf<Array<EReg>> {
        if (!Context.defined("hxtf_y")) {
            return macro [];
        }

        var includes = [for (raw in Context.definedValue("hxtf_y").split(":")) macro new EReg($v{raw}, "")];
        return macro $a{includes};
    }

    /**
        Returns if the `-a` or `--no-ansi` flag was set when the testing
        framework was invoked.

        This value is stored as the compiler define `"hxtf_noansi"`
    **/
    public static macro function isAnsiDisabled():ExprOf<Bool> {
        return macro $v{Context.defined("hxtf_noansi")};
    }

    /**
        Attempts to reify the given AST expression `e` into a the corresponding
        `haxe.macro.TypePath` object. Will throw an exception if type
        reification fails.

        This function was written for Haxe 3.4.7 and may need to be updated for
        future versions.

        For example:
        | expression input | output |
        | `String`         | `{name: "String", pack: []}` |
        | `haxe.ds.Vector` | `{name: "Vector", pack: ["haxe", "ds"]` |
        | `my.Sub.Type`    | `{name: "Sub", pack: ["my"], sub: "Type"` |
        | `42`             | exception |
        | `"Hello, World!"`| exception |

        See https://api.haxe.org/haxe/macro/TypePath.html for corresponding
        `haxe.macro.TypePath` information.
    **/
    public static function reifyTypePath(e:Expr):TypePath {
        var path = followTypePath(e);
        if (path.length == 0) throw "Type path reification returned as empty";
        if (path.length == 1) return {pack: [], name: path[0]};

        inline function firstAlphaIsLowerCase(s:String):Bool {
            var ret = false;
            for (index in 0...s.length) {
                var c = s.fastCodeAt(index);
                if (c != "_".code) {
                    ret = "a".code <= c && c <= "z".code;
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

    /**
        Helper function for `reifyTypePath`.

        Recursively follows `EField` entries of the given expression and builds
        an array of the module path in order.
    **/
    static function followTypePath(e:Expr):Array<String> {
        switch (e.expr) {
            case EConst(CIdent(s)): return [s];
            case EField(e, s): return followTypePath(e).concat([s]);
            default: throw "Type path reification followed to invalid expression";
        }
    }

    /**
        This function, given some `haxe.macro.TypePath` `tp`, converts it into
        an array pathing straight to the type (including sub-types).
    **/
    public static function toPackageArray(tp:TypePath):Array<String> {
        return if (tp.sub == null) {
            tp.pack.concat([tp.name]);
        } else {
            tp.pack.concat([tp.name, tp.sub]);
        }
    }

    /**
        This function evaluates the given type path `t` and determines if it
        should be included in testing.

        1. If any of the exclusion regexes match `t`, return `false`.
        1. Otherwise if there are inclusion regexes and: any of them match `t`,
           returns `true`; none of them match `t`, returns `false`.
        1. Otherwise if forcing to rerun previously-passed tests, returns
           `true`.
        1. Otherwise if the type has an entry in the previously-passed
           _&lt;test>.json_ cache, returns `true`.
        1. Otherwise returns `true`.
    **/
    public static function useTestObject(t:String):Bool {
        for (regex in TestRun.toExclude) {
            if (regex.match(t)) {
                return false;
            }
        }

        if (TestRun.toInclude.length != 0) {
            for (regex in TestRun.toInclude) {
                if (regex.match(t)) {
                    return true;
                }
            }
            return false;
        }

        if (TestRun.forcing) return true;

        return !TestRun.cache.exists(t);
    }
}
