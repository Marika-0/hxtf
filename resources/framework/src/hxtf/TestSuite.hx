package hxtf;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using Type;

@:allow(hxtf.TestRun)
class TestSuite {
    public var passed(default, null):UInt = 0;
    public var failed(default, null):UInt = 0;

    macro function add(_:Expr, e:Expr) {
        try {
            var type = BuildTools.reifyTypePath(e);
            var name = BuildTools.toPackageArray(type).join(".");

            if (!BuildTools.useTestObject(name)) {
                return macro null;
            }

            if (!Context.defined("hxtf__macro__SuiteHasCases_" + Context.getLocalClass().toString())) {
                return macro {
                    hxtf.Print.stdout('\n### launching ${this.getClass().getClassName()}\n');
                    hxtf.TestRun.evaluateCase(this, new $type(), $v{name});
                };
            }
            Compiler.define("hxtf__macro__SuiteHasCases_" + Context.getLocalClass().toString());
            return macro {
                hxtf.TestRun.evaluateCase(this, new $type(), $v{name});
            };
        } catch (ex:Dynamic) {
            Context.error('Error: ${Std.string(ex)}', Context.currentPos());
        }
        return macro null;
    }
}
