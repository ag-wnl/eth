// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "../src/erc20.sol";

contract ERC20Test is Test {
    ERC20 public token;
    address public owner;
    address public alice;
    address public bob;

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        
        token = new ERC20("Test Token", "TEST");
    }

    // Basic functionality tests
    function test_InitialState() public {
        assertEq(token.name(), "Test Token");
        assertEq(token.symbol(), "TEST");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 0);
        assertEq(token.owner(), owner);
    }

    function test_Mint() public {
        uint256 amount = 1000e18;
        
        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(address(0), alice, amount);
        
        token.mint(alice, amount);
        
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), amount);
    }

    function test_Mint_OnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert("only owner can mint tokens");
        token.mint(bob, 1000e18);
    }

    function test_Transfer() public {
        uint256 amount = 1000e18;
        token.mint(alice, amount);
        
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(alice, bob, amount);
        
        bool success = token.transfer(bob, amount);
        
        assertTrue(success);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), amount);
    }

    function test_Transfer_InsufficientBalance() public {
        token.mint(alice, 500e18);
        
        vm.prank(alice);
        vm.expectRevert("insufficient balance");
        token.transfer(bob, 1000e18);
    }

    function test_Transfer_ZeroAddress() public {
        token.mint(alice, 1000e18);
        
        vm.prank(alice);
        vm.expectRevert("cant send to zero address, call burn method if you want to destroy tokens");
        token.transfer(address(0), 1000e18);
    }

    function test_Approve() public {
        uint256 amount = 1000e18;
        
        vm.expectEmit(true, true, true, true);
        emit ERC20.Approval(alice, bob, amount);
        
        vm.prank(alice);
        bool success = token.approve(bob, amount);
        
        assertTrue(success);
        assertEq(token.allowance(alice, bob), amount);
    }

    function test_TransferFrom() public {
        uint256 amount = 1000e18;
        token.mint(alice, amount);
        
        vm.prank(alice);
        token.approve(bob, amount);
        
        vm.prank(bob);
        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(alice, bob, amount);
        
        bool success = token.transferFrom(alice, bob, amount);
        
        assertTrue(success);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), amount);
        assertEq(token.allowance(alice, bob), 0);
    }

    function test_TransferFrom_InsufficientAllowance() public {
        uint256 amount = 1000e18;
        token.mint(alice, amount);
        
        vm.prank(alice);
        token.approve(bob, 500e18);
        
        vm.prank(bob);
        vm.expectRevert("insufficient allowance");
        token.transferFrom(alice, bob, amount);
    }

    function test_TransferFrom_SelfTransfer() public {
        uint256 amount = 1000e18;
        token.mint(alice, amount);
        
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(alice, bob, amount);
        
        bool success = token.transferFrom(alice, bob, amount);
        
        assertTrue(success);
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), amount);
    }

    // Event emission tests
    function test_TransferEvent() public {
        uint256 amount = 1000e18;
        token.mint(alice, amount);
        
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit ERC20.Transfer(alice, bob, amount);
        token.transfer(bob, amount);
    }

    function test_ApprovalEvent() public {
        uint256 amount = 1000e18;
        
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit ERC20.Approval(alice, bob, amount);
        token.approve(bob, amount);
    }

    // Fuzz tests
    function testFuzz_Mint(uint256 amount) public {
        vm.assume(amount <= type(uint256).max / 2); // Prevent overflow
        
        token.mint(alice, amount);
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), amount);
    }

    function testFuzz_Transfer(uint256 amount) public {
        vm.assume(amount > 0 && amount <= type(uint256).max / 2);
        
        token.mint(alice, amount);
        
        vm.prank(alice);
        token.transfer(bob, amount);
        
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), amount);
    }

    function testFuzz_Approve(uint256 amount) public {
        vm.prank(alice);
        token.approve(bob, amount);
        assertEq(token.allowance(alice, bob), amount);
    }
}
