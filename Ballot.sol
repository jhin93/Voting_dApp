// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

//create a smart contract call Ballot
contract Ballot {

    //This struct function is a variable that contains many features
    //define a voter in this ballot

    struct Voter {
        uint weight;
        bool voted;
        address delegate;
        uint vote;
    }

    struct Proposal {
        bytes32 name; // the name of proposal
        uint voteCount; // how many vote that specific proposal received
    }


    address public chairperson;
    mapping (address => Voter) public voters;

    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        for(uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount:0
            }));
        }
    }


    function giveRighttoVote (address voter) external {
        require(
            msg.sender == chairperson, // 투표권을 주는 건 의장만 가능
            "Only Chairperson allowed to assign voting rights."
        );

        require(
            !voters[voter].voted, // require를 사용해 투표를 이미 했는지 체크하는 것.
            "Voter already voted once."
        );
        require(voters[voter].weight == 0);
        // 위의 조건들을 다 충족하고 나면 투표권을 1개 준다.
        voters[voter].weight = 1;
    }
    
    // 위임을 스스로에게 할 수 없도록 하는 함수.
    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted once.");

        require(to != msg.sender, "Self-delegation is not allowed");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop during Delegation");
        }

        sender.voted = true;
        sender.delegate = to;
    }
}









