// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Script, console2} from "forge-std/Script.sol";
import "../src/MetaPersona.sol";
import "../test/MetaPersona.t.sol";

contract MetaPersonaScript is Script {
    MetaPersonaTest mpt;

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
        _adam_p_y = uint192(1);
        fillAutosome(_adam_m_a);
        fillX(_adam_m_x);
        fillAutosome(_eve_p_a);
        fillAutosome(_eve_m_a);
        fillX(_eve_p_x);
        fillX(_eve_m_x);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.envAddress("DEPLOYER");
        string memory uri = vm.envString("URI");

        vm.startBroadcast(deployerPrivateKey);

        MetaPersona metaPersona = new MetaPersona(deployer, uri);

        metaPersona.genesis(_adam_p_a, _adam_p_y, _adam_m_a, _adam_m_x, _eve_p_a, _eve_p_x, _eve_m_a, _eve_m_x);

        vm.stopBroadcast();
    }

    function fillAutosome(uint256[37] memory _array) private view {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = i;
        }
    }

    function fillX(uint256[2] memory _array) private view {
        for (uint256 i = 0; i < _array.length; i++) {
            _array[i] = i;
        }
    }
}
