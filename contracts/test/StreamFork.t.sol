// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/Stream.sol";

/// @notice Fork test against the REAL tUSD8 on Aevum testnet (chain 44005).
/// Run with: forge test --fork-url https://rpc-test.qday.info --match-contract StreamForkTest -vv
/// Proves the stream contract works with the live token contract, not just a mock.
contract StreamForkTest is Test {
    address constant TUSD8 = 0x456569838f1d43009A91ebA4263147Afd7233483;

    PerSecondStream public stream;
    address employer = address(0xE001);
    address freelancer = address(0xF001);

    function setUp() public {
        stream = new PerSecondStream(TUSD8);
    }

    function testRealTokenStreamEndToEnd() public {
        // Give the employer 100 real tUSD8 on the fork (deal works on any ERC20).
        deal(TUSD8, employer, 100_000_000);
        assertEq(IERC20(TUSD8).balanceOf(employer), 100_000_000);

        // 0.01 tUSD8/sec for 1 hour = 36 tUSD8 locked.
        vm.prank(employer);
        IERC20(TUSD8).approve(address(stream), type(uint256).max);
        vm.prank(employer);
        uint256 id = stream.createStream(freelancer, 10_000, 3600);
        assertEq(IERC20(TUSD8).balanceOf(address(stream)), 36_000_000);

        // Half an hour in: 18 tUSD8 accrued.
        vm.warp(block.timestamp + 1800);
        assertEq(stream.accrued(id), 18_000_000);

        // Freelancer withdraws the accrued half.
        vm.prank(freelancer);
        uint256 paid = stream.withdraw(id);
        assertEq(paid, 18_000_000);
        assertEq(IERC20(TUSD8).balanceOf(freelancer), 18_000_000);

        // To the end of the stream: the other half is there.
        vm.warp(block.timestamp + 1800);
        vm.prank(freelancer);
        paid = stream.withdraw(id);
        assertEq(paid, 18_000_000);
        assertEq(IERC20(TUSD8).balanceOf(freelancer), 36_000_000);
        assertEq(IERC20(TUSD8).balanceOf(address(stream)), 0);
    }

    function testRealTokenCancelRefunds() public {
        deal(TUSD8, employer, 100_000_000);
        vm.prank(employer);
        IERC20(TUSD8).approve(address(stream), type(uint256).max);
        vm.prank(employer);
        uint256 id = stream.createStream(freelancer, 10_000, 3600);

        vm.warp(block.timestamp + 900); // a quarter in
        vm.prank(employer);
        stream.cancel(id);
        assertEq(IERC20(TUSD8).balanceOf(freelancer), 9_000_000);
        assertEq(IERC20(TUSD8).balanceOf(employer), 100_000_000 - 36_000_000 + 27_000_000);
    }
}
