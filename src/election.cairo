use starknet::ContractAddress;

#[starknet::interface]
trait ElectionTrait<TContractState> {
    fn get_vote_status(self: @TContractState) -> (u8, u8, u8, u8);
    fn vote(ref self: TContractState, vote: u8);
    fn voter_can_vote(self: @TContractState, user_address: ContractAddress) -> bool;
    fn is_voter_registered(self: @TContractState, user_address: ContractAddress) -> bool;
}

#[starknet::contract]
mod Election {
    use starknet::{ContractAddress, get_caller_address};

    const YES: u8 = 1_u8;
    const NO: u8 = 0_u8;

    #[storage]
    struct Storage {
        yes_votes: u8,
        no_votes: u8,
        can_vote: LegacyMap::<ContractAddress, bool>,
        registered_voter: LegacyMap::<ContractAddress, bool>
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        voter_1: ContractAddress,
        voter_2: ContractAddress,
        voter_3: ContractAddress
    ) {
        self._register_voters(voter_1, voter_2, voter_3);
        self.yes_votes.write(0_u8);
        self.no_votes.write(0_u8);
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        VoteCast: VoteCast,
        UnauthorizedAttempt: UnauthorizedAttempt
    }

    #[derive(Drop, starknet::Event)]
    struct VoteCast {
        voter: ContractAddress,
        vote: u8
    }

    #[derive(Drop, starknet::Event)]
    struct UnauthorizedAttempt {
        unauthorized_address: ContractAddress,
    }


    #[external(v0)]
    impl ElectionImpl of super::ElectionTrait<ContractState> {
        fn get_vote_status(self: @ContractState) -> (u8, u8, u8, u8) {
            let (yes_votes, no_votes) = self._get_voting_result();
            let (yes_votes_perc, no_votes_perc) = self._get_voting_result_in_percentage();
            (yes_votes, no_votes, yes_votes_perc, no_votes_perc)
        }

        fn vote(ref self: ContractState, vote: u8) {
            assert(vote == YES || vote == NO, 'Vote_0_OR_1');
            let caller: ContractAddress = get_caller_address();

            // check if user is allowed to vote
            self._assert_vote_allowed(caller);

            self.can_vote.write(caller, false);
            if (vote == NO) {
                self.no_votes.write(self.no_votes.read() + 1_u8);
            }
            if (vote == YES) {
                self.yes_votes.write(self.yes_votes.read() + 1_u8);
            }
            self.emit(VoteCast { voter: caller, vote });
        }

        fn voter_can_vote(self: @ContractState, user_address: ContractAddress) -> bool {
            self.can_vote.read(user_address)
        }
        fn is_voter_registered(self: @ContractState, user_address: ContractAddress) -> bool {
            self.registered_voter.read(user_address)
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        fn _register_voters(
            ref self: ContractState,
            voter_1: ContractAddress,
            voter_2: ContractAddress,
            voter_3: ContractAddress
        ) {
            self.registered_voter.write(voter_1, true);
            self.can_vote.write(voter_1, true);

            self.registered_voter.write(voter_2, true);
            self.can_vote.write(voter_2, true);

            self.registered_voter.write(voter_3, true);
            self.can_vote.write(voter_3, true);
        }

        fn _assert_vote_allowed(ref self: ContractState, user_address: ContractAddress) {
            let is_voter: bool = self.registered_voter.read(user_address);
            let can_vote = self.can_vote.read(user_address);

            if (can_vote == false) {
                self.emit(UnauthorizedAttempt { unauthorized_address: user_address });
            }

            assert(is_voter == true, 'USER_NOT_REGISTERED');
            assert(can_vote == true, 'USER_ALREADY_VOTED');
        }
    }


    #[generate_trait]
    impl VoteResultMethodImpl of VoteResultMethodImplTrait {
        fn _get_voting_result(self: @ContractState) -> (u8, u8) {
            let yes_votes: u8 = self.yes_votes.read();
            let no_votes: u8 = self.no_votes.read();

            (yes_votes, no_votes)
        }

        fn _get_voting_result_in_percentage(self: @ContractState) -> (u8, u8) {
            let yes_votes = self.yes_votes.read();
            let no_votes = self.no_votes.read();

            let total_votes: u8 = yes_votes + no_votes;

            if (total_votes == 0) {
                return (0, 0);
            }

            let yes_percentage: u8 = (yes_votes * 100_u8) / (total_votes);
            let no_percentage: u8 = (no_votes * 100_u8) / total_votes;
            (yes_percentage, no_percentage)
        }
    }
}
