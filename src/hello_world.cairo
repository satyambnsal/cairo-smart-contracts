use core::traits::Into;
use debug::PrintTrait;

const ONE_HOUR_IN_SECONDS: u32 = 3600;

fn main() {
    let x = 2;
    let y = 2;
    assert(x != y, 'error, x is equal to y');
}

#[test]
fn test_main() {
    main();
}
