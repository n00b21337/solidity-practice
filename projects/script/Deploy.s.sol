// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { DivisionExample, InvestmentTracker } from "../src/Bar.sol";
import { BaseScript, console } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (DivisionExample divisionExample, InvestmentTracker investmentTracker) {
        // Deploy DivisionExample contract
        divisionExample = new DivisionExample();
        console.log("The address of divisionExample is:", address(divisionExample));

        // Deploy InvestmentTracker contract
        investmentTracker = new InvestmentTracker(address(divisionExample));
        console.log("The address of investmentTracker is:", address(investmentTracker));

        // Test safeDivide
        try divisionExample.safeDivide(10, 2) returns (uint256 result) {
            console.log("The result of safeDivide(10, 2) is:", result);
        } catch {
            console.log("safeDivide failed with result:", 0);
        }

        // Test dividePositive
        try divisionExample.dividePositive() returns (int256 result) {
            console.log("The result of dividePositive() is:", uint256(result));
        } catch {
            console.log("dividePositive failed with result:", 0);
        }

        // Test calculatePercentage
        try divisionExample.calculatePercentage(755, 1000, 1) returns (uint256 result) {
            console.log("The result of calculatePercentage(755, 1000, 1) is:", result);
        } catch {
            console.log("calculatePercentage failed with result:", 0);
        }

        // Test calculateDiscount
        try divisionExample.calculateDiscount(1000, 2000) returns (uint256 result) {
            console.log("The result of calculateDiscount(1000, 2000) is:", result);
        } catch {
            console.log("calculateDiscount failed with result:", 0);
        }

        // Test exampleScenarios
        try divisionExample.exampleScenarios() returns (
            uint256 percentageExample, uint256 roiExample, uint256 discountExample
        ) {
            console.log("Example Scenarios Results:");
            console.log("The percentageExample is:", percentageExample);
            console.log("The roiExample is:", roiExample);
            console.log("The discountExample is:", discountExample);
        } catch {
            console.log("exampleScenarios failed with result:", 0);
        }

        // Test Investment ROI calculation
        DivisionExample.Investment memory investment = DivisionExample.Investment({ amount: 1000, profit: 1250 });

        try divisionExample.calculateROI(investment) returns (uint256 result) {
            console.log("The result of calculateROI(1000, 1250) is:", result);
        } catch {
            console.log("calculateROI failed with result:", 0);
        }

        // Test updatePosition
        try investmentTracker.updatePosition(1000) {
            console.log("updatePosition(1000) status:", 1); // Success
        } catch {
            console.log("updatePosition(1000) status:", 0); // Failure
        }

        // Test getROIFormatted
        try investmentTracker.getROIFormatted(address(this)) returns (string memory result) {
            console.log("The formatted ROI result is:", result);
        } catch {
            console.log("getROIFormatted failed with result:", 0);
        }

        // Test positions mapping
        try investmentTracker.positions(address(this)) returns (
            uint256 invested, uint256 currentValue, uint256 roiBasisPoints
        ) {
            console.log(" - Investment Position Details - ");
            console.log("The invested amount is:", invested);
            console.log("The current value is:", currentValue);
            console.log("The ROI in basis points is:", roiBasisPoints);
        } catch {
            console.log("positions query failed with result:", 0);
        }
    }
}
