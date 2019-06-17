package;

import hxtf.TestMain.add;

/**
    This is the main runner for tests.
**/
class TestMain extends hxtf.TestMain {
    function new() {
        add(suite.ExampleSuite);
    }
}
