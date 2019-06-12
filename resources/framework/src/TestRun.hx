package;

class TestRun extends hxtf.TestRun {
    static function main() {
        new TestRun();
    }

    function new() {
        add(suite.ExampleSuite);
    }
}
