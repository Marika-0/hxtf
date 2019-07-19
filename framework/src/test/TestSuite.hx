package test;

class TestSuite extends TestBroker {
    public function new() {
        addTest(test.ExampleTests);
        addBroker(test.example.TestSuite);
    }
}
