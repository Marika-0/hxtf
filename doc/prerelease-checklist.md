Pre-Release Checklist
=====================

A list of things to make sure of before making a release.

1. Make sure that things work for every target.
1. Make sure that `README.md` is formatted properly. Check there's an empty line before and after tables (future me, if you forget why I said to do this, just do it - some flavourings of markdown won't create a table if there isn't an empty line above it, and without an empty line after it the next paragraph can get merged into a new row of the table), and that there aren't any nested dot points (again, future me, just do it - not all flavourings support nested lists and it looks really bad).
1. Read through the pushed `README.md` on the github page. Check that all the links work, all the tables are formatted properly, html characters have been escaped, etc.
1. Make sure that all instances of the previous release tag have been changed to the new release tag. This includes in build scripts, in places where the current version is printed to the command line, and in `haxelib.json`.
1. Make sure that `CHANDELOG.md` has been updated appropriately for the changes in this release.
1. Make sure that the `releasenote` entry in `haxelib.json` has been given a short descriptor for the changes in this release.
1. Make sure that `LICENSE.md` has had the copyright year-range updated.
