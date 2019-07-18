package test;

class TestSuite extends TestBroker {
    public function new() {
        addCase(test.ExampleTests);
        addSuite(test.example.TestSuite);
    }
}
