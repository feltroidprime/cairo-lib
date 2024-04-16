use pedersen::PedersenTrait;
use hash::HashStateTrait;

// After 0.12
#[derive(Drop)]
struct StarknetBlockHeader {
    block_number: felt252,
    global_state_root: felt252,
    sequencer_address: felt252,
    block_timestamp: felt252,
    parent_block_hash: felt252,
    transaction_count: felt252,
    transaction_commitment: felt252,
    event_count: felt252,
    event_commitment: felt252,
}

#[generate_trait]
impl StarknetBlockHeaderImpl of StarknetBlockHeaderTrait {
    fn hash(self: @StarknetBlockHeader) -> felt252 {
        // compute_hash_on_elements([block_number, global_state_root, sequencer_address, block_timestamp, transaction_count, transaction_commitment, event_count, event_commitment, 0, 0, parent_block_hash])
        PedersenTrait::new(0) // State init
            .update(*self.block_number)
            .update(*self.global_state_root)
            .update(*self.sequencer_address)
            .update(*self.block_timestamp)
            .update(*self.transaction_count)
            .update(*self.transaction_commitment)
            .update(*self.event_count)
            .update(*self.event_commitment)
            .update(0)
            .update(0)
            .update(*self.parent_block_hash)
            .update(11) // 11 elements
            .finalize()
    }
}
