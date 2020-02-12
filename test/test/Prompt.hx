package;

class Prompt extends hxtf.TestObject {
    public function new() {
        for (i in 0...5) {
            Sys.sleep(1 / 9);
            prompt(Std.string(Std.int(Math.random() * 256)));
        }
    }
}
