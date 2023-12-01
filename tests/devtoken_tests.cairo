use snforge_std::{declare, ContractClassTrait};
use starknet::{ContractAddress};

fn deploy_contract(name: felt252) -> ContractAddress {
    let contract = declare(name);
    contract.deploy(@ArrayTrait::<felt252>::new()).unwrap()
}
