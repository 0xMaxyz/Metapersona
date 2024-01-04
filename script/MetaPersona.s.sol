// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "../src/MetaPersona.sol";

contract MetaPersonaScript is Script {
    address private proxy;

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        proxy = Upgrades.deployUUPSProxy(
            "MetaPersona.sol",
            abi.encodeCall(
                MetaPersona.initialize,
                (
                    0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
                    0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
                    0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
                )
            )
        );

        vm.stopBroadcast();
    }

    function run() public {
        vm.broadcast();
    }
}
