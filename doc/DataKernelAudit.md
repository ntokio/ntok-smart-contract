This contract is the part of ntok-x ERC20 token   
Provide additional functional for time management

Detailed describe of code:

```solidity
pragma solidity ^0.4.24;

/**
 * @title DateKernel
 * @dev The DateKernel contract has a data set for work with time
 */
contract DateKernel
{
    uint256 public unlockTime;

    // class constructor - self executed code
    constructor(uint256 _time) public {
    
        // set unlock time
        unlockTime = _time; // set unix timestamp
    }

    // Check date return percentage of partner balance which he is able to spend
    // func. determineDate - executed inside contract, not change any state
    // @return value M(0...p) of month dependent of unlock time date 
    function determineDate() internal view
    returns (uint256 v)
    {
    
        // uint256 n - [now] unix timestamp current block ethereum network
        uint256 n = now;
        
        // uint256 ut - [unlock time] time when will be unlocked first 10% of teams token
        uint256 ut = unlockTime;
        
        // uint256 mo - [month] equivalented 30 days period
        uint256 mo = 30 * 1 days;
        
        // uint8 p - [periods] how much periods will be possible reward
        uint8 p = 10;

        // enter point in solidity assambler
        // equivalent code below (gas execution 776 to 930)
        /************************************************
                 // define value and set it zero
         *       uint256 value = 0;
                 // If now more then unlock time exec.code
         *       if (now > unlockTime) {
                    // If now div unlock time result less or equal one month exec.code
         *          if ((now - unlockTime) <= month) {
                    // set value value 1
         *              value = 1;
                    // if more exec.code
         *           } else {
                    // set value [(25.10.2018 - 24.10.2018/ 1 month) + 1] - solidity returns
                    // only the integer values so we must add 1
         *               value = ((now - unlockTime)/month) + 1;
         *           }
                     // if value more or equal then 10[p] we must return 10
         *           if (value >= 10)  {
         *               value = 10;
         *           }
         *       }
                 // return constructor
         *       return value;
        ***************************************************/
        assembly {
            if sgt(n, ut) {
                if or(slt(sub(n, ut), mo), eq(sub(n, ut), mo)) {
                    v := 1
                }
                if sgt(sub(n, ut), mo) {
                    v := add(div(sub(n, ut), mo), 1)
                }
                if or(eq(v, p), sgt(v, p)) {
                    v := p
                }
            }
        }
    }
}

```