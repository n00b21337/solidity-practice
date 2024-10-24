// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { SendExample, CallStackAttacker, SendTester } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run()
        public
        broadcast
        returns (SendExample sendExample, CallStackAttacker attacker, SendTester sendTester)
    {
        // Deploy contracts
        sendExample = new SendExample();
        console.log("SendExample deployed at:", address(sendExample));

        attacker = new CallStackAttacker();
        console.log("CallStackAttacker deployed at:", address(attacker));

        sendTester = new SendTester();
        console.log("SendTester deployed at:", address(sendTester));

        // Fund SendTester for testing
        payable(address(sendTester)).transfer(1 ether);
        console.log("SendTester balance:", address(sendTester).balance);

        // Test unsafe send
        try sendExample.unsafeSend(payable(address(this)), 0.1 ether) {
            console.log("Unsafe send executed (no way to know if it succeeded)");
        } catch {
            console.log("Unsafe send reverted");
        }

        // Test safe send
        try sendExample.safeSend(payable(address(this)), 0.1 ether) {
            console.log("Safe send succeeded");
        } catch {
            console.log("Safe send failed");
        }

        // Test safer send with call
        try sendExample.saferSendWithCall(payable(address(this)), 0.1 ether) {
            console.log("Safer send with call succeeded");
        } catch {
            console.log("Safer send with call failed");
        }

        // Test normal send via SendTester
        try sendTester.testNormalSend(payable(address(this))) {
            console.log("Normal send test completed");
        } catch {
            console.log("Normal send test failed");
        }

        // Test deep call stack attack
        try sendTester.testSendWithDeepCallStack(payable(address(this))) {
            console.log("Deep call stack test completed");
        } catch {
            console.log("Deep call stack test failed");
        }

        // Test safe transfer
        try sendTester.safeTransfer(payable(address(this)), 0.1 ether) {
            console.log("Safe transfer succeeded");
        } catch {
            console.log("Safe transfer failed");
        }

        // Test modern transfer
        try sendTester.modernTransfer(payable(address(this)), 0.1 ether) {
            console.log("Modern transfer succeeded");
        } catch {
            console.log("Modern transfer failed");
        }

        // Log final balances
        console.log("Final SendExample balance:", address(sendExample).balance);
        console.log("Final SendTester balance:", address(sendTester).balance);
        console.log("Final script balance:", address(this).balance);
    }
}
