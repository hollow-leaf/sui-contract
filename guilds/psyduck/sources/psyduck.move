/// Module: psyduck
module psyduck::psyduck {
    use sui::package::{ Self };

    // OTW
    public struct PSYDUCK has drop {}

    fun init (otw: PSYDUCK, ctx: &mut TxContext){
        package::claim_and_keep(otw, ctx);
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(PSYDUCK{}, ctx);
    }
}
