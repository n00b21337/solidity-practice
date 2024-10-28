## Checklist of things to check in solidity code

1. Check that there is no division by 0, check that value that is divider is NEVER 0
2. If sending ETHER ot native currency CHECK that there is receive function or fallback with payable, otherwise coins
   are lost
3. Check that you have function to take out funds if there is PAYABLE function
4. If there is no payable function, and not recive or fallback, sending ether to contract will REVERT
5. Division is always floor rounded and rest is lost, to have higher precision in dividing, you must upscale the values
   and also first multiply and divide last when you can, to have least amount of lost decimals
6. Using low level functions to call a contract = handing over control to it (always with msg.sender.call)
7. If calling external state changing contracts (NOT VIEW), always think about what will they return and if there is no
   return is the silent failure option or you want to log it in or even revert
8. Check that user input is never 0 if this input is used for division
9. DelegateCall allows one contract to execute another contract's code as if it were its own. Both the calling and
   called contracts must have the same storage layout, otherwise clusterfuck happens
10. Enums are just an abstraction of unsigned integers (uint8). In the ABI (Application Binary Interface), enums are
    always represented as uint8 values.
11. Delete vars, doesnt delete and free space, it only set variables to their default values, check the code for
    defaults
