package hxtf.pattern;

using StringTools;
using Type;

/**
    An implementation of unix glob pattern-matching that translates a glob
    pattern into a Haxe regular expression.

    Wildcard | Description
    :------: | -----------
    `*`      | Matches any amount of any character.
    `?`      | Matches exactly one of any character.
    `[abc]`  | Matches one of any of the listed characters (the literal character `-` must be escaped like so: `\-`).
    `[a-h]`  | Matches one of any characters in the given range.
    `[!abc]` | Matches one of any characters that are not listed (escape `!` with `\!` if it is at the start of a non-exclusive group).
    `[!a-h]` | Matches one of any characters not in the given range.

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
    character must be escaped (`a\\b` -> `"a\b"`)

    Examples:
    - `[abcj-z]` will not match `"d"`, `"e"`, `"f"`, etc.
    - `[abcj\-z]` will only match `"a"`, `"b"`, `"c"`, `"j"`, `"-"`, or `"z"`.
    - `\*` will match the literal `"*"` character.
    - `\[abc\]` and `\[abc]` will both match the literal string `"[abc]"`.
    - `\` and `\\` will both match the literal string `"\"`.
    - `[\` will be interpreted as `[\\]`.
**/
class Glob {
    /**
        The raw string used to construct `this` glob.
    **/
    public var raw(default, null):RawGlob;

    var regex:EReg;

    /**
        Creates a new glob expression with pattern `raw`.

        Guaranteed to throw an instance of type `GlobException` if an error
        occurs.
    **/
    public function new(raw:RawGlob) {
        try {
            this.raw = parseRaw(raw);
            regex = new EReg(this.raw, "");
        } catch (ex:GlobException) {
            throw ex;
        } catch (ex:Dynamic) {
            throw GlobException.Unknown;
        }
    }

    /**
        Tells if `this` glob expression matches String `s`.

        If `s` is `null`, the result is unspecified.
    **/
    public function match(s:String):Bool {
        return regex.match(s);
    }

    /**
        Returns a copy of `this` Glob.
    **/
    public function copy():Glob {
        var copy = this.getClass().createEmptyInstance();
        copy.regex = regex;
        copy.raw = raw;
        return copy;
    }

    /**
        Parses the given raw glob and transforms it into a EReg-type string with
        the same match capabilities and limitations.
    **/
    public static function parseRaw(raw:RawGlob):RawGlob {
        var rawRegex = new StringBuf();
        rawRegex.addChar("^".code);

        var justParsedAny = false;
        var parsingGroup = false;
        var startedParsingGroup = false;
        var justNegatedGroup = false;
        var parsingSpan = false;
        var breaking = false;

        for (index in 0...raw.length) {
            var char = raw.fastCodeAt(index);
            var initStartedParsingGroup = startedParsingGroup;
            var initJustNegatedGroup = justNegatedGroup;
            var initParsingSpan = parsingSpan;
            var initBreaking = breaking;

            if (startedParsingGroup) {
                if (char != "]".code && char != "!".code) {
                    rawRegex.addChar("[".code);
                }
            } else if (justNegatedGroup) {
                if (char != "]".code) {
                    rawRegex.addChar("[".code);
                    rawRegex.addChar("^".code);
                }
            }

            switch (char) {
                case "*".code:
                    if (parsingGroup) {
                        rawRegex.addChar("*".code);
                    } else if (breaking) {
                        rawRegex.addChar("\\".code);
                        rawRegex.addChar("*".code);
                    } else {
                        if (!justParsedAny) {
                            rawRegex.addChar(".".code);
                            rawRegex.addChar("*".code);
                        }
                        justParsedAny = true;
                    }
                case "?".code:
                    if (parsingGroup) {
                        rawRegex.addChar("?".code);
                    } else if (breaking) {
                        rawRegex.addChar("\\".code);
                        rawRegex.addChar("?".code);
                    } else {
                        rawRegex.addChar(".".code);
                    }
                case "[".code:
                    if (parsingGroup) {
                        rawRegex.addChar("[".code);
                    } else if (breaking) {
                        rawRegex.addChar("\\".code);
                        rawRegex.addChar("[".code);
                    } else {
                        parsingGroup = true;
                        startedParsingGroup = true;
                    }
                case "!".code:
                    if (startedParsingGroup && !breaking) {
                        justNegatedGroup = true;
                    } else {
                        rawRegex.addChar("!".code);
                    }
                case "^".code:
                    if (startedParsingGroup || !parsingGroup) {
                        rawRegex.addChar("\\".code);
                    }
                    rawRegex.addChar("^".code);
                case "-".code:
                    if (parsingGroup) {
                        if (breaking) {
                            rawRegex.addChar("\\".code);
                        } else if (startedParsingGroup) {
                            throw GlobException.SpanCalledAfterGroupOpening;
                        } else if (justNegatedGroup) {
                            throw GlobException.SpanCalledAfterGroupNegation;
                        } else if (parsingSpan) {
                            throw GlobException.SpanCalledWhileParsingSpan;
                        } else {
                            parsingSpan = true;
                        }
                    }
                    rawRegex.addChar("-".code);
                case "]".code:
                    if (parsingGroup) {
                        if (breaking) {
                            // rawRegex.addChar("\\".code);
                        } else if (parsingSpan) {
                            throw GlobException.SpanRanIntoGroupClosure;
                        } else {
                            parsingGroup = false;
                        }
                    }
                    if (!startedParsingGroup && !justNegatedGroup) {
                        rawRegex.addChar("]".code);
                    }
                case "\\".code:
                    if (breaking) {
                        rawRegex.addChar("\\".code);
                        rawRegex.addChar("\\".code);
                    } else {
                        breaking = true;
                    }
                case ".".code | "+".code | "$".code | "|".code | "(".code | ")".code:
                    if (!parsingGroup) {
                        rawRegex.addChar("\\".code);
                    }
                    rawRegex.addChar(char);
                default: rawRegex.addChar(char);
            }

            if (char != "*".code) {
                justParsedAny = false;
            }

            if (initStartedParsingGroup) startedParsingGroup = false;
            if (initJustNegatedGroup) justNegatedGroup = false;
            if (initParsingSpan) parsingSpan = false;
            if (initBreaking) breaking = false;
        }

        if (breaking) {
            rawRegex.addChar("\\".code);
            rawRegex.addChar("\\".code);
        }
        if (parsingGroup && !startedParsingGroup && !justNegatedGroup) {
            rawRegex.addChar("]".code);
        }

        rawRegex.addChar("$".code);
        return rawRegex.toString();
    }

    /**
        Returns the hash code of this glob.
    **/
    public function hashCode():Int {
        var hash = 0;
        haxe.Utf8.iter(raw, function(c) hash += c);
        return hash;
    }
}

/**
    An enumeration of possible exceptions that can occur when creating a glob.
**/
enum GlobException {
    SpanCalledAfterGroupOpening;
    SpanCalledAfterGroupNegation;
    SpanCalledWhileParsingSpan;
    SpanRanIntoGroupClosure;
    Unknown;
}
