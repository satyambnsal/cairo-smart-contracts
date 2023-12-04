#[cfg(test)]
mod StarkVoiceTests {
    use core::serde::Serde;
    use array::ArrayTrait;
    use snforge_std::{declare, ContractClassTrait};
    use starknet::{ContractAddress, contract_address_to_felt252};
    use cairo_contracts::starkvoice::{
        StarkVoice, IStarkVoice, IStarkVoiceDispatcher, IStarkVoiceDispatcherTrait,
    };
    use debug::PrintTrait;


    fn deploy_contract() -> (ContractAddress, IStarkVoiceDispatcher, ContractAddress) {
        let MockERC20 = declare('MockERC20');
        let erc20_token = MockERC20.deploy(@ArrayTrait::<felt252>::new()).unwrap();
        let mut params = ArrayTrait::<felt252>::new();
        let erc20_address = contract_address_to_felt252(erc20_token);
        erc20_address.print();
        params.append(erc20_address);
        params.append('SN Developer DAO');
        let StarkVoiceContract = declare('StarkVoice');
        let contract_address = StarkVoiceContract.deploy(@params).unwrap();
        (erc20_token, IStarkVoiceDispatcher { contract_address }, contract_address)
    }

    #[test]
    fn constructor() {
        let (asset, dispatcher, _) = deploy_contract();
        assert(dispatcher.eligibility_token() == asset, 'Incorrect_token');
    }
}
