module sui_mover_kapy::kapy {

    // Dependencies

    use std::string::{String, utf8};
    use sui::package;
    use sui::display;
    use sui::vec_set::{Self, VecSet};
    use sui_mover_kapy::orange::{Self, Orange};

    // Errors

    const ECarrySameKindOfOrange: u64 = 0;
    fun err_carry_same_kind_of_orange() { abort ECarrySameKindOfOrange }

    // One Time Witness

    public struct KAPY has drop {}

    // Object (NFT)

    public struct Kapy has key, store {
        id: UID,
        index: u16,
        username: String,
        belongings: VecSet<u8>,
        level: u8,
        bytes: vector<u8>,
    }

    // Capability

    public struct MintCap has key {
        id: UID,
        supply: u16,
    }

    // Constructor

    fun init(otw: KAPY, ctx: &mut TxContext) {
        // setup Kapy display
        let keys = vector[
            utf8(b"name"),
            utf8(b"description"),
            utf8(b"image_url"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            // name
            utf8(b"Sui Mover: {username}"),
            // description
            utf8(b"Each orange represents your effort and achievement!"),
            // image_url
            utf8(b"https://aqua-natural-grasshopper-705.mypinata.cloud/ipfs/Qmd9RpFKPBDzHdfnq7HSdhND9svg1fJxr7GAwTYwfEr5vh/{index}_{level}o.png"),
            // project_url
            utf8(b"https://lu.ma/skany77u"),
            // creator
            utf8(b"Bucket X Typus X Scallop"),
        ];

        let deployer = ctx.sender();
        let publisher = package::claim(otw, ctx);
        let mut displayer = display::new_with_fields<Kapy>(
            &publisher, keys, values, ctx,
        );
        display::update_version(&mut displayer);

        transfer::public_transfer(displayer, deployer);
        transfer::public_transfer(publisher, deployer);

        // mint cap
        let cap = MintCap { id: object::new(ctx), supply: 0 };
        transfer::transfer(cap, deployer);
    }

    // Public Funs

    public fun update_username(
        kapy: &mut Kapy,
        username: String,
    ) {
        kapy.username = username;
    }

    public fun carry(
        kapy: &mut Kapy,
        orange: Orange,
    ) {
        let orange_kind = orange::destroy(orange);
        if (vec_set::contains(kapy.belongings(), &orange_kind))
            err_carry_same_kind_of_orange();
        vec_set::insert(&mut kapy.belongings, orange_kind);
        kapy.level = kapy.belongings().size() as u8;
    }

    // Admin Funs

    public fun mint(
        cap: &mut MintCap,
        ctx: &mut TxContext,
    ): Kapy {
        cap.supply = cap.supply() + 1;
        Kapy {
            id: object::new(ctx),
            index: cap.supply(),
            username: utf8(b""),
            belongings: vec_set::empty(),
            level: 0,
            bytes: vector[],
        }
    }

    entry fun mint_to(
        cap: &mut MintCap,
        recipient: address,
        ctx: &mut TxContext,
    ) {
        let kapy = mint(cap, ctx);
        transfer::transfer(kapy, recipient);
    }

    //  Getter Funs

    public fun index(kapy: &Kapy): u16 {
        kapy.index
    }

    public fun username(kapy: &Kapy): String {
        kapy.username
    }

    public fun belongings(kapy: &Kapy): &VecSet<u8> {
        &kapy.belongings
    }

    public fun level(kapy: &Kapy): u8 {
        kapy.level
    }

    public fun supply(cap: &MintCap): u16 {
        cap.supply
    }

    //  Test-only Funs

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        use sui::test_utils;
        init(test_utils::create_one_time_witness<KAPY>(), ctx);
    }
}
