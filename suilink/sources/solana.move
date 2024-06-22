module suilink::solana {

    // ----- Use Statements -----

    use suilink::suilink;
    use sui::clock;
    use sui::tx_context;
    use suilink::registry_v2;
    use std::string;
    use sui::address;
    use sui::ed25519;
    use suilink::utils;

    // ----- public structs -----

    public struct Solana has drop {
        dummy_field: bool,
    }

}
