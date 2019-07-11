package test.example;

class TestSuite extends TestObject {
    public function new() {
        addCase(test.example.ArrayTests);
        addCase(test.example.MathTests);
    }
}
