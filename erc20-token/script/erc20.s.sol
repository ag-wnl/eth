// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC20} from "../src/ERC20.sol";

contract CounterScript is Script {
    ERC20 public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new ERC20("Test Token", "TEST");

        vm.stopBroadcast();
    }
}
