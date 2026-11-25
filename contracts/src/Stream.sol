// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title PerSecondStream — a freelancer's pay streams per second in tUSD8
/// @notice Built for the Aevum Builder Challenge #1 (QDay) on Aevum testnet (chain 44005).
/// @notice Track: Payroll and Vesting. One flow: employer funds a stream, the
/// freelancer's pay accrues every second, they withdraw what has accrued at any
/// time, and the employer can cancel and reclaim whatever has not accrued yet.
/// @notice The token is tUSD8 (6 decimals) at 0x456569838f1d43009A91ebA4263147Afd7233483.
/// @notice Only standard ERC20 transfer / transferFrom / balanceOf are used, so
/// this works with the real tUSD8 (a USDC-style FiatToken) unchanged.
/// @notice EVM version is Shanghai (Aevum has no Cancun opcodes).

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PerSecondStream {
    IERC20 public immutable token;

    struct Stream {
        address employer;
        address freelancer;
        uint256 ratePerSecond; // tUSD8 base units (6 decimals) paid per second
        uint256 startTime;
        uint256 duration; // seconds the stream runs for
        uint256 deposited; // ratePerSecond * duration, locked in this contract
        uint256 withdrawn; // total already paid out to the freelancer
        bool cancelled;
    }

    uint256 public nextStreamId;
    mapping(uint256 => Stream) public streams;

    event StreamCreated(
        uint256 indexed streamId,
        address indexed employer,
        address indexed freelancer,
        uint256 ratePerSecond,
        uint256 duration,
        uint256 deposited,
        uint256 startTime
    );
    event Withdrawn(uint256 indexed streamId, address indexed to, uint256 amount);
    event StreamCancelled(
        uint256 indexed streamId,
        uint256 paidToFreelancer,
        uint256 refundedToEmployer
    );

    error ZeroAddress();
    error ZeroRate();
    error ZeroDuration();
    error NotFreelancer();
    error NotEmployer();
    error NothingAccrued();
    error StreamCancelledAlready();
    error TransferFailed();

    constructor(address tokenAddress) {
        if (tokenAddress == address(0)) revert ZeroAddress();
        token = IERC20(tokenAddress);
    }

    /// @notice Fund a new stream. Caller must have approved this contract for
    /// `ratePerSecond * durationSeconds` tUSD8 first.
    function createStream(
        address freelancer,
        uint256 ratePerSecond,
        uint256 durationSeconds
    ) external returns (uint256 streamId) {
        if (freelancer == address(0)) revert ZeroAddress();
        if (freelancer == msg.sender) revert ZeroAddress();
        if (ratePerSecond == 0) revert ZeroRate();
        if (durationSeconds == 0) revert ZeroDuration();

        uint256 deposit = ratePerSecond * durationSeconds;
        streamId = nextStreamId++;

        streams[streamId] = Stream({
            employer: msg.sender,
            freelancer: freelancer,
            ratePerSecond: ratePerSecond,
            startTime: block.timestamp,
            duration: durationSeconds,
            deposited: deposit,
            withdrawn: 0,
            cancelled: false
        });

        emit StreamCreated(
            streamId,
            msg.sender,
            freelancer,
            ratePerSecond,
            durationSeconds,
            deposit,
            block.timestamp
        );

        if (!token.transferFrom(msg.sender, address(this), deposit)) {
            revert TransferFailed();
        }
    }

    /// @notice Total tUSD8 earned so far, minus what was already withdrawn.
    function accrued(uint256 streamId) public view returns (uint256) {
        Stream storage s = streams[streamId];
        uint256 elapsed = block.timestamp > s.startTime
            ? block.timestamp - s.startTime
            : 0;
        if (elapsed > s.duration) elapsed = s.duration;
        uint256 total = s.ratePerSecond * elapsed;
        return total - s.withdrawn;
    }

    /// @notice Total tUSD8 the stream will ever pay (rate * duration).
    function totalPayout(uint256 streamId) public view returns (uint256) {
        return streams[streamId].deposited;
    }

    /// @notice Freelancer pulls whatever has accrued so far. Callable any time.
    function withdraw(uint256 streamId) external returns (uint256 amount) {
        Stream storage s = streams[streamId];
        if (msg.sender != s.freelancer) revert NotFreelancer();
        if (s.cancelled) revert StreamCancelledAlready();
        amount = accrued(streamId);
        if (amount == 0) revert NothingAccrued();
        s.withdrawn += amount;
        emit Withdrawn(streamId, s.freelancer, amount);
        if (!token.transfer(s.freelancer, amount)) revert TransferFailed();
    }

    /// @notice Employer stops the stream. Accrued pay goes to the freelancer,
    /// everything not yet accrued goes back to the employer.
    function cancel(uint256 streamId) external {
        Stream storage s = streams[streamId];
        if (msg.sender != s.employer) revert NotEmployer();
        if (s.cancelled) revert StreamCancelledAlready();
        s.cancelled = true;

        uint256 owed = accrued(streamId);
        uint256 refund = s.deposited - s.withdrawn - owed;
        s.withdrawn += owed;
        emit StreamCancelled(streamId, owed, refund);

        if (owed > 0 && !token.transfer(s.freelancer, owed)) {
            revert TransferFailed();
        }
        if (refund > 0 && !token.transfer(s.employer, refund)) {
            revert TransferFailed();
        }
    }
}
