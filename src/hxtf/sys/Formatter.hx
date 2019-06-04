package hxtf.sys;

using StringTools;

class Formatter {
	public static function stripAnsi(s:String) {
		var formatBuffer = new StringBuf();

		var i = 0;
		while (i < s.length) {
			var c = s.fastCodeAt(i);

			if (c == ''.code) {
				do {
					++i;
				} while (i < s.length && s.fastCodeAt(i) != 'm'.code);
			} else {
				formatBuffer.addChar(c);
			}

			++i;
		}

		return formatBuffer.toString();
	}

	public static inline function normalizeNewlining(s:String) {
		return s.replace("\r\n", "\n");
	}
}
