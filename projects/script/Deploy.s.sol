// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { VulnerableBank, SafeBank, Attacker, TestAttack } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run()
        public
        broadcast
        returns (VulnerableBank vbank, SafeBank sbank, Attacker attacker, TestAttack testAttack)
    {
        // Deploy all contracts
        vbank = new VulnerableBank();
        console.log("VulnerableBank deployed at:", address(vbank));

        sbank = new SafeBank();
        console.log("SafeBank deployed at:", address(sbank));

        attacker = new Attacker(address(vbank));
        console.log("Attacker deployed at:", address(attacker));

        testAttack = new TestAttack();
        console.log("TestAttack deployed at:", address(testAttack));

        // Log initial states
        console.log("\n--- Initial States ---");
        console.log("VulnerableBank balance:", address(vbank).balance);
        console.log("Attacker balance:", address(attacker).balance);

        // Test vulnerable bank attack
        console.log("\n--- Testing Vulnerable Bank Attack ---");
        try attacker.attack{ value: 1 ether }() {
            console.log("Attack executed");
            console.log("Attack count:", attacker.attackCount());
            console.log("VulnerableBank balance after attack:", address(vbank).balance);
            console.log("Attacker balance after attack:", address(attacker).balance);
        } catch {
            console.log("Attack failed");
        }

        // Test safe bank
        console.log("\n--- Testing Safe Bank ---");
        try sbank.deposit{ value: 1 ether }() {
            console.log("Deposited 1 ether to SafeBank");
            console.log("SafeBank balance:", address(sbank).balance);

            // Try to withdraw
            try sbank.safeWithdraw(1 ether) {
                console.log("Safe withdrawal successful");
            } catch {
                console.log("Safe withdrawal failed");
            }
        } catch {
            console.log("Safe bank deposit failed");
        }

        // Test pull payment pattern
        console.log("\n--- Testing Pull Payment Pattern ---");
        try sbank.requestWithdrawal(0.5 ether) {
            console.log("Withdrawal requested");
            try sbank.completePendingWithdrawal() {
                console.log("Pending withdrawal completed");
            } catch {
                console.log("Pending withdrawal completion failed");
            }
        } catch {
            console.log("Withdrawal request failed");
        }

        // Use TestAttack contract
        console.log("\n--- Testing via TestAttack Contract ---");
        try testAttack.setupAndAttack{ value: 1 ether }() {
            (uint256 bankBalance, uint256 attackerBalance, uint256 attackCount) = testAttack.checkBalances();

            console.log("Test attack completed:");
            console.log("Final bank balance:", bankBalance);
            console.log("Final attacker balance:", attackerBalance);
            console.log("Total attack count:", attackCount);
        } catch {
            console.log("TestAttack setup/attack failed");
        }

        // Log final states
        console.log("\n--- Final States ---");
        console.log("VulnerableBank final balance:", address(vbank).balance);
        console.log("SafeBank final balance:", address(sbank).balance);
        console.log("Attacker final balance:", address(attacker).balance);
        console.log("TestAttack final balance:", address(testAttack).balance);
        console.log("Script final balance:", address(this).balance);
    }

    // To receive ether in tests
    receive() external payable { }
}
