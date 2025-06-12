// SPDX-License-Identifier: MIX
pragma solidity ^0.8.13;

contract Vote {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 vote;
        uint256 age;
    }

    mapping(address => Voter) public voters;
    address public owner;
    uint256 public votingStartTime;
    uint256 public votingEndTime;

    modifier onlyOwner() {
        require(msg.sender == owner, "ONLY OWNER CAN CALL THIS FUNCTION");
        _;
    }

    modifier onlyDuringVoting() {
        require(
            block.timestamp >= votingStartTime && block.timestamp <= votingEndTime, "VOTING IS NOT ALLOWED AT THIS TIME"
        );
        _;
    }

    constructor(uint256 _votingStartTime, uint256 _votingEndTime) {
        owner = msg.sender;
        votingStartTime = _votingStartTime;
        votingEndTime = _votingEndTime;
    }

    function registerVoter(address _voter, uint256 _age) public onlyOwner {
        require(_age >= 18, "VOTER MUST BE AT LEAST 18 YEARS OLD");
        require(!voters[_voter].isRegistered, "VOTER ALREADY REGISTERED");
        voters[_voter] = Voter(true, false, 0, _age);
    }

    function vote(uint256 _vote) public onlyDuringVoting {
        Voter storage voter = voters[msg.sender];
        require(voter.isRegistered, "YOU ARE NOT REGISTERED TO VOTE");
        require(!voter.hasVoted, "YOU HAVE ALREADY VOTED");

        voter.vote = _vote;
        voter.hasVoted = true;
    }

    function getVote() public view returns (uint256) {
        Voter memory voter = voters[msg.sender];
        require(voter.isRegistered, "YOU ARE NOT REGISTERED TO VOTE");
        require(voter.hasVoted, "YOU HAVE NOT VOTED YET");

        return voter.vote;
    }

    function hasVoted() public view returns (bool) {
        return voters[msg.sender].hasVoted;
    }
}
