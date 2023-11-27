use array::ArrayTrait;
use starknet::ContractAddress;

// The amount of tokens that can be minted at once.
// Attempt to mint too many tokens can lead
// to large amount of gas being used and long gas estimation
const MAX_MINT_AMOUNT: u256 = 5000;

#[starknet::interface]
trait IERC721IPFSTemplate<TContractState> {
    // Standard ERC721 + ERC721Metadata methods
    fn name(self: @TContractState) -> felt252;
    fn symbol(self: @TContractState) -> felt252;
    fn token_uri(self: @TContractState, token_id: u256) -> Array<felt252>;
    fn supports_interface(self: @TContractState, interface_id: felt252) -> bool;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn get_approved(self: @TContractState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn approve(ref self: TContractState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn transfer_from(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, token_id: u256
    );
    fn safe_transfer_from(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    // camelCase methods that duplicate the main snake_case interface for compatibility
    fn tokenURI(self: @TContractState, tokenId: u256) -> Array<felt252>;
    fn supportsInterface(self: @TContractState, interfaceId: felt252) -> bool;
    fn balanceOf(self: @TContractState, account: ContractAddress) -> u256;
    fn ownerOf(self: @TContractState, tokenId: u256) -> ContractAddress;
    fn getApproved(self: @TContractState, tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(
        self: @TContractState, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn setApprovalForAll(ref self: TContractState, operator: ContractAddress, approved: bool);
    fn transferFrom(
        ref self: TContractState, from: ContractAddress, to: ContractAddress, tokenId: u256
    );
    fn safeTransferFrom(
        ref self: TContractState,
        from: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
        data: Span<felt252>
    );
    // Ownable implementation methods
    fn owner(self: @TContractState) -> ContractAddress;
    fn transfer_ownership(ref self: TContractState, new_owner: ContractAddress);
    fn renounce_ownership(ref self: TContractState);
    // and their camelCase equivalents
    fn transferOwnership(ref self: TContractState, newOwner: ContractAddress);
    fn renounceOwnership(ref self: TContractState);
    // Non-standard method for minting new NFTs. Can be called by admin only
    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
    // methods for retrieving supply
    fn max_supply(self: @TContractState) -> u256;
    fn total_supply(self: @TContractState) -> u256;
    // and their camelCase equivalents
    fn maxSupply(self: @TContractState) -> u256;
    fn totalSupply(self: @TContractState) -> u256;
    // method for setting base URI common for all tokens
    // TODO move this into constructor
    fn set_base_uri(ref self: TContractState, base_uri: Array<felt252>);
}

#[starknet::contract]
mod ERC721IPFSTemplate {
    use starknet::ContractAddress;
    use openzeppelin::token::erc721::ERC721;
    use alexandria_ascii::interger::ToAsciiTrait;
    use openzeppelin::access::ownable::Ownable;

    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        max_supply: u256,
        last_token_id: u256,
        base_uri_len: u32,
        base_uri: LegacyMap<u32, felt252>
    }

    mod Errors {
        const MINT_ZERO_AMOUNT: felt252 = 'mint amount should be >= 1';
        const MINT_AMOUNT_TOO_LARGE: felt252 = 'mint amount too large';
        const MINT_MAX_SUPPLY_EXCEEDED: felt252 = 'max supply exceeded';
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Transfer: Transfer,
        Approval: Approval,
        ApprovalForAll: ApprovalForAll,
        OwnershipTransferred: OwnershipTransferred
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        #[key]
        from: ContractAddress,
        #[key]
        to: ContractAddress,
        #[key]
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        #[key]
        owner: ContractAddress,
        #[key]
        approved: ContractAddress,
        #[key]
        token_id: u256
    }

    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        #[key]
        owner: ContractAddress,
        #[key]
        operator: ContractAddress,
        approved: bool
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred {
        previous_owner: ContractAddress,
        new_owner: ContractAddress,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        admin: ContractAddress,
        name: felt252,
        symbol: felt252,
        max_supply: u256
    ) {
        self.max_supply.write(max_supply);

        let mut unsafe_state = ERC721::unsafe_new_contract_state();
        ERC721::InternalImpl::initializer(ref unsafe_state, name, symbol);

        let mut unsafe_state = Ownable::unsafe_new_contract_state();
        Ownable::InternalImpl::initializer(ref unsafe_state, admin);
    }

    #[external(v0)]
    impl ERC721IPFSTemplateImpl of super::IERC721IPFSTemplate<ContractState> {
        fn name(self: @ContractState) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataImpl::name(@unsafe_state)
        }

        fn symbol(self: @ContractState) -> felt252 {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721MetadataImpl::symbol(@unsafe_state)
        }

        fn token_uri(self: @ContractState, token_id: u256) -> Array<felt252> {
            let mut uri = ArrayTrait::new();

            // retrieve base_uri from the storage and append to the uri string
            let mut i = 0;
            loop {
                if i >= self.base_uri_len.read() {
                    break;
                }
                uri.append(self.base_uri.read(i));
                i += 1;
            };

            let token_id_ascii = token_id.to_ascii();

            let mut i = 0;
            loop {
                if i >= token_id_ascii.len() {
                    break;
                }
                uri.append(*token_id_ascii.at(i));
                i += 1;
            };

            uri.append('.json');
            uri
        }

        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::SRC5Impl::supports_interface(@unsafe_state, interface_id)
        }

        fn supportsInterface(self: @ContractState, interfaceId: felt252) -> bool {
            let unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::SRC5CamelImpl::supportsInterface(@unsafe_state, interfaceId)
        }

        fn tokenURI(self: @ContractState, tokenId: u256) -> Array<felt252> {
            ERC721IPFSTemplateImpl::token_uri(self, tokenId)
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

        fn approve(ref self: ContractState, to: ContractAddress, token_id: u256) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::approve(ref unsafe_state, to, token_id)
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: ContractAddress, approved: bool
        ) {
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            ERC721::ERC721Impl::set_approval_for_all(ref unsafe_state, operator, approved)
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

        fn owner(self: @ContractState) -> ContractAddress {
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::owner(@unsafe_state)
        }

        fn transfer_ownership(ref self: ContractState, new_owner: ContractAddress) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::transfer_ownership(ref unsafe_state, new_owner);
        }

        fn renounce_ownership(ref self: ContractState) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableImpl::renounce_ownership(ref unsafe_state)
        }

        fn transferOwnership(ref self: ContractState, newOwner: ContractAddress) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableCamelOnlyImpl::transferOwnership(ref unsafe_state, newOwner)
        }

        fn renounceOwnership(ref self: ContractState) {
            let mut unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::OwnableCamelOnlyImpl::renounceOwnership(ref unsafe_state)
        }

        // Non-standard method for minting new NFTs. Can be called by admin only
        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            // check if sender is the owner of the contract
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::assert_only_owner(@unsafe_state);
            assert(amount > 0, Errors::MINT_ZERO_AMOUNT);
            // check mint amount validity
            assert(amount <= super::MAX_MINT_AMOUNT, Errors::MINT_AMOUNT_TOO_LARGE);
            // get the last id
            let last_token_id = self.last_token_id.read();
            // calculate the last id after mint (maybe use safe math if available)
            let last_mint_id = last_token_id + amount;
            // don't mint more than the preconfigured max supply
            let max_supply = self.max_supply.read();
            assert(last_mint_id <= max_supply, Errors::MINT_MAX_SUPPLY_EXCEEDED);
            // call mint sequentially
            let mut unsafe_state = ERC721::unsafe_new_contract_state();
            let mut token_id = last_token_id + 1;
            loop {
                if token_id > last_mint_id {
                    break;
                }
                ERC721::InternalImpl::_mint(ref unsafe_state, recipient, token_id);
                token_id += 1;
            };
            // Save the id of last minted token
            self.last_token_id.write(last_mint_id);
        }

        fn max_supply(self: @ContractState) -> u256 {
            self.max_supply.read()
        }

        fn total_supply(self: @ContractState) -> u256 {
            self.last_token_id.read()
        }

        fn maxSupply(self: @ContractState) -> u256 {
            ERC721IPFSTemplateImpl::max_supply(self)
        }

        fn totalSupply(self: @ContractState) -> u256 {
            ERC721IPFSTemplateImpl::total_supply(self)
        }

        fn set_base_uri(ref self: ContractState, base_uri: Array<felt252>) {
            // check if sender is the owner of the contract
            let unsafe_state = Ownable::unsafe_new_contract_state();
            Ownable::InternalImpl::assert_only_owner(@unsafe_state);

            let base_uri_len = base_uri.len();
            let mut i = 0;
            self.base_uri_len.write(base_uri_len);
            loop {
                if i >= base_uri.len() {
                    break;
                }
                self.base_uri.write(i, *base_uri.at(i));
                i += 1;
            }
        }
    }
}

#[cfg(test)]
mod tests {
    // Import the interface and dispatcher to be able to interact with the contract.
    use super::{
        ERC721IPFSTemplate, IERC721IPFSTemplateDispatcher, IERC721IPFSTemplateDispatcherTrait
    };

    // Import the deploy syscall to be able to deploy the contract.
    use starknet::class_hash::Felt252TryIntoClassHash;
    use starknet::{
        deploy_syscall, ContractAddress, get_caller_address, get_contract_address,
        contract_address_const
    };

    // Use starknet test utils to fake the transaction context.
    use starknet::testing::{set_caller_address, set_contract_address};

    // Deploy the contract and return its dispatcher.
    fn deploy(
        owner: ContractAddress, name: felt252, symbol: felt252, max_supply: u256
    ) -> IERC721IPFSTemplateDispatcher {
        // Set up constructor arguments.
        let mut calldata = ArrayTrait::new();
        owner.serialize(ref calldata);
        name.serialize(ref calldata);
        symbol.serialize(ref calldata);
        max_supply.serialize(ref calldata);

        // Declare and deploy
        let (contract_address, _) = deploy_syscall(
            ERC721IPFSTemplate::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
        )
            .unwrap();

        // Return the dispatcher.
        // The dispatcher allows to interact with the contract based on its interface.
        IERC721IPFSTemplateDispatcher { contract_address }
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_deploy() {
        let owner = contract_address_const::<1>();
        let name = 'Cool Token';
        let symbol = 'COOL';
        let max_supply = 100000;
        let contract = deploy(owner, name, symbol, max_supply);

        assert(contract.name() == name, 'wrong name');
        assert(contract.symbol() == symbol, 'wrong symbol');
        assert(contract.max_supply() == max_supply, 'wrong max supply');
        assert(contract.owner() == owner, 'wrong admin');
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_mint() {
        let owner = contract_address_const::<123>();
        set_contract_address(owner);
        let contract = deploy(owner, 'Token', 'T', 300);

        // set the base URI
        let base_uri = array![
            'ipfs://lllllllllllllooooooooooo',
            'nnnnnnnnnnngggggggggggggggggggg',
            'aaaaddddddrrrrrreeeeeeesssss'
        ];
        contract.set_base_uri(base_uri.clone());

        let recipient = contract_address_const::<1>();
        contract.mint(recipient, 100);
        contract.mint(recipient, 50);

        assert(contract.total_supply() == 150, 'wrong total supply');
        assert(contract.balance_of(recipient) == 150, 'wrong balance after mint');
        assert(contract.owner_of(150) == recipient, 'wrong owner');
        let token_uri_array = contract.token_uri(150);
        assert(*token_uri_array.at(0) == *base_uri.at(0), 'wrong token uri (part 1)');
        assert(*token_uri_array.at(1) == *base_uri.at(1), 'wrong token uri (part 2)');
        assert(*token_uri_array.at(2) == *base_uri.at(2), 'wrong token uri (part 3)');
        assert(*token_uri_array.at(3) == '150', 'wrong token uri (token id)');
        assert(*token_uri_array.at(4) == '.json', 'wrong token uri (suffix)');
    }

    #[test]
    #[available_gas(2000000000)]
    fn test_mint_all_amount() {
        let owner = contract_address_const::<123>();
        set_contract_address(owner);

        let contract = deploy(owner, 'Token', 'T', 300);

        let recipient = contract_address_const::<1>();
        contract.mint(recipient, 300);
    }

    #[test]
    #[should_panic]
    #[available_gas(2000000000)]
    fn test_mint_not_admin() {
        let admin = contract_address_const::<1>();
        set_contract_address(admin);

        let contract = deploy(admin, 'Token', 'T', 300);

        let not_admin = contract_address_const::<2>();
        set_contract_address(not_admin);

        contract.mint(not_admin, 100);
    }

    #[test]
    #[should_panic]
    #[available_gas(2000000000)]
    fn test_mint_too_much() {
        let contract = deploy(contract_address_const::<123>(), 'Token', 'T', 300);
        contract.mint(get_contract_address(), 301);
    }
}
