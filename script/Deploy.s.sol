// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "../contracts/src/Stream.sol";

/// @notice Deploy PerSecondStream to Aevum testnet (chain 44005).
/// @notice The deployer needs a little tQDAY for gas (about 0.001 tQDAY at
/// 1 gwei; the Discord faucet gives 1 tQDAY + 5 tUSD8). Aevum uses legacy
/// (type 0) transactions, so always pass --legacy.
/// @notice Run:
///   cast wallet import aevum-deployer --interactive   # paste TEST key only
///   forge script script/Deploy.s.sol --rpc-url https://rpc-test.qday.info \
///     --account aevum-deployer --legacy --broadcast
contract Deploy is Script {
    address constant TUSD8 = 0x456569838f1d43009A91ebA4263147Afd7233483;

    function run() external returns (address deployed) {
        vm.startBroadcast();
        PerSecondStream stream = new PerSecondStream(TUSD8);
        vm.stopBroadcast();
        deployed = address(stream);
    }
}
