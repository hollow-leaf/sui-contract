#[test_only]
module member::member_tests {
    // uncomment this line to import the module
    // use member::member;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_member() {
        // pass
    }

    #[test, expected_failure(abort_code = ::member::member_tests::ENotImplemented)]
    fun test_member_fail() {
        abort ENotImplemented
    }
}
