// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { TargetContract, CallExamples } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (TargetContract target, CallExamples callExamples) {
        // Deploy contracts
        target = new TargetContract();
        console.log("TargetContract deployed at:", address(target));

        callExamples = new CallExamples();
        console.log("CallExamples deployed at:", address(callExamples));

        console.log("\n--- Testing Normal Call ---");
        try callExamples.normalCall(target, 123) {
            console.log("Normal call succeeded");
            console.log("Target value:", target.value());
        } catch {
            console.log("Normal call failed");
        }

        console.log("\n--- Testing Low Level Calls ---");

        // Test proper low-level calls
        try callExamples.correctLowLevelCalls(address(target)) {
            console.log("Correct low-level calls executed");
            console.log("Target value:", target.value());
            console.log("Target message:", target.message());
        } catch {
            console.log("Correct low-level calls failed");
        }

        console.log("\n--- Testing Dangerous Calls ---");

        // Test dangerous calls
        try callExamples.dangerousExamples(address(target)) {
            console.log("Dangerous calls executed");
            console.log("Target value (should be unchanged):", target.value());
        } catch {
            console.log("Dangerous calls failed");
        }

        // Test sending Ether
        console.log("\n--- Testing Ether Send ---");
        try callExamples.sendEtherWithCall{ value: 1 ether }(address(target)) {
            console.log("Ether sent successfully");
            console.log("Target balance:", address(target).balance);
        } catch {
            console.log("Ether send failed");
        }

        // Test raw call data
        console.log("\n--- Testing Raw Call Data ---");
        bytes memory correctData = abi.encodeWithSignature("setValue(uint256)", 999);
        try callExamples.lowLevelCall(address(target), correctData) {
            console.log("Raw call succeeded");
            console.log("Target value:", target.value());
        } catch {
            console.log("Raw call failed");
        }
    }

    receive() external payable { }
}
