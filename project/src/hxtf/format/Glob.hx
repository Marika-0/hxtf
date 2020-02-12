package hxtf.format;

using StringTools;
using Type;

/**
    A clas for pattern matching with unix glob expressions.

    This class translates a given unix glob string into a Haxe Ereg and provides
    an interface for matching strings against that ereg.

    | Wildcard | Description |
    | :------: | ----------- |
    | `*`      | Matches any amount of any character. |
    | `?`      | Matches exactly one of any character. |
    | `[abc]`  | Matches one of any of the listed characters (the literal
                 character `-` must be escaped like so: `\-`). |
    | `[a-h]`  | Matches one of any characters in the given range. |
    | `[!abc]` | Matches one of any characters that are not listed (escape `!`
                 with `\!` if it is at the start of a non-exclusive group). |
    | `[!a-h]` | Matches one of any characters not in the given range. |

    A wildcard in a group will represent it's literal character/s.

    The negation-group character `!` only needs to be escaped if it is the
    first character in the group.

    The group span character `-` must be escaped if it is in a group and not
    indicating a span.

    Only the opening group character `[` needs to be escaped to not create a
    group, the closing group character `]` can remain unescaped.

    If an opened group is not closed, then the group will include every
    character until the end of the glob.

    Any escape sequence that is invalid for the situation will result in just
    the escape operand (eg `\k` -> `k`).

    The literal backslash character will only be interpreted if it is the last
    character in the glob (eg `a\` -> `"a\"`). In any other case, the backslash
    character must be escaped (`a\\b` -> `"a\b"`).

    Examples:
    - `[abcj-z]` will not match `"d"`, `"e"`, `"f"`, etc.
    - `[abcj\-z]` will only match `"a"`, `"b"`, `"c"`, `"j"`, `"-"`, or `"z"`.
    - `\*` will match the literal `"*"` character.
    - `\[abc\]` and `\[abc]` will both match the literal string `"[abc]"`.
    - `\` and `\\` will both match the literal string `"\"`.
    - `[abs` will be interpreted as `[abc]`.
    - `[\` will be interpreted as `[\\]`.
**/
class Glob {
    /**
        The string used to construct the Haxe Ereg instance.
    **/
    public final eregString:String;

    final regex:EReg;

    /**
        Simplifies the given string unix glob `glob`.
    **/
    public static function siplifyGlob(glob:String):String {
        var buf = new StringBuf();
        var index = 0;
        while (index < glob.length) {
            var char = glob.fastCodeAt(index++);
            buf.addChar(char);
            if (char == "*".code) {
                while (glob.fastCodeAt(index) == "*".code) {
                    index++;
                }
            }
        }
        return buf.toString();
    }

    /**
        Creates a new `Glob` using the given unix glob expressions `glob` for
        pattern matching.

        Throws an exception of type `String` if `glob` is not a valid unix glob
        expression.
    **/
    public function new(glob:String) {
        eregString = parseGlob(glob);
        regex = new EReg(eregString, "");
    }

    /**
        Tests if the given string `s` can be matched by the provided unix glob
        expression.
    **/
    public function match(s:String):Bool {
        return regex.match(s);
    }

    /**
        Converts the given unix glob expression `glob` into a Haxe Ereg string.

        Guaranteed to throw an exception of type `String` if `glob` is not a
        valid unix glob expression.
    **/
    function parseGlob(glob:String):String {
        var rawEregBuf = new StringBuf();
        if (!glob.startsWith("*")) {
            rawEregBuf.addChar("^".code);
        }

        var justParsedAny = false;
        var parsingGroup = false;
        var startedParsingGroup = false;
        var justNegatedGroup = false;
        var parsingSpan = false;
        var breaking = false;
        for (index in 0...glob.length) {
            var char = glob.fastCodeAt(index);
            var initStartedParsingGroup = startedParsingGroup;
            var initJustNegatedGroup = justNegatedGroup;
            var initParsingSpan = parsingSpan;
            var initBreaking = breaking;

            if (startedParsingGroup) {
                if (char != "]".code && char != "!".code) {
                    rawEregBuf.addChar("[".code);
                }
            } else if (justNegatedGroup) {
                if (char != "]".code) {
                    rawEregBuf.addChar("[".code);
                    rawEregBuf.addChar("^".code);
                }
            }

            switch (char) {
                case "*".code:
                    if (parsingGroup) {
                        rawEregBuf.addChar("*".code);
                    } else if (breaking) {
                        rawEregBuf.addChar("\\".code);
                        rawEregBuf.addChar("*".code);
                    } else {
                        if (!justParsedAny) {
                            rawEregBuf.addChar(".".code);
                            rawEregBuf.addChar("*".code);
                        }
                        justParsedAny = true;
                    }
                case "?".code:
                    if (parsingGroup) {
                        rawEregBuf.addChar("?".code);
                    } else if (breaking) {
                        rawEregBuf.addChar("\\".code);
                        rawEregBuf.addChar("?".code);
                    } else {
                        rawEregBuf.addChar(".".code);
                    }
                case "[".code:
                    if (parsingGroup) {
                        rawEregBuf.addChar("[".code);
                    } else if (breaking) {
                        rawEregBuf.addChar("\\".code);
                        rawEregBuf.addChar("[".code);
                    } else {
                        parsingGroup = true;
                        startedParsingGroup = true;
                    }
                case "!".code:
                    if (startedParsingGroup && !breaking) {
                        justNegatedGroup = true;
                    } else {
                        rawEregBuf.addChar("!".code);
                    }
                case "^".code:
                    if (startedParsingGroup || !parsingGroup) {
                        rawEregBuf.addChar("\\".code);
                    }
                    rawEregBuf.addChar("^".code);
                case "-".code:
                    if (parsingGroup) {
                        if (breaking) {
                            rawEregBuf.addChar("\\".code);
                        } else if (startedParsingGroup) {
                            throw "cannot span immediately after group opening";
                        } else if (justNegatedGroup) {
                            throw "cannot span immediately after group negation";
                        } else if (parsingSpan) {
                            throw "cannot span on an unescaped span";
                        } else {
                            parsingSpan = true;
                        }
                    }
                    rawEregBuf.addChar("-".code);
                case "]".code:
                    if (parsingGroup) {
                        if (breaking) {
                            rawEregBuf.addChar("\\".code);
                            rawEregBuf.addChar("]".code);
                            breaking = false;
                            continue;
                        } else if (parsingSpan) {
                            throw "cannot span into an unescaped group closure";
                        } else {
                            parsingGroup = false;
                        }
                    } else {
                        rawEregBuf.addChar("\\".code);
                        rawEregBuf.addChar("]".code);
                        breaking = false;
                        continue;
                    }
                    if (!startedParsingGroup && !justNegatedGroup) {
                        rawEregBuf.addChar("]".code);
                    }
                case "\\".code:
                    if (breaking) {
                        rawEregBuf.addChar("\\".code);
                        rawEregBuf.addChar("\\".code);
                    } else {
                        breaking = true;
                    }
                case ".".code | "+".code | "$".code | "|".code | "(".code | ")".code:
                    if (!parsingGroup) {
                        rawEregBuf.addChar("\\".code);
                    }
                    rawEregBuf.addChar(char);
                default:
                    rawEregBuf.addChar(char);
            }

            if (char != "*".code) {
                justParsedAny = false;
            }
            if (initStartedParsingGroup) {
                startedParsingGroup = false;
            }
            if (initJustNegatedGroup) {
                justNegatedGroup = false;
            }
            if (initParsingSpan) {
                parsingSpan = false;
            }
            if (initBreaking) {
                breaking = false;
            }
        }

        if (breaking) {
            rawEregBuf.addChar("\\".code);
            rawEregBuf.addChar("\\".code);
        }
        if (parsingGroup && !startedParsingGroup && !justNegatedGroup) {
            rawEregBuf.addChar("]".code);
        }

        if (!glob.endsWith("*")) {
            rawEregBuf.addChar("$".code);
        }
        return rawEregBuf.toString();
    }
}
