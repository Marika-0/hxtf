package hxtf;

import haxe.macro.Expr;
import haxe.macro.Context;

@:allow(hxtf.TestRun)
class TestMain {
    public var passed(default, null):UInt = 0;
    public var failed(default, null):UInt = 0;

    static macro function add(e:Expr) {
        try {
            var type = hxtf.BuildTools.reifyTypePath(e);
            var name = hxtf.BuildTools.toPackageArray(type).join(".");

            return macro {
                hxtf.TestRun.evaluateSuite(this, new $type(), $v{name});
            };
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }

        return macro null;
    }
}
