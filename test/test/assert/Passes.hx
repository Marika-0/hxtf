package assert;

class Passes extends hxtf.TestObject {
    public function new() {
        assert(true);
        assertF(false);
        assertImplicit(1, 1);
        assertExplicit(1, (n) -> n == 1);
        assertSpecific(1, 1, (a, b) -> a == b);
        assertNull(null);
        assertNNull(42);
        assertExcept(() -> throw 1);
        assertNExcept(() -> {});
    }
}
