- If, after installing HashLink, when running `hl` the error `hl: error while loading shared libraries: libhl.so: cannot open shared object file: No such file or directory` appears:
    1. Do a filesystem search for `libhl.so` and record the directory it's in.
    1. Check to see if the environment variable `LD_LIBRARY_PATH` already contains the recorded directory.
        - If it does, this won't help - try something else.
    1. Otherwise, add `export LD_LIBRARY_PATH="<dir>:$LD_LIBRARY_PATH"` (where `<dir>` is the recorded directory) to the end of the `~/.bashrc` file (or somewhere else appropriate).
