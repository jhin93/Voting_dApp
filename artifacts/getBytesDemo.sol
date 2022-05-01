// SPDX-License-Identifier: MIT Liscense
pragma solidity >=0.7.0 <0.9.0;
//  위임을 전달받기 위해선 해당 계정은 투표권리를 받은 상태여야 한다.
// 위임을 하면 위임받은 계정이 투표한 제안에 자동으로 투표된다.
contract getBytes {
    function getBytesNow1() pure public returns (bytes32[1] memory ba1) 
    {
        ba1 = [bytes32("Proposal A")];
    }
    function getBytesNow2() pure public returns (bytes32[1] memory ba2) 
    {
        ba2 = [bytes32("Proposal B")];
    }
    function getBytesNow3() pure public returns (bytes32[1] memory ba3) 
    {
        ba3 = [bytes32("Proposal C")];
    }
}











