// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// IT is VERY important to always check return values for external contract calls, if not, they could be silently
// failing
// and code will keep on executing

contract SendExample {
    // Events to log success/failure
    event SendSuccess(address recipient, uint256 amount);
    event SendFailed(address recipient, uint256 amount, string reason);

    // UNSAFE: Not checking send's return value
    function unsafeSend(address payable recipient, uint256 amount) public {
        // BAD - Don't do this!
        // send() might fail silently if:
        // 1. Call stack depth reaches 1024
        // 2. Recipient contract reverts
        // 3. Recipient has no receive() or fallback()
        recipient.send(amount); // Return value ignored!
    }

    // SAFE: Checking send's return value
    function safeSend(address payable recipient, uint256 amount) public {
        // GOOD - Always check return value
        bool success = recipient.send(amount);
        require(success, "Send failed");
        emit SendSuccess(recipient, amount);
    }

    // SAFER: Using call with return value check (recommended approach)
    function saferSendWithCall(address payable recipient, uint256 amount) public {
        // BEST - Using call with value
        (bool success,) = recipient.call{ value: amount }("");
        require(success, "Call failed");
        emit SendSuccess(recipient, amount);
    }

    // Receive function to accept Ether
    receive() external payable { }
}

// Contract to demonstrate call stack depth attack
contract CallStackAttacker {
    // Counter to track recursion depth
    uint256 public depth = 0;

    // Function to force deep call stack
    function forceDeepCallStack(address target, uint256 desiredDepth) external {
        if (depth < desiredDepth) {
            depth++;
            // Recursive call to increase call stack
            CallStackAttacker(target).forceDeepCallStack(target, desiredDepth);
        }
    }
}

// Contract to test send under different conditions
contract SendTester {
    SendExample public sendExample;
    CallStackAttacker public attacker;

    event TestResult(string test, bool success);

    constructor() {
        sendExample = new SendExample();
        attacker = new CallStackAttacker();
    }

    // Test normal send
    function testNormalSend(address payable recipient) public payable {
        // This should succeed under normal conditions
        bool success = recipient.send(msg.value);
        emit TestResult("Normal Send", success);
    }

    // Test send with deep call stack
    function testSendWithDeepCallStack(address payable recipient) public payable {
        // First, force deep call stack
        try attacker.forceDeepCallStack(
            address(attacker),
            1000 // Close to 1024 limit
        ) {
            // Try to send after creating deep call stack
            bool success = recipient.send(msg.value);
            emit TestResult("Deep Call Stack Send", success);
        } catch {
            emit TestResult("Deep Call Stack Send", false);
        }
    }

    // Safe implementation example
    function safeTransfer(address payable recipient, uint256 amount) public {
        // Input validation
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be positive");
        require(address(this).balance >= amount, "Insufficient balance");

        // Try send first
        bool success = recipient.send(amount);

        // If send fails, log it and revert
        if (!success) {
            emit TestResult("Safe Transfer", false);
            revert("Send failed");
        }

        emit TestResult("Safe Transfer", true);
    }

    // Modern recommended approach using call
    function modernTransfer(address payable recipient, uint256 amount) public {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be positive");
        require(address(this).balance >= amount, "Insufficient balance");

        // Use call instead of send
        (bool success,) = recipient.call{ value: amount }("");

        // Always check return value
        if (!success) {
            emit TestResult("Modern Transfer", false);
            revert("Transfer failed");
        }

        emit TestResult("Modern Transfer", true);
    }

    receive() external payable { }
}
