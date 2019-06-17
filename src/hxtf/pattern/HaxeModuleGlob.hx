package hxtf.pattern;

using hxtf.pattern.HaxeModuleGlobHelper;

/**
    This class represents a glob expression (converted into an EReg) designed to
    match package strings (eg `"my.pack"`, `"my.pack.Type"`, `"Type"`, etc).
**/
class HaxeModuleGlob extends Glob {
    public function new(raw:RawGlob) {
        if (!HaxeModuleGlobHelper.isValid(raw)) {
            throw HaxeModuleGlobException.InvalidGlob;
        }
        super(raw);
    }

    public inline override function hashCode():Int {
        return HaxeModuleGlobHelper.hashCode(raw);
    }
}

/**
    An exception type specific to a HaxeModuleGlob.
**/
enum HaxeModuleGlobException {
    InvalidGlob;
}
