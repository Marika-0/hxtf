Changelog
=========


1.2.0 (YYYY/mm/dd)
------------------

Integration and scripting improvements.

- API changes:
  - Added support for any flag starting with `"hxtf_push"` or `"hxtf_pull"` being interpreted as that flag.
  - Added exit status.
  - Added `-v` flag for printing version information.
  - Made `hxtf.TestCase._passed` write-accessible to inheriting classes.
- Internal changes:
  - Changed _\_.hxml_ file layout.
- Meta changes:
  - Updated documentation.

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
