package hxtf;

import haxe.macro.Context;
import haxe.macro.Expr;

@:allow(hxtf.TestRun)
class TestSuite {
    public var passed(default, null):UInt = 0;
    public var failed(default, null):UInt = 0;

    macro function add(_:Expr, e:Expr) {
        try {
            var type = BuildTools.reifyTypePath(e);
            var name = BuildTools.toPackageArray(type).join(".");

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

            return macro {hxtf.TestRun.evaluateCase(this, new $type(), $v{name});};
        } catch (ex:Dynamic) {
            Context.error('Error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}
