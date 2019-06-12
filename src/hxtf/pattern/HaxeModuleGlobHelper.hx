package hxtf.pattern;

using StringTools;

class HaxeModuleGlobHelper {
    public static var regex(default, never) = ~/^(([*0-9?A-Z_a-z])|(([*0-9?A-Z_a-z][.*0-9?A-Z_a-z]*[*0-9?A-Z_a-z])|(\[!?(([.0-9A-Z_a-z])|([.0-9A-Z_a-z]-[.0-9A-Z_a-z]))+\]))+)$/;
    public static var hashTable(default, never) = ['!'.code => 1, '*'.code => 2, '.'.code => 3, '0'.code => 4, '1'.code => 5, '2'.code => 6, '3'.code => 7,
        '4'.code => 8, '5'.code => 9, '6'.code => 10, '7'.code => 11, '8'.code => 12, '9'.code => 13, '?'.code => 14, 'A'.code => 15, 'B'.code => 16,
        'C'.code => 17, 'D'.code => 18, 'E'.code => 19, 'F'.code => 20, 'G'.code => 21, 'H'.code => 22, 'I'.code => 23, 'J'.code => 24, 'K'.code => 25,
        'L'.code => 26, 'M'.code => 27, 'N'.code => 28, 'O'.code => 29, 'P'.code => 30, 'Q'.code => 31, 'R'.code => 32, 'S'.code => 33, 'T'.code => 34,
        'U'.code => 35, 'V'.code => 36, 'W'.code => 37, 'X'.code => 38, 'Y'.code => 39, 'Z'.code => 40, '['.code => 41, ']'.code => 42, '_'.code => 43,
        'a'.code => 44, 'b'.code => 45, 'c'.code => 46, 'd'.code => 47, 'e'.code => 48, 'f'.code => 49, 'g'.code => 50, 'h'.code => 51, 'i'.code => 52,
        'j'.code => 53, 'k'.code => 54, 'l'.code => 55, 'm'.code => 56, 'n'.code => 57, 'o'.code => 58, 'p'.code => 59, 'q'.code => 60, 'r'.code => 61,
        's'.code => 62, 't'.code => 63, 'u'.code => 64, 'v'.code => 65, 'w'.code => 66, 'x'.code => 67, 'y'.code => 68, 'z'.code => 69];

    public static inline function isValid(glob:RawGlob) {
        return regex.match(glob);
    }

    public static function hashCode(glob:RawGlob) {
        var hash = 0;
        for (i in 0...glob.length) {
            hash *= 69;
            hash += hashTable.get(glob.fastCodeAt(i));
        }
        return hash;
    }
}
