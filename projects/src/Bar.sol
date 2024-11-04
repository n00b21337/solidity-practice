// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Contract with state variables
contract Storage {
    uint256 public value;
    address public lastCaller;

    event ValueChanged(uint256 newValue, address caller);
    event ContextInfo(string message, address currentAddress, address msgSender);

    constructor() {
        value = 100;
    }

    // Updates state and emits context info
    function updateValue(uint256 newValue) external {
        value = newValue;
        lastCaller = msg.sender;
        emit ValueChanged(newValue, msg.sender);
        emit ContextInfo("Direct call", address(this), msg.sender);
    }

    // Gets current context info
    function getContextInfo() external view returns (address, address) {
        return (address(this), msg.sender);
    }
}

// Contract that calls Storage in different ways
contract Caller {
    uint256 public value; // Local state
    Storage public storageContract; // Contract to call

    event CallInfo(string callType, uint256 localValue, uint256 targetValue);

    constructor(address _storage) {
        storageContract = Storage(_storage);
        value = 50; // Set local state
    }

    // Regular call - switches context
    function normalCall(uint256 newValue) external {
        // Local state is accessible here
        value = 100;

        // This switches context - Storage contract's state is used
        storageContract.updateValue(newValue);

        emit CallInfo(
            "Normal call",
            value, // Local state
            storageContract.value() // Storage contract state
        );
    }

    // Delegatecall - keeps caller's context
    function delegateCall(uint256 newValue) external {
        // Local state is accessible
        value = 100;

        // This preserves context - uses Caller's state
        (bool success,) =
            address(storageContract).delegatecall(abi.encodeWithSignature("updateValue(uint256)", newValue));
        require(success, "Delegatecall failed");

        emit CallInfo(
            "Delegatecall",
            value, // Will be updated by delegatecall
            storageContract.value() // Storage contract state unchanged
        );
    }

    // Try to access state during external call (will fail)
    function incorrectStateAccess(uint256 newValue) external {
        // Create a contract that tries to access state
        StateAccessor accessor = new StateAccessor();

        // This will fail because state is inaccessible during call
        accessor.tryAccessState(address(storageContract), newValue);
    }
}

// Contract that tries to access state during call
contract StateAccessor {
    uint256 public value;

    function tryAccessState(address target, uint256 newValue) external {
        // Set local state
        value = 75;

        // Make external call
        Storage(target).updateValue(newValue);

        // Try to access state during call (won't work as expected)
        value += 1; // This will work but isn't accessing Caller's state
    }
}

// Contract to demonstrate proper state handling
contract SafeCaller {
    uint256 public value;
    Storage public storageContract;

    constructor(address _storage) {
        storageContract = Storage(_storage);
        value = 50;
    }

    // Proper state handling - save state before call
    function safeStateHandling(uint256 newValue) external {
        // Save state we need
        uint256 oldValue = value;

        // Make external call
        storageContract.updateValue(newValue);

        // Can still use saved state
        value = oldValue + 1;
    }
}
