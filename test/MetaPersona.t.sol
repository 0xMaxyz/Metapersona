// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import "../src/MetaPersona.sol";
import "../src/lib/Helpers.sol";

contract MetaPersonaTest is Test {
    string uri = "https://www.metapersona.fun/pid/";
    address private proxy;
    address deployerAddress;
    MetaPersona metaPersona;
    uint256 randomSeed;

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.addr(deployerPrivateKey);

        vm.startPrank(deployerAddress);
        proxy =
            Upgrades.deployUUPSProxy("MetaPersona.sol", abi.encodeCall(MetaPersona.initialize, (deployerAddress, uri)));
        vm.stopPrank();

        metaPersona = MetaPersona(proxy);
    }

    function test_Access() public {
        // Upgrader
        bytes32 upgrader = metaPersona.UPGRADER_ROLE();
        bool isUpgrader = metaPersona.hasRole(upgrader, deployerAddress);

        assertEq(isUpgrader, true);
        // Admin
        bytes32 admin = metaPersona.DEFAULT_ADMIN_ROLE();
        bool isAdmin = metaPersona.hasRole(admin, deployerAddress);

        assertEq(isAdmin, true);
    }

    // function test_genesis() public {
    //     vm.startPrank(deployerAddress);
    //     Structs.Chromosome memory adamFather = initializeChromosomes(true);
    //     Structs.Chromosome memory adamMother = initializeChromosomes(false);
    //     Structs.Chromosomes memory adam;
    //     adam.chromosome[0] = adamFather;
    //     adam.chromosome[1] = adamMother;

    //     Structs.Chromosome memory eveFather = initializeChromosomes(false);
    //     Structs.Chromosome memory eveMother = initializeChromosomes(false);
    //     Structs.Chromosomes memory eve;
    //     eve.chromosome[0] = eveFather;
    //     eve.chromosome[1] = eveMother;

    //     metaPersona.genesis(adam, eve);
    //     vm.stopPrank();

    //     Structs.Chromosomes memory savedAdam = metaPersona.getChromosomes(deployerAddress, 1);
    //     Structs.Chromosomes memory savedEve = metaPersona.getChromosomes(deployerAddress, 2);

    //     assertEq(keccak256(abi.encode(adam)), keccak256(abi.encode(savedAdam)));
    //     assertEq(keccak256(abi.encode(eve)), keccak256(abi.encode(savedEve)));
    // }

    uint256 constant chromosomeYMask = 0x0000000000000000000000000000000000000000000000ffffffffffffffffff;

    // function initializeChromosomes(bool _male) private returns (Structs.Chromosome memory _chromosome) {
    //     for (uint256 j = 0; j < 39; j++) {
    //         uint256 rand = Helpers.random(randomSeed++);
    //         _chromosome.DNA[j] = rand;
    //     }
    //     if (_male) {
    //         // Remove X chromosome
    //         _chromosome.DNA[36] = _chromosome.DNA[36] & (~Genetics.C_X_36_MASK);
    //         _chromosome.DNA[37] = 0;
    //         _chromosome.DNA[38] = _chromosome.DNA[38] & (Genetics.C_Y_38_MASK);
    //     } else {
    //         // Remove Y chromosome
    //         _chromosome.DNA[38] = _chromosome.DNA[38] & (~Genetics.C_Y_38_MASK);
    //     }
    // }
}
