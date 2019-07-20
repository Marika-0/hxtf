## Help information and troubleshooting for development crud that happens.
---

If the following errror appears when trying to run HashLink:

> `hl: error while loading shared libraries: libhl.so: cannot open shared object file: No such file or directory`

1. Do a filesystem search for `libhl.so` and record the directory it's in.
1. Check to see if the environment variable `LD_LIBRARY_PATH` already contains the recorded directory.
    - If it does, this won't help - try something else.
1. Otherwise, add `export LD_LIBRARY_PATH="<dir>:$LD_LIBRARY_PATH"` (where `<dir>` is the recorded directory) to the end of the `~/.bashrc` file (or somewhere else appropriate).
1. If things still don't work, figure something else out and append your steps here.

---

If the following error appears when trying to run PHP:

> `PHP Fatal error:  Uncaught Error: Call to undefined function php\mb_internal_encoding() in <position>`

1. Check to see that the package `php-mbstring` has been installed on your system.
    - If not, install it and try again.
1. If that package is installed or installing it didn't help, keep it installed and find a `php.ini` file in you're system.
1. Search for `extension=mbstring` (should be in the Dynamic Extensions) section and remove preceeding semicolon(s).
    - If `extension=mbstring` can't be found, navigate to the Dynamic Extensions section and add it to a new line somewhere.
1. If things still don't work, figure something else out and append your steps here.

More information can be found [here](https://stackoverflow.com/questions/1216274/unable-to-call-the-built-in-mb-internal-encoding-method).

---
