// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import "../src/lib/Genetics.sol";

contract GeneticsTest is Test {
    function setUp() public {}

    function test_DecodeCrossovers(uint8 index) public {
        //vm.assume(index < 16);
        vm.assume(index < 8);

        uint8 crossOver = Genetics.getCrossover(index);
        console2.log(crossOver);
        assertEq(index + 3, crossOver);
    }
}
