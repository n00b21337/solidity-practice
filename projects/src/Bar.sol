// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ExtCodeSizeExample {
    // Event to track results
    event CallResult(string callType, bool success, string details);
    event ContractSize(address target, uint256 size);

    // Normal external call includes extcodesize check
    function safeExternalCall(address target) external {
        // This will revert if target doesn't exist or has no code
        ITarget(target).doSomething();
        emit CallResult("Safe external call", true, "Call succeeded");
    }

    // Low level calls don't check extcodesize
    function unsafeCallToNonExistent(address target) external payable {
        // Check and log contract size
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        emit ContractSize(target, size);

        // Call will "succeed" even if contract doesn't exist
        (bool success,) = target.call{ value: msg.value }(abi.encodeWithSignature("doSomething()"));

        emit CallResult(
            "Unsafe call", success, size == 0 ? "Called non-existent contract!" : "Called existing contract"
        );
    }

    // Same issue with other low-level calls
    function unsafeDelegateCallToNonExistent(address target) external {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        emit ContractSize(target, size);

        (bool success,) = target.delegatecall(abi.encodeWithSignature("doSomething()"));

        emit CallResult(
            "Unsafe delegatecall",
            success,
            size == 0 ? "Delegatecalled non-existent contract!" : "Delegatecalled existing contract"
        );
    }

    // Transfer will revert, but not because of extcodesize
    function transferToNonExistent(address payable target) external {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        emit ContractSize(target, size);

        // This reverts because of the 2300 gas stipend, not because of extcodesize
        target.transfer(1);
    }

    // Safe version with manual check
    function safeCallWithCheck(address target) external payable {
        // Manual extcodesize check
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        require(size > 0, "Target contract does not exist");

        (bool success,) = target.call{ value: msg.value }(abi.encodeWithSignature("doSomething()"));
        emit CallResult("Safe call with check", success, "Called existing contract");
    }

    // Helper function to check if address has code
    function hasCode(address _contract) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_contract)
        }
        return size > 0;
    }

    receive() external payable { }
}

// Interface for safe calls
interface ITarget {
    function doSomething() external;
}

// Contract to test with
contract TargetContract {
    event Called();

    function doSomething() external {
        emit Called();
    }

    receive() external payable { }
}
