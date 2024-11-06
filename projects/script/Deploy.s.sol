// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { PureExamples } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (PureExamples pureExamples) {
        // Deploy contracts
        pureExamples = new PureExamples();

        console.log("\n--- Testing Pure Functions ---");

        // Test trulyPure with parameter
        uint256 input = 5;
        console.log("trulyPure input:", input);
        console.log("trulyPure output:", pureExamples.trulyPure(input));

        // Test with multiple parameters
        uint256 x = 10;
        uint256 y = 20;
        console.log("\nalsoTrulyPure inputs:", x, "and", y);
        console.log("alsoTrulyPure output:", pureExamples.alsoTrulyPure(x, y));

        // Compare with view function
        console.log("\nState variable value:", pureExamples.value());
        console.log("viewFunction output:", pureExamples.viewFunction(input));

        return pureExamples;
    }
}
