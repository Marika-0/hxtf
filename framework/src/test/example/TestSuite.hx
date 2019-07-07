package test.example;

class TestSuite extends hxtf.TestSuite {
    public function new() {
        add(test.example.ArrayTests);
        add(test.example.MathTests);
    }
}
