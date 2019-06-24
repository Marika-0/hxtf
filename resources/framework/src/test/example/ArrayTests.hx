package test.example;

class ArrayTests extends hxtf.TestCase {
    function new() {
        super("Example Array Tests");
        test_length();
    }

    function test_length() {
        var a = new Array<Int>();
        assert(a.length == 0);
        assertImplicit(a.length, 0);
        assertExplicit(a.length, function(x) return x == 0);
        assertSpecific(a.length, 0, function(a, b) return a == b);
    }
}
