use array::ArrayTrait;

fn panicking_function() {
    let mut data = ArrayTrait::new();
    data.append('aaa');
    panic(data);
}

#[test]
#[should_panic]
fn failing() {
    panicking_function();
    assert(2 == 2, '2==2');
}
