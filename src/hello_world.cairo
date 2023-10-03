use traits::{Into};
use traits::TryInto;
use debug::PrintTrait;
use option::OptionTrait;


const ONE_HOUR_IN_SECONDS: u32 = 3600;


fn square_plus(x: u8, y: u8) -> u8 {
    x * x + y
}


fn main() {
    let first_arg = 13;
    let second_arg = 4;

    let result: u8 = square_plus(x: first_arg, y: second_arg);
    'Result:'.print();
    result.print();

    let version: u8 = 2;
    let is_awesome = true;

    if is_awesome && version > 0 {
        'Leet code!'.print();
    } else {
        'Great things are coming'.print();
    }

    let x: felt252 = 3618502788666131213697322783095070105623107215331596699973092056135872020480;
    let y: felt252 = 1;

    assert(x + y == 0, 'P == 0 (mod P)');

    assert(x + 1 == 0, '(P-1) + 1 == 0 (mod P)');
    assert(x == 0 - 1, 'subtraction is modular');
    assert(x * x == 1, 'multiplication is modular');
    let two = TryInto::try_into(2).unwrap();

    assert(felt252_div(2, two) == 3, '2 == 1* 2');

    let half_prime_plus_one =
        1809251394333065606848661391547535052811553607665798349986546028067936010241;

    assert(felt252_div(1, two) == half_prime_plus_one, '1 == ((P+1)/2) * 2 (mod P)');
}

#[test]
fn test_main() {
    main();
}
