// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";

import "../src/MetaPersona.sol";
import "../src/lib/Genetics.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../src/Errors.sol";

contract MetaPersonaTest is Test {
    using Strings for uint256;

    address deployerAddress;
    string uri;
    MetaPersona metaPersona;
    uint256 randomSeed;
    uint256 spawnFee;

    event PersonaStaked(uint256 indexed _personaId);
    event NewPersonaBorn(uint256 indexed _personaId, address indexed receiver);
    event PersonaUnstaked(uint256 indexed _personaId, uint256 indexed reward);

    function setUp() public {
        deployerAddress = vm.envAddress("DEPLOYER");
        uri = vm.envString("URI");

        vm.deal(deployerAddress, 100 ether);
        vm.startPrank(deployerAddress);
        metaPersona = new MetaPersona(deployerAddress, uri, 1);
        spawnFee = metaPersona.SpawnFee();
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

        // check Personas mapping
        vm.startPrank(deployerAddress);
        uint256[] memory personas = metaPersona.getPersonas();

        console.logUint(personas.length);
        assertEq(personas[0], 1);
        assertEq(personas[1], 2);
        vm.stopPrank();
    }

    function test_spawning() public {
        genesis();

        vm.startPrank(deployerAddress);
        uint256 newPersonaId = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        uint256[] memory ids = metaPersona.getPersonas();
        vm.stopPrank();

        assertEq(newPersonaId, 3);
        assertEq(ids[ids.length - 1], 3);

        vm.startPrank(deployerAddress);
        newPersonaId = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        uint256[] memory ids2 = metaPersona.getPersonas();
        vm.stopPrank();

        assertEq(newPersonaId, 4);
        assertEq(ids2[ids2.length - 1], 4);
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
        uint256 newPersonaId = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        // get the chromosomes of this new persona
        Genetics.Chromosome[2] memory _chr = metaPersona.getChromosomes(deployerAddress, newPersonaId);
        vm.stopPrank();

        vm.startPrank(spawner);
        newPersonaId = metaPersona.spawn(1, 2, deployerAddress, deployerAddress, deployerAddress, _chr);
        uint256[] memory ids1 = metaPersona.getPersonas(deployerAddress);
        vm.stopPrank();

        assertEq(ids1[ids1.length - 1], 4);

        vm.prank(deployerAddress);
        uint256[] memory ids2 = metaPersona.getPersonas();

        assertEq(newPersonaId, 4);
        assertEq(ids2[ids2.length - 1], 4);
    }

    function test_femaleCooldownError() public {
        genesis();
        vm.startPrank(deployerAddress);
        uint256 newPid = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        while (metaPersona.getGender(newPid) != Genetics.Gender.Female) {
            newPid = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        }
        // then the newPid is female and in cooldown

        vm.expectRevert();
        newPid = metaPersona.spawn{value: spawnFee}(1, newPid, deployerAddress);
        vm.stopPrank();
    }

    function test_femaleCooldownPassed() public {
        genesis();
        vm.startPrank(deployerAddress);
        uint256 newPid = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        while (metaPersona.getGender(newPid) != Genetics.Gender.Female) {
            newPid = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        }

        skip(2 days + 1);
        // then the newPid is female and ain+t in cooldown
        // next call does not revert
        newPid = metaPersona.spawn{value: spawnFee}(1, newPid, deployerAddress);
        vm.stopPrank();
    }

    function test_Children() public {
        genesis();
        vm.startPrank(deployerAddress);

        uint256 newPid = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        uint256[] memory children = metaPersona.getChildren(1, 2);

        assertEq(children[0], newPid);

        vm.stopPrank();
    }

    function test_Parents() public {
        genesis();
        vm.startPrank(deployerAddress);

        uint256 newPid = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        (uint256 parent1, uint256 parent2) = metaPersona.getParents(newPid);

        assert((parent1 == 1 && parent2 == 2) || (parent1 == 2 && parent2 == 1));

        vm.stopPrank();
    }

    function test_getUri() public {
        genesis();
        uint256 adam = 1;
        uint256 eve = 2;
        string memory adamUri = metaPersona.uri(adam);
        string memory eveUri = metaPersona.uri(eve);

        string memory expectedAdamUri = string(abi.encodePacked(uri, adam.toString()));
        string memory expectedEveUri = string(abi.encodePacked(uri, eve.toString()));

        assertEq(adamUri, expectedAdamUri);
        assertEq(eveUri, expectedEveUri);
    }

    function test_getUri0Reverts() public {
        vm.expectRevert();
        string memory _u = metaPersona.uri(0);
    }

    function test_transferSinglePersona() public {
        genesis();
        address receiver = makeAddr("TodenReceiver");

        vm.startPrank(deployerAddress);
        // make new Persona and give it to deployer
        uint256 newPersonaId = metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        // transfer this new persona to another account
        metaPersona.safeTransferFrom(deployerAddress, receiver, newPersonaId, 1, "");

        uint256 deployerBalance = metaPersona.balanceOf(deployerAddress, newPersonaId);
        assertEq(deployerBalance, 0);

        uint256[] memory deployerPersonas = metaPersona.getPersonas();

        vm.expectRevert();
        uint256 _v = deployerPersonas[2];

        vm.stopPrank();

        vm.prank(receiver);
        uint256[] memory receiverPersonas = metaPersona.getPersonas();

        assertEq(receiverPersonas[0], newPersonaId);

        uint256 receiverBalance = metaPersona.balanceOf(receiver, newPersonaId);
        assertEq(receiverBalance, 1);
    }

    function test_staking() public {
        genesis();
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, false, false, false);
        emit PersonaStaked(1);
        metaPersona.stake(1);
        vm.stopPrank();
    }

    function test_CantSpawnWhenStaked() public {
        genesis();
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, false, false, false);
        emit PersonaStaked(1);
        metaPersona.stake(1);

        vm.expectRevert(MetaPersona_CantSpawnWhenStaked.selector);
        metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);

        vm.stopPrank();
    }

    function test_CanSpawnAfterUnstake() public {
        genesis();
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, false, false, false);
        emit PersonaStaked(1);
        metaPersona.stake(1);

        skip(2 days + 1);
        vm.expectEmit(true, false, false, false);
        emit PersonaUnstaked(1, 1);
        metaPersona.unstake(1);

        vm.expectEmit(true, true, false, false);
        emit NewPersonaBorn(3, deployerAddress);
        metaPersona.spawn{value: spawnFee}(1, 2, deployerAddress);
        vm.stopPrank();
    }

    function test_CantUnstakeBeforeThresholdTime() public {
        genesis();
        vm.startPrank(deployerAddress);
        vm.expectEmit(true, false, false, false);
        emit PersonaStaked(1);
        metaPersona.stake(1);

        vm.expectRevert();
        metaPersona.unstake(1);

        vm.stopPrank();
    }

    function test_UnstakeMakesRewards() public {
        genesis();

        uint256 mpBalance = metaPersona.balanceOf(deployerAddress, 0);
        assert(mpBalance == 0);

        vm.startPrank(deployerAddress);
        vm.expectEmit(true, false, false, false);
        emit PersonaStaked(1);
        metaPersona.stake(1);

        skip(2 days + 1);
        vm.expectEmit(true, false, false, false);
        emit PersonaUnstaked(1, 1);
        metaPersona.unstake(1);

        mpBalance = metaPersona.balanceOf(deployerAddress, 0);
        console.log(mpBalance);

        assert(mpBalance > 0);

        vm.stopPrank();
    }

    function test_revertSpawnIfFeeNotEnough() public {
        genesis();
        vm.startPrank(deployerAddress);
        vm.expectRevert();
        metaPersona.spawn{value: 1 wei}(1, 2, deployerAddress);

        vm.stopPrank();
    }

    function test_combineBits(uint256 a, uint256 b) public pure {
        uint8 partA = uint8(a & 127);
        uint8 partB = uint8(b & 127);

        assert(partA + partB + 1 <= 255);
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
