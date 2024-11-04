// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Base contract
contract Base {
    uint256 public baseValue;

    event FunctionCalled(string name, address caller, uint256 gasLeft);

    // Internal function - called via jump
    function internalSet(uint256 value) internal {
        baseValue = value;
        emit FunctionCalled("internalSet", msg.sender, gasleft());
    }

    // Public function - creates EVM call when called externally
    function publicSet(uint256 value) public {
        baseValue = value;
        emit FunctionCalled("publicSet", msg.sender, gasleft());
    }

    // Internal function that calls another internal function
    function internalWrapper(uint256 value) internal {
        // This is a jump
        internalSet(value);
        emit FunctionCalled("internalWrapper", msg.sender, gasleft());
    }
}

// Contract inheriting from Base
contract Child is Base {
    uint256 public childValue;

    // Internal call to parent - uses jump
    function setViaInternal(uint256 value) public {
        // These are all jumps, no EVM calls
        internalSet(value); // Jump to parent's internal function
        childValue = value; // Local state change
        internalWrapper(value); // Jump to parent's wrapper
        emit FunctionCalled("setViaInternal", msg.sender, gasleft());
    }

    // External call to parent - creates EVM call
    function setViaExternal(uint256 value) public {
        // This creates an EVM call
        this.publicSet(value);
        emit FunctionCalled("setViaExternal", msg.sender, gasleft());
    }

    // Compare gas usage between internal and external
    function compareGas(uint256 value) public returns (uint256 gasInternal, uint256 gasExternal) {
        // Measure internal call gas
        uint256 startGas = gasleft();
        internalSet(value);
        gasInternal = startGas - gasleft();

        // Measure external call gas
        startGas = gasleft();
        this.publicSet(value);
        gasExternal = startGas - gasleft();

        emit FunctionCalled("compareGas", msg.sender, gasleft());
    }
}

// Contract to demonstrate external calls vs internal jumps
contract GasComparison {
    // Example of multiple internal calls
    uint256 private value;

    function internalOperation(uint256 x) internal returns (uint256) {
        return x + 1;
    }

    function manyInternalCalls() public returns (uint256) {
        uint256 result = 0;
        // These are all jumps - very gas efficient
        result = internalOperation(result);
        result = internalOperation(result);
        result = internalOperation(result);
        return result;
    }
}

// Contract to test different call patterns
contract Caller {
    Child public childContract;

    constructor(address _child) {
        childContract = Child(_child);
    }

    // Test different call patterns
    function testCalls(uint256 value) external {
        // External call - creates EVM call
        childContract.publicSet(value);

        // Another external call
        childContract.setViaInternal(value);

        // Compare gas usage
        (uint256 gasInternal, uint256 gasExternal) = childContract.compareGas(value);

        emit CallResults(gasInternal, gasExternal);
    }

    event CallResults(uint256 gasInternal, uint256 gasExternal);
}
