module sui_mover_lesson_1::lesson_1 {

    use std::string::{String, utf8};

    fun hello_world_bytes(): vector<u8> {
        b"hello world"
    }

    public fun hello_world(): String {
        let bytes = hello_world_bytes();
        utf8(bytes)
    }

    public fun sum(a: u64, b: u64): u64 {
        a + b
    }

    public fun try_borrow(vec: &vector<u64>, i: u64): Option<u64> {
        let vec_len = vec.length();
        if (vec_len > i) {
            option::some(*vec.borrow(i))
        } else {
            option::none()
        }
    }

    #[test_only]
    public fun numbers(): vector<u64> { vector[1, 2, 3] }
}
