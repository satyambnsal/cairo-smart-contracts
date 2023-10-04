#[starknet::contract]
mod DevToken {
    use starknet::ContractAddress;
    use openzeppelin::token::erc20::{ERC20};
    use openzeppelin::token::erc20::interface::{IERC20};

    #[storage]
    struct Storage {}

    #[constructor]
    fn constructor(ref self: ContractState, recipient: ContractAddress, initial_supply: u256) {
        let name = 'DevToken';
        let symbol = 'DEVT';

        let mut unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::InternalImpl::initializer(ref unsafe_state, name, symbol);
        ERC20::InternalImpl::_mint(ref unsafe_state, recipient, initial_supply);
    }

    #[external(v0)]
    impl DevTokenImpl of IERC20<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            let unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::name(@unsafe_state)
        }

        fn symbol(self: @ContractState) -> felt252 {
            let unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::symbol(@unsafe_state)
        }

        fn decimals(self: @ContractState) -> u8 {
            1
        }

        fn total_supply(self: @ContractState) -> u256 {
            let unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::total_supply(@unsafe_state)
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::balance_of(@unsafe_state, account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            let unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::allowance(@unsafe_state, owner, spender)
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let mut unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::transfer(ref unsafe_state, recipient, amount)
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) -> bool {
            let mut unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::transfer_from(ref unsafe_state, sender, recipient, amount)
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            let mut unsafe_state = ERC20::unsafe_new_contract_state();
            ERC20::ERC20Impl::approve(ref unsafe_state, spender, amount)
        }
    }

    #[external(v0)]
    fn totalSupply(self: @ContractState) -> u256 {
        let unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::total_supply(@unsafe_state)
    }


    #[external(v0)]
    fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
        let unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::balance_of(@unsafe_state, account)
    }

    #[external(v0)]
    fn transferFrom(
        ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool {
        let mut unsafe_state = ERC20::unsafe_new_contract_state();
        ERC20::ERC20Impl::transfer_from(ref unsafe_state, sender, recipient, amount)
    }
}
