// Convenience for extending test cases and distributors.
import hxtf.TestCase;
import hxtf.TestBroker;

// Something-or-other with macro's and derived classes. If these aren't imported
// then test object can't use them, so we just import them here to not need to
// import them in every test object file.
import hxtf.TestBroker.addCase;
import hxtf.TestBroker.addSuite;
