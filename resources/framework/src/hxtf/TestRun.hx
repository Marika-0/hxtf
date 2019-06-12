package hxtf;

import haxe.macro.Expr;
import haxe.macro.Context;

using Type;

class TestRun {
    macro function add(_:Expr, e:Expr) {
        try {
            var type = BuildTools.getTypePath(e);
            return macro {
                hxtf.Print.stdout("\n##  launching suite " + $v{BuildTools.toPackageArray(type).join(".")} + "\n");
                new $type();
            };
        } catch (ex:Dynamic) {
            Context.error('Error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro $v{42};
    }
}
