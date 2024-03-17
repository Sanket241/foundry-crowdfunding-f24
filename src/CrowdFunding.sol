// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
contract CrowdFunding{
    mapping (address => uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfcontribution;

    constructor(uint _target, uint _deadline){
        target =_target;
        deadline = block.timestamp+_deadline;
        minimumContribution = 100 wei;
        manager = msg.sender;
    }
    function sendEth() public payable{
        require(block.timestamp < deadline, "Deadline has passed");
        require(msg.value > minimumContribution, "You have not enough money");
        if(contributors[msg.sender] == 0){
            noOfcontribution++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function  getAmount() public view returns (uint){
        return address(this).balance;
    }
}