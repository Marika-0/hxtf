package hxtf;

import haxe.macro.Expr;
import haxe.macro.ExprTools;

class Macro {
    static var _version:String;

    static macro function buildVersion(s:String):Void {
        _version = s;
    }

    public static macro function version():Expr {
        var ver = _version;
        return macro $v{ver};
    }
}
