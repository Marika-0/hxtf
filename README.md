HxTF
====

[![Release](https://img.shields.io/github/release/Marika-0/hxtf.svg)](https://github.com/Marika-0/hxtf/releases)
[![Build](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/Marika-0/hxtf)
[![Coverage](https://img.shields.io/badge/coverage-0%25-critical.svg)](https://github.com/Marika-0/hxtf)
[![License](https://img.shields.io/github/license/Marika-0/hxtf.svg)](LICENSE.md)
[![Haxelib](https://img.shields.io/badge/haxelib-v1.1.0-blue.svg)](https://lib.haxe.org/p/hxtf/)
[![Outdatedness](https://img.shields.io/github/commits-since/Marika-0/hxtf/latest.svg)](https://github.com/Marika-0/hxtf/commits/master)
[![Latest Commit](https://img.shields.io/github/last-commit/Marika-0/hxtf.svg)](https://github.com/Marika-0/hxtf/commits/master)

A Lightweight Conditional Unit Testing Framework for Haxe 4 Targets with Access to the System Environment.


Installation
------------

##### Haxelib

To install HxTF as a Haxelib library, run:

```
haxelib install hxtf
```

##### Manual Installation

1. Edit `./project/build.hxml` as required.
1. Set the working directory to `./project/` and run `haxe build.hxml`.
1. Link to the produced build in some way.
1. Add `./src` as a class path flag when compiling with Haxe.


Abstract
--------

HxTF (**H**a**x**e **T**esting **F**ramework) describes two components:

- The `hxtf` command line tool (HxTF CLI), and
- The library files used to write Test Setups (HxTF API).

And is based around the following terms:

- A "Test Setup" is the source code, auxiliary, and resource files used to test a project for one or more Targets.
- A "Target" is a user-defined Haxe compilation target, configured with a _&lt;target&gt;.hxml_ file.
- A "Test Run" is the process of compiling and running Test Setups for any amount of Targets.
- A "Test Broker" is a class inheriting from `hxtf.TestBroker` and operates like a directory of other Test Brokers and Test Cases.
- A "Test Case" is a class inheriting from `hxtf.TestCase` and is the smallest unit of a Test Setup. It should perform a single unit test.

A Test Setup is organized so that a user-defined Test Broker class `TestMain` references other Test Brokers (and/or Test Cases), which in turn reference more Test Brokers (and/or Test Cases) and so on. This results in a sequential recursive instantiation of Test Cases.

The most easily maintainable Test Setup for HxTF is designed for there to be a Test Broker in each Haxe package, referencing all Test Cases in that package and all Test Brokers one package below.

---

The HxTF CLI can be configured for different Test Runs with various flags, several of which can be overridden by specific Targets in their _&lt;target&gt;.hxml_ files.

When the HxTF CLI is called to start a Test Run, each Target is compiled and run individually. HxTF creates an _\_.hxml_ file in the working directory nesting the hxml file for each specified targets. An example of this _\_.hxml_ file is shown below:

```hxml
--main    hxtf.TestRun

--library hxtf:1.2.0

--macro   hxtf.Macro.setup()

--define  hxtf_ansi=1
--define  hxtf_cache=1
--define  hxtf_cwd=/home/user/myProject/test
--define  hxtf_force=0
--define  hxtf_target=cpp_debug

cpp_debug.hxml
```

Each Target for a Test Run must have a _&lt;target&gt;.hxml_ file (configuring compilation) and a _&lt;target&gt;.script_ file (invoking the Test Run). Each target will have a _&lt;target&gt;.cache_ file created for it by HxTF storing a list of Test Cases that have passed in previous Test Runs.

All HxTF Targets are Haxe targets. Several HxTF Targets can be defined for the same Haxe target for testing different conditions (such as optimized and debug builds) or for calling different initialization macros etc.

Test Brokers and Test Cases _must_ have a constructor taking no arguments accessible to the Test Broker referencing it.


Requirements
------------

- HxTF requires that there be a type `TestMain` in the top-level package. This type must have a constructor taking no arguments, will be instantiated by the main class `hxtf.TestRun`, and would generally extend `hxtf.TestBroker` (being used as the main entry for adding Test Brokers and/or Test Cases).
- `addBroker()` and `addTest()` functions must be explicitly imported (see `--default-import` flag details)


Setup
-----

A particular Test Run is defined for some user-defined HxTF Target (a Haxe target potentially with some specialization), and requires a _&lt;target&gt;.hxml_ and _&lt;target&gt;.script_ file.

- The _&lt;target&gt;.hxml_ file includes compiler configuration for that Target and is nested within a hxml file created by HxTF.
- The _&lt;target&gt;.script_ file is read and passed to the command line. It can include setup and tear-down information for the test, but should invoke the Test Run in some way.

> The exit status of the Test Run is used by HxTF CLI to determine if the Test Run succeeded or failed. If the exit code of passing the _&lt;target&gt;.script_ file contents to the command line is not the same as the exit code of the Test Run, HxTF will not behave as expected.

HxTF defines the main function and automatically includes the current version of the HxTF library (if the `-l` flag isn't specified).

---

An example Test Setup might look like the following:

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
-p src
--debug
--cpp build/cpp/
```

_test/cpp\_debug.script_
```sh
./build/cpp/debug/TestRun-debug
```

_test/cpp\_optimized.hxml_
```hxml
-p src
--dce full
-D analyzer-optimize
-cpp build/cpp/
```

_test/cpp\_optimized.script_
```sh
./build/cpp/optimized/TestRun
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
        ...
    }

    ...
}
```

The example setup has a Test Broker called "TestSuite" in every package, adding all Test Cases in that package and all Test Brokers one package below.

The functions `addTest()` and `addBroker()` are macros inherited from `hxtf.TestBroker` accepting one absolute dot-path argument to another type.

The `addTest()` function, at compile time, checks a cache file to see if its argument was tested successful previously. If it has, the call is exited and no `new` expression is returned. Without a reference to the Test Case, the Haxe compiler ignores it and the type isn't generated, excluding it from later compilation and the Test Run in general.

> Technically, `addBroker()` just checks that the argument is a valid dot-path and returns a `new` expression to that path - it doesn't explicitly do any optimizations of its own. `addBroker()` is included with `addTest()` for completeness.

> `addTest()` performs some extra operations (checking the cache etc) on it's given type and output. It should be used specifically and exclusively for Test Cases.

---

In the above example, "cpp_debug" and "cpp_optimized" are separate HxTF Targets for the same Haxe target. Each Test Run will save the result of its testing in a _&lt;target&gt;.cache_ file, with each passing Test Case separated by a newline. Each cache is specific to its Target and referred to when compiling another Test Run for that Target.

HxTF creates an _\_.hxml_ file specifying the main class and some other configuration information. This _\_.hxml_ file defines the following compiler flags:

| Define | Default | Flag | Description | Location |
| ------ | :-----: | :--: | ----------- | -------- |
| `hxtf_ansi` | `"1"` | `-a` | If has the value `"1"`, ANSI formatting is not stripped from output printed through `hxtf.Print`. | `hxtf.Print.ansi` |
| `hxtf_cache` | `"1"` | `-z` | If has the value `"1"`, passing tests for the Test Run will be cached. | `hxtf.TestRun.savingCache` |
| `hxtf_cwd` | $PWD | N/A | The absolute path to the w orking directory that HxTF was invoked from, and the location where cache files are read from and written to. | `hxtf.TestRun.cwd` |
| `hxtf_force` | `"0"` | `-f` | If has the value of `"1"`, all tests are compiled and run even if they have an entry in the Target cache. | `hxtf.TestRun.forcing` |
| `hxtf_y` | CLI-defined | `-y` | A colon-separated list of PCRE regexes for tests to push to the Test Run.  | `hxtf.Macro.pushedTests` |
| `hxtf_n` | CLI-defined | `-n` | A colon-separated list of PCRE regexes for tests to pull from the Test Run. | `hxtf.Macro.pushedTests` |

The value of these flags can be overridden by specific HxTF Targets by defining the flag in that Target's hxml file. To always save the cache add the line `-D hxtf_cache=1`, to always strip ANSI formatting add the line `-D hxtf_ansi=0`, etc.

The `hxtf_ansi`, `hxtf_cache`, and `hxtf_force` flags can be safely overridden.

The `hxtf_cwd` flag should be overridden with care - it changes where _&lt;target&gt;.cache_ is read from and written to.

The `hxtf_y` and `hxtf_n` flags generally should not be overridden in hxml files. `hxtf_push` and `hxtf_pull` can be used instead. `hxtf_push` is used to extend the `hxtf_y` define with more tests to specifically compile the Test Run for, `hxtf_pull` is used to extend the `hxtf_n` define with more tests to specifically exclude from the Test Run. Both of these flags will attempt to be used as a colon-separated list of PCRE expressions.

> All compiler defines that _start_ with `"hxtf_pull"` or `"hxtf_push"` will be interpreted as the respective define. This allows the user to define multiple pull/push defines when nesting hxml files.


Use
---

The HxTF command line tool has several flags for configuring Test Runs.

```plaintext
Usage: hxtf [OPTIONS...] TARGETS...

Run unit tests for Haxe targets with access to the system environment

Options:
    -f, --force         force rerunning of previously-passed tests
    -q, --quick         do not wait for acknowledgment after a failed test run
    -c, --compile       only run compilation for the specified targets
    -w, --write         write haxe compiler outputs to stdout
                          output cannot be formatted to remove ANSI
    -a, --no-ansi       disable output ANSI formatting
    -l, --no-lib        disable automatically include the hxtf library
    -z, --no-cache      disable caching of passed tests

    -y, --push (TEST[:TEST]*)  compile/run only these tests
    -n, --pull (TEST[:TEST]*)  exclude these tests (overrides '-y')

    -h, --help          print this help and exit
    -v, --version       print version and exit
    -u, --usage         print usage information and exit
    -r, --reset         delete the passed-test cache of each target
    --default-import    create a default import.hx file in the working directory

Targets:
    A colon or space-separated list of targets to test (in order)
```

| Flag | Description |
| ------------------ | --------------------------------------------------------------------------------------------------------- |
| `-f`, `--force` | Forces previously-successful tests to be run. |
| `-q`, `--quick` | Don't block and wait for user input after a failed Test Run. |
| `-c`, `--compile` | Compile the specified HxTF Targets, but doesn't run any tests. |
| `-w`, `--write` | Write Haxe compilation output (does not strip ANSI). |
| `-a`, `--no-ansi` | Disable ANSI formatting in HxTF. |
| `-l`, `--no-lib` | Disable automatically including the current version of HxTF in the _\_.hxml_ file. |
| `-z`, `--no-cache` | Don't cache successful tests for this Test Run. |
| `-y`, `--push` | Followed by an argument of comma-separated glob dot-paths for tests to include in (push to) the Test Run. |
| `-n`, `--pull` | Followed by an argument of comma-separated glob dot-paths for tests to exclude (pull) from the Test Run. |
| `-h`, `--help` | Print help information and exit. |
| `-u`, `--usage` | Print usage information and exit. |
| `-r`, `--reset` | Delete the cache of specified Targets (or all caches if no Targets are specified). |
| `--default-import` | Generate a default _import.hx_ file for HxTF and exit. |


> From the command line, the `-y` and `-n` flags take a colon-separated list of glob expressions for Test Cases to push to and/or pull from the Test Run. The following wildcards are supported: `*`; `?`; `[abc]`; `[a-z]`; `[!abc]`; and `[!a-z]` - see [Wikipedia](https://en.wikipedia.org/wiki/Glob_%28programming%29#Syntax) for details.

> Internally, glob expressions are converted into PCRE expressions stored in the `hxtf_y` and `hxtf_n` compiler defines.

> Glob expressions for `-y` and `-n` flags may need to be enclosed in quotes or escaped with backslashes to prevent shells from expanding them into file lists.

> Glob expressions are not validated as being dot-path expressions and allow characters that would not appear in dot-paths.

Examples:

- `hxtf -ca cpp:neko:php`
  - Compile the 'cpp', 'neko', and 'php' HxTF Targets.
  - Strip ANSI from output.
  - Exit without running tests.
- `hxtf -fq cpp_unstable hl_unstable`
  - Compile the 'cpp_unstable' and 'hl_unstable' HxTF Targets.
  - Force rerunning of all tests.
  - Don't block for user input if a test fails.
- `hxtf -r`
  1. Confirm that the user wants to delete all cache files.
  1. Delete all _&lt;target&gt;.cache_ files that also have a _&lt;target&gt;.hxml_ and _&lt;target&gt;.sh_ file, then exit.
- `hxtf -r neko_stable`
  - Delete the _neko\_stable.cache_ file and exit.
- `hxtf neko -zyn "*Math*" "*Complex*"`
  - Compile the 'neko' HxTF Target for all tests with type-paths that match `~/.*Math.*/` and don't match `~/.*Complex.*/`.
  - Don't cache successful tests.
- `hxtf hl cpp_optimized -fnywa \*Math\*:\*lambda\* \*proj.\*`
  - Compile the 'hl' and 'cpp_optimized' HxTF Targets.
  - Force rerunning of all tests.
  - Ignore all tests with type paths that match `~/.*Math.*/` or `~/.*lambda.*/`.
  - Only include tests with type paths that match `~/.*proj\..*/`.
  - Write Haxe compiler output to stdout.
  - Strip ANSI formatting from HxTF output.

> When a test is marked as "push" (`-y`), all other tests that are not marked as "push" will not be included in the Test Run.

> When a test is marked as "pull" (`-n`), that test will not be included in the Test Run.

> If a test is not included in the Test Run, references to it from `addCase()` functions in Test Brokers are removed. Without any references to the type, the Haxe compiler will ignore it an it won't be included in compilation of the Test Run.

> If a test is marked as "push" and "pull", the exclusion of that test will take precedence but the effects of a test being included will remain. Other tests not marked as "push" still won't be included.


Test Cases
----------

A Test Case has several assertion methods, all of which have an optional argument for a custom message to be printed if they fail.

Below is a simplified outline of the methods natively available to a Test Case:

| Method | Description |
| ------ | ----------- |
| `assert(x:Bool)` | Asserts that the given value `x` is `true`. |
| `assertF(x:Bool)` | Asserts that the given value `x` is not `true`. |
| `assertImplicit<T>(a:T, b:T)` | Asserts that the expression `a == b` yields `true`. |
| `assertExplicit<T>(x:T, f:T->Bool)` | Asserts that the expression `f(x)` yields `true`. |
| `assertSpecific<A, B>(a:A, b:B, f:A->B->Bool)` | Asserts that the expression `f(a, b)` yields `true`. |
| `assertUnreachable()` | Fails the Test Case if called. |
| `assertNull(v:Dynamic)` | Asserts that the given value `v` is `null`. |
| `assertNNull(v:Null<Dynamic>)` | Asserts that the given value `v` is not `null`. |
| `assertExcept(f:Void->Void, ?type:Dynamic)` | Asserts that running the given function `f` throws an exception, and, if `type` is specified, asserts that the exception is of type `type`. |
| `assertNExcept(f:Void->Void)` | Asserts that running the given function `f` does not throw an exception. |
| `assertFinite(v:Float)` | Asserts that the given Float `v` is a finite number (not `Math.POSITIVE_INFINITY`, `Math.NEGATIVE_INFINITY`, or `Math.NaN`). |
| `assertNaN(v:Float)` | Asserts that the given Float `v` is `Math.NaN`. |
| `assertNNaN(v:Float)` | Asserts that the given Float `v` is not `Math.NaN`. |
| `prompt(msg:String, printPos = false)` | Prompts the standard output stream with the message `msg`. |
| `softFail(msg:String, printPos = true)` | Prompts the standard error stream with the message `msg` and soft fails the Test Case. |
| `hardFail(msg:String, printPos = true)` | Prompts the standard error stream with the message `msg` and hard fails the Test Case. |

> A Test Case that has 'soft failed' will not be saved to the cache, but will also not be explicitly marked as a failure. Soft failures will be overridden by hard failures (a failed assertion results in a hard failure), which explicitly mark the test as failed as well as preventing it from being cached.

`hxtf.TestCase` instances also have a `@:noCompletion var _passed(default, never):Bool` field. This field is used internally to record if the Test Case has had a hard failure - modify during runtime at your own risk.


Exit Status
-----------

| Code | Description |
| ---- | ----------- |
| `0` | Normal program termination - all assertions passed. |
| `1` | Unexpected run-time error occurred in HxTF or haxelib. |
| `2` | At least one assertion for at least one target failed. |
| `3` | Unexpected run-time error occurred in a Test Run. |
| `4` | At least one Test Run failed to compile. |

Higher exit codes are prioritized over lower ones. If a Test Run fails to compile one Target and another Target has a run-time failure, code `4` will be returned by HxTF over code `3`.
