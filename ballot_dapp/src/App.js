import './App.css';
import { useState } from 'react';
import { ethers } from 'ethers';
import Ballot from './artifacts/contracts/Ballot.sol/Ballot.json'

// 배포를 진행한 주소
const ballotAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3"

function App() {

  async function requestAccount() { // connect to the metamask wallet of a user 메타마스크 지갑 연결
    await window.ethereum.request({method: 'eth_requestAccounts'}); // request account info 계정 정보
  }

  // async function giveRighttoVote(){}

  // async function removeVotingRights(){}

  // async function delegate(){}

  // async function vote(){}

  // async function winningProposal(){}

  // async function winnerName(){}

  return (
    <div className="App">
      <header className="App-header">
        <h1>Voting Application </h1>
        <h3>Contract Address: {ballotAddress}</h3>
      </header>
    </div>
  );
}

export default App;
