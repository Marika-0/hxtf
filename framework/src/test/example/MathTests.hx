package test.example;

class MathTests extends TestCase {
    public function new() {
        test_random();
        test_NaN();
    }

    function test_random() {
        for (_ in 0...1000000) {
            assert(Math.random() < 1);
        }
        assert(Math.random() < 0);
        assertExplicit(Math.random(), function(x) return x < 1);
        assertSpecific(Math.random(), 1, function(a, b) return a < b);
    }

    function test_NaN() {
        assert(Math.isNaN(Math.NaN));
        assertExplicit(Math.NaN, function(x) return Math.isNaN(x));

        throw("Uncaught exceptions will fail the test case.");
    }
}
