package hxtf.cli;

import hxtf.format.AnsiFormat;

/**
    Handles printing to the standard output and error streams, stripping ANSI
    if specified to by the user.
**/
class Print {
    /**
        Prints `s` to the standard output stream, stripping ANSI if configured
        to.
    **/
    public static function stdout(s:String):Void {
        Sys.stdout().writeString(Config.DISABLE_ANSI_FORMATTING ? AnsiFormat.strip(s) : s);
        Sys.stdout().flush();
    }

    /**
        Prints `s` to the standard error stream, stripping ANSI if configured
        to.
    **/
    public static function stderr(s:String):Void {
        Sys.stderr().writeString(Config.DISABLE_ANSI_FORMATTING ? AnsiFormat.strip(s) : s);
        Sys.stderr().flush();
    }
}
