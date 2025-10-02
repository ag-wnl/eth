// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vesting {
    struct VestingInfo {
        uint256 totalAmount;
        uint256 startTime;
        uint256 duration;
        uint256 claimedAmount;
    }

    IERC20 public immutable token; // vested token

    mapping(address => VestingInfo) public vestingInfo;

    // events
    event Deposit(address recipient, uint256 amount, uint256 duration);
    event Claim(address recipient, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function deposit(address _recipient, uint256 _amount, uint256 _duration) external {
        require(_amount > 0, "amount should be > 0.");
        require(_duration > 0, "duration should be > 0 days");
        require(_recipient != address(0), "recipient cant be zero address.");

        uint256 duration = _duration * 1 days;
        require(token.transferFrom(msg.sender, address(this), _amount), "deposit failed.");

        VestingInfo storage info = vestingInfo[_recipient];
        info.totalAmount += _amount;
        info.duration = _duration;
        info.startTime = block.timestamp;

        emit Deposit(_recipient, _amount, duration);
    }

    // @note shows amount of unlocked tokens which can be claimed
    function unlockedTokens(address _recipient) public view returns (uint256) {
        VestingInfo memory info = vestingInfo[_recipient];
        if(info.totalAmount == 0) return 0;

        uint256 elapsed = block.timestamp - info.startTime;
        
        if(elapsed >= info.duration) return info.totalAmount - info.claimedAmount;

        uint256 vested = (info.totalAmount * elapsed) / info.duration;
        return vested > info.claimedAmount ? vested - info.claimedAmount : 0;
    }

    function claim() external returns (bool) {
        uint256 amount = unlockedTokens(msg.sender);
        require(amount > 0, "no tokens to claim...");

        VestingInfo storage info = vestingInfo[msg.sender];
        info.claimedAmount += amount;

        require(token.transfer(msg.sender, amount), "transfer failed...");
        emit Claim(msg.sender, amount);

        return true;
    }

    function getVestingInfo(address _recipient) public view returns (VestingInfo memory) {
        return vestingInfo[_recipient];
    }
}
