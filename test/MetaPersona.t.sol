// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import "../src/MetaPersona.sol";
import "../src/lib/Genetics.sol";

contract MetaPersonaTest is Test {
    address deployerAddress;
    string uri;
    MetaPersona metaPersona;
    uint256 randomSeed;

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER");
        uri = vm.envString("URI");

        vm.startPrank(deployerAddress);
        metaPersona = new MetaPersona(deployerAddress, uri, 1);
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

    function fillAutosome(uint256[37] memory _array) public pure {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = i;
        }
    }

    function fillX(uint256[2] memory _array) public pure {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = i;
        }
    }

    function genesis() private {
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
    }

    function test_genesis() public {
        genesis();
        uint256 adB = metaPersona.balanceOf(deployerAddress, 1);
        uint256 evB = metaPersona.balanceOf(deployerAddress, 2);

        assertEq(adB, 1);
        assertEq(evB, 1);
    }

    function test_breeding() public {
        genesis();

        vm.startPrank(deployerAddress);
        uint256 newPersonaId = metaPersona.breed(1, 2, deployerAddress, deployerAddress, deployerAddress);
        vm.stopPrank();

        assertEq(newPersonaId, 3);

        vm.startPrank(deployerAddress);
        newPersonaId = metaPersona.breed(1, 2, deployerAddress, deployerAddress, deployerAddress);
        vm.stopPrank();

        assertEq(newPersonaId, 4);
    }
}
