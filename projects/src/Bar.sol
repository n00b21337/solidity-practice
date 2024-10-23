// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DivisionExample {
    // Event to log percentage calculations
    event PercentageCalculated(uint256 numerator, uint256 denominator, uint256 percentage);

    // In Solidity, division results are automatically rounded towards zero
    // Division by zero causes panic error and cannot be caught, even in try/catch
    // It will escape 'unchecked' blocks

    function divideByZero() public pure returns (uint256) {
        uint256 a = 5;
        uint256 b = 0;

        // This will panic and revert
        // Cannot be caught with try/catch
        // Will escape unchecked block
        unchecked {
            return a / b; // This will panic
        }
    }

    // Safe division function with check
    function safeDivide(uint256 a, uint256 b) public pure returns (uint256) {
        require(b > 0, "Division by zero not allowed");
        return a / b;
    }

    // Example with positive numbers (rounds down)
    function dividePositive() public pure returns (int256) {
        int256 a = 7;
        int256 b = 2;
        // 7/2 = 3.5, but returns 3 (rounded down)
        return a / b;
    }

    // Calculate percentage with different precision levels
    // precision = 0: whole numbers
    // precision = 2: two decimal places
    function calculatePercentage(uint256 numerator, uint256 denominator, uint8 precision) public returns (uint256) {
        require(denominator > 0, "Denominator cannot be zero");

        // Calculate multiplier based on precision
        // precision = 0: multiplier = 100
        // precision = 2: multiplier = 10000
        uint256 multiplier = 100 * (10 ** precision);

        uint256 result = (numerator * multiplier) / denominator;
        emit PercentageCalculated(numerator, denominator, result);
        return result;
    }

    // Practical examples of percentage calculations
    struct Investment {
        uint256 amount;
        uint256 profit; // Changed from 'returns' to 'profit'
    }

    // Calculate ROI (Return on Investment)
    function calculateROI(Investment memory investment) public pure returns (uint256) {
        require(investment.amount > 0, "Investment amount cannot be zero");

        // ROI = (profit / investment) * 100
        // Using 2 decimal precision
        // Returns value is in basis points (10000 = 100.00%)
        return (investment.profit * 10_000) / investment.amount;
    }

    // Example: Calculate discount
    function calculateDiscount(
        uint256 originalPrice,
        uint256 discountPercent
    )
        public
        pure
        returns (uint256 discountedPrice)
    {
        require(discountPercent <= 100 * 100, "Discount cannot exceed 100%");

        // Calculate discount amount
        // Using 2 decimal precision for discount percent
        uint256 discount = (originalPrice * discountPercent) / (100 * 100);
        return originalPrice - discount;
    }

    // Example usage scenarios
    function exampleScenarios()
        public
        returns (uint256 percentageExample, uint256 roiExample, uint256 discountExample)
    {
        // Scenario 1: Calculate 75.5% of 200
        percentageExample = calculatePercentage(755, 1000, 1); // Should return 75.5

        // Scenario 2: Calculate ROI for investment
        Investment memory inv = Investment({
            amount: 1000,
            profit: 1250 // Changed from 'returns' to 'profit'
         });
        roiExample = calculateROI(inv); // Should return 12500 (125.00%)

        // Scenario 3: Calculate price after 20% discount
        discountExample = calculateDiscount(1000, 2000); // 20.00% discount on 1000

        return (percentageExample, roiExample, discountExample);
    }
}

// Example contract showing how to use the percentage calculations
contract InvestmentTracker {
    DivisionExample private calculator;

    struct InvestmentPosition {
        uint256 invested;
        uint256 currentValue;
        uint256 roiBasisPoints; // ROI in basis points (100 = 1%)
    }

    mapping(address => InvestmentPosition) public positions;

    constructor(address calculatorAddress) {
        calculator = DivisionExample(calculatorAddress);
    }

    // Update investment position and calculate ROI
    function updatePosition(uint256 newValue) public {
        InvestmentPosition storage position = positions[msg.sender];

        if (position.invested == 0) {
            position.invested = newValue;
            position.currentValue = newValue;
            position.roiBasisPoints = 10_000; // 100% (no gain/loss)
        } else {
            position.currentValue = newValue;
            // Calculate new ROI
            DivisionExample.Investment memory inv = DivisionExample.Investment({
                amount: position.invested,
                profit: newValue // Changed from 'returns' to 'profit'
             });
            position.roiBasisPoints = calculator.calculateROI(inv);
        }
    }

    // Get ROI as a formatted string (e.g., "125.50%")
    function getROIFormatted(address investor) public view returns (string memory) {
        InvestmentPosition memory position = positions[investor];
        uint256 wholePart = position.roiBasisPoints / 100; // Get whole number
        uint256 decimalPart = position.roiBasisPoints % 100; // Get decimal part

        // Format as string (simplified, you might want to add proper string handling)
        return
            string(abi.encodePacked(uint2str(wholePart), ".", decimalPart < 10 ? "0" : "", uint2str(decimalPart), "%"));
    }

    // Helper function to convert uint to string
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
