#[starknet::interface]
trait IMyLuckyNo<TContractState> {
    fn get_no(self: @TContractState) -> u32;
    fn set_no(ref self: TContractState, x: u32);
}

#[starknet::contract]
mod MyLuckyNo {
    use super::IMyLuckyNo;
    #[storage]
    struct Storage {
        my_lucky_no: u32,
    }

    #[external(v0)]
    impl IMyLuckyNoImpl of IMyLuckyNo<ContractState> {
        fn get_no(self: @ContractState) -> u32 {
            self.my_lucky_no.read()
        }

        fn set_no(ref self: ContractState, x: u32) {
            self.my_lucky_no.write(x);
        }
    }
}
