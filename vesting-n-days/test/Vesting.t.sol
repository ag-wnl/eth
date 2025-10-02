// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Vesting} from "../src/Vesting.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract CounterTest is Test {
    Vesting public vesting;
    MockERC20 public token;

    address public user = makeAddr("user");
    address public recipient = makeAddr("recipient");
    uint256 public amount = 1 ether;
    uint256 public duration = 4 days;

    // @note - vm.prank use to emulate user actions
    function setUp() public {
        token = new MockERC20("Test Token", "TEST");
        vesting = new Vesting(address(token));
        
        token.mint(user, 1000 ether);
        vm.prank(user);
        token.approve(address(vesting), 1000 ether);
    }

    function test_Deposit() public {
        vm.prank(user);
        vesting.deposit(recipient, amount, duration);

        assertEq(vesting.getVestingInfo(recipient).totalAmount, amount);
        assertEq(vesting.getVestingInfo(recipient).duration, duration);
        assertEq(vesting.getVestingInfo(recipient).claimedAmount, 0);
    }

    function test_UnlockedTokens() public {
        assertEq(vesting.unlockedTokens(recipient), 0);
    }

    function test_Claim() public {
        vm.prank(recipient);
        vesting.claim();
        
        assertNotEq(vesting.getVestingInfo(recipient).claimedAmount, amount);
    }
}
