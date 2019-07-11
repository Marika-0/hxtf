package test.example;

class ArrayTests extends TestCase {
    public function new() {
        test_length();
        test_delayTimeABit();
    }

    function test_length() {
        var a = new Array<Int>();
        assert(a.length == 0);
        assertImplicit(a.length, 0);
        assertExplicit(a.length, function(x) return x == 0);
        assertSpecific(a.length, 0, function(a, b) return a == b);
    }

    function test_delayTimeABit() {
        for (_ in 0...10000) {
            assert(true);
        }
    }
}
