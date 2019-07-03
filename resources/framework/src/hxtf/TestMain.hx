package hxtf;

import haxe.macro.Expr;
import haxe.macro.Context;

class TestMain {
    static macro function add(e:Expr) {
        try {
            var type:TypePath;
            try {
                type = BuildTools.reifyTypePath(e);
            } catch (ex:Dynamic) {
                hxtf.Print.stderr('[3m${Print.formatPosString(Context.currentPos())}${Std.string(ex)}[0m\n');
                return macro null;
            }
            return macro new $type();
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}
