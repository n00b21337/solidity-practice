// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CallChecksExample {
    event CallResult(bool success, bytes data);

    // CASE 1: If expecting return data, don't need extcodesize
    // ABI decoder will revert if no/wrong return data
    function safeCallWithReturn(address target) external returns (uint256) {
        // This will revert automatically if target doesn't exist
        // or doesn't return correct data
        return ITarget(target).getValue();
    }

    // CASE 2: Low level call returning (success, data)
    // Does NOT revert automatically if success is false
    function lowLevelCall(address target) external returns (bool, bytes memory) {
        (bool success, bytes memory data) = target.call(abi.encodeWithSignature("getValue()"));
        emit CallResult(success, data);
        // Just returns result - doesn't revert on false
        return (success, data);
    }

    // CASE 3: Safe low level call that handles failures
    function safeLowLevelCall(address target) external returns (bytes memory) {
        (bool success, bytes memory data) = target.call(abi.encodeWithSignature("getValue()"));
        require(success, "Call failed"); // Now it will revert on failure
        return data;
    }

    // CASE 4: Complete safe call with data validation
    function completeSafeCall(address target) external returns (uint256) {
        (bool success, bytes memory data) = target.call(abi.encodeWithSignature("getValue()"));
        require(success, "Call failed");
        require(data.length >= 32, "Invalid return data");
        return abi.decode(data, (uint256));
    }
}

interface ITarget {
    function getValue() external returns (uint256);
}
