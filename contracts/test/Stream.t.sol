// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/Stream.sol";
import "./MockUSD8.sol";

/// @notice Unit tests for PerSecondStream, using MockUSD8 (6 decimals) in
/// place of the real tUSD8. 1 tUSD8 = 1_000_000 base units.
contract StreamTest is Test {
    PerSecondStream public stream;
    MockUSD8 public token;

    address employer = address(0xE001);
    address freelancer = address(0xF001);

    // 0.01 tUSD8 per second = 10_000 base units/sec; 1 hour = 36 tUSD8.
    uint256 constant RATE = 10_000;
    uint256 constant DURATION = 3600;
    uint256 constant DEPOSIT = RATE * DURATION; // 36_000_000 = 36 tUSD8

    function setUp() public {
        token = new MockUSD8();
        stream = new PerSecondStream(address(token));
        token.mint(employer, 1_000_000_000); // 1,000 tUSD8
        vm.prank(employer);
        token.approve(address(stream), type(uint256).max);
    }

    function _create() internal returns (uint256 id) {
        vm.prank(employer);
        id = stream.createStream(freelancer, RATE, DURATION);
    }

    function testCreateStreamLocksDeposit() public {
        uint256 id = _create();
        (address emp, address free, uint256 rate, uint256 start, uint256 dur, uint256 dep, uint256 wd, bool canc) =
            stream.streams(id);
        assertEq(emp, employer);
        assertEq(free, freelancer);
        assertEq(rate, RATE);
        assertEq(dur, DURATION);
        assertEq(dep, DEPOSIT);
        assertEq(wd, 0);
        assertFalse(canc);
        assertEq(start, block.timestamp);
        assertEq(token.balanceOf(address(stream)), DEPOSIT);
        assertEq(token.balanceOf(employer), 1_000_000_000 - DEPOSIT);
    }

    function testAccruedGrowsPerSecond() public {
        uint256 id = _create();
        assertEq(stream.accrued(id), 0);
        vm.warp(block.timestamp + 60);
        assertEq(stream.accrued(id), RATE * 60); // 0.6 tUSD8 after a minute
        vm.warp(block.timestamp + 3540);
        assertEq(stream.accrued(id), DEPOSIT); // capped at the deposit
    }

    function testAccruedCapsAtDepositAfterDuration() public {
        uint256 id = _create();
        vm.warp(block.timestamp + DURATION + 99999);
        assertEq(stream.accrued(id), DEPOSIT);
    }

    function testWithdrawPaysAccruedAndKeepsTicking() public {
        uint256 id = _create();
        vm.warp(block.timestamp + 1800); // half the stream
        vm.prank(freelancer);
        uint256 paid = stream.withdraw(id);
        assertEq(paid, RATE * 1800);
        assertEq(token.balanceOf(freelancer), RATE * 1800);
        assertEq(stream.accrued(id), 0);
        vm.warp(block.timestamp + 1800); // to the end
        vm.prank(freelancer);
        paid = stream.withdraw(id);
        assertEq(paid, RATE * 1800);
        assertEq(token.balanceOf(freelancer), DEPOSIT);
        assertEq(token.balanceOf(address(stream)), 0);
    }

    function testWithdrawRevertsWhenNothingAccrued() public {
        uint256 id = _create();
        vm.prank(freelancer);
        vm.expectRevert(PerSecondStream.NothingAccrued.selector);
        stream.withdraw(id);
    }

    function testWithdrawOnlyFreelancer() public {
        uint256 id = _create();
        vm.warp(block.timestamp + 10);
        vm.prank(employer);
        vm.expectRevert(PerSecondStream.NotFreelancer.selector);
        stream.withdraw(id);
    }

    function testCancelPaysAccruedAndRefundsRest() public {
        uint256 id = _create();
        vm.warp(block.timestamp + 900); // a quarter of the stream
        vm.prank(employer);
        stream.cancel(id);
        assertEq(token.balanceOf(freelancer), RATE * 900);
        assertEq(token.balanceOf(employer), 1_000_000_000 - DEPOSIT + (DEPOSIT - RATE * 900));
        assertEq(token.balanceOf(address(stream)), 0);
        (, , , , , , , bool canc) = stream.streams(id);
        assertTrue(canc);
    }

    function testCancelThenWithdrawReverts() public {
        uint256 id = _create();
        vm.warp(block.timestamp + 100);
        vm.prank(employer);
        stream.cancel(id);
        vm.prank(freelancer);
        vm.expectRevert(PerSecondStream.StreamCancelledAlready.selector);
        stream.withdraw(id);
    }

    function testCancelOnlyEmployer() public {
        uint256 id = _create();
        vm.prank(freelancer);
        vm.expectRevert(PerSecondStream.NotEmployer.selector);
        stream.cancel(id);
    }

    function testDoubleCancelReverts() public {
        uint256 id = _create();
        vm.prank(employer);
        stream.cancel(id);
        vm.prank(employer);
        vm.expectRevert(PerSecondStream.StreamCancelledAlready.selector);
        stream.cancel(id);
    }

    function testCreateRevertsOnBadInputs() public {
        vm.prank(employer);
        vm.expectRevert(PerSecondStream.ZeroAddress.selector);
        stream.createStream(address(0), RATE, DURATION);
        vm.prank(employer);
        vm.expectRevert(PerSecondStream.ZeroRate.selector);
        stream.createStream(freelancer, 0, DURATION);
        vm.prank(employer);
        vm.expectRevert(PerSecondStream.ZeroDuration.selector);
        stream.createStream(freelancer, RATE, 0);
    }

    function testTwoStreamsAreIndependent() public {
        uint256 a = _create();
        uint256 b = _create();
        vm.warp(block.timestamp + 100);
        assertEq(stream.accrued(a), RATE * 100);
        assertEq(stream.accrued(b), RATE * 100);
        vm.prank(freelancer);
        stream.withdraw(a);
        assertEq(stream.accrued(a), 0);
        assertEq(stream.accrued(b), RATE * 100);
        assertEq(token.balanceOf(address(stream)), DEPOSIT * 2 - RATE * 100);
    }
}
