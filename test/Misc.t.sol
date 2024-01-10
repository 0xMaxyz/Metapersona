// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";

contract MiscTests is Test {
    function setUp() public {}

    function test_bitShifting() public {
        uint256 input = 0xffffffff00000000000000000000000000000000000000000000000000000000;
        uint256 rsh = 0xffffffff;
        uint256 result = input >> 224;

        assertEq(result, rsh);

        input = 0xf23456789000000000000000000000000000000000aaaaaaaaaaaaaaffffffff;
        uint256 lsh = 0xffffffff;
        result = (input << 224) >> 224;

        assertEq(result, lsh);
    }

    function test_GasTest() public {
        uint256 input = 0xf23456789000000000000000000000000000000000aaaaaaaaaaaaaaffffffff;

        uint256 b = input / 2;

        uint256 a1 = b + 7;
        uint256 a2 = b + 8;
        uint256 a3 = b + 9;
        uint256 a4 = b + 10;
    }
}
