#[test_only]
module sui_mover_lesson_3::lesson_3_tests {
    // uncomment this line to import the module
    // use lesson3::lesson3;

    const ENotImplemented: u64 = 0;

    #[test]
    fun test_lesson3() {
        // pass
    }

    #[test, expected_failure(abort_code = sui_mover_lesson_3::lesson_3_tests::ENotImplemented)]
    fun test_lesson3_fail() {
        abort ENotImplemented
    }
}
