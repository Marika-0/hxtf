package test;

class ExampleTests extends TestCase {
    public function new() {
        assert(true);
        assertF(false);
        assertImplicit(42, 42);
        assertExplicit(0, function(x) return x == 0);
        assertSpecific(42, 42, function(a, b) return a == b);
        if (Math.random() == 1) {
            assertUnreachable();
        }
        assertNull(null);
        assertNNull(42);
        assertExcept(function() throw 42);
        assertExcept(function() throw 42, Int);
        assertNExcept(function() assert(true));
        assertFinite(42);
        assertNaN(Math.NaN);
        assertNNaN(42);
        assertNNaN(Math.POSITIVE_INFINITY);
        assertNNaN(Math.NEGATIVE_INFINITY);
        softFail("Soft failure message - won't fail test case");
        hardFail("Hard failure message - will fail test case");
    }
}
