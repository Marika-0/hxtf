package hxtf.sys;

import sys.FileSystem.*;

/**
    This class abstracts common filesystem operations to make other code cleaner
    and less error-prone.
**/
class FSManager extends sys.FileSystem {
    /**
        Returns if a file exists at the given path and the file is not a
        directory.
    **/
    public static function doesFileExist(path:String):Bool {
        return exists(path) && !isDirectory(path);
    }

    /**
        Returns if a file exists at the given path and the file is a directory.
    **/
    public static function doesDirectoryExist(path:String):Bool {
        return exists(path) && isDirectory(path);
    }

    /**
        Ensures that a file can be created at the given path, by deleting
        anything that exists there already, and anything in the file path that
        would prevent a directory from being created.

        ensuring the availability of `"my/dir.f/File.txt"` would delete the file
        `"my/dir.f"` if it exists.

        If the path cannot be made available, returns false, otherwise returns
        true.
    **/
    public static function ensureFileAvailability(path:String):Bool {
        try {
            if (exists(path)) {
                if (isDirectory(path)) {
                    deleteDirectory(path);
                }
                return true;
            }

            var dirs = path.split("/");
            dirs.pop();
            var trail = new StringBuf();

            for (dir in dirs) {
                trail.add(dir + "/");
                if (!exists(trail.toString())) {
                    break;
                } else if (!isDirectory(trail.toString())) {
                    deleteFile(trail.toString());
                    break;
                }
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }

    /**
        Similar to `ensureFileAvailability`, but also creates the directory at
        the given position if it can.
    **/
    public static function ensureDirectoryAvailability(path:String):Bool {
        try {
            if (exists(path)) {
                if (!isDirectory(path)) {
                    deleteFile(path);
                }

                createDirectory(path);
                return true;
            }

            var trail = new StringBuf();
            for (dir in path.split("/")) {
                trail.add(dir + "/");
                if (!exists(trail.toString())) {
                    break;
                } else if (!isDirectory(trail.toString())) {
                    deleteFile(trail.toString());
                    break;
                }
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }

    /**
        Deletes the object (file or directory) at the given path.

        Returns `false` if this failed or the object did not exist, otherwise
        returns `true`.
    **/
    public static function delete(path:String):Bool {
        try {
            if (!exists(path)) {
                return false;
            }

            if (isDirectory(path)) {
                deleteDirectory(path);
            } else {
                deleteFile(path);
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }

    /**
        Deletes the directory at the given path if it is empty.

        Returns `true` if a directory was deleted, returns `false` otherwise.
    **/
    public static function deleteIfEmpty(path:String):Bool {
        try {
            if (!exists(path)) {
                return false;
            }

            if (isDirectory(path)) {
                if (readDirectory(path).length != 0) {
                    deleteDirectory(path);
                }
            } else {
                if (stat(path).size == 0) {
                    deleteFile(path);
                }
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }

    /**
        Returns an array of all files at the specified path `path`.

        If the directory specified by `path` does not exist, `null` is returned.

        `path` is not prepended to to output file names.
    **/
    public static function readFiles(path:String):Array<String> {
        if (!doesDirectoryExist(path)) {
            return null;
        }
        return readDirectory(path).filter(function(p) return !isDirectory(p));
    }
}
