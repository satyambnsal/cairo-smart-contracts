use core::traits::Into;
use debug::PrintTrait;

const ONE_HOUR_IN_SECONDS: u32 = 3600;

fn main() {
    let mut x = 5;
    x.print();
    x = 6;
    x.print();
    ONE_HOUR_IN_SECONDS.print();
    let x: felt252 = x.into();
    x.print();
    let a: felt252 = 1;
    let b: felt252 = 2;

    let y = 1_u128 / 2_u128;
    y.print();
}
