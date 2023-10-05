#[starknet::contract]
mod SillyApes {
    use starknet::{ContractAddress, get_caller_address};
    use openzeppelin::token::erc721::{ERC721};
    use openzeppelin::token::erc721::interface::{IERC721};
    use openzeppelin::access::ownable::Ownable;


    #[storage]
    struct Storage {
        base_uri: felt252
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name: felt252,
        symbol: felt252,
        recipient: ContractAddress,
        token_id: u256
    ) {
        let mut unsafe_state_erc721 = ERC721::unsafe_new_contract_state();
        let mut unsafe_state_ownable = Ownable::unsafe_new_contract_state();
        ERC721::InternalImpl::initializer(ref unsafe_state_erc721, name, symbol);
        Ownable::InternalImpl::initializer(ref unsafe_state_ownable, recipient);

        ERC721::InternalImpl::_mint(ref unsafe_state_erc721, recipient, token_id);
    }


    #[external(v0)]
    fn name(self: @ContractState) -> felt252 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721MetadataImpl::name(@unsafe_state)
    }

    #[external(v0)]
    fn symbol(self: @ContractState) -> felt252 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721MetadataImpl::name(@unsafe_state)
    }

    #[external(v0)]
    fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721Impl::approve(ref unsafe_state, to, token_id)
    }


    #[external(v0)]
    fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721MetadataImpl::token_uri(@unsafe_state, token_id)
    }


    #[external(v0)]
    fn transfer_from(
        ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    ) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721Impl::transfer_from(ref unsafe_state, from, to, token_id)
    }

    #[external(v0)]
    fn safe_transfer_from(
        ref self: ContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    ) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721Impl::safe_transfer_from(ref unsafe_state, from, to, token_id, data)
    }


    #[external(v0)]
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721Impl::balance_of(@unsafe_state, account)
    }

    #[external(v0)]
    fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721Impl::owner_of(@unsafe_state, token_id)
    }

    #[external(v0)]
    fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721Impl::get_approved(@unsafe_state, token_id)
    }

    #[external(v0)]
    fn mint_token(ref self: ContractState, recipient: ContractAddress, token_id: u256) {
        let unsafe_state_ownable = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::assert_only_owner(@unsafe_state_ownable);

        let mut unsafe_state_erc721 = ERC721::unsafe_new_contract_state();
        ERC721::InternalImpl::_mint(ref unsafe_state_erc721, recipient, token_id);
    }

    #[external(v0)]
    fn set_token_uri(ref self: ContractState, token_id: u256, token_uri: felt252) {
        let unsafe_state_ownable = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::assert_only_owner(@unsafe_state_ownable);

        // let caller: ContractAddress = get_caller_address();
        // let owner: ContractAddress = ERC721::ERC721Impl::owner_of(@unsafe_state, token_id);
        // assert(owner == caller, "CALLER_IS_NOT_OWNER");

        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::InternalImpl::_set_token_uri(ref unsafe_state, token_id, token_uri);
    }

    //CamelCase Method Implementations

    #[external(v0)]
    fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721CamelOnlyImpl::balanceOf(@unsafe_state, account)
    }


    #[external(v0)]
    fn ownerOf(self: @ContractState, token_id: u256) -> ContractAddress {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721CamelOnlyImpl::ownerOf(@unsafe_state, token_id)
    }

    #[external(v0)]
    fn getApproved(self: @ContractState, token_id: u256) -> ContractAddress {
        let unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721CamelOnlyImpl::getApproved(@unsafe_state, token_id)
    }

    #[external(v0)]
    fn transferFrom(
        ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    ) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721CamelOnlyImpl::transferFrom(ref unsafe_state, from, to, token_id)
    }

    #[external(v0)]
    fn safeTransferFrom(
        ref self: ContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    ) {
        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::ERC721CamelOnlyImpl::safeTransferFrom(ref unsafe_state, from, to, token_id, data)
    }
}
