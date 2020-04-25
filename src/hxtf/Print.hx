package hxtf;

import haxe.CallStack;
import haxe.PosInfos;

/**
    Handles printing to the standard output and error streams, stripping ANSI
    if required.
**/
class Print {
    /**
        The EReg that matches with ANSI escape sequences.
    **/
    static final ansiRegex = ~/[\x1b\x9b][\[\]()#;?]*((([a-zA-Z0-9]*(;[-a-zA-Z0-9\/#&.:=?%@~_]*)*)?\x07)|(([0-9][0-9]?[0-9]?[0-9]?(;[0-9]?[0-9]?[0-9]?[0-9]?)*)?[0-9A-PR-TZcf-ntqry=><~]))/g;

    /**
        Removes ANSI escape sequences from the given string `str`.
    **/
    public static inline function stripAnsi(str:String):String {
        return ansiRegex.split(str).join("");
    }

    /**
        Prints `s` to the standard output stream, stripping ANSI if required.
    **/
    public static function stdout(s:String):Void {
        Sys.stdout().writeString(Config.stripAnsi ? stripAnsi(s) : s);
        Sys.stdout().flush();
    }

    /**
        Prints `s` to the standard error stream, stripping ANSI if required.
    **/
    public static function stderr(s:String):Void {
        Sys.stderr().writeString(Config.stripAnsi ? stripAnsi(s) : s);
        Sys.stderr().flush();
    }
}

/**
    Handles general and ANSI formatting of strings for printing the state of a
    test run to the user.

    Used internally by HxTF.
**/
class Format {
    public static function formatTestStartMessage(test:String):String {
        var path = test.split(".");
        var type = path.pop();
        if (path.length != 0) {
            path.push("");
        }
        return '[37m~ ${path.join(".")}[1m$type[0m[37...[0m\n';
    }

    public static function formatTimeDelta(delta:Float):String {
        if (delta < 0) {
            return "ERR_NEG_TIME";
        } else if (delta == 0) {
            return "";
        }

        var diff = DateTools.parse(1000 * delta);
        var string = "";

        if (0 < diff.days) {
            string += diff.days + "d ";
        }
        if (0 < diff.hours) {
            string += diff.hours + "h ";
        }
        if (0 < diff.minutes) {
            string += diff.minutes + "m ";
        }
        if (0 < diff.seconds) {
            string += diff.seconds + "s ";
        }
        if (0 < Std.int(diff.ms)) {
            string += Math.round(diff.ms) + "ms ";
        }

        return string == "" ? "" : '[${StringTools.trim(string)}]';
    }

    public static function formatAssertionFailureMessage(source:String, reason:String, description:String, ?pos:PosInfos):String {
        return '[41;1m! '
            + '$source (line ${pos.lineNumber}):'
            + '${reason == null ? "" : ' $reason'}'
            + '${description == null ? "" : ' $description'} [0m\n';
    }

    public static function formatPromptMessage(source:String, message:String, printLine = true, ?pos:PosInfos):String {
        return '[41;1m? $source${printLine ? ' (line ${pos.lineNumber})' : ""}: $message [0m\n';
    }

    public static function formatMaxAssertionsError(source:String):String {
        return '[41;1mX $source maximum assertion failures reached - aborting test [0m\n';
    }

    public static function formatExceptionFailure(source:String, exception:Dynamic):String {
        var lines = new Array<String>();
        lines.push('[41;1mX $source: uncaught exception: ${Std.string(exception)} [0m\n');
        if (CallStack.exceptionStack().length == 0) {
            lines.push("[41;1m  > Exception stack unavailable [0m \n");
        } else {
            var stack = CallStack.toString(CallStack.exceptionStack()).split("\n");
            lines = lines.concat(stack.map((line) -> {
                // `CallStack.toString()` starts each line with a newline, so we
                // need to filter that out before we can print properly.
                if (line.length == 0) {
                    return "";
                }
                return '[41;1m  > $line [0m\n';
            }));
        }
        return lines.join("");
    }

    public static function formatTestCompletionMessage(test:String, passed:Bool, timeDelta:Float):String {
        var time = formatTimeDelta(timeDelta);
        if (time != "") {
            if (passed) {
                time = " [96;1m" + time;
            } else {
                time = " [93;1m" + time;
            }
        }

        var path = test.split(".");
        var type = path.pop();
        if (path.length != 0) {
            path.push("");
        }

        if (passed) {
            return '[92m+ ${path.join(".")}[1m$type[0m[92m passed$time[0m\n';
        }
        return '[91m# ${path.join(".")}[1m$type[0m[91m failed$time[0m\n';
    }
}
