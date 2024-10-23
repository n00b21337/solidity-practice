// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contract A will send ether to Contract B
contract ContractA {
    // Function using recommended way to send ether - "call"
    function sendEtherToBUsingCall(address payable contractB) public payable {
        // Using call is the recommended way as of Solidity 0.8.0
        // It forwards all available gas (unlike transfer which has 2300 gas limit)
        // Returns (bool success, bytes memory data)
        (bool success,) = contractB.call{ value: msg.value }("");
        require(success, "Failed to send Ether");
    }

    // Using transfer (not recommended - limited to 2300 gas)
    function sendEtherToB(address payable contractB) public payable {
        // transfer will revert if:
        // 1. contractB has no receive/fallback function
        // 2. receive/fallback function uses more than 2300 gas
        contractB.transfer(msg.value);
    }

    // Using send (not recommended - limited to 2300 gas)
    function sendEtherToBUsingSend(address payable contractB) public payable {
        // send will return false if:
        // 1. contractB has no receive/fallback function
        // 2. receive/fallback function uses more than 2300 gas
        bool sent = contractB.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    receive() external payable { }
}

// Contract B will receive ether and has a fallback function
contract ContractB {
    // Event to log when fallback is called
    event FallbackCalled(address sender, uint256 value);

    // Event to log the current balance
    event BalanceUpdated(uint256 newBalance);

    // Variables to track calls to fallback
    uint256 public fallbackCalls = 0;

    // Fallback function with payable modifier
    // - Will receive ether if no receive() exists
    // - Can perform complex operations since called with call()
    // - With transfer/send, limited to 2300 gas
    fallback() external payable {
        fallbackCalls++;
        emit FallbackCalled(msg.sender, msg.value);
        emit BalanceUpdated(address(this).balance);
    }
}

// Example of what happens with no receive/fallback:
/*
contract ContractWithNoReceive {
    // This contract cannot receive ether because:
    // 1. No receive() function
    // 2. No fallback() function
    // Any attempt to send ether will revert
    // transfer() will throw an error
    // send() will return false
    // call() will return (false, "")
}
*/
