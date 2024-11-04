// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Storage, Caller, StateAccessor, SafeCaller } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (Storage storage_, Caller caller, SafeCaller safeCaller) {
        // Deploy contracts
        storage_ = new Storage();
        caller = new Caller(address(storage_));
        safeCaller = new SafeCaller(address(storage_));

        console.log("\n--- Initial States ---");
        console.log("Storage contract value:", storage_.value());
        console.log("Caller contract value:", caller.value());
        console.log("SafeCaller contract value:", safeCaller.value());

        // Test normal call
        console.log("\n--- Testing Normal Call ---");
        try caller.normalCall(200) {
            console.log("After normal call:");
            console.log("Storage value:", storage_.value());
            console.log("Caller value:", caller.value());
        } catch {
            console.log("Normal call failed");
        }

        // Test delegatecall
        console.log("\n--- Testing Delegatecall ---");
        try caller.delegateCall(300) {
            console.log("After delegatecall:");
            console.log("Storage value:", storage_.value());
            console.log("Caller value:", caller.value());
        } catch {
            console.log("Delegatecall failed");
        }

        // Test incorrect state access
        console.log("\n--- Testing Incorrect State Access ---");
        try caller.incorrectStateAccess(400) {
            console.log("State access attempt completed");
        } catch {
            console.log("State access attempt failed");
        }

        // Test safe state handling
        console.log("\n--- Testing Safe State Handling ---");
        try safeCaller.safeStateHandling(500) {
            console.log("After safe handling:");
            console.log("Storage value:", storage_.value());
            console.log("SafeCaller value:", safeCaller.value());
        } catch {
            console.log("Safe handling failed");
        }

        // Get context info
        (address contractAddr, address sender) = storage_.getContextInfo();
        console.log("\n--- Context Info ---");
        console.log("Contract address:", contractAddr);
        console.log("Message sender:", sender);
    }
}
