pragma solidity ^0.4.24;

import "./Distributable.sol";
import "./openzeppelin-solidity/token/ERC20/BurnableToken.sol";
import "./openzeppelin-solidity/ownership/CanReclaimToken.sol";
import "./openzeppelin-solidity/ownership/Claimable.sol";

/**
 * @title TutorNinjaToken
 * @dev ERC20 Token on OpenZeppelin framework
 */
contract TutorNinjaToken is Distributable, BurnableToken, CanReclaimToken, Claimable {

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public INITIAL_SUPPLY = 33e6 * (10 ** uint256(decimals));

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor()
    public
    DateKernel(now + (4*30*1 days))
    {
        name = "Tutor Ninja"; // solium-disable-line uppercase
        symbol = "NTOK"; // solium-disable-line uppercase
        decimals = 10; // solium-disable-line uppercase
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @dev Disallows direct send by settings a default function without the `payable` flag.
     */
    function() external {
        revert("Does not accept ether");
    }
}
