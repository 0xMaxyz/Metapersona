// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import "../src/MetaPersona.sol";
import "../src/Chromosome.sol";

contract MetaPersonaTest is Test, PersonaBase {
    address deployerAddress;
    string uri;
    MetaPersona metaPersona;
    uint256 randomSeed;

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        deployerAddress = vm.envAddress("DEPLOYER");
        uri = vm.envString("URI");

        vm.startPrank(deployerAddress);
        metaPersona = new MetaPersona(deployerAddress, uri);
        vm.stopPrank();
    }

    function test_Access() public {
        // Admin
        bytes32 admin = metaPersona.DEFAULT_ADMIN_ROLE();
        bool isAdmin = metaPersona.hasRole(admin, deployerAddress);

        assertEq(isAdmin, true);

        // God
        bytes32 god = metaPersona.GOD_ROLE();
        bool isGod = metaPersona.hasRole(god, deployerAddress);

        assertEq(isGod, true);
    }

    function fillAutosome(uint256[37] memory _array) public view {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = i;
        }
    }

    function fillX(uint256[2] memory _array) public view {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = i;
        }
    }

    function test_genesis() public {
        vm.startPrank(deployerAddress);

        uint256[37] memory _adam_p_a;
        uint192 _adam_p_y;
        uint256[37] memory _adam_m_a;
        uint256[2] memory _adam_m_x;
        uint256[37] memory _eve_p_a;
        uint256[2] memory _eve_p_x;
        uint256[37] memory _eve_m_a;
        uint256[2] memory _eve_m_x;

        fillAutosome(_adam_p_a);
        _adam_p_y = uint192(1);
        fillAutosome(_adam_m_a);
        fillX(_adam_m_x);
        fillAutosome(_eve_p_a);
        fillAutosome(_eve_m_a);
        fillX(_eve_p_x);
        fillX(_eve_m_x);

        metaPersona.genesis(_adam_p_a, _adam_p_y, _adam_m_a, _adam_m_x, _eve_p_a, _eve_p_x, _eve_m_a, _eve_m_x);
        vm.stopPrank();

        // Structs.Chromosomes memory savedAdam = metaPersona.getChromosomes(deployerAddress, 1);
        // Structs.Chromosomes memory savedEve = metaPersona.getChromosomes(deployerAddress, 2);

        // assertEq(keccak256(abi.encode(adam)), keccak256(abi.encode(savedAdam)));
        // assertEq(keccak256(abi.encode(eve)), keccak256(abi.encode(savedEve)));
    }
}
