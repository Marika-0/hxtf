// Convenience for extending test cases and objects.
import hxtf.TestCase;
import hxtf.TestObject;

// Something-or-other with macro's and derived classes. If these aren't imported
// then test object can't use them, so we just import them here to not need to
// import them in every test object file.
import hxtf.TestObject.addCase;
import hxtf.TestObject.addSuite;
