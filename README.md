HxTF
====

[![Release](https://img.shields.io/github/release/Marika-0/hxtf.svg)](https://github.com/Marika-0/hxtf/releases) [![License](https://img.shields.io/github/license/Marika-0/hxtf.svg)](LICENSE.md)

A Lightweight Multithreaded Conditional Unit Testing Framework for Haxe 4 Targets with Access to the System Environment.

Installation
------------

To install HxTF as a Haxelib package, run:
```
haxelib install hxtf
```

To install HxTF manually:

1. Download the latest release.
1. Go to `~/project/` and run `haxe build.hxml`.
1. Add the `~/src/` directory and `~/run.n` neko binary to your project.
1. Run HxTF using `neko run.n --help`.

Setting Up Unit Tests
-----

There are two parts to HxTF: The HxTF CLI, which you interact with through the command line (`haxelib run hxtf ...`, `neko run.n ...`, etc); and the HxTF API, which is the interface used to create test cases.

The HxTF CLI requires, at minimum, any number of colon-separated arguments specifying the targets to test. A "target" in terms of HxTF refers to the name of build and script files used for testing, as opposed to a Haxe target, which refers to a language that Haxe code can be compiled to.

The following commands are all valid for starting a test run (assuming that the appropriate build and script files exist):
```
haxelib run hxtf hashlink
# Run HxTF for the `hashlink` target.
haxelib run hxtf hl cpp java
# Run HxTF for the `hl`, `cpp`, and `java` targets.
haxelib run hxtf hl:cpp:java lua
# Run HxTF for the `hl`, `cpp`, `java`, and `lua` targets.
```

In order for HxTF to start a test run for a given target `<target>`, both a `<target>.hxml` build hxml and `<target>.script` script file must exist in the working directory. The build hxml must specify the Haxe target to compile to, and the script file must run the compiled test and return the exit code of the test run.

Examples of build hxmls and script files can be found in this project's [`test`](test) directory.

---

HxTF defines its own main class (`hxtf.TestRun`), but requires that a class `TestMain` exists in the root package with a public constructor taking no arguments. `TestMain` will be instantiated after `hxtf.TestRun.main()` finishes some initialization.

From `TestMain.new()`, testing can be branched out to other classes using `hxtf.TestRun.addObject(e:Expr):Expr`. `addObject()` expects a single argument, a dot path to a class with a public constructor taking no arguments, and will return an expression dependent on that class. If the given class extends `hxtf.TestObject`, it will be treated as a testing object; otherwise, `addObject()` simply returns a `new` expression to the given type.

If the class passed to `hxtf.TestRun.addObject()` does not exist, does not have a public constructor taking no arguments, or is not accessible to the class calling `addObject()`, an error will likely be thrown by the Haxe Compiler; but the behavior is overall unspecified.

`hxtf.TestRun.addObject()` handles everything to do with filtering tests based on the passed-test-cache and include/exclude specifications, multithreading, printing when a unit test starts and ends to the command line, handling a unit test exceeding the maximum assertion failure amount, and recording whether the test passed or failed. It is recommended to import `hxtf.TestRun.addObject` in an `import.hx` file in the root testing package for ease of use, but the user isn't required to do anything.

Examples of the use of `hxtf.TestRun.addObject()` can be found in Haxe source files in this projects [`test/src`](test/test) directory.

---

The `hxtf.TestObject` class is the base class for creating unit tests. A specific unit test class must extend `hxtf.TestObject` to be treated as a unit test by HxTF when added using `hxtf.TestMain.addObject()`.

`hxtf.TestObject` defines several methods for use in testing:

| Method | Description |
| :----- | :---------- |
| `assert(x:Bool, ?msg:String, ?pos:haxe.PosInfos):Bool` | Asserts that the given boolean `x` is `true`. |
| `assertF(x:Bool, ?msg:String, ?pos:haxe.PosInfos):Bool` | Asserts that the given boolean `x` is `false`. |
| `assertImplicit<T>(a:T, b:T, ?msg:String, ?pos:haxe.PosInfos):Bool` | Asserts that `a == b`. |
| `assertExplicit<T>(x:T, f:(T) -> Bool, ?msg:String, ?pos:PosInfos):Bool` | Asserts that `f(x)` returns `true`. |
| `assertSpecific<A, B>(a:A, b:B, f:(A, B) -> Bool, ?msg:String, ?pos:PosInfos):Bool` | Asserts that `f(a, b)` returns `true`. |
| `assertUnreachable(?msg:String, ?pos:PosInfos):Void` | Asserts that this assertion isn't reached during testing. |
| `assertNull(v:Null<Dynamic>, ?msg:String, ?pos:PosInfos):Bool` | Asserts that the given value `v` is null. |
| `assertNNull(v:Null<Dynamic>, ?msg:String, ?pos:PosInfos):Bool` | Asserts that the given value `v` is not null. |
| `assertExcept(f:() -> Void, ?type:Dynamic, ?msg:String, ?pos:PosInfos):Bool` | Asserts that the given function `f`, when called, throws an exception (if `type` is not null, also tests that the thrown exception is of type `type` using `Std.is()`). |
| `assertNExcept(f:() -> Void, ?msg:String, ?pos:PosInfos):Bool` | Asserts that the given function `f`, when called, does not throw an exception. |
| `prompt(msg:String, printPos = true, ?pos:PosInfos):Void` | Prints a prompt `msg` to the command line using standard HxTF formatting. This function will not result in a failure of the unit test. |

All assertion that return a boolean will return `true` if the assertion succeeded or `false` if it failed. A failed assertion will print an error to the command line describing the type of error and where it occurred, optionally with some message `msg` passed to the assertion function.

The HxTF option `--max-assertions N` specifies `N` as being the maximum number of assertions that can fail in a unit test before the test is aborted. If this number is of assertion failures is reached, the test is stopped prematurely.

Running Unit Tests
------------------

The HxTF CLI has various flags for configuring a test run.

| Flag | Argument/s | Description |
| :--: | :--------: | ----------- |
| `-f`, `--force` | &lt;none&gt; | Force rerunning of all tests, regardless of if the cache states those tests have already passed. |
| `-b`, `--block` | &lt;none&gt; | Block when testing of a target fails until the user presses a key (for multi-target testing). |
| `-c`, `--compile` | &lt;none&gt; | Only compile the specified target/s. If this flag is set, script file do not need to exist for the given targets, only build hxmls. |
| `-w`, `--write` | &lt;none&gt; | Write output of the Haxe compiler to the command line during compilation. |
| `-a`, `--no-ansi` | &lt;none&gt; | Strip ANSI formatting from everything printed to the standard output streams. |
| `-l`, `--no-lib` | &lt;none&gt; | Don't automatically include the HxTF library when compiling test runs. |
| `-z`, `--no-cache` | &lt;none&gt; | Don't save passing unit tests to a `<target>.cache` file. |
| `-t`, `--max-threads` | A signed 32-bit integer | The maximum number of threads to use when running tests. The given value will be clamped in the range `[1,32]`. |
| `-m`, `--max-failures` | A signed 32-bit integer | The maximum number of assertions that can fail in a single unit test before the test is prematurely aborted. A value less than `1` will disable this feature. |
| `-y`, `--push` | A colon-separated list of class dot-paths globs | The unit tests to run in this test run. All other unit tests will not be run. |
| `-n`, `--pull` | A colon-separated list of class dot-paths globs | The unit tests to exclude from this test run. Overrides the tests specified to include in `-y`. |
| `-h`, `--help` | &lt;none&gt; | Print help information and exit. |
| `-v`, `--version` | &lt;none&gt; | Print version information and exit. |
| `-u`, `--usage` | &lt;none&gt; | Print usage information and exit. |
| `-r`, `--reset` | None, or the target list | If the target list is given, deletes the cache file of each target. If no target list is given, deletes every `<name>.cache` file for every existing `<name>.hxml` and `<name>.script` file. |

If the `--help`, `--version`, `--usage`, or `--reset` flags are set, the target list does not need to be included all other flags (except for `--no-ansi` in the case of `--reset`) will be ignored. `--help`, `--version`, and `--usage` take priority over `--reset`, and the first to be reached will print its information before exiting.

`--max-threads` requires a signed 32-bit integer as an argument. If `--max-threads` is not flagged or its argument cannot be parsed, a default value of `4` will be used. The argument value will otherwise be clamped in the range `[1,32]`.

`--max-failures` requires a signed 32-bit integer as an argument. If `--max-failures` is not flagged or its argument cannot be parsed, a default value of `4` will be used. The argument value will otherwise be clamped in the range `[0,2147483647]`, with a value of `0` disabling aborting tests.

The `--push` and `--pull` flags both require a colon-separated list of Unix glob expressions for the class paths of unit tests. This list may need to be wrapped in double-quotes or otherwise escaped to prevent shell expansion.

---

Some examples of commands to run tests or delete caches are as follows:

`hxtf -afz hl_dceStd cpp_noOptimisation java`
Test the `hl_dceStd`, `cpp_noOptimisation`, and `java` targets without ANSI formatting, excluding tests that the cache says are already passing, or saving the passing tests from this test run to the cache.

`hxtf -r python_std python_simple` - delete the `python_std.cache` and `python_simple.cache` files if they exist.

`hxtf -r` - delete every `<test>.cache` file if there exists a `<test>.hxml` and `<test>.script` file.

`hxtf -t 0 -m 0 cs` - test the `cs` target without multithreading and without aborting tests prematurely.

`hxtf -y "numeric.*:math.*" -n "math.algebra.*" lua_fullOp:lua_noOp neko` - test everything in the `numeric` and `math` packages, except for everything in the `math.algebra` package for the `lua_fullOp`, `lua_noOp`, and `neko` targets, and don't run unit tests that have been cached as passed in previous test runs on each target.

Advanced Target Configuration
-----------------------------

Specific HxTF targets can be setup to override or add to command line configuration by specifying compiler defines:

| Flag | Define | Value |
| :--: | :----: | :---- |
| `-f`, `--force` | `hxtf.readCache` | `"true"` to read the cache, otherwise ignores the cache. |
| `-a`, `--no-ansi` | `hxtf.stripAnsi` | `"true"` to strip ansi, otherwise doesn't modify strings. |
| `-z`, `--no-cache` | `hxtf.writeCache` | `"true"` to save passing tests to the cache, otherwise doesn't cache them. |
| `-t`, `--max-threads` | `hxtf.maxTestingThreads` | Parsed as an integer and clamped in `[1,32]`, defaults to `4` if parsing fails. |
| `-m`, `--max-failures` | `hxtf.maxAssertionFailures` | Parsed as an integer and clamped in the positive signed 32-bit integer range, defaults to `4` if parsing fails. |
| `-y`, `--push` | `hxtf.includeTests` | A colon-separated list of Haxe EReg strings. |
| `-n`, `--pull` | `hxtf.excludeTests` | A colon-separated list of Haxe EReg strings. |
| &lt;none&gt; | `hxtf.workingDirectory` | A path to an existing write-accessible directory. |

All defines beginning with `hxtf.includeTests` or `hxtf.excludeTests` are aggregated with the appropriate include/exclude list. This allows specific targets or nested hxml files to push or pull certain unit tests without overriding the `--push`/`--pull` command line arguments (e.g. `hl_noSys.hxml` can define `hxtf.excludeTests.noSys=^sys.:^filesystem.` to always exclude everything in the `sys` and `filesystem` packages, and `--pull "ds.*"` can still be defined on the command line to exclude everything in the `ds` package).

`hxtf.workingDirectory` stores the working directory that HxTF was launched from. It's the path that test run cache files are read from and written to, and is used so that a target run script file can change the working directory before starting a test run without changing where cache files are stored.


Exit Codes
----------

The HxTF CLI returns an exit status based on how testing went for the given target/s:

| Code | Description |
| :--: | :---------- |
| `0` | Normal program termination - all unit tests for all targets compiled and ran successfully. |
| `1` | An unexpected runtime error occurred in HxTF. |
| `2` | A unit test failed. |
| `3` | An unexpected runtime error occurred in a test run. |
| `4` | A target failed to compile. |

Of exit codes `2`, `3`, and `4`: `4` takes precedence over `3`, which takes precedence over `2` (e.g. when testing multiple targets, if one target compiled successfully but had a unit test fail, and another target failed to compile, the exit code `4` would be returned instead of `2`).

A compiled test run using the HxTF API also returns an exit code:

| Code | Description |
| :--: | :---------- |
| `0` | All unit tests passed, no errors occurred. |
| `1` | An unexpected runtime error occurred. |
| `2` | A unit test failed. |


Remarks
-------

HxTF currently uses Haxe EReg's for pattern matching. This could be confusing when trying to switch between using Unix globs in the command line and EReg strings in build hxmls, adds to compilation time, requires PCRE libraries, etc. A future version of HxTF is planned to implement a simple Unix glob-style pattern matching type to simplify things and add to the "lightweightness" of HxTF.

To ease with parsing the output of HxTF, changing the formatting of information printed to the command line is considered a breaking change. Statements that a test started, failed an assertion, printed a prompt, reaching the maximum assertion failure limit, threw an uncaught exception, passed or failed, etc, are all printed to the command line in a specific format that won't be changed without the release of another major version of HxTF.

Care should be taken when branching unit tests from other unit test. If a unit test `A` adds other unit tests `B` and `C`, and `A` is cached as passing on one test run, then `B` and `C` will not be run in future test runs without ignoring the cache.

When multithreading with Java, printing to the standard outputs from multiple threads merges strings together into an unreadable mess. This hasn't been fixed yet.
