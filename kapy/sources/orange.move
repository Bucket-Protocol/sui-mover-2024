module sui_mover_kapy::orange {

    use std::type_name::{Self, TypeName};
    use sui::vec_map::{Self, VecMap};

    // Errors

    const EInvalidMintRule: u64 = 0;
    fun err_invalid_mint_rule() { abort EInvalidMintRule }

    // Object (NFT)

    public struct Orange has key, store {
        id: UID,
        kind: u8,
    }

    // Config

    public struct Config has key {
        id: UID,
        mint_rules: VecMap<u8, TypeName>,
    }

    // Capability

    public struct AdminCap has key, store {
        id: UID,
    }

    // Constructor

    fun init(ctx: &mut TxContext) {
        let config = Config { id: object::new(ctx), mint_rules: vec_map::empty() };
        transfer::share_object(config);

        let cap = AdminCap { id: object::new(ctx) };
        transfer::transfer(cap, ctx.sender());
    }

    // Public funs

    public fun mint<R: drop>(
        config: &Config,
        kind: u8,
        _rule_witness: R,
        ctx: &mut TxContext,
    ): Orange {
        let rule_name = type_name::get<R>();
        if (*vec_map::get(&config.mint_rules, &kind) != rule_name)
            err_invalid_mint_rule();
        Orange {
            id: object::new(ctx),
            kind,
        }
    }

    // Friend funs

    public(package) fun destroy(orange: Orange): u8 {
        let Orange { id, kind } = orange;
        object::delete(id);
        kind
    }

    // Admin funs

    public fun add_rule<R: drop>(
        _cap: &AdminCap,
        config: &mut Config,
        kind: u8,
    ) {
        vec_map::insert(
            &mut config.mint_rules,
            kind,
            type_name::get<R>(),
        );
    }

    public fun remove_rule(
        _cap: &AdminCap,
        config: &mut Config,
        kind: u8
    ) {
        vec_map::remove(
            &mut config.mint_rules,
            &kind,
        );
    }

    public fun mint_by_admin(
        _cap: &AdminCap,
        kind: u8,
        ctx: &mut TxContext,
    ): Orange {
        Orange {
            id: object::new(ctx),
            kind
        }
    }

    //  Getter funs

    public fun kind(orange: &Orange): u8 {
        orange.kind
    }

    //  Test-only funs

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }
}
