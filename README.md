HxTF
====

[![Release](https://img.shields.io/github/release/Marika-0/hxtf.svg)](https://github.com/Marika-0/hxtf/releases) ![Build](https://img.shields.io/badge/build-passing-brightgreen.svg) ![Coverage](https://img.shields.io/badge/coverage-0%25-critical.svg) [![Commit](https://img.shields.io/github/last-commit/Marika-0/hxtf.svg)](https://github.com/Marika-0/hxtf/commits/master) [![License](https://img.shields.io/github/license/Marika-0/hxtf.svg)](LICENSE.md) [![Haxelib](https://img.shields.io/badge/haxelib-v1.0.0-blue.svg)](https://lib.haxe.org/p/hxtf/)

A Haxe 4 conditional unit testing framework for targets with access to the system environment.


Abstract
========

HxTF (**H**a**x**e **T**esting **F**ramework) operates through a  series of 'Test Brokers' (or 'Test Suites') which sequentially instantiate more Test Brokers and/or 'Test Cases'.

An example setup might look like the following:

```plaintext
test/
├── src/
│   ├── test/
│   │   ├── datastructure/
│   │   │   ├── LinkedListTests.hx
│   │   │   ├── HeapTests.hx
│   │   │   └── TestSuite.hx
│   │   ├── lambda/
│   │   │   ├── ComparisonTests.hx
│   │   │   ├── ConversionTests.hx
│   │   │   ├── IterationTests.hx
│   │   │   └── TestSuite.hx
│   │   ├── DynamicTests.hx
│   │   ├── MathTests.hx
│   │   └── TestSuite.hx
│   └── TestMain.hx
├── cpp_debug.hxml
├── cpp_debug.script
├── cpp_optimized.hxml
├── cpp_optimized.script
├── neko.hxml
└── neko.script
```

_test/cpp\_debug.hxml_
```hxml
-cp src
-debug
-cpp build/cpp
```

_test/cpp\_debug.script_
```sh
./build/cpp/TestRun
```

_test/cpp\_optimized.hxml_
```hxml
-cp src
-dce full
-D analyzer-optimize
-cpp build/cpp
```

_test/src/TestMain.hx_
```haxe
package;

class TestMain extends hxtf.TestBroker {
    function new() {
        addBroker(test.TestSuite);
    }
}
```

_test/src/test/TestSuite.hx_
```haxe
package test;

class TestSuite extends hxtf.TestBroker {
    public function new() {
        addTest(test.DynamicTests);
        addTest(test.MathTests);
        addBroker(test.datastructure.TestSuite);
        addBroker(test.lambda.TestSuite);
    }
}
```

_test/src/test/MathTests.hx_
```haxe
package test;

class MathTests extends hxtf.TestCase {
    public function new() {
        test_addition();
        test_multiplication();
        ...
    }

    function test_addition():Void {
        // Math addition tests
    }

    ...
}
```

HxTF requires that there be a root class named "TestMain" with an access-irrelevent constructor taking no arguments. All other Test Brokers and Test Cases must have constructors taking no arguments and accessible to the Test Broker instantiating it.

The general setup has a Test Broker called "TestSuite" in every package, which adds all Test Cases in that package and all Test Brokers one package below. The functions `addTest()` and `addBroker()` are macro's inherited from `hxtf.TestBroker` accepting one absolute dot-path argument to another type, and returning a `new` expression to that type taking no arguments.

> Technically, the `addBroker()` function just checks that the argument is a valid dot-path and returns a `new` expression to that path. `addTest()`, however, does some extra checks and things on the side, so it should be used specifically and exclusivly for Test Cases.

The `addTest()` function, at compile time, checks a cache file to see if its argument has passed testing previously. If it has, the call is exited and no `new` expression is returned. Without a reference to the Test Case, the Haxe compiler ignores it and the type isn't generated, excluding it from later compilation and the test run in general.


Setup
=====

A HxTF target is defined as a Haxe target with access to the system environment, with a hxml file configuring its compilation and a script file executing the test run.

In the above example, `cpp_debug` and `cpp_optimized` are separate HxTF targets for the same Haxe target. Each test run will save the result of its testing in a "&lt;target&gt;.cache" file, with each passing Test Case separated by a newline. Each cache is specific to the target and referred to when compiling another test run for that target.

HxTF creates an "\_.hxml" file specifying the main class and some other configuration information. This \_.hxml file defines the following compiler flags:

| Define         | Default     | Flag | Description                                                                                                        | Location                   |
| -------------- | :---------: | :--: | ------------------------------------------------------------------------------------------------------------------ | -------------------------- |
| `hxtf_ansi`    | `"1"`       | `-a` | If has the value `"1"`, ANSI formatting is not stripped from output printed through `hxtf.Print`.                  | `hxtf.Print.ansi`          |
| `hxtf_cache`   | `"1"`       | `-z` | If has the value `"1"`, passing tests for the test run will be cached.                                             | `hxtf.TestRun.savingCache` |
| `hxtf_cwd`     | $PWD        | N/A  | The working directory that HxTF was invoked from, and the location where cache files are read from and written to. | `hxtf.TestRun.cwd`.        |
| `hxtf_force`   | `"0"`       | `-f` | If has the value of `"1"`, all tests are compiled and run even if they have an entry in the target cache.          | `hxtf.TestRun.forcing`     |
| `hxtf_y`       | CLI-defined | `-y` | A colon-separated list of PCRE regexes for tests to push to the test run.                                          | `hxtf.Macro.pushedTests`   |
| `hxtf_n`       | CLI-defined | `-n` | A colon-separated list of PCRE regexes for tests to pull from the test run.                                        | `hxtf.Macro.pushedTests`   |

The value of these flags can be overridden by specific HxTF targets by defining the flag in that targets hxml file. E.g. to always save the cache add the line `-D hxtf_cache=1`, or to always strip ANSI formatting add the line `-D hxtf_ansi=0`.

The `hxtf_ansi`; `hxtf_cache`; and `hxtf_force` flags can be safely overridden.

The `hxtf_cwd` flag should be overridden with care - it changes where "&lt;target&gt;.cache" is read from and written to.

The `hxtf_y` and `hxtf_n` flags generally should not be overridden in hxml files. `hxtf_push` and `hxtf_pull` can be used instead. `hxtf_push` is used to extend the `hxtf_y` define with more tests to specifically compile the test run for, `hxtf_pull` is used to extend the `hxtf_n` define with more tests to specifically exclude from the test run. Both of these flags will attempt to be used as a colon-separated list of PCRE expressions.

> Note that, as hxml files can be nested within each other, it may simplify things to have an "\_base.hxml" or similar file defining source directories and compiler flags, and include it in HxTF target hxml files.


Use
===

The HxTF command line tool has several flags for configuring test runs.

```plaintext
usage: hxtf [OPTIONS...] TARGETS...

Options:
    -c, --compile   only run compilation for the specified targets
    -f, --force     force rerunning of previously-passed tests
    -q, --quick     do not wait for acknowledgement after a failed test run
    -r, --reset     delete the passed-test cache of each target
                      tests will not be invoked
    -a, --no-ansi   disable output ANSI formatting
    -w, --write     write haxe compiler outputs to stdout
                      output cannot be formatted to remove ANSI
    -z, --no-cache  disable caching of passed tests

    -y TEST[:TEST]* only compile/run these tests
    -n TEST[:TEST]* exclude these tests (overrides '-y')

    -h, --help      print this help and exit
    -u, --usage     print usage information and exit

Targets:
    A colon or space-separated list of targets to test (in order)
```

| Flag               | Description                                                                                               |
| ------------------ | --------------------------------------------------------------------------------------------------------- |
| `-c`, `--compile`  | Compile the specified HxTF targets, but doesn't run any tests.                                            |
| `-f`, `--force`    | Forces previously-passed tests to be run.                                                                 |
| `-q`, `--quick`    | Don't block and wait for user input after a failed test run.                                              |
| `-r`, `--reset`    | Delete the cache of specified targets (or all caches if no targets are specified).                        |
| `-a`, `--no-ansi`  | Disable ANSI formatting in hxTF.                                                                          |
| `-w`, `--write`    | Write Haxe compilation output (does not strip ANSI).                                                      |
| `-z`, `--no-cache` | Don't cache passed tests for this test run.                                                               |
| `-y`               | Followed by an argument of comma-separated glob dot-paths for tests to include in (push to) the test run. |
| `-n`               | Followed by an argument of comma-separated glob dot-paths for tests to exclude (pull) from the test run.  |
| `-h`, `--help`     | Print help information and exit.                                                                          |
| `-u`, `--usage`    | Print usage information and exit.                                                                         |


> From the command line, the `-y` and `-n` flags take a colon-separated list of glob expressions for Test Cases to push to and/or pull from the test run. The following wildcards are supported: `*`; `?`; `[abc]`; `[a-z]`; `[!abc]`; and `[!a-z]` - see [Wikipedia](https://en.wikipedia.org/wiki/Glob_%28programming%29#Syntax) for details.

> Internally, glob expressions are converted into PCRE expressions, and these are what are stored in the `hxtf_y` and `hxtf_n` flags.

> Glob expressions for `-y` and `-n` flags may need to be enclosed in quotes to prevent the shell from expanding them into file lists.

> Glob expressions validated as being dot-path expressions and allow characters that would not appear in dot-paths. If the character `":"` is included, the result is unspecified.

Examples:

- `hxtf -ca cpp:neko:php`
  - Compile the `cpp`; `neko`; and `php` HxTF targets.
  - Stripping ANSI from output.
  - Exit without running tests.
- `hxtf -fq cpp_unstable hl_unstable`
  - Compile the `cpp_unstable` and `hl_unstable` HxTF targets.
  - Force rerunning of all tests.
  - Don't block and wait for user input if a test fails.
- `hxtf -r`
  1. Confirm that the user wants to delete all cache files.
  1. Delete all _target_.cache files that also have a _target_.hxml and _target_.sh file.
- `hxtf neko -zy "*Math*" -n "*Complex*"`
  - Compile the `neko` HxTF target for all tests that match `~/.*Math.*/` and don't match `~/.*Complex.*/`.
  - Don't cache passed tests.


When a test is marked as "push" (`-y`), all other tests that are not marked as "push" will not be included in the test run.

When a test is marked as "pull" (`-n`), that test will not be included in the test run.

If a test is not included in the test run, references to it from `addCase()` functions in Test Brokers are removed and it shouldn't get picked up by the Haxe compiler.

> If a test is marked as "push" and "pull", the exclusion of that test will take precidence but the effects of a test being included will remain. Other tests not marked as "push" still won't be compiled.


Test Cases
==========

A Test Case has several assertion methods, all of which have an optional argument for a custom message to be printed if they fail.

Below is a simplified outline of

| Method                                       | Description |
| -------------------------------------------- | ----------- |
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
| prompt(msg:String, printPos = false)         | Prompts the standard output stream with the message `msg`. |
| softFail(msg:String, printPos = true)        | Prompts the standard error stream with the message `msg` and soft fails the Test Case. |
| hardFail(msg:String, printPos = true)        | Prompts the standard error stream with the message `msg` and hard fails the Test Case. |

> A Test Case that has 'soft failed' will not be saved to the case, but will not explicitly by marked as a failure. Soft failures will be overridden by hard failures (a failed assertion results in a hard failures), and a hard failure explicitly marks the test as failed as well as preventing it from being cached.

`hxtf.TestCase` instances also have a _@:noCompletion_ property `_passed(default, never)`. This field is used to record if the Test Case has hard failed - modify it during test runs at your own risk.
