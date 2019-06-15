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

            var ignore = false;
            for (regex in TestRun.toExclude) {
                if (regex.match(name)) {
                    ignore = true;
                    break;
                }
            }
            if (!ignore && TestRun.toInclude.length != 0) {
                ignore = true;
                for (regex in TestRun.toInclude) {
                    if (regex.match(name)) {
                        ignore = false;
                        break;
                    }
                }
            }
            if (ignore || (TestRun.cache.exists(name) && !TestRun.forcing)) {
                return macro null;
            }

            return macro {
                hxtf.Print.stdout("\n### launching " + $v{name} + "\n");
                hxtf.TestRun.evaluateSuite(this, new $type(), $v{name});
            };
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }

        return macro null;
    }
}
