// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { ModifierExamples, SafeModifiers, ModifierTester } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (ModifierExamples examples, SafeModifiers safe, ModifierTester tester) {
        // Deploy contracts
        examples = new ModifierExamples();
        safe = new SafeModifiers();
        tester = new ModifierTester();

        console.log("\n--- Testing Basic Modifier ---");
        examples.basicExample();
        console.log("Basic example value:", examples.value());

        console.log("\n--- Testing Multiple Executions ---");
        examples.multipleExample();
        console.log("Multiple example value:", examples.value());

        console.log("\n--- Testing Local Var Example ---");
        examples.localVarExample();
        console.log("Local var example value:", examples.value());

        console.log("\n--- Testing Multiple Modifiers ---");
        examples.multiModifierExample();
        console.log("Multi modifier example value:", examples.value());

        console.log("\n--- Testing Safe Modifiers ---");
        safe.safeOperation(10);
        console.log("Safe operation value:", safe.value());

        console.log("\n--- Testing Invalid Cases ---");
        // Test first revert condition
        console.log("Testing zero input:");
        vm.expectRevert("Must be positive");
        safe.safeOperation(0);
        console.log("Revert caught as expected for zero input");

        // To test the "Value must increase" condition, we need to pass the first check
        // but fail the second one
        console.log("\nTesting no value increase:");
        safe.safeOperation(10); // First set a value
        vm.expectRevert("Value must increase");
        safe.safeOperation(5); // Try with smaller value
        console.log("Revert caught as expected for no increase");

        // Test the full flow with tester
        console.log("\n--- Testing Full Flow ---");
        tester.testAll();
        console.log("All tests completed");

        // Final state checks
        console.log("\n--- Final States ---");
        console.log("Examples contract value:", examples.value());
        console.log("Safe contract value:", safe.value());
    }
}
