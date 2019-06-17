package hxtf.sys;

using StringTools;

/**
    This class handles the formatting of things.
**/
class Formatter {
    /**
        Strip the ANSI escape sequences from the given string `s`.
    **/
    public static function stripAnsi(s:String):String {
        var formatBuffer = new StringBuf();

        var i = 0;
        while (i < s.length) {
            var c = s.fastCodeAt(i);

            if (c == "".code) {
                do {
                    i++;
                } while (i < s.length && s.fastCodeAt(i) != "m".code);
            } else {
                formatBuffer.addChar(c);
            }

            i++;
        }

        return formatBuffer.toString();
    }
}
