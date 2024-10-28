// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Defaults per type
// delete uint    => 0
// delete bool    => false
// delete address => address(0)
// delete string  => ""
// delete array   => length = 0
// delete mapping element => 0
// delete struct  => all members reset to defaults

contract DeleteExample {
    // Struct to demonstrate delete on complex types
    struct Person {
        string name;
        uint256 age;
        bool isActive;
        address wallet;
    }

    // Variables to demonstrate delete
    uint256 public simpleValue;
    bool public boolValue = true;
    address public addressValue = address(0x123);
    string public stringValue = "Hello";
    uint256[] public arrayValues;
    mapping(uint256 => uint256) public mappingValues;
    Person public person;

    // Events to track changes
    event ValueDeleted(string valueType, string message);
    event ValueBefore(string valueType, bytes value);
    event ValueAfter(string valueType, bytes value);

    // Initialize some values
    function initialize() external {
        simpleValue = 100;
        arrayValues = [1, 2, 3, 4, 5];
        mappingValues[1] = 100;
        mappingValues[2] = 200;

        person = Person({ name: "Alice", age: 30, isActive: true, wallet: msg.sender });
    }

    // Delete simple value
    function deleteSimpleValue() external {
        emit ValueBefore("simpleValue", abi.encode(simpleValue));
        delete simpleValue; // Sets to 0
        emit ValueAfter("simpleValue", abi.encode(simpleValue));
        emit ValueDeleted("simpleValue", "Reset to 0");
    }

    // Delete bool
    function deleteBool() external {
        emit ValueBefore("boolValue", abi.encode(boolValue));
        delete boolValue; // Sets to false
        emit ValueAfter("boolValue", abi.encode(boolValue));
        emit ValueDeleted("boolValue", "Reset to false");
    }

    // Delete address
    function deleteAddress() external {
        emit ValueBefore("addressValue", abi.encode(addressValue));
        delete addressValue; // Sets to address(0)
        emit ValueAfter("addressValue", abi.encode(addressValue));
        emit ValueDeleted("addressValue", "Reset to address(0)");
    }

    // Delete string
    function deleteString() external {
        emit ValueBefore("stringValue", abi.encode(stringValue));
        delete stringValue; // Sets to empty string
        emit ValueAfter("stringValue", abi.encode(stringValue));
        emit ValueDeleted("stringValue", "Reset to empty string");
    }

    // Delete array
    function deleteArray() external {
        emit ValueBefore("arrayValues", abi.encode(arrayValues));
        delete arrayValues; // Sets length to 0
        emit ValueAfter("arrayValues", abi.encode(arrayValues));
        emit ValueDeleted("arrayValues", "Reset to empty array");
    }

    function getArrayLength() external view returns (uint256) {
        return arrayValues.length;
    }

    // Delete single array element
    function deleteArrayElement(uint256 index) external {
        require(index < arrayValues.length, "Index out of bounds");
        emit ValueBefore("arrayElement", abi.encode(arrayValues[index]));
        delete arrayValues[index]; // Sets element to 0
        emit ValueAfter("arrayElement", abi.encode(arrayValues[index]));
        emit ValueDeleted("arrayElement", "Reset element to 0");
    }

    // Delete mapping element
    function deleteMappingElement(uint256 key) external {
        emit ValueBefore("mappingElement", abi.encode(mappingValues[key]));
        delete mappingValues[key]; // Sets value to 0
        emit ValueAfter("mappingElement", abi.encode(mappingValues[key]));
        emit ValueDeleted("mappingElement", "Reset value to 0");
    }

    // Delete struct
    function deleteStruct() external {
        emit ValueBefore("person", abi.encode(person.name, person.age, person.isActive, person.wallet));
        delete person; // Resets all fields to default values
        emit ValueAfter("person", abi.encode(person.name, person.age, person.isActive, person.wallet));
        emit ValueDeleted("person", "Reset all fields to defaults");
    }

    // Get current values for verification
    function getValues()
        external
        view
        returns (
            uint256 _simpleValue,
            bool _boolValue,
            address _addressValue,
            string memory _stringValue,
            uint256[] memory _arrayValues,
            Person memory _person
        )
    {
        return (simpleValue, boolValue, addressValue, stringValue, arrayValues, person);
    }
}
