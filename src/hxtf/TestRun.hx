package hxtf;

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;
using Lambda;

/**
    The main class of HxTF.

    HxTF requires that a `TestMain` class with a public contructor exists in the
    root package.
**/
class TestRun {
    /**
        Expects a dot path to a real type, and returns a `new` expression
        possibly wrapped in some other code.

        If the given type inherites from `hxtf.TestObject`, the returned `new`
        expression will print the name of the test to the command line when the
        type is instantiated and the pass/fail state of the test when it
        finishes.
    **/
    public static macro function addObject(e:Expr):Expr {
        return macro hxtf.Driver.addObject($e);
    }

    static macro function setup():Void {
        Config.setup();
    }

    static function main():Void {
        Config.initialise();
        Print.stdout(Helper.getStartupHeader());
        Driver.run();
    }
}

private class Helper {
    public static macro function getStartupHeader():Expr {
        var header = '(HxTF ${Context.definedValue("hxtf")}, '
            + 'Haxe ${Context.definedValue("haxe")}, '
            + '${Config.IS_THREADING_TESTS ? '${Config.MAX_TESTING_THREADS} threads' : "no multithreading"})\n\n';
        return macro $v{header};
    }
}
