pragma solidity ^0.4.24;

/**
 * @title DateKernel
 * @dev The DateKernel contract has a data set for work with time
 */
contract DateKernel
{
    uint256 public unlockTime;

    constructor(uint256 _time) public {
        unlockTime = _time; // set unix timestamp
    }

    // Check date return percentage of partner balance which he able to spend
    function determineDate() internal view
    returns (uint256 v)
    {
        uint256 n = now;
        uint256 ut = unlockTime;
        uint256 mo = 30 * 1 days;
        uint8 p = 10;

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
