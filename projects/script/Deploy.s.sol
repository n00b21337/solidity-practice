// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { ExtCodeSizeExample, TargetContract } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (ExtCodeSizeExample example, TargetContract target) {
        // Deploy contracts
        example = new ExtCodeSizeExample();
        console.log("ExtCodeSizeExample deployed at:", address(example));

        target = new TargetContract();
        console.log("TargetContract deployed at:", address(target));

        // Create a non-existent address
        address nonExistent = address(uint160(uint256(keccak256("nonexistent"))));
        console.log("Non-existent address:", nonExistent);

        // Test with existing contract
        console.log("\n--- Testing with existing contract ---");
        try example.safeExternalCall(address(target)) {
            console.log("Safe call to existing contract succeeded");
        } catch {
            console.log("Safe call to existing contract failed");
        }

        console.log("\nContract sizes:");
        console.log("Target contract:", example.hasCode(address(target)));
        console.log("Non-existent:", example.hasCode(nonExistent));

        // Test unsafe calls to non-existent contract
        console.log("\n--- Testing with non-existent contract ---");
        try example.unsafeCallToNonExistent(nonExistent) {
            console.log("Unsafe call 'succeeded' to non-existent contract!");
        } catch {
            console.log("Unsafe call failed");
        }

        // Test delegatecall
        console.log("\n--- Testing delegatecall ---");
        try example.unsafeDelegateCallToNonExistent(nonExistent) {
            console.log("Unsafe delegatecall 'succeeded' to non-existent contract!");
        } catch {
            console.log("Unsafe delegatecall failed");
        }

        // Test transfer
        console.log("\n--- Testing transfer ---");
        try example.transferToNonExistent(payable(nonExistent)) {
            console.log("Transfer succeeded");
        } catch {
            console.log("Transfer failed (expected)");
        }

        // Test safe version with manual check
        console.log("\n--- Testing safe version with manual check ---");
        try example.safeCallWithCheck(nonExistent) {
            console.log("Safe call succeeded");
        } catch {
            console.log("Safe call failed due to extcodesize check (expected)");
        }
    }

    receive() external payable { }
}
