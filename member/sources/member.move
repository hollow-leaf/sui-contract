module member::member {
    use sui::object_bag::{Self as ob, ObjectBag};
    use sui::table::{Self, Table};

    public struct AdminCap has key, store{
        id: UID
    }

    public struct MemberReg has key{
        id: UID,
        registry: Table<address, ID>,
        /// MemberOwnerCap --> ownedAssets
        member_assets: Table<ID, ObjectBag>
    }

    // Intransferable
    /// Key to access owner's objectBags in MemberReg
    public struct MemberOwnerCap has key{
        id: UID
    }

    public fun member_asset(reg: &mut MemberReg, member_cap_id: ID):&ObjectBag{
        table::borrow(&reg.member_assets, member_cap_id)
    }

    fun member_asset_mut(reg: &mut MemberReg, member_cap_id: ID):&mut ObjectBag{
        table::borrow_mut(&mut reg.member_assets, member_cap_id)
    }

    fun init(ctx: &mut TxContext){
        // AdminCap
        let cap = AdminCap{
            id: object::new(ctx)
        };
        transfer::transfer(cap, ctx.sender());

        // MemberReg
        let reg = MemberReg{
            id: object::new(ctx),
            registry: table::new(ctx),
            member_assets: table::new(ctx)
        };
        transfer::share_object(reg);
    }

    // mint to recipient
    public fun new(
        _: &AdminCap,
        reg: &mut MemberReg,
        recipient: address,
        ctx: &mut TxContext
    ){
        let owner_cap = MemberOwnerCap{
            id: object::new(ctx)
        };
        
        // abort if already registered
        reg.registry.add(recipient, object::id(&owner_cap));
        transfer::transfer(owner_cap, recipient);
    }

    // receive objectsa
    public fun admin_deposit<T: key + store>(
        _: &AdminCap,
        recipient: address,
        reg: &mut MemberReg,
        obj: T
    ){
        let user_cap_id = table::borrow(&reg.registry, recipient);
        let member_asset_mut = member_asset_mut(reg, *user_cap_id);
        
        let obj_id = object::id(&obj);
        ob::add(member_asset_mut, obj_id, obj);
    }
}
