This contract is the part of ntok-x ERC20 token   
Provide additional functional for distribution tokens system 

Detailed describe of code:

```solidity
pragma solidity ^0.4.24;

// connect dependencies
import "./openzeppelin-solidity/math/SafeMath.sol";
import "./openzeppelin-solidity/token/ERC20/StandardToken.sol";
import "./openzeppelin-solidity/ownership/Ownable.sol";
import "./openzeppelin-solidity/access/Whitelist.sol";
import "./DateKernel.sol";

/**
 * @title Distributable
 * @dev Contract which providing safety functional for creating address-balance list of partner
 * Note that the partners can watch their balances
 */
contract Distributable is StandardToken, Ownable, Whitelist, DateKernel {
    // connect library SafeMath
    using SafeMath for uint;

    // Event triggered when distribution loop is over
    event Distributed(uint256 amount);
    // Event triggered when member info of team mapping was created/updated
    event MemberUpdated(address member, uint256 balance);

    // Storage of member data 
    struct member {
        // uint256 lastWithdrawal - [last withdrawal] integer value of month after unlocking tokens 
        uint256 lastWithdrawal;
        // uint256 tokensTotal - [tokens total] total supply of tokens got from distribution
        uint256 tokensTotal;
        // uint256 tokensLeft - [tokens left] current balance of tokens
        uint256 tokensLeft; 
    }

    // All partners and teams
    // map. teams - [teams] getter for teams data by wallet address
    mapping (address => member) public teams;

    /**
    * @dev Transfer (private) token for a specified address
    */
    // func. _transfer - [transfer] internal function as func. ERC20 transferFrom
    function _transfer(address _from, address _to, uint256 _value) private returns (bool) {
        require(_value <= balances[_from]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Update data of team's member
     */
     // func. updateMember - [update member] internal function accept data for update state of mapping teams
    function updateMember(address _who, uint256 _last, uint256 _total, uint256 _left) internal returns (bool) {
        teams[_who] = member(_last, _total, _left);
        emit MemberUpdated(_who, _left);
        return true;
    }
    
    /**
     * @dev Airdrop.
     * @ !important Before using, send needed token amount to this contract
     */
     // func.airdrop -[airdrop] mass transfer
    function airdrop(address[] dests, uint[] values) public onlyOwner {
        // This simple validation will catch most mistakes without consuming
        // too much gas.
        require(dests.length == values.length);
        // loop for
        for (uint256 i = 0; i < dests.length; i++) {
            transfer(dests[i], values[i]);
        }
    }

    /**
     * @dev Distribution dropper
     */
     // func. distributeTokens - [distribute tokens] only if user
    function distributeTokens(address[] _member, uint256[] _amount)
    // can execute only contract admin
    onlyOwner
    public
    returns (bool)
    {
        // require that length both arrays was equivalent 
        require(_member.length == _amount.length);
        // initialize loop for 
        for (uint256 i = 0; i < _member.length; i++) {
            // calling func. updateMember, creating new members
            updateMember(_member[i], 0, _amount[i], _amount[i]);
            // add this members to white list
            addAddressToWhitelist(_member[i]);
        }
        emit Distributed(_member.length);
        return true;
    }

    /**
      * @dev Return available tokens for get funds
      */
    // func. rewardController - [reward controller] internal function controller for determining the share of remuneration
    function rewardController(address _member)
    internal
    returns (uint256)
    {
        // member storage mbr - [member] local variable for mapping teams
        member storage mbr = teams[_member];
        
        // require that left balance was more then zero, else fail transaction and execute error message "You've spent your share", means "balance is zero"
        require(mbr.tokensLeft > 0, "You've spent your share");
        
        // uint256 multiplier - [multiplier] multiplication operand
        uint256 multiplier;
        uint256 callback;
        uint256 curDate = determineDate();
        uint256 lastDate = mbr.lastWithdrawal;
    
        // if current date value is more then last date value
        if(curDate > lastDate) {
            // get integer multiplier 
            multiplier = curDate.sub(lastDate);
            // if current date value equal to last date value
        } else if(curDate == lastDate) {
            // fail transaction and execute error message "Its no time", means "still same month from last reward"
            revert("Its no time");
        }
        
        // prevent execution of incorrect total balance wallets 
        if(mbr.tokensTotal >= mbr.tokensLeft && mbr.tokensTotal > 0) {
            // fix the residual balance due to the effect of division in an integer system
            if(curDate == 10) { 
                // in this scenario return left balance
                callback = mbr.tokensLeft;
            } else {
                // else [result] = [available shares] * [share's value], where [share's value] - is the 1/10 of total supply
                callback = multiplier.mul((mbr.tokensTotal).div(10));
            }
        }
        
        // execute func. updateMember, which change current data
        updateMember(
            _member,
            // set new date
            curDate,
            // total supply not changeable 
            mbr.tokensTotal,
            // left balance after subtraction
            mbr.tokensLeft.sub(callback)
        );

        return callback;
    }

    /**
    * @dev Transfer available shares to partner
    */
    // func. getDistributedToken - [get distributed token] external function which provides access for members to get their tokens
    function getDistributedToken()
    public
    // can execute only who is in the white list
    onlyIfWhitelisted(msg.sender)
    returns(bool)
    {
        // require that current time will be more than unlocking time
        require(unlockTime > now);
        // uint256 amount - [amount] local integer value, storage for result of execution func. rewardController
        uint256 amount = rewardController(msg.sender);
        // init internal transfer unlocked tokens from this contract to the transaction executor
        _transfer(this, msg.sender, amount);
        return true;
    }

}
```