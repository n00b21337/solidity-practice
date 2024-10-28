## Checklist of things to check in solidity code

1. Check that there is no division by 0, check that value that is divider is NEVER 0
2. If sending ETHER ot native currency CHECK that there is receive function or fallback with payable, otherwise coins
   are lost
3. Check that you have function to take out funds if there is PAYABLE function
4. If there is no payable function, and not recive or fallback, sending ether to contract will REVERT
5. Division is always floor rounded and rest is lost, to have higher precision in dividing, you must upscale the values
   and also first multiply and divide last when you can, to have least amount of lost decimals
6.
