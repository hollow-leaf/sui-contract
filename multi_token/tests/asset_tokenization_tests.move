#[test_only]
module multi_token::multi_token_tests {
    // uncomment this line to import the module
    // use asset_tokenization::asset_tokenization;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_multi_token() {
        // pass
    }

    #[test, expected_failure(abort_code = multi_token::multi_token_tests::ENotImplemented)]
    fun test_multi_token_fail() {
        abort ENotImplemented
    }
}
