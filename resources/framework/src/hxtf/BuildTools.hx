package hxtf;

import haxe.macro.Expr;

using StringTools;

class BuildTools {
    public static function getTypePath(e:Expr):TypePath {
        var path = followTypePath(e);
        if (path.length == 0) throw "Type path reification returned as empty";
        if (path.length == 1) return {pack: [], name: path[0]};

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

    static function firstAlphaIsLowerCase(s:String) {
        var i = 0;
        while (i < s.length) {
            var c = s.fastCodeAt(i);
            if (c != '_'.code) return 'a'.code <= c && c <= 'z'.code;
            i++;
        }
        return false;
    }
}
