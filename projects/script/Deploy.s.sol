// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { DemoContract, TestContract } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (TestContract test) {
        // Deploy test contract
        test = new TestContract();

        console.log("\n--- Testing Library View Function ---");

        // Test the state change
        test.testStateChange();

        return test;
    }
}
