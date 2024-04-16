use cairo_lib::data_structures::starknet_block::{StarknetBlockHeader, StarknetBlockHeaderTrait};

#[test]
fn test_snb_block_hash() {
    // Sepolia block 56399
    let block_hash_56399: felt252 =
        2164192536789366427034857826628165510214683759353778181510131152009496439065;
    let block_56399 = StarknetBlockHeader {
        block_number: 56399,
        global_state_root: 0x3f9310de4b831d181ddcb131ea9911cef1198e51d3035c876113faef432a654,
        sequencer_address: 0x1176a1bd84444c89232ec27754698e5d2e7e1a7f1539f12027f28b23ec9f3d8,
        block_timestamp: 0x660e6460,
        transaction_count: 0x24,
        transaction_commitment: 0x135c26bd5d840f205ce30823b375bb87d00205af64b894c2b6ba5ace95815b6,
        event_count: 0x75,
        event_commitment: 0x3707326e40b0d213c26e84b0d7950e12dbf2edd628f9a9433213025b9bc912,
        parent_block_hash: 0x26641f3ebf60add28e933d72b75594fed8e4d230a2aa841de1d3bea9cc6b839
    };
    assert_eq!((@block_56399).hash(), block_hash_56399);
}
