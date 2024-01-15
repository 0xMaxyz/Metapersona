// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/MetaPersona.sol";
import "../src/lib/Genetics.sol";

contract MetaPersonaScript is Script {
    function run() public {
        uint256[37] memory _adam_p_a;
        uint192 _adam_p_y;
        uint256[37] memory _adam_m_a;
        uint256[2] memory _adam_m_x;
        uint256[37] memory _eve_p_a;
        uint256[2] memory _eve_p_x;
        uint256[37] memory _eve_m_a;
        uint256[2] memory _eve_m_x;

        // initialize input values
        fillAutosome(_adam_p_a);
        _adam_p_y = uint192(rand());
        fillAutosome(_adam_m_a);
        fillX(_adam_m_x);
        fillAutosome(_eve_p_a);
        fillAutosome(_eve_m_a);
        fillX(_eve_p_x);
        fillX(_eve_m_x);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.envAddress("DEPLOYER");
        string memory uri = vm.envString("URI");

        uint256 seed = rand();

        vm.startBroadcast(deployerPrivateKey);

        MetaPersona metaPersona = new MetaPersona(deployer, uri, seed);

        metaPersona.genesis(_adam_p_a, _adam_p_y, _adam_m_a, _adam_m_x, _eve_p_a, _eve_p_x, _eve_m_a, _eve_m_x);

        vm.stopBroadcast();
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
