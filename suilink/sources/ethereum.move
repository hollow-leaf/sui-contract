module suilink::ethereum {

    // ----- Use Statements -----

    use sui::ecdsa_k1;
    use sui::hash;
    use suilink::suilink;
    use sui::clock;
    use suilink::registry_v2;
    use std::string;
    use sui::address;
    use suilink::utils;

    // ----- public structs -----

    public struct Ethereum has drop {
        dummy_field: bool,
    }
    // ----- Internal Functions -----

    fun ecrecover_eth_address(
        mut signature: vector<u8>, 
        message: vector<u8>
    ): vector<u8> {
        let recovery_id = vector::borrow_mut(&mut signature, 64);
        // The recovery identifier (“v”)
        if (*recovery_id == 27) {
            *recovery_id = 0;
        } else if (*recovery_id == 28) {
            *recovery_id = 1;
        } else if (*recovery_id > 35) {
            *recovery_id = (*recovery_id - 1) % 2;
        };
        let uncompressed_pubkey = ecdsa_k1::secp256k1_ecrecover(&signature, &message, 0);
        let decompressed_pubkey = ecdsa_k1::decompress_pubkey(&uncompressed_pubkey);
        let mut data_with_prefix = b"";
        let mut i = 1;
        while (i < 65) {
            vector::push_back(&mut data_with_prefix, *vector::borrow(&decompressed_pubkey, i));
            i = i + 1;
        };
        let hashed_data = hash::keccak256(&data_with_prefix);
        let mut eth_address = b"";
        let mut j = 12;
        while (j < 32) {
            vector::push_back(&mut eth_address, *vector::borrow(&hashed_data, j));
            j = j + 1;
        };
        eth_address
    }

    // ----- Public Functions -----

    public fun ethereum(
        _: &suilink::AdminCap
    ): Ethereum {
        Ethereum { dummy_field: false }
    }

    public fun link_v2(
        registry: &mut registry_v2::SuiLinkRegistryV2,
        signature: vector<u8>,
        clock: &clock::Clock,
        ctx: &mut tx_context::TxContext,
    ) {
        let mut message_prefix = string::utf8(b"19457468657265756d205369676e6564204d6573736167653a0a31393757656c636f6d6520746f205375694c696e6b21205369676e2074686973206d65737361676520746f206c696e6b20796f757220457468657265756d2077616c6c657420746f205355492061646472657373203078");
        let sui_address_str = address::to_string(tx_context::sender(ctx));
        string::append_utf8(&mut message_prefix, *string::bytes(&sui_address_str));
        string::append_utf8(&mut message_prefix, b". No blockchain transaction or gas cost required.");
        registry_v2::mint<Ethereum>(
            registry,
            //retrieve eth address
            utils::bytes_to_hex(
                ecrecover_eth_address(signature, *string::bytes(&message_prefix))
            ),
            clock,
            0,
            ctx
        );
    }

    #[test]
    public fun test_eth_sig(){
        let address = x"30A674400ECa0776fA42bF3160A77FCCcD20abF5";
        let msg = string::utf8(b"acumferi21");
        let signature = x"2f22b3e9ec1c67d8c18e9677e34d3c3dcaf765b12a0ed3c1f6b2d837133db02d2852939a0e0f7d3c95e892d316814865720d309d1618432250b34b5833d729721c";


        let decompressed_bytes = ecrecover_eth_address(signature, *string::bytes(&msg));
        let decompressed_address = utils::bytes_to_hex(decompressed_bytes);

std::debug::print(&decompressed_bytes);
std::debug::print(&decompressed_address);

        assert!(address == decompressed_bytes, 404);
    }
}
