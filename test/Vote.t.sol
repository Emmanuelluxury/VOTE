// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Vote.sol";

contract VoteTest is Test {
    Vote voteContract;
    address owner;
    address voter1;
    address voter2;
    uint256 startTime;
    uint256 endTime;

    function setUp() public {
        owner = address(0x234); 
        voter1 = address(0x1);
        voter2 = address(0x2);
        startTime = block.timestamp + 1 hours;
        endTime = block.timestamp + 2 hours;
        vm.prank(owner); // deploy contract as owner
        voteContract = new Vote(startTime, endTime);
    }

    function testRegisterVoter() public {
        vm.prank(owner); // register as owner 
        voteContract.registerVoter(voter1, 25);
        (bool isRegistered,,,) = voteContract.voters(voter1);
        assertTrue(isRegistered);
    }

    function testRegisterVoterasNonOwner() public {
    vm.prank(voter1); // register as nonowner
    vm.expectRevert("ONLY OWNER CAN CALL THIS FUNCTION");
    voteContract.registerVoter(voter1, 25);
}

    function testRegisterUnderageVoter() public {
        vm.prank(owner);
        vm.expectRevert("VOTER MUST BE AT LEAST 18 YEARS OLD");
        voteContract.registerVoter(voter1, 17);
    }

    function testDoubleRegistration() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.prank(owner);
        vm.expectRevert("VOTER ALREADY REGISTERED");
        voteContract.registerVoter(voter1, 30);
    }

    function testVoteBeforeStartTime() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.prank(voter1);
        vm.expectRevert("VOTING IS NOT ALLOWED AT THIS TIME");
        voteContract.vote(1);
    }

    function testVoteAfterEndTime() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.warp(endTime + 1);
        vm.prank(voter1);
        vm.expectRevert("VOTING IS NOT ALLOWED AT THIS TIME");
        voteContract.vote(1);
    }

    function testSuccessfulVote() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        (, bool hasVoted, uint256 voteChoice,) = voteContract.voters(voter1);
        assertTrue(hasVoted);
        assertEq(voteChoice, 1);
    }

    function testDoubleVoting() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        vm.prank(voter1);
        vm.expectRevert("YOU HAVE ALREADY VOTED");
        voteContract.vote(2);
    }

    function testUnregisteredCannotVote() public {
        vm.warp(startTime + 1);
        vm.prank(voter2);
        vm.expectRevert("YOU ARE NOT REGISTERED TO VOTE");
        voteContract.vote(1);
    }

    function testGetVote() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        vm.prank(voter1);
        uint256 retrievedVote = voteContract.getVote();
        assertEq(retrievedVote, 1);
    }

    function testGetVoteNotVoted() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.prank(voter1);
        vm.expectRevert("YOU HAVE NOT VOTED YET");
        voteContract.getVote();
    }

    function testGetVoteNotRegistered() public {
        vm.prank(voter2);
        vm.expectRevert("YOU ARE NOT REGISTERED TO VOTE");
        voteContract.getVote();
    }

    function testHasVoted() public {
        vm.prank(owner);
        voteContract.registerVoter(voter1, 25);
        vm.warp(startTime + 1);
        vm.prank(voter1);
        voteContract.vote(1);
        vm.prank(voter1);
        bool hasVoted = voteContract.hasVoted();
        assertTrue(hasVoted);
    }
}