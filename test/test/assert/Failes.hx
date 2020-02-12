package assert;

class Failes extends hxtf.TestObject {
    public function new() {
        assert(false);
        assertF(true);
        assertImplicit(1, 2);
        assertExplicit(1, (n) -> n == 2);
        assertSpecific(1, 2, (a, b) -> a == b);
        assertNull(42);
        assertNNull(null);
        assertExcept(() -> {});
        assertNExcept(() -> throw 1);
    }
}
