package hxtf.pattern;

/**
    This class represents a glob expression (converted into an EReg) designed to
    match package strings (eg `"my.pack"`, `"my.pack.Type"`, `"Type"`, etc).
**/
class HaxeModuleGlob extends Glob {
    /**
        Creates a new HaxeModuleGlob.
    **/
    public function new(raw:RawGlob) {
        if (!~/^(([*0-9?A-Z_a-z])|(([*0-9?A-Z_a-z][.*0-9?A-Z_a-z]*[*0-9?A-Z_a-z])|(\[!?(([.0-9A-Z_a-z])|([.0-9A-Z_a-z]-[.0-9A-Z_a-z]))+\]))+)$/.match(raw)) {
            throw HaxeModuleGlobException.InvalidGlob;
        }
        super(raw);
    }
}

/**
    An exception type specific to a HaxeModuleGlob.
**/
enum HaxeModuleGlobException {
    InvalidGlob;
}
