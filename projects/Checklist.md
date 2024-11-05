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
12. The evm considers a call to non-existing contract to always succeed, so there is a check of extcodesize > 0 when
    making an external call. But call, staticcall, delegatecall, send, transfer do not include this check so need to add
    it if you are calling non specified contracts
13. address(this).balance == 0 is not good check if the contract has no ether, as it might get from miners/stakers in
    the same block

----------------------- need to sort above by branch

11. Check for return data from external calls "return IReturnContract(target).getNumber();" dont call it like this and
    let silenty fail or send corrupted data "IReturnContract(target).noReturn();"
12. Precompile contracts defined as address constant ECRECOVER = address(0x1); // Recovery of ECDSA signatures
13. Functions called from uncheck block still have overflow and underflow check, but bitwise operators dont have those
    checks
14. After a failed call, Do not assume that the error message is coming directly from the called contract
15. If using delegatecall, it will run the code from that contract, but on local values and, other instances of that
    contract dont affect local values
16. After contract creation, The deployed code does not include the constructor code or internal functions only called
    from the constructor as they wont be used again, so its just used for setting state on initail deployment
17. Dont use this.f inside constructor
18. Internal is the default visibility level for state variables
19. Internal function calls do not create an EVM message call. They are called using simple jump statements. Same for
    functions of inherited contracts but otherContract.function(); does make EVM call or this.externalFunction(); which
    changes context and also make more gas costs
20. If you have a public state variable of array type, then you can only retrieve single elements of the array via the
    auto generated getter function
