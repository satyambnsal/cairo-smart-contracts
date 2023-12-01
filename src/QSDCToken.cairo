#[starknet::contract]
mod QSDCToken {
    use openzeppelin::token::erc20::interface::IERC20Metadata;
    use openzeppelin::token::erc20::ERC20Component;
    use openzeppelin::token::erc20::interface;
    use starknet::{ContractAddress, get_caller_address};
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl = ERC20Component::ERC20CamelOnlyImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        decimals: u8
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        let name = 'QSDC Token';
        let symbol = 'QSDC';
        self._set_decimals(2);
        self.erc20.initializer(name, symbol);
        self.erc20._mint(owner, 1_000_000_000);
    }

    #[external(v0)]
    impl ERC20MetadataImpl of interface::IERC20Metadata<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            self.erc20.name()
        }
        fn symbol(self: @ContractState) -> felt252 {
            self.erc20.symbol()
        }
        fn decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _set_decimals(ref self: ContractState, decimals: u8) {
            self.decimals.write(decimals);
        }
    }
}
