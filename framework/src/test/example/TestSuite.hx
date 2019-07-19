package test.example;

class TestSuite extends TestBroker {
    public function new() {
        addTest(test.example.ArrayTests);
        addTest(test.example.MathTests);
    }
}
