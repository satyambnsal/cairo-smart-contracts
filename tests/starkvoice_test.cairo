#[cfg(test)]
mod StarkVoiceTests {
    use core::serde::Serde;
    use array::ArrayTrait;
    use snforge_std::{declare, ContractClassTrait, CheatTarget, start_prank, stop_prank};
    use starknet::{
        ContractAddress, contract_address_to_felt252, contract_address_const, get_contract_address
    };
    use cairo_contracts::starkvoice::{
        StarkVoice, IStarkVoice, IStarkVoiceDispatcher, IStarkVoiceDispatcherTrait,
    };
    use openzeppelin::token::erc20::{ERC20ABIDispatcher, interface::ERC20ABIDispatcherTrait};
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

    fn create_proposal(asset: ContractAddress, dispatcher: IStarkVoiceDispatcher) -> u64 {
        let title: (felt252, felt252, felt252) = ('SN Developer ', 'DAO', 'test');
        let (t1, t2, t3) = title;
        let details_ipfs_url: (felt252, felt252, felt252) = ('https://', 'a', '.json');

        let proposal_id = dispatcher.create_proposal(title, details_ipfs_url);
        proposal_id
    }

    #[test]
    fn test_constructor() {
        let (asset, dispatcher, _) = deploy_contract();
        assert(dispatcher.eligibility_token() == asset, 'Incorrect_token');
    }

    #[test]
    fn test_create_proposal() {
        let (asset, dispatcher, _) = deploy_contract();
        let title: (felt252, felt252, felt252) = ('SN Developer ', 'DAO', 'test');
        let (t1, t2, t3) = title;
        let details_ipfs_url: (felt252, felt252, felt252) = ('https://', 'a', '.json');

        let proposal_id = dispatcher.create_proposal(title, details_ipfs_url);
        assert(proposal_id == 1, 'INCORRECT_PROPOSAL_ID');
        let proposal_title = dispatcher.get_proposal_title(proposal_id);
        let (first_part, second_part, third_part) = proposal_title;
        first_part.print();
        t1.print();
        assert(first_part == t1, 'INCORRECT_FIRST_PART');
        assert(second_part == t2, 'INCORRECT_SECOND_PART');
        assert(third_part == t3, 'INCORRECT_THIRD_PART')
    }

    #[test]
    fn test_yes_vote() {
        let (asset, dispatcher, contract_address) = deploy_contract();
        let proposal_id = create_proposal(asset, dispatcher);
        let owner = contract_address_const::<0x42>();
        let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };

        let amount = erc20dispatcher.balance_of(get_contract_address());

        erc20dispatcher.transfer(owner, amount);
        start_prank(CheatTarget::One(contract_address), owner);
        dispatcher.vote(proposal_id, 1);

        let (yes_votes, _, _, _) = dispatcher.get_vote_status(proposal_id);
        assert(yes_votes == amount, 'Incorrect yes votes')
    }
    #[test]
    fn test_no_vote() {
        let (asset, dispatcher, contract_address) = deploy_contract();
        let proposal_id = create_proposal(asset, dispatcher);
        let owner = contract_address_const::<0x42>();
        let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };

        let amount = erc20dispatcher.balance_of(get_contract_address());

        erc20dispatcher.transfer(owner, amount);
        start_prank(CheatTarget::One(contract_address), owner);
        dispatcher.vote(proposal_id, 0);
        stop_prank(CheatTarget::One(contract_address));

        let (_, no_votes, _, _) = dispatcher.get_vote_status(proposal_id);
        assert(no_votes == amount, 'Incorrect no votes')
    }

    #[test]
    fn test_percentage_vote() {
        let (asset, dispatcher, contract_address) = deploy_contract();
        let proposal_id = create_proposal(asset, dispatcher);
        let erc20dispatcher = ERC20ABIDispatcher { contract_address: asset };
        let user1 = contract_address_const::<0x1>();
        let user2 = contract_address_const::<0x2>();
        let user3 = contract_address_const::<0x3>();
        let user4 = contract_address_const::<0x4>();

        erc20dispatcher.transfer(user1, 100);
        erc20dispatcher.transfer(user2, 300);
        erc20dispatcher.transfer(user3, 250);
        erc20dispatcher.transfer(user4, 350);

        // Yes votes from user1 and user2
        start_prank(CheatTarget::One(contract_address), user1);
        dispatcher.vote(proposal_id, 1);
        stop_prank(CheatTarget::One(contract_address));

        start_prank(CheatTarget::One(contract_address), user2);
        dispatcher.vote(proposal_id, 1);
        stop_prank(CheatTarget::One(contract_address));

        // No votes from user1 and user2
        start_prank(CheatTarget::One(contract_address), user3);
        dispatcher.vote(proposal_id, 0);
        stop_prank(CheatTarget::One(contract_address));

        start_prank(CheatTarget::One(contract_address), user4);
        dispatcher.vote(proposal_id, 0);
        stop_prank(CheatTarget::One(contract_address));

        let (yes_votes, no_votes, yes_votes_percentage, no_votes_percentage) = dispatcher
            .get_vote_status(proposal_id);
        'Yes votes'.print();
        yes_votes.print();
        'No Votes'.print();
        no_votes.print();
        assert(yes_votes == 400, 'Incorrect yes votes');
        assert(no_votes == 600, 'Incorrect no votes');
        assert(yes_votes_percentage == 40, 'Incorrect yes votes percentage');
        assert(no_votes_percentage == 60, 'Incorrect no votes percentage');
    }
}
