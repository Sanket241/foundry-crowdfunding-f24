// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract CrowdFunding {
    mapping(address => uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContribution;

    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;
    uint public numRequests;

    constructor(uint _target, uint _deadline) {
        target = _target;
        deadline = block.timestamp + _deadline;
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline, "Deadline has passed");
        require(
            msg.value >= minimumContribution,
            "You have not sent enough money"
        );

        if (contributors[msg.sender] == 0) {
            noOfContribution++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    function getAmount() public view returns (uint) {
        return address(this).balance;
    }

    function refund() public {
        require(
            block.timestamp > deadline && raisedAmount < target,
            "You are not eligible for a refund"
        );
        require(
            contributors[msg.sender] > 0,
            "You have not contributed any funds"
        );

        address payable user = payable(msg.sender);
        user.transfer(100);
        contributors[msg.sender] = 0;
    }

    modifier onlyManager() {
        require(
            msg.sender == manager,
            "Only the manager can call this function"
        );
        _;
    }

    function createRequest(
        string memory _description,
        address payable _recipient,
        uint _value
    ) public onlyManager {
        require(
            _value <= address(this).balance,
            "Insufficient balance in the contract"
        );
        Request storage newRequest = requests[numRequests];

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
        numRequests++;
    }

    function voteRequest(uint _requestNo) public {
        require(
            contributors[msg.sender] > 0,
            "You must be a contributor to vote"
        );
        require(_requestNo < numRequests, "Invalid request number");

        Request storage thisRequest = requests[_requestNo];
        require(
            !thisRequest.voters[msg.sender],
            "You have already voted for this request"
        );

        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }
    function makePayment(uint _requestNo) public onlyManager {
        require(_requestNo < numRequests, "Invalid request number");
        Request storage thisRequest = requests[_requestNo];
        require(
            thisRequest.completed == false,
            "This request has already been completed"
        );
        require(
            thisRequest.noOfVoters > noOfContribution / 2,
            "The request has not been approved by the contributors"
        );

        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;
    }
}
