#[starknet::contract]
mod SillyApes {
    use starknet::{ContractAddress, get_caller_address};
    use openzeppelin::token::erc721::{ERC721};
    use openzeppelin::token::erc721::interface::{
        IERC721, IERC721Metadata, IERC721MetadataCamelOnly, IERC721CamelOnly,
    };
    use openzeppelin::introspection::interface::ISRC5Camel;
    use openzeppelin::introspection::src5::SRC5;
    use openzeppelin::token::erc721::dual721::{DualCaseERC721, DualCaseERC721Impl};
    use openzeppelin::access::ownable::Ownable;
    use openzeppelin::utils::UnwrapAndCast;
    use openzeppelin::utils::selectors;
    use openzeppelin::utils::serde::SerializedAppend;
    use openzeppelin::utils::try_selector_with_fallback;

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
    impl ERC721MetaDataImpl of IERC721Metadata<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataImpl::name(@unsafe_state)
        }
        fn symbol(self: @ContractState) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataImpl::name(@unsafe_state)
        }

        fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataImpl::token_uri(@unsafe_state, token_id)
        }
    }

    #[external(v0)]
    impl IERC721MetadataCamelOnlyImpl of IERC721MetadataCamelOnly<ContractState> {
        fn tokenURI(self: @ContractState, tokenId: u256) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataCamelOnlyImpl::tokenURI(@unsafe_state, tokenId)
        }
    }


    #[external(v0)]
    impl IERC721Impl of IERC721<ContractState> {
        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::approve(ref unsafe_state, to, token_id)
        }

        fn transfer_from(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, token_id: u256
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::transfer_from(ref unsafe_state, from, to, token_id)
        }

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

        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::balance_of(@unsafe_state, account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::owner_of(@unsafe_state, token_id)
        }

        fn get_approved(self: @ContractState, token_id: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::get_approved(@unsafe_state, token_id)
        }

        fn is_approved_for_all(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::is_approved_for_all(@unsafe_state, owner, operator)
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::set_approval_for_all(ref unsafe_state, operator, approved)
        }
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
    impl IERC721CamelOnlyImpl of IERC721CamelOnly<ContractState> {
        fn balanceOf(self: @ContractState, account: ContractAddress) -> u256 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::balanceOf(@unsafe_state, account)
        }

        fn ownerOf(self: @ContractState, tokenId: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::ownerOf(@unsafe_state, tokenId)
        }

        fn getApproved(self: @ContractState, tokenId: u256) -> ContractAddress {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::getApproved(@unsafe_state, tokenId)
        }

        fn transferFrom(
            ref self: ContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::transferFrom(ref unsafe_state, from, to, tokenId)
        }

        fn safeTransferFrom(
            ref self: ContractState,
            from: ContractAddress,
            to: ContractAddress,
            tokenId: u256,
            data: Span<felt252>
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::safeTransferFrom(ref unsafe_state, from, to, tokenId, data)
        }

        fn isApprovedForAll(
            self: @ContractState, owner: ContractAddress, operator: ContractAddress
        ) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::isApprovedForAll(@unsafe_state, owner, operator)
        }

        fn setApprovalForAll(ref self: ContractState, operator: ContractAddress, approved: bool) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721CamelOnlyImpl::setApprovalForAll(ref unsafe_state, operator, approved)
        }
    }

    #[external(v0)]
    impl SRC5CamelImpl of ISRC5Camel<ContractState> {
        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            let unsafe_state = SRC5::unsafe_new_contract_state();
            SRC5::SRC5CamelImpl::supportsInterface(@unsafe_state, interfaceId)
        }
    }
}
