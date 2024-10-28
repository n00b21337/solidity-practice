// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { DeleteExample } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (DeleteExample deleteExample) {
        // Deploy contract
        deleteExample = new DeleteExample();
        console.log("DeleteExample deployed at:", address(deleteExample));

        // Initialize values
        deleteExample.initialize();
        logValues(deleteExample, "Initial values");

        // Test delete operations
        console.log("\n--- Testing Delete Operations ---");

        // Delete simple value
        deleteExample.deleteSimpleValue();
        console.log("Simple value after delete:", deleteExample.simpleValue());

        // Delete bool
        deleteExample.deleteBool();
        console.log("Bool value after delete:", deleteExample.boolValue());

        // Delete address
        deleteExample.deleteAddress();
        console.log("Address value after delete:", deleteExample.addressValue());

        // Delete string
        deleteExample.deleteString();
        console.log("String value after delete:", deleteExample.stringValue());

        // Delete array
        deleteExample.initialize();
        deleteExample.deleteArray();
        console.log("Array length after delete:", deleteExample.getArrayLength());

        // Reinitialize for array element delete
        deleteExample.initialize();
        deleteExample.deleteArrayElement(2);
        console.log("Array element 2 after delete:", deleteExample.arrayValues(2));

        // Delete mapping element
        deleteExample.deleteMappingElement(1);
        console.log("Mapping value 1 after delete:", deleteExample.mappingValues(1));

        // Delete struct
        deleteExample.deleteStruct();

        // Log final state
        logValues(deleteExample, "Final values");
    }

    function logValues(DeleteExample deleteExample, string memory label) internal view {
        console.log("\n---", label, "---");
        (
            uint256 simpleValue,
            bool boolValue,
            address addressValue,
            string memory stringValue,
            uint256[] memory arrayValues,
            DeleteExample.Person memory person
        ) = deleteExample.getValues();

        console.log("Simple value:", simpleValue);
        console.log("Bool value:", boolValue);
        console.log("Address value:", addressValue);
        console.log("String value:", stringValue);
        console.log("Array length:", arrayValues.length);
        console.log("Person name:", person.name);
        console.log("Person age:", person.age);
        console.log("Person active:", person.isActive);
        console.log("Person wallet:", person.wallet);
    }
}
