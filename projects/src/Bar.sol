// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FallbackReturn {
    // Regular function - returns ABI encoded data
    function normalFunction() public pure returns (uint256) {
        return 123;  // Will be ABI encoded (padded to 32 bytes)
    }
    
    // Fallback - returns raw unencoded data
    fallback() external payable {
        // Return raw bytes without ABI encoding
        assembly {
            // Return 0x123 without padding
            mstore(0, 0x123)
            return(0, 3)  // Return 3 bytes only
        }
    }
    
    // Another example with different length
    fallback2() external payable {
        assembly {
            // Store and return 0x1234
            mstore(0, 0x1234)
            return(0, 2)  // Return 2 bytes
        }
    }
}

// Contract to test different return data
contract TestReturns {
    event ReturnData(bytes data);
    
    function testNormalFunction(address target) public {
        // Call normal function - will get ABI encoded return
        (bool success, bytes memory data) = target.call(
            abi.encodeWithSignature("normalFunction()")
        );
        require(success, "Call failed");
        emit ReturnData(data);  // Will be 32 bytes padded
    }
    
    function testFallback(address target) public {
        // Call fallback - will get raw unencoded return
        (bool success, bytes memory data) = target.call("");
        require(success, "Call failed");
        emit ReturnData(data);  // Will be exact bytes returned
    }
    
    // Function to show the difference in hex
    function testBoth(address target) public returns (
        bytes memory normalReturn,
        bytes memory fallbackReturn
    ) {
        // Get normal function return
        (bool success, bytes memory data) = target.call(
            abi.encodeWithSignature("normalFunction()")
        );
        require(success, "Normal call failed");
        normalReturn = data;
        
        // Get fallback return
        (success, data) = target.call("");
        require(success, "Fallback call failed");
        fallbackReturn = data;
        
        emit ReturnData(normalReturn);
        emit ReturnData(fallbackReturn);
    }
}