package hxtf.cli;

import hxtf.cli.Flags.disableAnsi;

using hxtf.sys.Formatter;

/**
    Handles printing to the standard output and error streams.

    Strips ANSI from the strings if configured to from the command line.
**/
class Printer {
    /**
        Writes the given string `str` to the process standard output stream
        (stripping ANSI if required).
    **/
    public static inline function stdout(str:String):Void {
        Sys.stdout().writeString(disableAnsi ? str.stripAnsi() : str);
        Sys.stdout().flush();
    }

    /**
        Writes the given string `str` to the process standard error stream
        (stripping ANSI if required).
    **/
    public static inline function stderr(str:String):Void {
        Sys.stderr().writeString(disableAnsi ? str.stripAnsi() : str);
        Sys.stderr().flush();
    }
}
