// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Base, Child, GasComparison, Caller } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (Child child, GasComparison gasComp, Caller caller) {
        // Deploy contracts
        child = new Child();
        gasComp = new GasComparison();
        caller = new Caller(address(child));

        console.log("\n--- Testing Internal vs External Calls ---");

        // Test internal call
        uint256 startGas = gasleft();
        child.setViaInternal(100);
        uint256 internalGas = startGas - gasleft();
        console.log("Gas used for internal call:", internalGas);

        // Test external call
        startGas = gasleft();
        child.setViaExternal(200);
        uint256 externalGas = startGas - gasleft();
        console.log("Gas used for external call:", externalGas);

        console.log("\n--- Testing Inheritance Jumps ---");
        console.log("Base value before:", child.baseValue());
        child.setViaInternal(300);
        console.log("Base value after internal:", child.baseValue());
        child.setViaExternal(400);
        console.log("Base value after external:", child.baseValue());

        console.log("\n--- Testing Multiple Internal Calls ---");
        startGas = gasleft();
        uint256 result = gasComp.manyInternalCalls();
        uint256 multipleJumpsGas = startGas - gasleft();
        console.log("Result of multiple jumps:", result);
        console.log("Gas used for multiple jumps:", multipleJumpsGas);

        console.log("\n--- Testing via Caller Contract ---");
        try caller.testCalls(500) {
            console.log("Caller test completed");
            console.log("Final base value:", child.baseValue());
            console.log("Final child value:", child.childValue());
        } catch {
            console.log("Caller test failed");
        }
    }
}
