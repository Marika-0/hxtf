package test;

class TestSuite extends TestObject {
    public function new() {
        addCase(test.ExampleTests);
        addSuite(test.example.TestSuite);
    }
}
