// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { UncheckedExample } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (UncheckedExample example) {
        example = new UncheckedExample();

        console.log("\n--- Testing Unchecked Behavior ---");
        uint256[] memory results = example.testUncheckedBehavior();
        console.log("Bitwise shift result:", results[0]);
        console.log("Unchecked addition result:", results[1]);
        console.log("Bitwise AND result:", results[2]);
        console.log("Bitwise OR result:", results[3]);

        console.log("\n--- Testing Function Calls ---");
        // Test with max uint256 and 1
        (bool normalReverts, bool uncheckedReverts, bool directUncheckedWorks) =
            example.testFunctionCalls(type(uint256).max, 1);

        console.log("Normal add reverts:", normalReverts);
        console.log("Unchecked add reverts:", uncheckedReverts);
        console.log("Direct unchecked works:", directUncheckedWorks);

        console.log("\n--- Testing Bitwise Operations ---");
        uint256[] memory bitwiseResults = example.testBitwiseOperations();
        console.log("Left shift:", bitwiseResults[0]);
        console.log("Right shift:", bitwiseResults[1]);
        console.log("AND:", bitwiseResults[2]);
        console.log("OR:", bitwiseResults[3]);
        console.log("XOR:", bitwiseResults[4]);
        console.log("NOT:", bitwiseResults[5]);
    }
}
