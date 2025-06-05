// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Vote.sol";

contract VoteTest is Test {
    Vote voteContract;
    address owner;
    address voter1;
    address voter2;
    uint256 startTime;
    uint256 endTime;

    function setUp() public {
        owner = address(this);
        voter1 = address(0x1);
        voter2 = address(0x2);
        startTime = block.timestamp + 1 hours;
        endTime = block.timestamp + 2 hours;
        voteContract = new Vote(startTime, endTime);
    }

    function testRegisterVoter() public {
        voteContract.registerVoter(voter1, 25);
        (bool isRegistered,,,) = voteContract.voters(voter1);
        assertTrue(isRegistered);
    }

    function testRegisterUnderageVoter() public {
        vm.expectRevert("VOTER MUST BE AT LEAST 18 YEARS OLD");
        voteContract.registerVoter(voter1, 17);
    }

    function testVoteBeforeStartTime() public {
        voteContract.registerVoter(voter1, 25);
        vm.prank(voter1);
        vm.expectRevert("VOTING IS NOT ALLOWED AT THIS TIME");
        voteContract.vote(1);
    }

    function testVoteAfterEndTime() public {
        voteContract.registerVoter(voter1, 25);
        vm.warp(endTime + 1);
        vm.prank(voter1);
        vm.expectRevert("VOTING IS NOT ALLOWED AT THIS TIME");
        voteContract.vote(1);
    }

    function testSuccessfulVote() public {
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        (, bool hasVoted, uint256 voteChoice,) = voteContract.voters(voter1);
        assertTrue(hasVoted);
        assertEq(voteChoice, 1);
    }

    function testDoubleVoting() public {
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        vm.prank(voter1);
        vm.expectRevert("YOU HAVE ALREADY VOTED");
        voteContract.vote(2);
    }

    function testGetVote() public {
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        vm.prank(voter1);
        uint256 retrievedVote = voteContract.getVote();
        assertEq(retrievedVote, 1);
    }

    function testHasVoted() public {
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        vm.prank(voter1);
        bool hasVoted = voteContract.hasVoted();
        assertTrue(hasVoted);
    }
}