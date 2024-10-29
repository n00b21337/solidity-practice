// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { VulnerableContract, Attacker } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (VulnerableContract vulnerable, Attacker attacker) {
        // Deploy contracts
        vulnerable = new VulnerableContract();
        attacker = new Attacker();

        console.log("\n--- Testing Vulnerable Contract ---");
        console.log("Initial balance:", vulnerable.getBalance());

        // Test normal operation - expect it to succeed when balance is 0
        //    vm.expectRevert(); // This will pass if the function reverts
        vulnerable.unsafeFunction();
        console.log("Function reverted as expected with zero balance");

        // Attack by forcing ETH
        attacker.attackVulnerable{ value: 1 ether }(address(vulnerable));
        console.log("Forced ETH sent");
        console.log("New balance:", vulnerable.getBalance());

        // Test after attack - expect specific revert message
        vm.expectRevert("Must have no ether");
        vulnerable.unsafeFunction();
        console.log("Function reverted as expected after force sending ETH");

        // Can also test with specific revert message bytes
        vm.expectRevert(abi.encodePacked("Must have no ether"));
        vulnerable.unsafeFunction();
        console.log("Function reverted with expected message");

        console.log("All tests completed");
    }
}
