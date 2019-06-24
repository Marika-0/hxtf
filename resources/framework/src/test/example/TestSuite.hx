package test.example;

class TestSuite extends hxtf.TestSuite {
    function new() {
        super("Example Test Suite");

        add(test.example.ArrayTests);
        add(test.example.MathTests);
    }
}
