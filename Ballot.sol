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
}









