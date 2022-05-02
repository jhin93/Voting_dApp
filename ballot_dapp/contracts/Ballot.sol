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


    function removeVotingRights(address voter) external {
        require(msg.sender == chairperson, "Only Chairperson allowed to remove voting rights.");
         // voters[voter].voted가 true 인 경우는 투표권리를 삭제 못하게 require문 작성. 만약 투표를 안해서 voters[voter].voted가 false면, !false는 true가 되서 require문 통과.
        require(!voters[voter].voted, "Voter cannot be removed while vote is active");
        require(voters[voter].weight == 1); // weight가 남아있어야함.
        voters[voter].weight = 0; // 투표권 박탈.
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
        while (voters[to].delegate != address(0)) { // voters[to].delegate가 공백(address(0))이 아니라면... 이라는 조건문
        // https://bbokkun.tistory.com/166
        // https://stackoverflow.com/questions/48219716/what-is-address0-in-solidity
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop during Delegation"); // 우리는 delegation에 루프가 있음을 확인 했고 허용하지 않았습니다.
        }

        sender.voted = true; // msg.sender.voted가 true로 된건데 위임을 했으니까 더 이상 투표권이 없다는 뜻.
        sender.delegate = to; // msg.sender.delegeate에 인자(투표권을 준 주소)를 대입
        Voter storage delegate_ = voters[to]; //delegate_라는 변수에 to 라는 주소의 Voter 구조체 할당.
        if(delegate_.voted){// 대표가 이미 투표한 경우, 투표 수에 직접 추가 하십시오
            proposals[delegate_.vote].voteCount += sender.weight; // proposals라는 구조체 배열의 인덱스(delegate_.vote)는 안건(Proposal 구조체)를 의미한다. 투표한 해당 안건의 voteCount에 sender.weight를 더한다.
        } else { // 대표가 아직 투표하지 않았다면 weight에 추가하십시오.
            delegate_.weight += sender.weight;   // 위임하는 사람(주소)의 투표권 수를 위임받는 사람(주소)의 투표권 수에 더한다.
        }
    }

    function vote(uint proposal) external { // 위의 delegate 함수와 동일
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "No right to vote");
        require(!sender.voted, "Already voted once.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

    // 모든 이전 득표를 고려하여 승리한 제안서를 계산합니다. 
    function winningProposal() public view returns (uint winningProposal_) {
        uint winningVoteCount = 0;
        for(uint p = 0; p < proposals.length; p++) { // 안건 배열을 조회.
            if(proposals[p].voteCount > winningVoteCount) { // 첫 안건부터 투표받은 수를 조회하여
                winningVoteCount = proposals[p].voteCount; // 가장 많은 투표 수를 갱신하고
                winningProposal_ = p; // 받은 안건도 계속 갱신한다.
            }
        }
    }

    function winnerName() external view returns (bytes32 winnerName_) {
        winnerName_ = proposals[winningProposal()].name; // 가장 많은 득표를 한 안건을 반환
    }

}









