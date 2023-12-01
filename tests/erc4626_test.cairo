use snforge_std::{ContractClassTrait, PrintTrait, declare, start_prank, stop_prank};

use integer::BoundedU256;
use openzeppelin::token::erc20::{ERC20ABIDispatcher, interface::ERC20ABIDispatcherTrait};
use starknet::{ContractAddress, contract_address_const, get_contract_address};
use cairo_contracts::ERC4626::{IERC4626Dispatcher, IERC4626DispatcherTrait};

fn deploy_contract() -> (ContractAddress, IERC4626Dispatcher, ContractAddress) {
    let mockERC20 = declare('MockERC20');
    let calldata = ArrayTrait::<felt252>::new();

    let asset = mockERC20.deploy(@ArrayTrait::<felt252>::new()).unwrap();
    let mut params = ArrayTrait::<felt252>::new();
    asset.serialize(ref params);
    params.append('ERC4626 Tokenized Vault');
    params.append('ERC4626 ERC20');
    let contract = declare('ERC4626');
    let contract_address = contract.deploy(@params).unwrap();
    (asset, IERC4626Dispatcher { contract_address }, contract_address)
}

#[test]
fn constructor() {
    let (asset, dispatcher, _) = deploy_contract();
    assert(dispatcher.asset() == asset, 'invalid asset');
    assert(dispatcher.decimals() == 18, 'invalid decimals');
    assert(dispatcher.name() == 'ERC4626 Tokenized Vault', 'invalid name');
    assert(dispatcher.symbol() == 'ERC4626 ERC20', 'invalid symbol');
}

#[test]
fn convert_to_assets() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.convert_to_assets(42) == 42, 'invalid convert');
}

#[test]
fn convert_to_shares() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.convert_to_shares(42) == 42, 'invalid convert');
}

#[test]
fn deposit() {
    let (asset, dispatcher, vault) = deploy_contract();
    let owner = contract_address_const::<0x42>();
    let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };
    let amount = erc20dispatcher.balance_of(get_contract_address());
    erc20dispatcher.transfer(owner, amount);
    start_prank(asset, owner);
    erc20dispatcher.approve(vault, BoundedU256::max());
    stop_prank(asset);
    start_prank(vault, owner);
    assert(dispatcher.deposit(amount, owner) == amount, 'invalid shares');
    assert(dispatcher.balance_of(owner) == amount, 'invalid balance');
}

#[test]
fn max_deposit() {
    let (asset, dispatcher, _) = deploy_contract();
    assert(
        dispatcher.max_deposit(get_contract_address()) == BoundedU256::max(), 'invalid max deposit'
    );
}

#[test]
fn max_mint() {
    let (asset, dispatcher, _) = deploy_contract();
    assert(dispatcher.max_mint(get_contract_address()) == BoundedU256::max(), 'invalid max mint');
}

#[test]
fn max_redeem() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.max_redeem(get_contract_address()) == 0, 'invalid initial max redeem');
    let owner = contract_address_const::<0x42>();
    let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };
    let amount = erc20dispatcher.balance_of(get_contract_address());
    erc20dispatcher.transfer(owner, amount);
    start_prank(asset, owner);
    erc20dispatcher.approve(vault, BoundedU256::max());
    stop_prank(asset);
    start_prank(vault, owner);
    dispatcher.deposit(amount, owner);
    assert(dispatcher.max_redeem(owner) == amount, 'invalid max redeem');
}

#[test]
fn max_withdraw() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.max_withdraw(get_contract_address()) == 0, 'invalid initial max withdraw');
    let owner = contract_address_const::<0x42>();
    let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };
    let amount = erc20dispatcher.balance_of(get_contract_address());
    erc20dispatcher.transfer(owner, amount);
    start_prank(asset, owner);
    erc20dispatcher.approve(vault, BoundedU256::max());
    stop_prank(asset);
    start_prank(vault, owner);
    dispatcher.deposit(amount, owner);
    assert(dispatcher.max_withdraw(owner) == amount, 'invalid max withdraw');
}

#[test]
fn mint() {
    let (asset, dispatcher, vault) = deploy_contract();
    let owner = contract_address_const::<0x42>();
    let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };
    let amount = erc20dispatcher.balance_of(get_contract_address());
    erc20dispatcher.transfer(owner, amount);
    start_prank(asset, owner);
    erc20dispatcher.approve(vault, BoundedU256::max());
    stop_prank(asset);
    start_prank(vault, owner);
    assert(dispatcher.mint(amount, owner) == amount, 'invalid assets');
    assert(dispatcher.balance_of(owner) == amount, 'invalid balance');
}

#[test]
fn preview_deposit() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.convert_to_shares(42) == 42, 'invalid preview');
}

#[test]
fn preview_mint() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.convert_to_assets(42) == 42, 'invalid preview');
}

#[test]
fn preview_redeem() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.convert_to_assets(42) == 42, 'invalid preview');
}

#[test]
fn preview_withdraw() {
    let (asset, dispatcher, vault) = deploy_contract();
    assert(dispatcher.convert_to_shares(42) == 42, 'invalid preview');
}

#[test]
fn redeem() {
    let (asset, dispatcher, vault) = deploy_contract();
    let owner = contract_address_const::<0x42>();
    let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };
    let amount = erc20dispatcher.balance_of(get_contract_address());
    erc20dispatcher.transfer(owner, amount);
    start_prank(asset, owner);
    erc20dispatcher.approve(vault, BoundedU256::max());
    stop_prank(asset);
    start_prank(vault, owner);
    dispatcher.deposit(amount, owner);
    assert(dispatcher.balance_of(owner) == amount, 'invalid balance');
    assert(dispatcher.redeem(amount, owner, owner) == amount, 'invalid assets');
    assert(dispatcher.balance_of(owner) == 0, 'invalid final balance');
}

#[test]
fn withdraw() {
    let (asset, dispatcher, vault) = deploy_contract();
    let owner = contract_address_const::<0x42>();
    let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };
    let amount = erc20dispatcher.balance_of(get_contract_address());
    erc20dispatcher.transfer(owner, amount);
    start_prank(asset, owner);
    erc20dispatcher.approve(vault, BoundedU256::max());
    stop_prank(asset);
    start_prank(vault, owner);
    dispatcher.deposit(amount, owner);
    assert(dispatcher.balance_of(owner) == amount, 'invalid balance');
    assert(dispatcher.withdraw(amount, owner, owner) == amount, 'invalid shares');
    assert(dispatcher.balance_of(owner) == 0, 'invalid final balance');
}
