package hxtf;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;

/**
    Secondary root for test runs - chains test cases.
**/
class TestSuite {
    macro function add(_:Expr, e:Expr) {
        try {
            var type:TypePath;
            try {
                type = BuildTools.reifyTypePath(e);
            } catch (ex:Dynamic) {
                hxtf.Print.stderr('[3m${Print.formatPosString(Context.currentPos())}${Std.string(ex)}[0m\n');
                return macro null;
            }

            var name = ExprTools.toString(e);
            if (!BuildTools.useTestCase(name)) {
                return macro null;
            }

            return macro {
                var stamp = haxe.Timer.stamp();
                hxtf.Print.stdout('[37m${hxtf.Print.noAnsi ? " ~~ " : "~~  "}running ${name}...[0m\n');
                try {
                    hxtf.TestRun.evaluateCase(new $type(), $v{name}, stamp);
                } catch (ex:Dynamic) {
                    hxtf.TestRun.caseException(ex, $v{name}, stamp);
                }
            }
        } catch (ex:Dynamic) {
            Context.error('error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}
