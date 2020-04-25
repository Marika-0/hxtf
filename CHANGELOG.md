Changelog
=========


2.0.1 (2020/02/22)
------------------

Printing and documentation fixes.

- Fixed the total printed testing time to the total time of all unit tests instead of the total time for everything after initializing `TestMain`.
- Fixed the printing of invalid CLI flags.
- Fixed the separator bar not being printed after failing to compile a test run.
- Fixed not having updated the "No tests were run" statement to align with new formatting.
- Fixed *many* documentation errors, and made a list of things to check before making a release so that hopefully there will be fewer errors in future.


2.0.0 (2020/02/12)
------------------

Multithreading and maximum assertion failure limits.

- Breaking changes:
  - Changed the `-q`/`--quick` flag to `-b`/`--block` and reversed it's function.
  - Removed `hxtf.TestBroker` and `hxtf.TestCase`, unit tests now extend `hxtf.TestObject` and are added with `hxtf.TestRun.addObject()`.
  - Changed hxtf-specific compile define names and values.
  - Changed the format of command-line printing during a test run.
- New Features:
  - Multithreading of unit tests available is with the `--max-threads` flag (only available on targets that support multithreading).
  - Individual unit tests will stop after reaching a maximum number of assertion failures available with the `--max-failures` flag.
  - When a test run begins, the HxTF version, Haxe compiler version, and the number of threads are printed to the command line.


1.2.1 (2019/09/17)
------------------

Printing and formatting fixes.

- Bug fixes:
  - Fixed invalid ANSI stripping regex (was causing compilation failure for Java).
  - Fixed Test Objects in the root package having their path incorrectly parsed.
  - Fixed Test Objects in the root package having their path incorrectly displayed.
- Improvements:
  - Now flushing stdout and stderr after writing to them.
- Meta changes:
  - Fixed a lot of documentation grammar.


1.2.0 (2019/08/29)
------------------

Integration and scripting improvements.

- API changes:
  - Added support for any flag starting with `"hxtf_push"` or `"hxtf_pull"` being interpreted as that flag.
  - Added exit status.
  - Added `-v` flag for printing version information.
  - Made `hxtf.TestCase._passed` write-accessible to inheriting classes.
- Internal changes:
  - Changed _\_.hxml_ file layout.
  - Made an project initialization `hxtf.Macro.buildVersion` that takes a string and populates the build version.
- Meta changes:
  - Updated documentation.
  - Changed project description.


1.1.0 (2019/07/24)
------------------

Usability and documentation improvements.

- API changes:
  - Added `--push` flag to CLI (equivalent to `-y`).
  - Added `--pull` flag to CLI (equivalent to `-n`).
  - Added `-l`/`--no-lib` flag to CLI (prevents automatic library inclusion).
- Internal changes:
  - Overhauled `hxtf.cli.Printer.run`.
  - Improved a lot of variable names.
  - Improved and added a lot of commenting.
- Meta changes:
  - Updated documentation.


1.0.0 (2019/07/21)
------------------

Initial release.
