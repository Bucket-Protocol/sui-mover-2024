module sui_mover_exercise_3::exercise_3 {

    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui_mover_kapy::kapy::{Kapy};
    use sui_mover_kapy::orange::{Self, Orange};
    use sui_mover_kapy::config::{Config};

    const ORANGE_KIND: u8 = 3;
    const NORMAL_PRICE: u64 = 1_000_000;

    const EPaymentNotEnough: u64 = 0;
    fun err_payment_not_enough() { abort EPaymentNotEnough }

    // Witness

    public struct SuiMoverExercise3 has drop {}

    // Objects

    public struct OrangeStore has key {
        id: UID,
        treasury: Balance<SUI>,
    }

    // Hot Potato

    public struct PaymentInfo {
        price: u64,
    }

    // Constructor

    fun init(ctx: &mut TxContext) {
        let store = OrangeStore {
            id: object::new(ctx),
            treasury: balance::zero(),
        };
        transfer::share_object(store);
    }

    // Public Funs

    public fun buy(): PaymentInfo {
        PaymentInfo { price: NORMAL_PRICE }
    }

    public fun buy_with_kapy(kapy: &Kapy): PaymentInfo {
        let kapy_level = kapy.level() as u64;
        let price = NORMAL_PRICE * (10 - kapy_level) / 10;
        PaymentInfo { price }
    }

    public fun buy_with_orange(orange: &Orange): PaymentInfo {
        let orange_kind = orange.kind() as u64;
        let price = NORMAL_PRICE * (10 - orange_kind) / 10;
        PaymentInfo { price }
    }

    public fun pay(
        store: &mut OrangeStore,
        config: &Config,
        info: PaymentInfo,
        payment: Coin<SUI>,
        ctx: &mut TxContext,
    ): Orange {
        let PaymentInfo { price } = info;
        if (payment.value() < price) err_payment_not_enough();
        coin::put(&mut store.treasury, payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }

    // bad examples

    public fun direct_buy(
        store: &mut OrangeStore,
        config: &Config,
        payment: Coin<SUI>,
        ctx: &mut TxContext,
    ): Orange {
        if (payment.value() < NORMAL_PRICE) err_payment_not_enough();
        coin::put(&mut store.treasury, payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }

    public fun direct_buy_with_kapy(
        store: &mut OrangeStore,
        config: &Config,
        kapy: &Kapy,
        payment: Coin<SUI>,
        ctx: &mut TxContext,
    ): Orange {
        let kapy_level = kapy.level() as u64;
        let price = NORMAL_PRICE * (10 - kapy_level) / 10;
        if (payment.value() < price) err_payment_not_enough();
        coin::put(&mut store.treasury, payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }


    public fun direct_buy_with_orange(
        store: &mut OrangeStore,
        config: &Config,
        orange: &Orange,
        payment: Coin<SUI>,
        ctx: &mut TxContext,
    ): Orange {
        let orange_kind = orange.kind() as u64;
        let price = NORMAL_PRICE * (10 - orange_kind) / 10;
        if (payment.value() < price) err_payment_not_enough();
        coin::put(&mut store.treasury, payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }

    public fun orange_kind(): u8 { ORANGE_KIND }
}
