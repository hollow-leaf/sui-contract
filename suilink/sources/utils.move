module suilink::utils {

    // ----- Use Statements -----

    use std::string;
    use sui::bcs;
    use sui::hash;
    // ----- Public Functions -----

    public fun bytes_to_hex(input: vector<u8>): string::String {
        let hex_prefix = b"0123456789abcdef";
        let mut hex_output = b"0x";
        let mut index = 0;
        while (index < vector::length(&input)) {
            let byte = *vector::borrow(&input, index);
            vector::push_back(&mut hex_output, *vector::borrow(&hex_prefix, ((byte >> 4) as u64)));
            vector::push_back(&mut hex_output, *vector::borrow(&hex_prefix, ((byte & 15) as u64)));
            index = index + 1;
        };
        string::utf8(hex_output)
    }

    public fun hex_to_base58(input: vector<u8>): string::String {
        let base58_alphabet = b"123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
        let mut temp_input = input;
        let mut base58_vector = b"";
        while (!vector::is_empty<u8>(&temp_input)) {
            let mut carry = 0u64;
            let mut temp_vector = b"";
            let mut index = 0;
            while (index < vector::length<u8>(&temp_input)) {
                let value = (*vector::borrow<u8>(&temp_input, index) as u64) + carry * 256;
                let div = value / 58;
                carry = value % 58;
                if (!vector::is_empty<u8>(&temp_vector) || div > 0) {
                    vector::push_back<u8>(&mut temp_vector, (div as u8));
                };
                index = index + 1;
            };
            vector::push_back<u8>(&mut base58_vector, *vector::borrow<u8>(&base58_alphabet, carry));
            temp_input = temp_vector;
        };
        let mut reversed_base58 = b"";
        let mut length = vector::length<u8>(&base58_vector);
        while (length > 0) {
            let last_index = length - 1;
            length = last_index;
            vector::push_back<u8>(&mut reversed_base58, *vector::borrow<u8>(&base58_vector, last_index));
        };
        string::utf8(reversed_base58)
    }

    public fun hex_to_bytes(hex_string: string::String): vector<u8> {
        let hex_prefix = b"0123456789abcdef";
        let hex_bytes = string::bytes(&hex_string);
        let mut result_bytes = vector[];
        let mut i = 0;

        while (i < vector::length<u8>(hex_bytes)) {
            let high_nibble = *vector::borrow<u8>(hex_bytes, i);
            let low_nibble = *vector::borrow<u8>(hex_bytes, i + 1);
            let (_, high_nibble_index) = vector::index_of<u8>(&hex_prefix, &high_nibble);
            let (_, low_nibble_index) = vector::index_of<u8>(&hex_prefix, &low_nibble);
            assert!(high_nibble_index >= 0 && low_nibble_index >= 0, 0);
            vector::push_back<u8>(
                &mut result_bytes,
                ((high_nibble_index << 4) as u8) | (low_nibble_index as u8)
            );
            i = i + 2;
        };

        result_bytes
    }

    public(package) fun hash_registry_entry(
        entry_type: u32,
        address: address,
        network_address: string::String
    ): vector<u8> {
        let mut empty_vec = vector::empty<vector<u8>>();
        let vec_ref = &mut empty_vec;
        vector::push_back(vec_ref, bcs::to_bytes(&entry_type));
        vector::push_back(vec_ref, hash_sui_address_and_network_address(address, network_address));
        let final_vec = empty_vec;
        let bytes_to_hash = bcs::to_bytes(&final_vec);
        hash::blake2b256(&bytes_to_hash)
    }

    public(package) fun hash_sui_address_and_network_address(
        sui_address: address,
        network_address: string::String
    ): vector<u8> {
        let mut empty_vec = vector::empty<vector<u8>>();
        let vec_ref = &mut empty_vec;
        vector::push_back(vec_ref, bcs::to_bytes(&sui_address));
        vector::push_back(vec_ref, *string::bytes(&network_address));
        let combined_vec = empty_vec;
        let bytes_to_hash = bcs::to_bytes(&combined_vec);
        hash::blake2b256(&bytes_to_hash)
    }

    public(package) fun migration_hash_registry_entry(
        version: u32,
        data: vector<u8>
    ): vector<u8> {
        let mut entries = vector::empty<vector<u8>>();
        let entries_ref = &mut entries;
        vector::push_back(entries_ref, bcs::to_bytes(&version));
        vector::push_back(entries_ref, data);
        let serialized_entries = bcs::to_bytes(&entries);
        hash::blake2b256(&serialized_entries)
    }
}
