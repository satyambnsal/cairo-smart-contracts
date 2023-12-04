use starknet::ContractAddress;

#[starknet::interface]
trait IStarkVoice<TContractState> {
    fn get_vote_status(self: @TContractState, proposal_id: u64) -> (u256, u256, u8, u8);
    fn vote(ref self: TContractState, proposal_id: u64, vote: u8);
    fn voter_can_vote(
        self: @TContractState, user_address: ContractAddress, proposal_id: u64
    ) -> bool;
    fn get_proposal_title(self: @TContractState, proposal_id: u64) -> (felt252, felt252, felt252);
    fn create_proposal(ref self: TContractState, title: (felt252, felt252, felt252), details_ipfs_url: (felt252, felt252, felt252)) -> u64;
    fn eligibility_token(self: @TContractState) -> ContractAddress;
}

#[starknet::contract]
mod StarkVoice {
    use starknet::{ContractAddress, get_caller_address, get_block_timestamp};
    use alexandria_storage::list::{List, ListTrait};
    use openzeppelin::token::erc20::{ERC20ABIDispatcher, interface::{ERC20ABIDispatcherTrait}};

    const YES: u8 = 1_u8;
    const NO: u8 = 0_u8;

    #[storage]
    struct Storage {
        owner: ContractAddress,
        eligibility_token: ContractAddress,
        proposal_count: u64,
        proposals: LegacyMap<u64, Proposal>,
        has_voted: LegacyMap<(u64, ContractAddress), bool>,
        name: felt252,
        id: u64
    }

    #[derive(Drop, Serde, starknet::Store)]
    struct Proposal {
        proposal_id: u64,
        yes_votes: u256,
        no_votes: u256,
        details_ipfs_url: (felt252, felt252, felt252),
        title: (felt252, felt252, felt252),
    }

    #[constructor]
    fn constructor(ref self: ContractState, eligibility_token: ContractAddress, name: felt252) {
        let admin = get_caller_address();

        let erc20_token = ERC20ABIDispatcher { contract_address: eligibility_token };
        let balance = erc20_token.balance_of(admin);
        assert(balance > 0, 'TOKEN_BALANCE_IS_ZERO');

        // initialize storage 
        self.proposal_count.write(0);
        self.eligibility_token.write(eligibility_token);
        self.owner.write(admin);
        self.name.write(name);
        let id: u64 = get_block_timestamp();
        self.id.write(id);

        self.emit(NewSpace {name,id});
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        NewProposal: NewProposal,
        VoteCast: VoteCast,
        UnauthorizedAttempt: UnauthorizedAttempt,
        NewSpace: NewSpace
    }

    #[derive(Drop, starknet::Event)]
    struct VoteCast {
        voter: ContractAddress,
        proposal_id: u64,
        vote: u8
    }

    #[derive(Drop, starknet::Event)]
    struct UnauthorizedAttempt {
        unauthorized_address: ContractAddress,
        proposal_id: u64
    }

    #[derive(Drop, starknet::Event)]
    struct NewProposal {
        proposal_id: u64,
        title: (felt252, felt252, felt252),
    }

    #[derive(Drop, starknet::Event)]
    struct NewSpace {
        #[key]        
        id: u64,
        name: felt252
    }

    #[external(v0)]
    impl StarkVoiceImpl of super::IStarkVoice<ContractState> {
        fn create_proposal(
            ref self: ContractState, title: (felt252, felt252, felt252), details_ipfs_url: (felt252, felt252, felt252)
        ) -> u64 {
            let proposal_count = self.proposal_count.read();
            let proposal_id = proposal_count + 1;
            let proposal = Proposal {
                proposal_id, yes_votes: 0, no_votes: 0,
                title,
                details_ipfs_url
            };
            self.proposals.write(proposal_id, proposal);
            self.emit(NewProposal { proposal_id, title });
            proposal_id
        }

        fn get_vote_status(self: @ContractState, proposal_id: u64) -> (u256, u256, u8, u8) {
            let (yes_votes, no_votes) = self._get_voting_result(proposal_id);
            let (yes_percentage, no_percentage) = self
                ._get_voting_result_in_percentage(proposal_id);
            (yes_votes, no_votes, yes_percentage, no_percentage)
        }

        fn vote(ref self: ContractState, proposal_id: u64, vote: u8) {
            assert(vote == YES || vote == NO, 'VOTE_MUST_BE_0_OR_1');
            let caller: ContractAddress = get_caller_address();
            self._assert_vote_allowed(caller, proposal_id);
            self.has_voted.write((proposal_id, caller), false);
            let mut proposal = self.proposals.read(proposal_id);
            let vote_count = self._token_balance();

            if (vote == NO) {
                proposal.no_votes = proposal.no_votes + vote_count;
            }
            if (vote == YES) {
                proposal.yes_votes = proposal.yes_votes + vote_count;
            }
            self.proposals.write(proposal_id, proposal);

            self.emit(VoteCast { voter: caller, vote, proposal_id })
        }

        fn voter_can_vote(
            self: @ContractState, user_address: ContractAddress, proposal_id: u64
        ) -> bool {
            self._can_vote(user_address, proposal_id)
        }

        fn get_proposal_title(self: @ContractState, proposal_id: u64) -> (felt252, felt252, felt252) {
            let proposal = self.proposals.read(proposal_id);
            proposal.title
        }

        fn eligibility_token(self: @ContractState) -> ContractAddress {
            self.eligibility_token.read()
        }
    }


    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _assert_vote_allowed(
            ref self: ContractState, user_address: ContractAddress, proposal_id: u64
        ) {
            let has_tokens = self._has_tokens();
            let has_voted = self.has_voted.read((proposal_id, user_address));

            if (has_voted == true) {
                self.emit(UnauthorizedAttempt { unauthorized_address: user_address, proposal_id });
            }

            if (has_tokens == false) {
                self.emit(UnauthorizedAttempt { unauthorized_address: user_address, proposal_id });
            }

            assert(has_tokens == true, 'INSUFFICIENT_TOKEN_BALANCE');
            assert(has_voted == false, 'USER_ALREADY_VOTED')
        }
        fn _can_vote(
            self: @ContractState, user_address: ContractAddress, proposal_id: u64
        ) -> bool {
            let has_tokens = self._has_tokens();
            let has_voted = self.has_voted.read((proposal_id, user_address));

            if (has_tokens && has_voted == false) {
                true
            } else {
                false
            }
        }
    }

    #[generate_trait]
    impl VoteResultMethodImpl of VoteResultMethodImplTrait {
        fn _get_voting_result(self: @ContractState, proposal_id: u64) -> (u256, u256) {
            let proposal = self.proposals.read(proposal_id);
            let yes_votes: u256 = proposal.yes_votes;
            let no_votes: u256 = proposal.no_votes;
            (yes_votes, no_votes)
        }

        fn _get_voting_result_in_percentage(self: @ContractState, proposal_id: u64) -> (u8, u8) {
            let proposal = self.proposals.read(proposal_id);
            let yes_votes = proposal.yes_votes;
            let no_votes = proposal.no_votes;

            let total_votes: u256 = yes_votes + no_votes;

            if (total_votes == 0) {
                return (0, 0);
            }

            let yes_percentage: u8 = ((yes_votes * 100_u256) / (total_votes)).try_into().unwrap();
            let no_percentage: u8 = ((no_votes * 100_u256) / (total_votes)).try_into().unwrap();

            (yes_percentage, no_percentage)
        }
    }

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn _token_balance(self: @ContractState) -> u256 {
            let admin = get_caller_address();

            let eligibility_token_address = self.eligibility_token.read();
            let eligibility_token = ERC20ABIDispatcher {
                contract_address: eligibility_token_address
            };
            let balance = eligibility_token.balance_of(admin);
            balance
        }

        fn _has_tokens(self: @ContractState) -> bool {
            let balance = self._token_balance();
            if (balance > 0) {
                true
            } else {
                false
            }
        }
    }
}