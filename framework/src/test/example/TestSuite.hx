package test.example;

class TestSuite extends TestBroker {
    public function new() {
        addCase(test.example.ArrayTests);
        addCase(test.example.MathTests);
    }
}
