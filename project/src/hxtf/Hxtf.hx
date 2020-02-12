package hxtf;

import hxtf.cli.Initialise;
import hxtf.sys.FileSystem;

/**
    Main class for HxTF.
**/
class Hxtf {
    static function main():Void {
        Initialise.run();
        Driver.handleInitialisation();
        Driver.handleTestRuns();
        Exit.exit();
    }
}
