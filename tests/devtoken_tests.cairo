use snforge_std::{declare, ContractClassTrait};

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(ArrayTrait::new()).unwrap()
}