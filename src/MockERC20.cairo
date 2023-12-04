#[starknet::contract]
mod MockERC20 {
    use openzeppelin::token::erc20::{ERC20Component, interface::{IERC20, IERC20Metadata}};
    use starknet::{ContractAddress, get_caller_address};

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        ERC20InternalImpl::initializer(ref self.erc20, 'MockERC20', 'M-ERC20');
        ERC20InternalImpl::_mint(ref self.erc20, get_caller_address(), 1_000_000_000);
    }
}