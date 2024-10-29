// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Vulnerable contract relying on balance check
contract VulnerableContract {
    function unsafeFunction() external {
        // UNRELIABLE: Someone can force ETH before this check
        require(address(this).balance == 0, "Must have no ether");
        // ... important logic assuming no ETH ...
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

// Safer contract tracking its own balance
contract SafeContract {
    uint256 private trackedBalance;

    // Only track ETH we explicitly accept
    receive() external payable {
        trackedBalance += msg.value;
    }

    function safeFunction() external {
        // RELIABLE: We only care about ETH we've tracked
        require(trackedBalance == 0, "Must have no tracked ether");
        // ... important logic ...
    }

    function withdraw() external {
        uint256 amount = trackedBalance;
        trackedBalance = 0;
        payable(msg.sender).transfer(amount);
    }

    // Can check actual vs tracked balance
    function getBalances() external view returns (uint256 actual, uint256 tracked) {
        return (address(this).balance, trackedBalance);
    }
}

// Contract to demonstrate the attack
contract Attacker {
    function attackVulnerable(address target) external payable {
        // Force send ETH via selfdestruct
        selfdestruct(payable(target));
        // Now target's balance check will fail
    }
}

// Test contract
contract BalanceTest {
    event TestResult(string message, uint256 balance);

    function testVulnerable() public returns (bool) {
        // Deploy vulnerable contract
        VulnerableContract vulnerable = new VulnerableContract();

        // Try normal operation
        try vulnerable.unsafeFunction() {
            emit TestResult("Vulnerable function succeeded", vulnerable.getBalance());
            return true;
        } catch {
            emit TestResult("Vulnerable function failed", vulnerable.getBalance());
            return false;
        }
    }

    function testSafe() public returns (bool) {
        // Deploy safe contract
        SafeContract safe = new SafeContract();

        // Try operation
        try safe.safeFunction() {
            (uint256 actual, uint256 tracked) = safe.getBalances();
            emit TestResult("Safe function succeeded", tracked);
            return true;
        } catch {
            (uint256 actual, uint256 tracked) = safe.getBalances();
            emit TestResult("Safe function failed", tracked);
            return false;
        }
    }
}
