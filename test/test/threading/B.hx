package threading;

class B {
    public function new() {
        addObject(Ba);
        addObject(Bb);
        addObject(Bc);
    }
}

class Ba {
    public function new() {
        addObject(Baa);
        addObject(Bba);
        addObject(Bca);
    }
}

class Baa extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bba extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bca extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bb {
    public function new() {
        addObject(Bab);
        addObject(Bbb);
        addObject(Bcb);
    }
}

class Bab extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bbb extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bcb extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bc {
    public function new() {
        addObject(Bac);
        addObject(Bbc);
        addObject(Bcc);
    }
}

class Bac extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bbc extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}

class Bcc extends hxtf.TestObject {
    public function new() {
        assert(Math.random() < 0.5);
    }
}
