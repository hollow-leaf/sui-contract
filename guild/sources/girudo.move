module girudo::girudo {
    use sui::dynamic_field as field;
    // Adventurer struct
    public struct Adventurer has key {
        id: UID,
        name: vector<u8>,
    }

    // Dynamic field child struct type containing a counter
    public struct DFChild has store {
        girudo_id: ID,
        count: u64,
    }

    // Girudo struct
    public struct Girudo has key {
        id: UID,
        name: vector<u8>,
    }

    // Create a new Adventurer, ensuring only one per user and initial transfer to minter
    public fun create_adventurer(name: vector<u8>, ctx: &mut TxContext) {
        let new_adventure = Adventurer {
            id: object::new(ctx),
            name,
        };
        // transfer the forge object to the module/package publisher
        transfer::transfer(new_adventure, tx_context::sender(ctx));
    }

    // Create a new DFChild
    public fun create_dfchild(count: u64, girudo: &Girudo): DFChild {
        let girudo_id = object::id(girudo);
        DFChild {
            girudo_id,
            count,
        }
    }

    // Mutate a DFChild's counter via its parent object
    public fun add_points_by_girudo_id(parent: &mut Adventurer, count: u64, girudo: &Girudo) {
        // let child_exists = field::exists_(&parent.id, child_name);
        // let child = field::borrow_mut<vector<u8>, DFChild>(&mut parent.id, child_name);
        let child_name = girudo.name;
        let exist = field::exists_(&parent.id, child_name);
        if (exist) {
            let child = field::borrow_mut<vector<u8>, DFChild>(&mut parent.id, child_name);
            child.count = child.count + count;
        } else {
            let girudo_id = object::id(girudo);
            let new_child = DFChild {
                girudo_id,
                count,
            };
            field::add(&mut parent.id, child_name, new_child);
        }
    }

    // Add points to DFChild by girudo_id; create if it doesn't exist
    public fun minus_points_by_girudo_id(parent: &mut Adventurer, count: u64, girudo: &Girudo) {
    // let child_exists = field::exists_(&parent.id, child_name);
        let child_name = girudo.name;
        let child = field::borrow_mut<vector<u8>, DFChild>(&mut parent.id, child_name);
        child.count = child.count - count;
    }
}