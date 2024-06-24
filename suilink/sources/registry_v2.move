// Decompiled by SuiGPT
module suilink::registry_v2 {

    // ----- Use Statements -----
    use std::string;

    use sui::bag;
    use sui::clock;
    use sui::dynamic_field;
    use sui::vec_set;

    use suilink::suilink;
    use suilink::utils;

    // ----- public structs -----

    public struct RecordsV1 has copy, drop, store {
        dummy_field: bool,
    }

    public struct SuiLinkRegistryV2 has key {
        id: object::UID,
        version: u8,
        registry: bag::Bag,
    }
    // ----- Public Functions -----

    public fun create_from_v1(
        suiLinkRegistry: suilink::SuiLinkRegistry,
        ctx: &mut tx_context::TxContext,
    ) {
        let mut new_id = object::new(ctx);
        let recordsV1 = RecordsV1 { dummy_field: false };
        dynamic_field::add<RecordsV1, vector<vector<u8>>>(
            &mut new_id,
            recordsV1,
            vec_set::into_keys(
                suilink::destroy_registry(suiLinkRegistry)
            )
        );
        let suiLinkRegistryV2 = SuiLinkRegistryV2 {
            id: new_id,
            version: 2,
            registry: bag::new(ctx),
        };
        transfer::share_object(suiLinkRegistryV2);
    }

    public fun delete<T>(
        registry: &mut SuiLinkRegistryV2,
        sui_link: suilink::SuiLink<T>,
        entry_id: u32,
        ctx: &mut tx_context::TxContext,
    ) {
        let records_v1 = RecordsV1 { dummy_field: false };
        assert!(
            !dynamic_field::exists_<RecordsV1>(&registry.id, records_v1),
            2
        );
        assert!(registry.version == 2, 1);
        let _:bool = bag::remove(
            &mut registry.registry,
            utils::hash_registry_entry(
                entry_id,
                tx_context::sender(ctx),
                suilink::destroy(sui_link)
            )
        );
    }

    public fun migrate_records(registry_v2: &mut SuiLinkRegistryV2) {
        let records_v1 = RecordsV1 { dummy_field: false };
        assert!(dynamic_field::exists_<RecordsV1>(&registry_v2.id, records_v1), 3);
        let records_data = dynamic_field::borrow_mut<RecordsV1, vector<vector<u8>>>(&mut registry_v2.id, records_v1);
        let mut counter = 0;
        while (!vector::is_empty<vector<u8>>(records_data) && counter <= 250) {
            let record = vector::pop_back<vector<u8>>(records_data);
            bag::add<vector<u8>, bool>(
                &mut registry_v2.registry,
                utils::migration_hash_registry_entry(0, record),
                true
            );
            bag::add<vector<u8>, bool>(
                &mut registry_v2.registry,
                utils::migration_hash_registry_entry(1, record),
                true
            );
            counter = counter + 1;
        };
        if (vector::is_empty<vector<u8>>(records_data)) {
            let empty_records_v1 = RecordsV1 { dummy_field: false };
            dynamic_field::remove<RecordsV1, vector<vector<u8>>>(&mut registry_v2.id, empty_records_v1);
        };
    }

    public(package) fun mint<T>(
        registry: &mut SuiLinkRegistryV2,
        link: string::String,
        clock: &clock::Clock,
        nonce: u32,
        ctx: &mut tx_context::TxContext,
    ) {
        let record = RecordsV1 { dummy_field: false };
        assert!(!dynamic_field::exists_<RecordsV1>(&registry.id, record), 2);
        assert!(registry.version == 2, 1);
        let sender = tx_context::sender(ctx);
        let entry_hash = utils::hash_registry_entry(nonce, sender, link);
        assert!(!bag::contains(&registry.registry, entry_hash), 0);
        bag::add(&mut registry.registry, entry_hash, true);
        let minted_token = suilink::mint<T>(link, clock::timestamp_ms(clock), ctx);
        suilink::transfer(minted_token, sender);
    }
}
