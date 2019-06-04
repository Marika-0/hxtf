package hxtf.pattern;

using hxtf.pattern.HaxeModuleGlobHelper;

class HaxeModuleGlob extends Glob {
	public function new(raw:RawGlob) {
		if (!raw.isValid()) {
			throw HaxeModuleGlobException.InvalidGlob;
		}
		super(raw);
	}

	public inline override function hashCode() {
		return raw.hashCode();
	}
}

enum HaxeModuleGlobException {
	InvalidGlob;
}
