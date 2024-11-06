// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { console } from "forge-std/src/Script.sol";

// Library with "view" function that actually modifies state
library ViewLibrary {
    // Even though this is marked view, it can modify state!
    function dangerousView(uint256 value) public view returns (uint256) {
        // This works despite being marked as view!
        value = 42;
        return value;
    }

    // Safe view function for comparison
    function safeView(uint256 value) public view returns (uint256) {
        return value;
    }
}

// Contract using the library
contract DemoContract {
    using ViewLibrary for uint256;

    uint256 public value;

    // This will actually modify state despite using a "view" function
    function useLibraryView() public returns (uint256) {
        return value.dangerousView();
    }

    // This is actually view-safe
    function useSafeView() public view returns (uint256) {
        return value.safeView();
    }

    // For comparison - regular view function
    function regularView() public view returns (uint256) {
        return value;
        // This would not compile:
        // value = 42;
    }
}

// Test contract
contract TestContract {
    DemoContract public demo;

    constructor() {
        demo = new DemoContract();
    }

    function testStateChange() public {
        console.log("Value before:", demo.value());
        demo.useLibraryView();
        console.log("Value after:", demo.value());
    }
}
