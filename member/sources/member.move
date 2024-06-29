module member::member {
    use sui::object_bag::{Self as ob, ObjectBag};
    use sui::table::{Self, Table};

    public struct AdminCap has key, store{
        id: UID
    }

    public struct MemberReg has key{
        id: UID,
        registry: Table<address, ID>,
        /// ID of MemberOwnerCap --> ownedAssets
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
    public fun add_member(
        reg: &mut MemberReg,
        _: &AdminCap,
        member: address,
        ctx: &mut TxContext
    ):MemberOwnerCap{
        let owner_cap = MemberOwnerCap{
            id: object::new(ctx)
        };
        let owner_cap_id = object::id(&owner_cap);
        
        // abort if already registered
        reg.registry.add(member, owner_cap_id);
        reg.member_assets.add(owner_cap_id, ob::new(ctx));

        owner_cap
    }

    public fun remove_member(
        reg: &mut MemberReg,
        _: &AdminCap,
        member: address,
    ){
        let user_cap_id = table::remove(&mut reg.registry, member);
        let member_asset = reg.member_assets.remove(user_cap_id);
    
        // abort if not empty
        member_asset.destroy_empty();
    }

    // admin help deposit asset
    public fun admin_deposit<T: key + store>(
        reg: &mut MemberReg,
        _: &AdminCap,
        recipient: address,
        obj: T
    ){
        let user_cap_id = table::borrow(&reg.registry, recipient);
        let member_asset_mut = member_asset_mut(reg, *user_cap_id);
        
        let obj_id = object::id(&obj);
        ob::add(member_asset_mut, obj_id, obj);
    }

    public fun deposit<T: key + store>(
        owner_cap: &MemberOwnerCap,
        reg: &mut MemberReg,
        obj: T
    ){
        let user_cap_id = object::id(owner_cap);
        let member_asset_mut = member_asset_mut(reg, user_cap_id);
        
        let obj_id = object::id(&obj);
        ob::add(member_asset_mut, obj_id, obj);
    }

    public fun withdraw<T: key + store>(
        owner_cap: &MemberOwnerCap,
        reg: &mut MemberReg,
        taked_obj_id: ID
    ):T{
        let user_cap_id = object::id(owner_cap);
        let member_asset_mut = member_asset_mut(reg, user_cap_id);
        
        ob::remove(member_asset_mut, taked_obj_id)
    }

    #[test_only]
    use sui::test_utils::destroy;
    #[test]
    fun test_add_user(){
        let mut ctx_ = tx_context::dummy();
        let ctx = &mut ctx_;

        let mut reg = MemberReg{
            id: object::new(ctx),
            registry: table::new(ctx),
            member_assets: table::new(ctx)
        };
        let cap = AdminCap{id: object::new(ctx)};
        

        let dummy_address = @0x1234;
        // register
        let owner_cap = reg.add_member(&cap, dummy_address, ctx);
    
        // admin deposit
        let mock_obj = AdminCap { id: object::new(ctx) };
        let mock_obj_id = object::id(&mock_obj);
        reg.admin_deposit(&cap, dummy_address, mock_obj);

        // owner withdraw
        let obj = owner_cap.withdraw<AdminCap>(&mut reg, mock_obj_id);
        destroy(obj);

        // remove_member
        reg.remove_member(&cap, dummy_address);

        destroy(reg);
        destroy(cap);
        destroy(owner_cap);
    }
}
