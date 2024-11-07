// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public creator;
    uint public goal;
    uint public deadline;
    uint public totalFunds;
    bool public isGoalReached;
    bool public isFundReleased;

    mapping(address => uint) public contributions;

    // Events to log contract interactions
    event ContributionReceived(address contributor, uint amount);
    event GoalReached(uint totalFunds);
    event FundsWithdrawn(address creator, uint amount);

    // Constructor to initialize the crowdfunding parameters
    constructor(uint _goal, uint _durationInDays) {
        creator = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
        isGoalReached = false;
        isFundReleased = false;
    }

    // Function to contribute to the crowdfunding
    function contribute() public payable {
        require(block.timestamp < deadline, "Crowdfunding has ended");
        require(msg.value > 0, "Contribution must be greater than 0");

        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
        
        emit ContributionReceived(msg.sender, msg.value);

        // Check if the goal is reached
        if (totalFunds >= goal && !isGoalReached) {
            isGoalReached = true;
            emit GoalReached(totalFunds);
        }
    }

    // Function for the creator to withdraw funds if the goal is met
    function withdrawFunds() public {
        require(msg.sender == creator, "Only the creator can withdraw funds");
        require(isGoalReached, "Goal not reached");
        require(!isFundReleased, "Funds already withdrawn");

        isFundReleased = true;
        payable(creator).transfer(totalFunds);

        emit FundsWithdrawn(creator, totalFunds);
    }

    // Function to allow contributors to withdraw their funds if the goal is not reached
    function refund() public {
        require(block.timestamp >= deadline, "Crowdfunding is still ongoing");
        require(!isGoalReached, "Goal reached, no refunds available");
        require(contributions[msg.sender] > 0, "No contributions from this address");

        uint amount = contributions[msg.sender];
        contributions[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }
}
