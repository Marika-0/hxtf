package hxtf.cli;

import hxtf.cli.Flags.disableAnsiFormatting;

using hxtf.sys.Formatter;

/**
    This class handles the formatting and writing of strings to the standard
    output/error streams.
**/
class Printer {
    /**
        Writes the given string `str` to the process standard output stream
        (stripping ANSI from the string if required).
    **/
    public static inline function stdout(str:String):Void {
        Sys.stdout().writeString(disableAnsiFormatting ? str.stripAnsi() : str);
    }

    /**
        Writes the given string `str` to the process standard error stream
        (stripping ANSI from the string if required).
    **/
    public static inline function stderr(str:String):Void {
        Sys.stderr().writeString(disableAnsiFormatting ? str.stripAnsi() : str);
    }
}
