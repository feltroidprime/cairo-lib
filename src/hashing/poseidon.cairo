use cairo_lib::hashing::hasher::Hasher;
use cairo_lib::utils::types::words64::Words64;
use poseidon::{poseidon_hash_span, hades_permutation};

struct Poseidon {}

#[generate_trait]
impl PoseidonHasherWords64 of PoseidonTrait {
    fn hash_words64(words: Words64) -> felt252 {
        let mut arr = ArrayTrait::new();
        let mut i: usize = 0;
        loop {
            if i == words.len() {
                break poseidon_hash_span(arr.span());
            }

            arr.append((*words.at(i)).into());

            i += 1;
        }
    }
}

// Permutation params: https://docs.starknet.io/documentation/architecture_and_concepts/Cryptography/hash-functions/#poseidon_hash
impl PoseidonHasher of Hasher<felt252, felt252> {
    fn hash_single(a: felt252) -> felt252 {
        let (single, _, _) = hades_permutation(a, 0, 1);
        single
    }

    fn hash_double(a: felt252, b: felt252) -> felt252 {
        let (double, _, _) = hades_permutation(a, b, 2);
        double
    }

    fn hash_many(input: Span<felt252>) -> felt252 {
        poseidon_hash_span(input)
    }
}
