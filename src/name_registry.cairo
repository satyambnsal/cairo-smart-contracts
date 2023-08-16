use starknet::ContractAddress;

#[starknet::interface]
trait INameRegistry<TContractState> {
    fn store_name(ref self: TContractState, name: felt252);
    fn get_name(self: @TContractState, address: ContractAddress) -> felt252;
}

#[starknet::contract]
mod NameRegistry {
    use starknet::{ContractAddress, get_caller_address};

    #[storage]
    struct Storage {
        names: LegacyMap::<ContractAddress, felt252>,
        total_names: u128,
        owner: Person
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

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Person {
        name: felt252,
        address: ContractAddress
    }

    #[constructor]
    fn constructor(ref self: ContractState, address: ContractAddress) {
        self.names.write(address, 91678031044973);
        self.total_names.write(1);
        self.owner.write(Person { name: 91678031044973, address });
    }

    #[external(v0)]
    impl NameRegistry of super::INameRegistry<ContractState> {
        fn store_name(ref self: ContractState, name: felt252) {
            let caller = get_caller_address();
            self._store_name(caller, name);
        }

        fn get_name(self: @ContractState, address: ContractAddress) -> felt252 {
            let name = self.names.read(address);
            name
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _store_name(ref self: ContractState, user: ContractAddress, name: felt252) {
            let mut total_names = self.total_names.read();
            self.names.write(user, name);
            self.total_names.write(total_names + 1);
            self.emit(Event::StoredName(StoredName { user: user, name: name }));
        }
    }

    fn _get_contract_name() -> felt252 {
        'Name Registry'
    }
}
