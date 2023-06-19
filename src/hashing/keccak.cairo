use cairo_lib::hashing::hasher::Hasher;
use array::ArrayTrait;
use keccak::keccak_uint256s_le;

struct Keccak {}

impl KeccakHasher of Hasher<u256, u256> {
    fn hash_single(a: u256) -> u256 {
        let mut arr = ArrayTrait::new();
        arr.append(a);
        keccak_uint256s_le(arr.span())
    }

    fn hash_double(a: u256, b: u256) -> u256 {
        let mut arr = ArrayTrait::new();
        arr.append(a);
        arr.append(b);
        keccak_uint256s_le(arr.span())
    }

    fn hash_many(input: Span<u256>) -> u256 {
        keccak_uint256s_le(input)
    }
}
