use cairo_lib::data_structures::mmr::peaks::{Peaks, PeaksTrait};
use cairo_lib::data_structures::mmr::proof::{Proof, ProofTrait};
use cairo_lib::data_structures::mmr::utils::{compute_root, get_height};
use cairo_lib::hashing::poseidon::PoseidonHasher;
use cairo_lib::utils::bitwise::bit_length;
use cairo_lib::utils::math::pow;

use debug::PrintTrait; // TODO: remove

// @notice Merkle Mountatin Range struct
#[derive(Drop, Clone, Serde, starknet::Store)]
struct MMR {
    root: felt252,
    last_pos: usize
}

impl MMRDefault of Default<MMR> {
    // @return MMR with last_pos 0 and root poseidon(0, 0)
    #[inline(always)]
    fn default() -> MMR {
        MMR { root: PoseidonHasher::hash_double(0, 0), last_pos: 0 }
    }
}

#[generate_trait]
impl MMRImpl of MMRTrait {
    // @notice Creates a new MMR
    // @param root The root of the MMR
    // @param last_pos The last position in the MMR
    // @return MMR with the given root and last_pos
    #[inline(always)]
    fn new(root: felt252, last_pos: usize) -> MMR {
        MMR { root, last_pos }
    }

    // @notice Appends an element to the MMR
    // @param hash The hashed element to append
    // @param peaks The peaks of the MMR
    // @return Result with the new root and new peaks of the MMR
    fn append(ref self: MMR, hash: felt252, peaks: Peaks) -> Result<(felt252, Peaks), felt252> {
        if !peaks.valid(self.last_pos, self.root) {
            return Result::Err('Invalid peaks');
        }

        self.last_pos += 1;

        let mut peaks_arr = ArrayTrait::new();
        let mut i: usize = 0;
        loop {
            if i == peaks.len() {
                break ();
            }

            peaks_arr.append(*peaks.at(i));

            i += 1;
        };
        peaks_arr.append(hash);

        let mut p = 1;
        let mut q = pow(2, bit_length(self.last_pos) - 1);
        let mut r = 0; // number of peaks that will be join together after append
        loop {
            if p >= q {
                break ();
            }
            let m: usize = (p + q) / 2;

            if self.last_pos < m {
                q = m - 1;
                r = 0;
            } else {
                p = m;
                q = q - 1;
                r = r + 1;
            };
        };
        let s = peaks_arr.len();

        // create one peak from last *r* peaks
        let mut i = 0;
        let mut acc = *peaks_arr.at(s - 1);
        loop {
            if i == r {
                break ();
            }
            let peak = *peaks_arr.at(s - 2 - i);
            acc = PoseidonHasher::hash_double(peak, acc);
            i += 1;
        };

        // copy peaks that didn't change
        let mut i = 0;
        let mut new_peaks = ArrayTrait::new();
        loop {
            if i == s - r {
                break ();
            }
            new_peaks.append(*peaks_arr.at(i));
            i += 1;
        };

        // add new peak
        new_peaks.append(acc);

        // debug code
        // let mut i = 0;
        // loop {
        //     if i == new_peaks.len() - 1 {
        //         break ();
        //     }
        //     let x = *new_peaks.at(i);
        //     x.print();
        //     i += 1;
        // };

        let arr_span = new_peaks.span();

        let new_root = compute_root(self.last_pos.into(), arr_span);
        self.root = new_root;

        Result::Ok((new_root, arr_span))
    }

    // @notice Verifies a proof for an element in the MMR
    // @param index The index of the element in the MMR
    // @param hash The hash of the element
    // @param peaks The peaks of the MMR
    // @param proof The proof for the element
    // @return Result with true if the proof is valid, false otherwise
    fn verify_proof(
        self: @MMR, index: usize, hash: felt252, peaks: Peaks, proof: Proof
    ) -> Result<bool, felt252> {
        if !peaks.valid(*self.last_pos, *self.root) {
            return Result::Err('Invalid peaks');
        }

        let peak = proof.compute_peak(index, hash);
        Result::Ok(peaks.contains_peak(peak))
    }
}
