module suilink::solana {

    // ----- Use Statements -----

    use suilink::suilink;
    use sui::clock;
    use suilink::registry_v2;
    use std::string;
    use sui::address;
    use sui::ed25519;
    use suilink::utils;

    // ----- Structs -----

    public struct Solana has drop {
        dummy_field: bool,
    }
    // ----- Public Functions -----

    public fun link(
        _registry: &mut suilink::SuiLinkRegistry,
        _arg1: vector<u8>,
        _clock: &clock::Clock,
        _arg3: vector<u8>,
        _ctx: &mut tx_context::TxContext,
    ) {
        abort 1
    }

    public fun link_v2(
        registry: &mut registry_v2::SuiLinkRegistryV2,
        signature: vector<u8>,
        clock: &clock::Clock,
        data: vector<u8>,
        ctx: &mut tx_context::TxContext,
    ) {
        let prefix = string::utf8(b"Welcome to SuiLink! Sign this message to link your Solana wallet to SUI address 0x");
        let sender_str = address::to_string(tx_context::sender(ctx));
        let mut message = prefix;
        string::append_utf8(&mut message, *string::bytes(&sender_str));
        string::append_utf8(&mut message, b". No blockchain transaction or gas cost required.");
        assert!(
            ed25519::ed25519_verify(
                &signature,
                &data,
                string::bytes(&message)
            ),
            0
        );
        registry_v2::mint<Solana>(
            registry,
            utils::hex_to_base58(data),
            clock,
            1,
            ctx
        );
    }

    public fun solana(_: &suilink::AdminCap): Solana {
        Solana { dummy_field: false }
    }
}
