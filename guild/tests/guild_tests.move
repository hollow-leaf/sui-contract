#[test_only]
module guild::guild_tests {
    // uncomment this line to import the module
    // use guild::guild;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_guild() {
        // pass
    }

    #[test, expected_failure(abort_code = ::guild::guild_tests::ENotImplemented)]
    fun test_guild_fail() {
        abort ENotImplemented
    }
}
