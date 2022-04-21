// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

//create a smart contract call Ballot
contract Ballot {

    //This struct function is a variable that contains many features
    //define a voter in this ballot

    struct Voter {
        uint weight; // weight는 투표권. 의장에 의해 주어진다.
        bool voted;  // 만약 이 값이 true라면, 그 사람은 이미 투표한 것 입니다.
        address delegate; // 투표에 위임된 사람
        uint vote; // 투표된 제안의 인덱스 데이터 값
    }
    // 이것은 단일 제안에 대한 유형.
    struct Proposal {
        bytes32 name; // 간단한 명칭. the name of proposal
        uint voteCount; // 누적 투표수. how many vote that specific proposal received
    }


    address public chairperson;
    // 이것은 각각의 가능한 주소에 대해 `Voter` 구조체를 저장하는 상태변수를 선언합니다.
    mapping (address => Voter) public voters;

    // 동적으로 크기가 지정된 `Proposal` 구조체의 배열입니다.
    Proposal[] public proposals;

    // `proposalNames` 중 하나를 선택하기 위한 새로운 투표권을 생성하십시오.
    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        // 각각의 제공된 제안서 이름에 대해, 새로운 제안서 개체를 만들어 배열 끝에 추가합니다.
        for(uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount:0
            }));
        }
    }

    // `voter` 에게 이 투표권에 대한 권한을 부여하십시오.
    // 오직 `chairperson` 으로부터 호출받을 수 있습니다.
    function giveRighttoVote (address voter) external {
        require(
            msg.sender == chairperson, // 투표권을 주는 건 의장만 가능
            "Only Chairperson allowed to assign voting rights."
        );

        require(
            !voters[voter].voted, // 만약 voters[voter].voted 이 참이면, !에 의해 false가 되기에 require를 통과하지 못함. 결과적으로 투표한 적이 없어야 함.
            "Voter already voted once."
        );
        require(voters[voter].weight == 0); // 투표권이 없어야 함.
        // 위의 조건들을 다 충족하고 나면 투표권을 1개 준다.
        voters[voter].weight = 1;
    }
    
    // `to` 로 유권자에게 투표를 위임하십시오.
    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted once."); // 만약 sender.voted가 참(이미 투표했다는 말)이면 !에 의해 false가 되어 require문 통과 X

        require(to != msg.sender, "Self-delegation is not allowed"); // 자체 위임은 허용되지 않습니다.

        // `to`가 위임하는 동안 delegation을 전달하십시오.
        // 일반적으로 이런 루프는 매우 위험하기 때문에,
        // 너무 오래 실행되면 블록에서 사용가능한 가스보다
        // 더 많은 가스가 필요하게 될지도 모릅니다.
        // 이 경우 위임(delegation)은 실행되지 않지만,
        // 다른 상황에서는 이러한 루프로 인해
        // 스마트 컨트랙트가 완전히 "고착"될 수 있습니다.
        while (voters[to].delegate != address(0)) { // voters[to].delegate가 공백(address(0))이 아니라면, https://bbokkun.tistory.com/166
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop during Delegation");
        }

        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if(delegate_.voted){
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "No right to vote");
        require(!sender.voted, "Already voted once.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for(uint p = 0; p < proposals.length; p++) {
            if(proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name;
    }

}









