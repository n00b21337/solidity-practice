// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UncheckedExample {
    // Function that will be called from unchecked block
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        // Still has overflow checks!
        return a + b;
    }

    // Function with its own unchecked block
    function addUnchecked(uint256 a, uint256 b) public pure returns (uint256) {
        unchecked {
            return a + b; // No overflow check here
        }
    }

    // Demonstrate unchecked block behavior
    function testUncheckedBehavior() public pure returns (uint256[] memory results) {
        results = new uint256[](4);

        unchecked {
            // Bitwise operations never check overflow
            results[0] = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF << 1; // No check

            // This call to add() still has checks!
            // results[1] = add(type(uint256).max, 1);  // Will revert

            // Direct arithmetic in unchecked doesn't check
            results[1] = type(uint256).max + 1; // Wraps to 0

            // Bitwise AND
            results[2] = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF & 0x1; // Always safe

            // Bitwise OR
            results[3] = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF | 0x1; // Always safe
        }

        return results;
    }

    // Test function calls
    function testFunctionCalls(
        uint256 a,
        uint256 b
    )
        public
        pure
        returns (bool normalReverts, bool uncheckedReverts, bool directUncheckedWorks)
    {
        // Test normal add (should revert on overflow)
        try this.add(a, b) {
            normalReverts = false;
        } catch {
            normalReverts = true;
        }

        // Test unchecked add (should wrap)
        try this.addUnchecked(a, b) {
            uncheckedReverts = false;
        } catch {
            uncheckedReverts = true;
        }

        // Test direct unchecked arithmetic
        unchecked {
            uint256 result = a + b; // Will wrap instead of revert
            directUncheckedWorks = true;
        }

        return (normalReverts, uncheckedReverts, directUncheckedWorks);
    }

    // Demonstrate bitwise operations
    function testBitwiseOperations() public pure returns (uint256[] memory results) {
        results = new uint256[](6);

        // These never need checks, even outside unchecked
        results[0] = type(uint256).max << 1; // Shift left
        results[1] = type(uint256).max >> 1; // Shift right
        results[2] = type(uint256).max & 0x1; // AND
        results[3] = 0x1 | 0x2; // OR
        results[4] = type(uint256).max ^ 0x1; // XOR
        results[5] = ~uint256(0x1); // NOT

        return results;
    }
}
