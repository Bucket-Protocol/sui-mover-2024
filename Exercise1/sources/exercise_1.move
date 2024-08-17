module sui_mover_exercise_1::exercise_1 {

    // Dependencies

    use std::string::{String};
    use sui_mover_kapy::config::{Config};
    use sui_mover_kapy::kapy::{Kapy};
    use sui_mover_kapy::orange;

    // Constants

    const MIN_USER_NAME_LENGTH: u64 = 3;
    const MAX_USER_NAME_LENGTH: u64 = 16;

    // Errors

    const EUsernameTooShort: u64 = 1;
    fun err_username_too_short() { abort EUsernameTooShort }
    
    const EUsernameTooLong: u64 = 2;
    fun err_username_too_long() { abort EUsernameTooLong }

    const EUsernameNotAllLettersOrNumbers: u64 = 3;
    fun err_username_not_all_letters_or_numbers() { abort EUsernameNotAllLettersOrNumbers }

    const EWrongAnswerOne: u64 = 4;
    fun err_wrong_answer_one() { abort EWrongAnswerOne }

    const EWrongAnswerTwo: u64 = 5;
    fun err_wrong_answer_two() { abort EWrongAnswerTwo }

    // Witness

    public struct SuiMoverExercise1 has drop {}

    // Public Funs

    public fun solve(
        config: &Config,
        kapy: &mut Kapy,
        username: String,
        answer_1: u64,
        answer_2: bool,
        ctx: &mut TxContext,
    ) {
        // check 1
        if (username.length() < MIN_USER_NAME_LENGTH) err_username_too_short();

        // check 2
        if (username.length() > MAX_USER_NAME_LENGTH) err_username_too_long();

        // check 3
        if (!is_all_letters(&username))
            err_username_not_all_letters_or_numbers();

        // check 4
        let kapy_index_u64 = kapy.index() as u64;
        let lucky_number = (kapy_index_u64 * 618 + 3140) / kapy_index_u64;
        if (answer_1 != lucky_number) err_wrong_answer_one();
        
        // check 5
        let index_is_even = kapy.index() % 2 == 0;
        if (answer_2 != index_is_even) err_wrong_answer_two();

        // update username
        kapy.update_username(username);

        // carry an orange if pass all checks
        let orange = orange::mint(
            config,
            1,
            SuiMoverExercise1 {},
            ctx,
        );
        kapy.carry(orange);
    }

    // Internal Funs

    fun is_letter_or_number(code: u8): bool {
        (code >= 65 && code < 65 + 26) || // range of uppercase letters
        (code >= 97 && code < 97 + 26) || // range of lowercase letters
        (code >= 48 && code < 48 + 10)    // range of numbers
    }

    fun is_all_letters(string: &String): bool {
        let string_len = string.length();
        let string_bytes = string.as_bytes();
        let mut idx = 0;
        while(idx < string_len) {
            let char_ascii_code = *string_bytes.borrow(idx);
            if (!is_letter_or_number(char_ascii_code)) {
                return false
            };
            idx = idx + 1;
        };
        true
    }

}
