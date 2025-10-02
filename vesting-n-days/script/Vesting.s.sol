// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Vesting} from "../src/Vesting.sol";

contract CounterScript is Script {
    Vesting public vesting;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vesting = new Vesting(address(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238)); // usdc eth-sepolia

        vm.stopBroadcast();
    }
}
