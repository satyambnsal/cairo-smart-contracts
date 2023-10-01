#[starknet::interface]
trait ISimpleStorage<TContractState> {
    fn set(ref self: TContractState, x: u128);
    fn get(self: @TContractState) -> u128;
}

#[starknet::contract]
mod SimpleStorageSatyam {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        satyam_lucky_no: u128
    }

    #[external(v0)]
    impl SimpleStorageSatyam of super::ISimpleStorage<ContractState> {
        fn set(ref self: ContractState, x: u128) {
            self.satyam_lucky_no.write(x);
        }
        fn get(self: @ContractState) -> u128 {
            self.satyam_lucky_no.read()
        }
    }
}
