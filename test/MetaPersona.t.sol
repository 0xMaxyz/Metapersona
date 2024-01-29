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

        // Spawn
        bytes32 spwn = metaPersona.SPAWN_ROLE();
        bool isspwn = metaPersona.hasRole(spwn, deployerAddress);

        assertEq(isspwn, true);
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
        _adam_p_y = uint192(rand());
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

    function test_spawning() public {
        genesis();

        vm.startPrank(deployerAddress);
        uint256 newPersonaId = metaPersona.spawn(1, 2, deployerAddress, deployerAddress);
        vm.stopPrank();

        assertEq(newPersonaId, 3);

        vm.startPrank(deployerAddress);
        newPersonaId = metaPersona.spawn(1, 2, deployerAddress, deployerAddress);
        vm.stopPrank();

        assertEq(newPersonaId, 4);
    }

    function test_OffchainSpawning() public {
        genesis();

        (address spawner,) = makeAddrAndKey("spawner");

        vm.startPrank(deployerAddress);
        metaPersona.addSpawner(spawner);
        bytes32 spwn = metaPersona.SPAWN_ROLE();
        bool isspwn = metaPersona.hasRole(spwn, spawner);
        assertEq(isspwn, true);

        // create new persona using onchain calculation
        uint256 newPersonaId = metaPersona.spawn(1, 2, deployerAddress, deployerAddress);
        // get the chromosomes of this new persona
        Genetics.Chromosome[2] memory _chr = metaPersona.getChromosomesN(deployerAddress, newPersonaId);
        vm.stopPrank();

        vm.startPrank(spawner);
        newPersonaId = metaPersona.spawn(1, 2, deployerAddress, deployerAddress, deployerAddress, _chr);
        vm.stopPrank();

        assertEq(newPersonaId, 4);
    }

    function rand() public returns (uint256) {
        string[] memory inputs = new string[](6);
        inputs[0] = "openssl";
        inputs[1] = "rand";
        inputs[2] = "-rand";
        inputs[3] = "/dev/random";
        inputs[4] = "-hex";
        inputs[5] = "32";

        bytes memory res = vm.ffi(inputs);
        return bytesToUint256(res);
    }

    function bytesToUint256(bytes memory data) private pure returns (uint256) {
        uint256 result;
        assembly {
            result := mload(add(data, 32))
        }
        return result;
    }

    function fillAutosome(uint256[37] memory _array) public {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = rand();
        }
    }

    function fillX(uint256[2] memory _array) public {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = rand();
        }
    }
}
