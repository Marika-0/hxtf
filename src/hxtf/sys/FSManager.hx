package hxtf.sys;

import sys.FileSystem.*;
import sys.io.File;

class FSManager extends sys.FileSystem {
    public static function doesFileExist(path:String) {
        return exists(path) && !isDirectory(path);
    }

    public static function doesDirectoryExist(path:String) {
        return exists(path) && isDirectory(path);
    }

    public static function ensureFileAvailability(path:String) {
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
                }
                else if (!isDirectory(trail.toString())) {
                    deleteFile(trail.toString());
                    break;
                }
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }

    public static function ensureDirectoryAvailability(path:String) {
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
                }
                else if (!isDirectory(trail.toString())) {
                    deleteFile(trail.toString());
                    break;
                }
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }

    public static function delete(path:String) {
        try {
            if (!exists(path)) {
                return false;
            }

            if (isDirectory(path)) {
                deleteDirectory(path);
            }
            else {
                deleteFile(path);
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }

    public static function deleteIfEmpty(path:String) {
        try {
            if (!exists(path)) {
                return false;
            }

            if (isDirectory(path)) {
                if (readDirectory(path).length != 0) {
                    deleteDirectory(path);
                }
            }
            else {
                if (stat(path).size == 0) {
                    deleteFile(path);
                }
            }
            return true;
        } catch (ex:Dynamic) {
            return false;
        }
    }
}
