package suite;

class ExampleSuite extends hxtf.TestSuite {
    public function new() {
        add(test.example.ArrayTests);
        add(test.example.MathTests);
    }
}
