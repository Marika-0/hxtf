package hxtf;

import haxe.macro.Context;
import haxe.macro.Expr;

class TestSuite {
    var _passing:Int = 0;
    var _failing:Int = 0;

    macro function add(_:Expr, e:Expr) {
        try {
            var type = BuildTools.getTypePath(e);

            return macro {
                {
                    var t = new $type();
                    if (t._passed) {
                        hxtf.Print.stdout("[32m +  " + t._id + " succeeded (" + hxtf.Print.formatTimeDelta(t._stamp, haxe.Timer.stamp()) + ")[0m\n");
                        _passing++;
                    } else {
                        hxtf.Print.stderr("[31;1m >> " + t._id + " failed (" + hxtf.Print.formatTimeDelta(t._stamp, haxe.Timer.stamp()) + ")[0m\n");
                        _failing++;
                    }
                }
            };
        } catch (ex:Dynamic) {
            Context.error('Error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro $v{42};
    }
}
