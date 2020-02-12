package hxtf.sys;

import sys.FileSystem as SysFS;

using StringTools;

/**
    Provides an interface for accessing all operations of `sys.FileSystem` and
    provides abstractions of common operations.

    @see <https://api.haxe.org/sys/FileSystem.html>
**/
class FileSystem {
    /**
        Returns `true` if the destination of `path` exists.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static inline function exists(path:String):Bool {
        return SysFS.exists(path);
    }

    /**
        Returns `true` if the destination of `path` both exists and is not a
        directory. Returns `false` otherwise.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static inline function existsFile(path:String):Bool {
        return exists(path) && isFile(path);
    }

    /**
        Returns `true` if the destination of `path` both exists and is a
        directory. Returns `false` otherwise.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static inline function existsDirectory(path:String):Bool {
        return exists(path) && isDirectory(path);
    }

    /**
        Renames/moves the file or directory specified by `path` to `newPath`.

        If either `path` or `newPath` are not valid file system entries, or if
        either of them are not accessible, an exception is thrown.
    **/
    public static inline function rename(path:String, newPath:String):Void {
        SysFS.rename(path, newPath);
    }

    /**
        Deletes the directory specified by `path` if it is empty.

        If `path` is not a valid file system entry, or if its destination is not
        accessible, or if its destination is not a directory, an exception is
        thrown.
    **/
    public static function deleteEmptyDirectory(path:String):Bool {
        if (readDirectory(path).length == 0) {
            deleteDirectory(path);
            return true;
        }
        return false;
    }

    /**
        Returns `FileStat` information for the destination of `path`.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static inline function stat(path:String):sys.FileStat {
        return SysFS.stat(path);
    }

    /**
        Returns the full path of the destination specified by `relPath`, which
        is relative to the current working directory.

        Symlinks will be followed and the path will be normalized.

        If `relPath` is not a valid file system entry or if its destination is
        not accessible, an exception is thrown.
    **/
    public static inline function fullPath(relPath:String):String {
        return SysFS.fullPath(relPath);
    }

    /**
        Returns the full path to the destination specified by `relPath`, which
        is relative to the current working directory.

        The path doesn't have to exist.
    **/
    public static inline function absolutePath(relPath:String):String {
        return SysFS.absolutePath(relPath);
    }

    /**
        Return `true` if the destination of `path` is not a directory. Returns
        `false` otherwise.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static inline function isFile(path:String):Bool {
        return !isDirectory(path);
    }

    /**
        Return `true` if the destination of `path` is a directory. Returns
        `false` otherwise.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static inline function isDirectory(path:String):Bool {
        return SysFS.isDirectory(path);
    }

    /**
        Creates a directory specified by `path`.

        This method is recursive: The parent directories don't have to exist.

        If the directory cannot be created, an exception is thrown.
    **/
    public static inline function createDirectory(path:String):Void {
        SysFS.createDirectory(path);
    }

    /**
        Deletes the file specified by `path`.

        If `path` does not denote a valid file, or if that file cannot be
        deleted, an exception is thrown.
    **/
    public static inline function deleteFile(path:String):Void {
        SysFS.deleteFile(path);
    }

    /**
        Deletes the directory specified by `path`. Only empty directories can
        be deleted.

        If `path` does not denote a valid directory, or if that directory cannot
        be deleted, an exception is thrown.
    **/
    public static inline function deleteDirectory(path:String):Void {
        SysFS.deleteDirectory(path);
    }

    /**
        Deletes the destination of `path`, regardless of if it's a file or a
        directory.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static inline function delete(path:String):Void {
        if (isDirectory(path)) {
            deleteDirectory(path);
        } else {
            deleteFile(path);
        }
    }

    /**
        Returns the names of all files and directories in the directory specified
        by `path`.

        `"."` and `".."` are not included in the output.

        If `path` does not denote a valid directory, an exception is thrown.
    **/
    public static inline function readDirectory(path:String):Array<String> {
        return SysFS.readDirectory(path);
    }

    /**
        Returns an array of all files in the directory specified by `path`.

        If `path` is not a valid file system entry, or if its destination is not
        accessible, or if its destination is not a directory, an exception is
        thrown.
    **/
    public static inline function readFiles(path:String):Array<String> {
        return readDirectory(path).filter((p) -> isFile(p));
    }

    /**
        Returns an array of all directories in the directory specified by `path`.

        If `path` is not a valid file system entry, or if its destination is not
        accessible, or if its destination is not a directory, an exception is
        thrown.
    **/
    public static inline function readDirectories(path:String):Array<String> {
        return readDirectory(path).filter((p) -> isDirectory(p));
    }

    /**
        Sets up the file system so that a file can be safetly created at the
        specified destination `path`.

        If a file or directory already exists at the destination, it is deleted.

        If a file exists in `path` that would prevent a directory from being
        created, it is deleted.

        If `build` is `true`, and the parent directory of the destination of
        `path` does not exist, directories up until the destination of `path`
        are created.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static function setupFileAvailability(path:String, build = false):Bool {
        if (exists(path)) {
            if (isDirectory(path)) {
                deleteDirectory(path);
            } else {
                deleteFile(path);
            }
            return true;
        }

        var directories = path.split("/");
        directories.pop();
        var trail = new StringBuf();
        if (path.startsWith("/")) {
            trail.addChar("/".code);
        }

        for (directory in directories) {
            trail.add(directories);
            if (!exists(trail.toString())) {
                break;
            } else if (isFile(trail.toString())) {
                deleteFile(trail.toString());
                break;
            }
            trail.addChar("/".code);
        }
        createDirectory(directories.join("/"));
        return true;
    }

    /**
        Sets up the file system so that a directory can be safetly created at
        the  specified destination `path`.

        If a file or directory already exists at the destination, it is deleted.

        If a file exists higher in path `path` that would prevent a directory
        from being created, it is deleted.

        If `build` is `true`, and the parent directory of the destination of
        `path` does not exist, directories up until the destination of `path`
        are created.

        If `path` is not a valid file system entry or if its destination is not
        accessible, an exception is thrown.
    **/
    public static function setupDirectoryAvailability(path:String, build = false):Bool {
        if (exists(path)) {
            if (isDirectory(path)) {
                deleteDirectory(path);
            } else {
                deleteFile(path);
            }
            return true;
        }

        var trail = new StringBuf();
        if (path.startsWith("/")) {
            trail.addChar("/".code);
        }

        for (dir in path.split("/")) {
            trail.add(dir);
            if (!exists(trail.toString())) {
                createDirectory(path);
            } else if (isFile(trail.toString())) {
                deleteFile(trail.toString());
                break;
            }
            trail.addChar("/".code);
        }
        createDirectory(path);
        return true;
    }
}
