// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PureExamples {
    uint256 public value = 100; // State variable

    // This is fine - only uses parameter
    function trulyPure(uint256 x) public pure returns (uint256) {
        return x * 2; // OK - only uses parameter x
    }

    // This won't compile - tries to use state variable 'value'
    function notPure(uint256 x) public pure returns (uint256) {
        // return value + x;  // ERROR - can't access state variable 'value' in pure function
        return x + 1; // This line would be fine
    }

    // This is also fine - uses multiple parameters
    function alsoTrulyPure(uint256 x, uint256 y) public pure returns (uint256) {
        return x + y; // OK - only uses parameters
    }

    // For comparison - view function can access state
    function viewFunction(uint256 x) public view returns (uint256) {
        return value + x; // OK - view functions can read state
    }
}
