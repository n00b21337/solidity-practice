// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { FallbackReturn, TestReturns } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (FallbackReturn fallback, TestReturns test) {
        // Deploy contracts
        fallback = new FallbackReturn();
        test = new TestReturns();
        
        console.log("\n--- Testing Return Data ---");
        
        // Test normal function
        console.log("Testing normal function return:");
        test.testNormalFunction(address(fallback));
        
        // Test fallback
        console.log("\nTesting fallback return:");
        test.testFallback(address(fallback));
        
        // Test both and compare
        console.log("\nComparing both returns:");
        (bytes memory normalReturn, bytes memory fallbackReturn) = test.testBoth(address(fallback));
        
        console.log("Normal function return length:", normalReturn.length);
        console.log("Fallback return length:", fallbackReturn.length);
        
        // Print hex representation
        console.log("Normal return hex:");
        for(uint i = 0; i < normalReturn.length; i++) {
            console.log(uint8(normalReturn[i]));
        }
        
        console.log("\nFallback return hex:");
        for(uint i = 0; i < fallbackReturn.length; i++) {
            console.log(uint8(fallbackReturn[i]));
        }
        
        return (fallback, test);
    }
}