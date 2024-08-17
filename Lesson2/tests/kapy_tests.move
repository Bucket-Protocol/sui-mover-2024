#[test_only]
module sui_mover_kapy::kapy_tests {

    use std::string::utf8;
    use sui::test_scenario::{Self as ts, Scenario};
    use sui_mover_kapy::config::{Self, AdminCap};
    use sui_mover_kapy::kapy::{Self, MintCap, Kapy};
    use sui_mover_kapy::orange::{Self, Orange};

    public fun admin(): address { @0xad }
    public fun user_0(): address { @0x100 }
    public fun user_1(): address { @0x101 }

    #[test]
    fun test_kapy(): Scenario {
        let mut scenario = ts::begin(admin());
        let s = &mut scenario;
        {
            kapy::init_for_testing(ts::ctx(s));
            config::init_for_testing(ts::ctx(s));
        };

        // mint 2 kapies
        ts::next_tx(s, admin());
        {
            let mut mint_cap = ts::take_from_sender<MintCap>(s);
            let admin_cap = ts::take_from_sender<AdminCap>(s);

            // mint and check kapy_0
            let kapy_0 = kapy::mint(&mut mint_cap, ts::ctx(s));            // check kapy_0
            assert!(kapy_0.index() == 1);
            assert!(kapy_0.username() == utf8(b""));
            assert!(kapy_0.level() == 0);
            transfer::public_transfer(kapy_0, user_0());
            assert!(mint_cap.supply() == 1);
            
            // mint and check kapy_1
            let mut kapy_1 = kapy::mint(&mut mint_cap, ts::ctx(s));
            kapy_1.update_username(utf8(b"justa"));
            assert!(kapy_1.index() == 2);
            assert!(kapy_1.username() == utf8(b"justa"));
            assert!(kapy_1.level() == 0);
            transfer::public_transfer(kapy_1, user_1());
            assert!(mint_cap.supply() == 2);
            
            // mint oranges to user_0
            let orange_0 = orange::mint_by_admin(&admin_cap, 0, ts::ctx(s));
            assert!(orange_0.kind() == 0);
            transfer::public_transfer(orange_0, user_0());
            let orange_1 = orange::mint_by_admin(&admin_cap, 1, ts::ctx(s));
            assert!(orange_1.kind() == 1);
            transfer::public_transfer(orange_1, user_0());

            // mint oranges to user_1
            let orange_0 = orange::mint_by_admin(&admin_cap, 2, ts::ctx(s));
            assert!(orange_0.kind() == 2);
            transfer::public_transfer(orange_0, user_1());
            let orange_0 = orange::mint_by_admin(&admin_cap, 2, ts::ctx(s));
            assert!(orange_0.kind() == 2);
            transfer::public_transfer(orange_0, user_1());

            ts::return_to_sender(s, mint_cap);
            ts::return_to_sender(s, admin_cap);
        };

        ts::next_tx(s, user_0());
        {
            let mut kapy_0 = ts::take_from_sender<Kapy>(s);
            let orange = ts::take_from_sender<Orange>(s);
            kapy_0.carry(orange);
            assert!(kapy_0.level() == 1);
            let orange = ts::take_from_sender<Orange>(s);
            kapy_0.carry(orange);
            assert!(kapy_0.level() == 2);
            ts::return_to_sender(s, kapy_0);
        };

        scenario
    }

    #[test, expected_failure(abort_code = sui_mover_kapy::kapy::ECarrySameKindOfOrange)]
    fun test_carry_orange_fail(): Scenario {
        let mut scenario = test_kapy();
        let s = &mut scenario;

        ts::next_tx(s, user_1());
        {
            let mut kapy_1 = ts::take_from_sender<Kapy>(s);
            let orange = ts::take_from_sender<Orange>(s);
            kapy_1.carry(orange);
            assert!(kapy_1.level() == 1);
            let orange = ts::take_from_sender<Orange>(s);
            kapy_1.carry(orange);
            assert!(kapy_1.level() == 2);
            ts::return_to_sender(s, kapy_1);
        };

        scenario
    }
}
