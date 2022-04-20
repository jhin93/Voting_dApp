//SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.4;

contract techCoin {

    address public minter; // 민팅을 하는 주체 minter 선언
    
    mapping(address => uint) public balances; // 해당 주소의 잔액을 확인할 수 있는 매핑 변수 생성

    //스마트 컨트랙트가 프론트엔드와 소통을 하기 위해서 이용되는 것이 바로 Event이다.
    event Sent (address from, address to, uint amount);

    /* Event
    스마트 컨트랙트 코드) i. 이벤트 정의: “Kitty 사냥 성공” 이벤트
    event HuntedKitty(uint kittyId, uint exp);

    스마트 컨트랙트 코드) ii. 이벤트 발생: “Kitty 사냥 성공" 발생!
    function huntKitty(uint kittyId, uint exp) {
        HuntedKitty(kittyId, exp); // 이벤트 발생! 프론트엔드 코드로 이벤트 전달
        delete kitties[kittyId]; // kitties 배열에서 사냥당한 kitty 삭제
    }

    프론트엔드 코드) iii. 이벤트 처리: “Kitty 사냥 성공" 이벤트 수신 및 처리
    MyContract.HuntedKitty((error, result) => {
        showHuntedKittyWithExp(result.kittyId, result.exp); // 사냥한 Kitty와 얻은 경험치를 보여줌.
    }
     */

    // 생성자 함수.
    // 컨트랙트가 생성될 때 생성자 함수가 실행되어 컨트랙트의 상태를 초기화
    constructor () {
        minter = msg.sender; // msg.sender가 minter라고 초기화.
    }

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter); // 컨트랙트 배포자와 송금인이 동일한 것을 전제함
        balances[receiver] += amount; // receiver의 잔액이 amount 만큼 증가. 여기서 receiver는 민팅을 하는 주체의 주소, amount는 민팅을 하는 수량
    }
    error InsufficientFunds(uint requested, uint available); // 만약 잔액 이상의 수량을 송금할 시, 발생시킬 에러
    

    function send(address receiver, uint amount) public { // 주소에서 주소로 송금하는 함수
        if (amount > balances[msg.sender]) // 만약 msg.sender의 잔액보다 송금하는 수량이 많을 시,
            revert InsufficientFunds({ // 에러를 revert
                requested: amount, // 에러의 requested 인자에는 송금하려 했던 수량을 대입
                available: balances[msg.sender] // 에러의 available 인자에는 현재 msg.sender의 잔액을 입력
            }); // 만약 에러가 아닐 시 위 에러는 revert 되지 않음.
        balances[msg.sender] -= amount; // msg.sender의 잔액은 amount 만큼 송금했으니 차감.
        balances[receiver] += amount; // receiver의 잔액은 amount 만큼 송금했으니 증가.
        emit Sent(msg.sender, receiver, amount); // Sent 이벤트에 각각 인자 대입. from == msg.sender, to == receiver, amount == amount
    }
}


