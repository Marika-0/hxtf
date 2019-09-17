Changelog
=========


1.2.1 (YYYY/MM/DD)
------------------

Fixes and stability improvements.

- Bug fixes:
  - Fixed invalid ANSI stripping regex (was causing compilation failure for Java).
  - Fixed Test Objects in the root package having their path incorrectly parsed.
  - Fixed Test Objects in the root package having their path incorrectly displayed.


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
