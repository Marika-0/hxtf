# hxtf
Haxe unit testing framework for targets with access to the system environment.

| Word                            | Explanation |
|:--------------------------------|:------------|
| hxtf                            | **H**a**x**e unit **t**esting **f**ramework. Refers to both the backend binary which invokes the Haxe compiler and test runs, and the framework of everything used in a Test Run. |
| Target                          | Refers specifically to the combined `<target>.hxml` and `<target>.script` files (e.g. "cpp_optimized" and "cpp_debug" are different hxtf targets for the same Haxe target). |
| Test Run                        | An abstract term for a whole single test of a specific target. |
| Test Broker (`hxtf.TestBroker`) | A container of Test Cases and other Test Brokers - similar to a directory. May also be referred to as a Test Distributor, or Test Suite. |
| Test Case (`hxtf.TestCase`)     | A single test unit. Often referred to as simply a "test". |
| Included (pushed) Test          | Tests that a test run is specifically for. |
| Excluded (pulled) Test          | Tests that a test run is specifically excluding. |

A test run for a specific target is composed of test suites invoking test cases, which may be excluded (pushed) from the test run, or specifically included (pulled) in the test run.

### Source

Hxtf requires that a root type `TestMain` with a constructor. This type would usually extend `hxtf.TestBroker` and add other test brokers and/or cases.

`hxtf.TestBroker` has two methods: `addSuite()` and `addCase()`, which take a full dot path to another type with a constructor. `addSuite()` should be used to add test suites and `addCase()` should be used to add test cases.

A test case has several assertion methods, all of which have an optional argument for a custom message to be printed if they fail.

| Method                                       | Description |
|:---------------------------------------------|:------------|
| assert(x:Bool)                               | Asserts that the given value `x` is `true`. |
| assertF(x:Bool)                              | Asserts that the given value `x` is not `true`. |
| assertImplicit<T>(a:T, b:T)                  | Asserts that the expression `a == b` yields `true`. |
| assertExplicit<T>(x:T, f:T->Bool)            | Asserts that the expression `f(x)` yields `true`. |
| assertSpecific<A, B>(a:A, b:B, f:A->B->Bool) | Asserts that the expression `f(a, b)` yields `true`. |
| assertUnreachable()                          | Fails the Test Case if called. |
| assertNull(v:Dynamic)                        | Asserts that the given value `v` is `null`. |
| assertNNull(v:Null<Dynamic>)                 | Asserts that the given value `v` is not `null`. |
| assertExcept(f:Void->Void, ?type:Dynamic)    | Asserts that running the given function `f` throws an exception, and, if `type` is specified, asserts that the exception is of type `type`. |
| assertNExcept(f:Void->Void)                  | Asserts that running the given function `f` does not throw an exception. |
| assertFinite(v:Float)                        | Asserts that the given Float `v` is a finite number (not `Math.POSITIVE_INFINITY`, `Math.NEGATIVE_INFINITY`, or `Math.NaN`). |
| assertNaN(v:Float)                           | Asserts that the given Float `v` is `Math.NaN`. |
| assertNNaN(v:Float)                          | Asserts that the given Float `v` is not `Math.NaN`. |
| prompt(msg:String, printPos = false)         | Prompts the standard output stream with an error-formatted message `msg`.
| softFail(msg:String, printPos = true)        | Prompts the standard error stream with an error-formatted message `msg` and prevents the Test Case from being added to the cache for this target (the Test Case will be rerun until the soft failure don't occur), but does not explicitly fail the Test Case. |
| hardFail(msg:String, printPos = true)        | Prompts the standard error stream with an error-formatted message `msg` and explicitly fails the Test Case. |

`hxtf.TestCase` instances also have a _@:noCompletion_ property `_passed(default, never)`, used internally to record if any of the Test Cases assertions have failed. Be careful if messing with this.

### Command Line

| Flag              | Description |
|:------------------|:------------|
| `-c`, `--compile` | Only compile each hxtf target - don't invoke Test Runs. |
| `-f`, `--force`   | Force rerunning of previously-passed tests. |
| `-q`, `--quick`   | Don't block and wait for user input after a failed Test Run. |
| `-r`, `--reset`   | Delete the passed-test cache of passed targets (or all caches if no targets are passed). |
| `-a`, `--no-ansi` | Disable ANSI formatting in hxtf. |
| `-w`, `--write`   | Write Haxe compilation output (does not strip ANSI). |
| `-y`              | Followed by an argument of comma-separated glob dot-paths for tests to include in (push to) the test run. |
| `-n`              | Followed by an argument of comma-separated glob dot-paths for tests to exclude (pull) from the test run. |
| `-h`, `--help`    | Print help information and exit. |
| `-u`, `--usage`   | Print usage information and exit. |

When a test is marked as "push", all other tests that are not marked as "push" will not be included in the test run.

When a test is marked as "pull", that test will not be included in the test run.

If a test is not 'included' in the run, references to it from `addSuite()` and/or `addCase()` functions in test brokers are removed and it shouldn't get picked up by Haxe, therefore stopping it from existing in the final output.

> If a test is marked as "push" and "pull", the exclusion of that test will take precidence but the effects of a test being included will remain. Other tests not marked as "push" still won't be compiled.

### Structure

The initial working directory where hxtf is invoked for a target must contain a &lt;target&gt;.hxml and a &lt;target&gt;.script file. The &lt;target&gt;.hxml file is a hxml file for compiling the test run, and the &lt;target&gt;.script file is a script for running the test run.

There are some defines that the &lt;target&gt;.hxml can override to configure for specific targets:

| Define            | Values               | Description |
|:------------------|:---------------------|:------------|
| `-D hxtf_ansi`    | `"0"`, `"1"`         | Allows ANSI if has a value of `"1"`, otherwise disables it. |
| `-D hxtf_forcing` | `"0"`, `"1"`         | Forces previously-passed tests to be rerun if has a value of `"1"`, otherwise ignores them. |
| `-D hxtf_push`    | Colon-separated PCRE | A list of PCRE expressions separated by colons - the tests to include in the test run, in addition to ones specified by the `-y` flag. |
| `-D hxtf_pull`    | Colon-separated PCRE | A list of PCRE expressions separated by colons - the tests to exclude from the test run, in addition to ones specified by the `-n` flag. |

Tests that pass for each target are stored in a &lt;target&gt;.cache file, separated by newlines.

Hxtf creates an _.hxml file defining the main class and other information, nesting the &lt;target&gt;.hxml file.

Other defines used by hxtf are `hxtf_cwd`; `hxtf_target`; `hxtf_y`; and `hxtf_n`. Override these at your own risk.
