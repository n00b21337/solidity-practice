// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ModifierExamples {
    uint256 public value;

    event ModifierExecuted(string step, uint256 value);

    // Modifier with single underscore
    modifier basic() {
        emit ModifierExecuted("Before", value);
        _; // Function body goes here
        emit ModifierExecuted("After", value);
    }

    // Modifier with multiple underscores
    modifier multipleExecutions() {
        emit ModifierExecuted("First execution start", value);
        _; // First execution of function body
        emit ModifierExecuted("Between executions", value);
        _; // Second execution of function body
        emit ModifierExecuted("Second execution end", value);
    }

    // Modifier with local variables (not visible in function)
    modifier withLocalVars( // Only visible in modifier
    ) {
        uint256 modifierVar = 100;
        emit ModifierExecuted("ModifierVar", modifierVar);
        _;
        // Function cannot access modifierVar
    }

    // Modifier with parameters
    modifier checkValue(uint256 threshold) {
        require(value <= threshold, "Value too high");
        _;
        // threshold not visible in function
    }

    // Basic function with single modifier
    function basicExample() public basic {
        value += 1;
        // Cannot access modifier's local variables here
    }

    // Function executed multiple times
    function multipleExample() public multipleExecutions {
        value += 1;
        emit ModifierExecuted("In function", value);
    }

    // Function with modifier that has local vars
    function localVarExample() public withLocalVars {
        // Cannot access modifierVar here
        value += 1;
        // This would not compile: modifierVar += 1;
    }

    // Multiple modifiers - executed in order
    function multiModifierExample() public basic withLocalVars checkValue(200) {
        value += 1;
    }

    // Examples of what NOT to do
    uint256 private attempts;

    // BAD: Modifier changing state that function might depend on
    modifier unsafeStateChange( // Modifies state
    ) {
        attempts += 1;
        _;
        // Function might depend on attempts value
    }

    // BAD: Modifier using function local variables
    modifier unsafeVarAccess() {
        // These variables don't exist yet
        // x and y are not in scope
        // require(x + y <= 100, "Sum too large");
        _;
    }
}

// Contract to demonstrate proper modifier patterns
contract SafeModifiers {
    uint256 public value;

    // GOOD: Modifier only checks conditions
    modifier onlyPositive(uint256 x) {
        require(x > 0, "Must be positive");
        _;
    }

    // GOOD: Modifier handles its own variables
    modifier withTracking() {
        uint256 beforeValue = value;
        _;
        require(value > beforeValue, "Value must increase");
    }

    // Function using modifiers correctly
    function safeOperation(uint256 x) public onlyPositive(x) withTracking {
        value += x;
    }
}

// Contract to test modifier behaviors
contract ModifierTester {
    ModifierExamples public examples;
    SafeModifiers public safe;

    constructor() {
        examples = new ModifierExamples();
        safe = new SafeModifiers();
    }

    function testAll() external {
        // Test basic modifier
        examples.basicExample();

        // Test multiple executions
        examples.multipleExample();

        // Test local var example
        examples.localVarExample();

        // Test multiple modifiers
        examples.multiModifierExample();

        // Test safe modifiers
        safe.safeOperation(10);
    }
}
