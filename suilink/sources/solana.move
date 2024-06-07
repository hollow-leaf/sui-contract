module suilink::solana {

    // ----- Use Statements -----

    use 0xf857fa9df5811e6df2a0240a1029d365db24b5026896776ddd1c3c70803bccd3::suilink;
    use sui::clock;
    use sui::tx_context;
    use 0xf857fa9df5811e6df2a0240a1029d365db24b5026896776ddd1c3c70803bccd3::registry_v2;
    use std::string;
    use sui::address;
    use sui::ed25519;
    use 0xf857fa9df5811e6df2a0240a1029d365db24b5026896776ddd1c3c70803bccd3::utils;

    // ----- public structs -----

    public struct Solana has drop {
        dummy_field: bool,
    }

}
