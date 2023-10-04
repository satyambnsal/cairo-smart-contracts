#[starknet::contract]
mod MyToken {
    use core::option::OptionTrait;
    use starknet::ContractAddress;
    use openzeppelin::token::erc20::ERC20;
    use starknet::contract_address_const;

    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(ref self: ContractState) {
        let name = 'MyToken';
        let symbol = 'MTK';
        let initial_supply = 1000000;
        let supply: u256 = initial_supply.into();
        let recipient: ContractAddress =
            0x32aee2a95f251a984a391fb2919757a9074065f3c12b010a142c9fd939e9339
            .try_into()
            .unwrap();

        let mut unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::InternalImpl::initializer(ref unsafe_state, name, symbol);
        ERC20::InternalImpl::_mint(ref unsafe_state, recipient, supply);
    }

    #[external(v0)]
    fn name(self: @ContractState) -> felt252 {
        let unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::name(@unsafe_state)
    }

    #[external(v0)]
    fn symbol(self: @ContractState) -> felt252 {
        let unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::symbol(@unsafe_state)
    }

    #[external(v0)]
    fn decimals(self: @ContractState) -> u8 {
        let unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::decimals(@unsafe_state)
    }

    #[external(v0)]
    fn total_supply(self: @ContractState) -> u256 {
        let unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::total_supply(@unsafe_state)
    }

    #[external(v0)]
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        let unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::balance_of(@unsafe_state, account)
    }

    #[external(v0)]
    fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
        let mut unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::transfer(ref unsafe_state, recipient, amount)
    }
}
