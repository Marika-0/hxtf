package hxtf;

import haxe.macro.Expr;
import haxe.macro.ExprTools;

/**
    Macro functions for retreiving information about HxTF.
**/
class Macro {
    #if macro
    /**
        Storage of the build version of this release
    **/
    public static var _BUILD(default, null):String;

    /**
        Initialisation macro called with the build version of this release.
    **/
    static macro function setBuild(s:String):Void {
        _BUILD = s;
    }
    #end

    /**
        Returns a constant string literal for the build version of this release.
    **/
    public static macro function getBuild():Expr {
        return macro $v{_BUILD};
    }
}
