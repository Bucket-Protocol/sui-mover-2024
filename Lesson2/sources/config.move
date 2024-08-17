module sui_mover_kapy::config {

    // Dependencies

    use std::type_name::{Self, TypeName};
    use sui::vec_map::{Self, VecMap};

    // Object

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
        let config = Config {
            id: object::new(ctx),
            mint_rules: vec_map::empty(),
        };
        transfer::share_object(config);

        let cap = AdminCap {
            id: object::new(ctx),
        };
        transfer::transfer(cap, ctx.sender());
    }

    // Admin Funs

    public fun add_mint_rule<R: drop>(
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

    public fun remove_mint_rule(
        _cap: &AdminCap,
        config: &mut Config,
        kind: u8
    ) {
        vec_map::remove(
            &mut config.mint_rules,
            &kind,
        );
    }

    // Getter Funs

    public fun is_valid_mint_rule<R: drop>(config: &Config, kind: u8): bool {
        if (vec_map::contains(&config.mint_rules, &kind)) {
            let rule_name = *vec_map::get(&config.mint_rules, &kind);
            rule_name == type_name::get<R>()
        } else {
            false
        }
    }

    // Test-only Funs

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }

    #[test_only]
    public fun add_mint_rule_for_testing<R: drop>(
        config: &mut Config,
        kind: u8,
    ) {
        vec_map::insert(
            &mut config.mint_rules,
            kind,
            type_name::get<R>(),
        );   
    }
}
