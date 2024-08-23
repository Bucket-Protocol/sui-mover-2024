module sui_mover_exercise_3::exercise_3 {

    // Dependencies

    use std::type_name::{Self, TypeName};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::dynamic_field as df;
    use sui_mover_kapy::kapy::{Kapy};
    use sui_mover_kapy::orange::{Self, Orange};
    use sui_mover_kapy::config::{Config};

    // Constants

    const ORANGE_KIND: u8 = 3;

    // Errors

    const EPaymentNotEnough: u64 = 0;
    fun err_payment_not_enough() { abort EPaymentNotEnough }

    const ETreasuryTypeAlreadyExists: u64 = 1;
    fun err_treasury_type_already_exists() { abort ETreasuryTypeAlreadyExists }

    const ETreasuryTypeNotExists: u64 = 2;
    fun err_treasury_type_not_exists() { abort ETreasuryTypeNotExists }

    // Witness

    public struct SuiMoverExercise3 has drop {}

    // Objects

    public struct OrangeStore has key {
        id: UID,
    }

    // DF Contents

    public struct Treasury<phantom T> has store {
        normal_price: u64,
        balance: Balance<T>,
    }

    // Capability

    public struct KeeperCap has key, store {
        id: UID,
    }

    // Hot Potato

    public struct DiscountVoucher {
        discount: u64,
    }

    // Constructor

    fun init(ctx: &mut TxContext) {
        let store = OrangeStore { id: object::new(ctx) };
        transfer::share_object(store);
        
        let cap = KeeperCap { id: object::new(ctx) };
        transfer::transfer(cap, ctx.sender());
    }

    // Public Funs

    public fun buy(): DiscountVoucher {
        DiscountVoucher { discount: 0 }
    }

    public fun buy_with_kapy(kapy: &Kapy): DiscountVoucher {
        DiscountVoucher { discount: (kapy.level() as u64) }
    }

    public fun buy_with_orange(orange: &Orange): DiscountVoucher {
        DiscountVoucher { discount: (orange.kind() as u64) }
    }

    public fun pay<T>(
        store: &mut OrangeStore,
        config: &Config,
        voucher: DiscountVoucher,
        payment: Coin<T>,
        ctx: &mut TxContext,
    ): Orange {
        let DiscountVoucher { discount } = voucher;
        let price = store.normal_price<T>() * (10 - discount) / 10;
        if (payment.value() < price) err_payment_not_enough();
        store.put_into_treasury(payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }

    // Admin Funs

    public fun create_treasury<T>(
        store: &mut OrangeStore,
        _: &KeeperCap,
        normal_price: u64,
    ) {
        let treasury_type = type_name::get<T>();
        if (df::exists_with_type<TypeName, Treasury<T>>(&store.id, treasury_type))
            err_treasury_type_already_exists();
        let treasury = Treasury<T> { normal_price, balance: balance::zero() };
        df::add(&mut store.id, treasury_type, treasury);
    }

    public fun remove_treasury<T>(
        store: &mut OrangeStore,
        _: &KeeperCap,
    ): Balance<T> {
        let treasury_type = type_name::get<T>();
        if (!df::exists_with_type<TypeName, Treasury<T>>(&store.id, treasury_type))
            err_treasury_type_not_exists();
        let treasury = df::remove<TypeName, Treasury<T>>(&mut store.id, treasury_type);
        let Treasury<T> { normal_price: _, balance } = treasury;
        balance
    }

    public fun update_normal_price<T>(
        store: &mut OrangeStore,
        _: &KeeperCap,
        normal_price: u64,
    ) {
        let treasury = store.borrow_treasury_mut<T>();
        treasury.normal_price = normal_price
    }

    // Getter Funs

    public fun orange_kind(): u8 { ORANGE_KIND }

    public fun normal_price<T>(store: &OrangeStore): u64 {
        borrow_treasury<T>(store).normal_price
    }

    public fun treasury_balance<T>(store: &OrangeStore): u64 {
        borrow_treasury<T>(store).balance.value()
    }

    public fun discount(voucher: &DiscountVoucher): u64 {
        voucher.discount
    }

    // Internal Funs

    fun borrow_treasury<T>(store: &OrangeStore): &Treasury<T> {
        let treasury_type = type_name::get<T>();
        if (!df::exists_with_type<TypeName, Treasury<T>>(&store.id, treasury_type))
            err_treasury_type_not_exists();
        df::borrow(&store.id, treasury_type)
    }

    fun borrow_treasury_mut<T>(store: &mut OrangeStore): &mut Treasury<T> {
        let treasury_type = type_name::get<T>();
        if (!df::exists_with_type<TypeName, Treasury<T>>(&store.id, treasury_type))
            err_treasury_type_not_exists();
        df::borrow_mut(&mut store.id, treasury_type)
    }

    fun put_into_treasury<T>(store: &mut OrangeStore, coin: Coin<T>) {
        coin::put(&mut store.borrow_treasury_mut().balance, coin)
    }

    // bad examples

    public fun direct_buy<T>(
        store: &mut OrangeStore,
        config: &Config,
        payment: Coin<T>,
        ctx: &mut TxContext,
    ): Orange {
        if (payment.value() < store.normal_price<T>()) err_payment_not_enough();
        store.put_into_treasury(payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }

    public fun direct_buy_with_kapy<T>(
        store: &mut OrangeStore,
        config: &Config,
        kapy: &Kapy,
        payment: Coin<T>,
        ctx: &mut TxContext,
    ): Orange {
        let kapy_level = kapy.level() as u64;
        let price = store.normal_price<T>() * (10 - kapy_level) / 10;
        if (payment.value() < price) err_payment_not_enough();
        store.put_into_treasury(payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }

    public fun direct_buy_with_orange<T>(
        store: &mut OrangeStore,
        config: &Config,
        orange: &Orange,
        payment: Coin<T>,
        ctx: &mut TxContext,
    ): Orange {
        let orange_kind = orange.kind() as u64;
        let price = store.normal_price<T>() * (10 - orange_kind) / 10;
        if (payment.value() < price) err_payment_not_enough();
        store.put_into_treasury(payment);
        orange::mint(
            config,
            orange_kind(),
            SuiMoverExercise3 {},
            ctx
        )
    }
}
