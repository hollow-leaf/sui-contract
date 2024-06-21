module member::member {
    use sui::package;
    use sui::display;
    use std::string::{String, utf8};
    use sui::object_bag::{Self, ObjectBag};
    use sui::table::{Self, Table};

    public struct AdminCap has key, store{
        id: UID
    }

    public struct MemberReg has key{
        id: UID,
        registry: Table<address, ID>
    }

    public struct MEMBER has drop {}
    
    // Intransferable
    public struct Member has key{
        id: UID,
        name: String,
        eth_link: String,
        sol_link: String,
        assets: ObjectBag
    }

    fun init(otw: MEMBER, ctx: &mut TxContext){
        // AdminCap
        let cap = AdminCap{
            id: object::new(ctx)
        };
        transfer::transfer(cap, ctx.sender());

        // MemberReg
        let reg = MemberReg{
            id: object::new(ctx),
            registry: table::new(ctx)
        };
        transfer::share_object(reg);

        // display
        let publisher = package::claim(otw, ctx);
        let keys = vector[
            utf8(b"name"),
            utf8(b"eth_link"),
            utf8(b"sol_link"),
        ];
        let values = vector[
            utf8(b"{name}"),
            utf8(b"{eth_link}"),
            utf8(b"{sol_link}"),
        ];
        let mut display = display::new_with_fields<Member>(&publisher, keys, values, ctx);
        display::update_version(&mut display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    // mint to recipient
    public fun register(
        _: &AdminCap,
        recipient: address,
        ctx: &mut TxContext
    ){
        let member = Member{
            id: object::new(ctx),
            assets: object_bag::new(ctx),
            name: utf8(b""),
            eth_link: utf8(b""),
            sol_link: utf8(b"")
        };
        transfer::transfer(member, recipient);
    }

    entry fun edit_name(
        self: &mut Member,
        name: vector<u8>
    ){
        self.name = utf8(name);
    }

    entry fun edit_sol_link(
        self: &mut Member,
        name: vector<u8>
    ){
        self.name = utf8(name);
    }

    entry fun edit_eth_link(
        self: &mut Member,
        name: vector<u8>
    ){
        self.name = utf8(name);
    }
}
