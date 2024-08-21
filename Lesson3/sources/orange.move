module sui_mover_lesson_3::orange {
    
    // Dependencies

    use sui_mover_lesson_3::config::{Self, Config, AdminCap};

    // Errors

    const EInvalidMintRule: u64 = 0;
    fun err_invalid_mint_rule() { abort EInvalidMintRule }

    // Object (NFT)

    public struct Orange has key, store {
        id: UID,
        kind: u8,
    }

    // Public Funs

    public fun mint<R: drop>(
        config: &Config,
        kind: u8,
        _rule_witness: R,
        ctx: &mut TxContext,
    ): Orange {
        if (!config::is_valid_mint_rule<R>(config, kind))
            err_invalid_mint_rule();

        Orange {
            id: object::new(ctx),
            kind,
        }
    }

    // Friend Funs

    public(package) fun destroy(orange: Orange): u8 {
        let Orange { id, kind } = orange;
        object::delete(id);
        kind
    }

    // Admin Funs

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

    //  Getter Funs

    public fun kind(orange: &Orange): u8 {
        orange.kind
    }
}
