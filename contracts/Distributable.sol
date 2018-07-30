pragma solidity ^0.4.24;

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
    using SafeMath for uint;

    event Distributed(uint256 amount);
    event MemberUpdated(address member, uint256 balance);

    struct member {
        uint256 lastWithdrawal;
        uint256 tokensTotal;
        uint256 tokensLeft;
    }

    // All partners and teams
    mapping (address => member) public teams;

    /**
    * @dev Transfer (private) token for a specified address
    */
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
    function updateMember(address _who, uint256 _last, uint256 _total, uint256 _left) internal returns (bool) {
        teams[_who] = member(_last, _total, _left);
        emit MemberUpdated(_who, _left);
        return true;
    }

    /**
     * @dev Distribution dropper
     */
    function distributeTokens(address[] _member, uint256[] _amount)
    onlyOwner
    public
    returns (bool)
    {
        require(_member.length == _amount.length);
        for (uint256 i = 0; i < _member.length; i++) {
            updateMember(_member[i], 0, _amount[i], _amount[i]);
            addAddressToWhitelist(_member[i]);
        }
        emit Distributed(_member.length);
        return true;
    }

    /**
      * @dev Return available tokens for get funds
      */
    function rewardController(address _member)
    internal
    returns (uint256)
    {
        member storage mbr = teams[_member];

        require(mbr.tokensLeft > 0, "You've spent your share");

        uint256 multiplier;
        uint256 callback;
        uint256 curDate = determineDate();
        uint256 lastDate = mbr.lastWithdrawal;

        if(curDate > lastDate) {
            multiplier = curDate.sub(lastDate);
        } else if(curDate == lastDate) {
            revert("Its no time");
        }

        if(mbr.tokensTotal >= mbr.tokensLeft && mbr.tokensTotal > 0) {
            if(curDate == 10) { // fix the residual balance due to the effect of division in an integer system
                callback = mbr.tokensLeft;
            } else {
                callback = multiplier.mul((mbr.tokensTotal).div(10));
            }
        }

        updateMember(
            _member,
            curDate,
            mbr.tokensTotal,
            mbr.tokensLeft.sub(callback)
        );

        return callback;
    }

    /**
    * @dev Transfer available shares to partner
    */
    function getDistributedToken()
    public
    onlyIfWhitelisted(msg.sender)
    returns(bool)
    {
        require(unlockTime > now);
        uint256 amount = rewardController(msg.sender);
        _transfer(this, msg.sender, amount);
        return true;
    }

}