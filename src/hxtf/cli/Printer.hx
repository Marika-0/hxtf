package hxtf.cli;

import hxtf.cli.Flags.disableAnsiFormatting;

using hxtf.sys.Formatter;

class Printer {
    public static inline function stdout(str:String) {
        Sys.stdout().writeString(disableAnsiFormatting ? str.stripAnsi() : str);
    }

    public static inline function stderr(str:String) {
        Sys.stderr().writeString(disableAnsiFormatting ? str.stripAnsi() : str);
    }
}
