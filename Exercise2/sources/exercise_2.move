module sui_mover_exercise_2::exercise_2 {

    // Dependencies

    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui_mover_kapy::config::{Config};
    use sui_mover_kapy::orange::{Self, Orange};
    use sui_mover_kapy::kapy::{Kapy};

    // Constants

    const ORANGE_KIND: u8 = 2;
    const ORANGE_BASIC_PRICE: u64 = 1_000;

    // Errors

    const EKapyAlreadyHasOrange: u64 = 1;
    fun err_kapy_already_has_orange() { abort EKapyAlreadyHasOrange }
    
    const EPaymentNotEnough: u64 = 2;
    fun err_payment_not_enough() { abort EPaymentNotEnough }

    // Witness

    public struct SuiMoverExercise2 has drop {}

    // Objects 

    public struct OrangeStore has key {
        id: UID,
        treasury: Balance<SUI>,
    }

    // Capabilities 

    public struct WithdrawCap has key, store {
        id: UID,
    }

    // Constructor

    fun init(ctx: &mut TxContext) {
        let config = OrangeStore {
            id: object::new(ctx),
            treasury: balance::zero(),
        };
        transfer::share_object(config);

        let cap = WithdrawCap {
            id: object::new(ctx),
        };
        transfer::transfer(cap, ctx.sender());
    }

    // Public Funs

    public fun buy(
        store: &mut OrangeStore,
        config: &Config,
        kapy: &Kapy,
        payment: Coin<SUI>,
        ctx: &mut TxContext,
    ): Orange {

        // check 1
        if (kapy.belongings().contains(&orange_kind()))
            err_kapy_already_has_orange();

        // check 2
        if (payment.value() < ORANGE_BASIC_PRICE + (kapy.index() as u64))
            err_payment_not_enough();

        // put payment into treasury
        coin::put(&mut store.treasury, payment);

        // output an orange (kind: 2)
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise2 {},
            ctx,
        )
    }

    entry fun buy_to(
        store: &mut OrangeStore,
        config: &Config,
        kapy: &Kapy,
        payment: Coin<SUI>,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let orange = store.buy(
            config,
            kapy,
            payment,
            ctx,
        );
        transfer::public_transfer(orange, recipient);
    }

    // Admin Funs

    public fun withdraw(
        _cap: &WithdrawCap,
        store: &mut OrangeStore,
        ctx: &mut TxContext,
    ): Coin<SUI> {
        coin::from_balance(store.treasury.withdraw_all(), ctx)
    }

    entry fun withdraw_to(
        cap: &WithdrawCap,
        store: &mut OrangeStore,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        transfer::public_transfer(
            withdraw(cap, store, ctx),
            recipient,
        );
    }

    // Getter Funs

    public fun orange_kind(): u8 { ORANGE_KIND }

    public fun basic_price(): u64 { ORANGE_BASIC_PRICE }

    public fun treasury_value(store: &OrangeStore): u64 {
        store.treasury.value()
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }
}
