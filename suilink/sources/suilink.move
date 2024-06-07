module suilink::suilink {

    // ----- Use Statements -----

    use sui::object;
    use std::string;
    use sui::vec_set;
    use sui::tx_context;
    use sui::package;
    use sui::transfer;

    // ----- public structs -----

    public struct AdminCap has store, key {
        id: object::UID,
    }

    public struct SUILINK has drop {
        dummy_field: bool,
    }

    public struct SuiLink<phantom T0> has key {
        id: object::UID,
        network_address: string::String,
        timestamp_ms: u64,
    }

    public struct SuiLinkRegistry has key {
        id: object::UID,
        registry: vec_set::VecSet<vector<u8>>,
    }
    // ----- Init Functions -----

    fun init(
        suiLink: SUILINK,
        ctx: &mut tx_context::TxContext,
    ) {
        package::claim_and_keep(suiLink, ctx);
        let adminCap = AdminCap { id: object::new(ctx) };
        transfer::public_transfer(adminCap, tx_context::sender(ctx));
        let suiLinkRegistry = SuiLinkRegistry {
            id: object::new(ctx),
            registry: vec_set::empty<vector<u8>>(),
        };
        transfer::share_object(suiLinkRegistry);
    }

    // ----- Public Functions -----

    public fun delete<T>(
        registry: &mut SuiLinkRegistry,
        link: SuiLink<T>,
        ctx: &mut tx_context::TxContext,
    ) {
        abort 0
    }

    public(package) fun destroy<T>(
        sui_link: SuiLink<T>
    ): string::String {
        let SuiLink {
            id,
            network_address,
            timestamp_ms: _,
        } = sui_link;
        object::delete(id);
        network_address
    }

    public(package) fun destroy_registry(
        registry: SuiLinkRegistry
    ): vec_set::VecSet<vector<u8>> {
        let SuiLinkRegistry { id, registry: links } = registry;
        object::delete(id);
        links
    }

    public(package) fun mint<T>(
        network_address: string::String,
        timestamp_ms: u64,
        ctx: &mut tx_context::TxContext,
    ): SuiLink<T> {
        SuiLink<T> {
            id: object::new(ctx),
            network_address,
            timestamp_ms,
        }
    }

    public(package) fun transfer<T>(
        suiLink: SuiLink<T>,
        recipient: address,
    ) {
        transfer::transfer(suiLink, recipient);
    }
}
