// SPDX-License-Identifier: MIT Liscense
pragma solidity >=0.7.0 <0.9.0;
// 6 22:17
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











