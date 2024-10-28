// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Target contract with normal functions
contract TargetContract {
    uint256 public value;
    string public message;

    event FunctionCalled(string name, bytes data);

    // Normal function with strict typing
    function setValue(uint256 _value) external {
        value = _value;
        emit FunctionCalled("setValue", abi.encode(_value));
    }

    // Function expecting string
    function setMessage(string memory _message) external {
        message = _message;
        emit FunctionCalled("setMessage", abi.encode(_message));
    }

    // Function to receive Ether
    receive() external payable { }
}

// Contract demonstrating different call methods
contract CallExamples {
    event CallResult(bool success, bytes data);

    // Normal typed call - Safe with checks
    function normalCall(TargetContract target, uint256 _value) external {
        // This enforces:
        // 1. Function must exist
        // 2. Types must match
        // 3. Proper argument packing
        target.setValue(_value);
    }

    // Low-level call - Bypasses checks
    function lowLevelCall(address target, bytes memory data) external {
        // This bypasses:
        // 1. Function existence check
        // 2. Type checking
        // 3. Argument packing
        (bool success, bytes memory returnData) = target.call(data);
        emit CallResult(success, returnData);
    }

    // Examples of dangerous/bypassed calls
    function dangerousExamples(address target) external {
        // 1. Call non-existent function - Still executes but fails
        (bool success1,) = target.call(abi.encodeWithSignature("nonExistentFunction()"));
        emit CallResult(success1, "Called non-existent function");

        // 2. Wrong type arguments - No type checking
        (bool success2,) = target.call(abi.encodeWithSignature("setValue(string)", "wrong type"));
        emit CallResult(success2, "Called with wrong type");

        // 3. Wrong number of arguments - No argument checking
        (bool success3,) = target.call(abi.encodeWithSignature("setValue(uint256,uint256)", 1, 2));
        emit CallResult(success3, "Called with wrong number of args");

        // 4. Malformed calldata - Raw bytes
        (bool success4,) = target.call(hex"deadbeef");
        emit CallResult(success4, "Called with malformed data");
    }

    // Example of correct low-level calls
    function correctLowLevelCalls(address target) external {
        // Proper function signature and argument encoding
        (bool success1,) = target.call(abi.encodeWithSignature("setValue(uint256)", 123));
        emit CallResult(success1, "Correct setValue call");

        // Proper encoding for string
        (bool success2,) = target.call(abi.encodeWithSignature("setMessage(string)", "Hello"));
        emit CallResult(success2, "Correct setMessage call");
    }

    // Send Ether with call
    function sendEtherWithCall(address target) external payable {
        (bool success,) = target.call{ value: msg.value }("");
        emit CallResult(success, "Sent Ether with call");
    }
}
