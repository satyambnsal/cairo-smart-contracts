use starknet::ContractAddress;

#[starknet::interface]
trait INameRegistryV2<T> {
    fn store_name(ref self: T, name: felt252);
    fn get_name(self: @T, address: ContractAddress) -> felt252;
}

#[starknet::contract]
mod NameRegistryV2 {

    use super::INameRegistryV2;
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        names: LegacyMap::<ContractAddress, felt252>,
        total_names: u128,
        owner: Person
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: Person) {
        self.names.write(owner.address, owner.name);
        self.total_names.write(1);
        self.owner.write(owner);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        StoredName: StoredName
    }

    #[derive(Drop, starknet::Event)]
    struct StoredName {
        #[key]
        user: ContractAddress,
        name: felt252
    }

    #[derive(Drop, Copy, Serde, starknet::Store)]
    struct Person {
        name: felt252,
        address: ContractAddress
    }

    #[external(v0)]
    impl NameRegistryV2 of INameRegistryV2<ContractState> {
        fn store_name(ref self: ContractState, name: felt252) {
            let caller = get_caller_address();
            self._store_name(caller, name);
        }

        fn get_name(self: @ContractState, address: ContractAddress) -> felt252 {
            self.names.read(address)
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _store_name(ref self: ContractState, user: ContractAddress, name: felt252) {
            let mut total_names = self.total_names.read();
            self.names.write(user, name);
            self.total_names.write(total_names + 1);
            // Emit event
            self.emit(StoredName {user, name});
        }
    }

    fn _get_contract_name() -> felt252 {
        'Name Registry V2'
    }

}