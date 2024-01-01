// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Test, console2} from "forge-std/Test.sol";
import {Helpers} from "../src/lib/Helpers.sol";
import {Errors} from "../src/lib/Errors.sol";

contract HelpersTest is Test {
    function setUp() public {}

    function test_getStringLength() public {
        string memory input1 = "TestString"; // 10
        string memory input2 = "12345678901234567890"; // 20

        uint256 input1Length = 10;
        uint256 input2Length = 20;

        uint256 result1 = Helpers.getStringLength(input1);
        uint256 result2 = Helpers.getStringLength(input2);

        assertEq(input1Length, result1);
        assertEq(input2Length, result2);
    }

    function test_fromHexChar() public {
        uint8 input = uint8(bytes("0")[0]);
        uint8 output = Helpers.fromHexChar(input);
        assertEq(0, output);

        input = uint8(bytes("9")[0]);
        output = Helpers.fromHexChar(input);
        assertEq(9, output);

        input = uint8(bytes("A")[0]);
        output = Helpers.fromHexChar(input);
        assertEq(10, output);

        input = uint8(bytes("a")[0]);
        output = Helpers.fromHexChar(input);
        assertEq(10, output);

        input = uint8(bytes("F")[0]);
        output = Helpers.fromHexChar(input);
        assertEq(15, output);

        input = uint8(bytes("f")[0]);
        output = Helpers.fromHexChar(input);
        assertEq(15, output);

        input = uint8(bytes("g")[0]);
        vm.expectRevert(Errors.InvalidHexChar.selector);
        output = Helpers.fromHexChar(input);
    }
}
