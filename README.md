# Per-Second Freelancer Stream — tUSD8 on Aevum

A freelancer's pay streams every second in tUSD8 on the Aevum testnet.
Built for the **Aevum Builder Challenge #1 (QDay)**, Track: **Payroll and Vesting**.

**Live on Aevum testnet since 24 Nov 2026 — contract `0xbc6dD8c5c9E2a36A55c716339aBfF404b68F4D97`, 12 unit + 2 fork tests pass.**

**Live demo:** https://skymiller1509-blip.github.io/per-second-stream/
**Demo video:** TODO — film from `VIDEO-SCRIPT.md` (3 min, live testnet flow).

## Hackathon Requirements Met

Aevum Builder Challenge #1 (QDay), DoraHacks — deadline 11 Dec 2026, 09:00 WAT. Each requirement, with proof:

- [x] Public GitHub repo — https://github.com/skymiller1509-blip/per-second-stream (renamed 26 Nov 2026).
- [x] Aevum integration evidence — Stream contract deployed on chain 44005, `0xbc6dD8c5c9E2a36A55c716339aBfF404b68F4D97` (24 Nov 2026), explorer: https://explorer-test.qday.info; tUSD8 `0x456569838f1d43009A91ebA4263147Afd7233483`.
- [x] Live deployment (working demo) — https://skymiller1509-blip.github.io/per-second-stream/ (render-verified 27 Nov 2026: loads, Start a stream and My streams sections present, balances tick once a second).
- [x] Documentation — this README, with the exact commands and the real test results.
- [ ] Demo video — script in `VIDEO-SCRIPT.md`; Eddie films on her phone (live testnet flow: create → accrue → withdraw → cancel).
- [ ] DoraHacks BUIDL submitted before 11 Dec 2026 09:00 WAT (Eddie's step; draft ready in `BUIDL-DRAFT.md`, only the YouTube link is missing).

Demo failure-proofing: the filmed stream is short (about 5 minutes, 0.08 hours at 0.01 tUSD8/s, about 3 tUSD8 deposit) so it fits the 4 tUSD8 the wallet holds. The contract calls the app makes are the same ones proven on the fork.

## Judging Highlights

- **Innovation:** pay that streams every second — the freelancer watches their balance tick up live, once a second, and pulls out what they have earned at any time.
- **Technical execution:** contract deployed live on chain 44005; 12 unit tests and 2 fork tests pass; live-fork end to end proven (stream 0 accrued exactly 18,000,000 base units after 1,800 seconds; stream 1 cancelled after 900 seconds with the exact 9,000,000 accrued paid and the 27,000,000 remainder refunded).
- **Impact:** freelancers wait weeks to get paid and then chase invoices. A stream pays continuously, and if the job ends early the employer cancels and gets back whatever has not accrued yet.
- **Completeness:** contract + web app + docs, all live; the top 5 do a 3–5 minute live video-call walkthrough, and this demo is built for exactly that.

## The problem

Freelancers wait weeks to get paid, then chase invoices. A stream pays
continuously: the money is locked up front, it accrues every second, and the
freelancer pulls out what they have earned at any time. If the job ends early,
the employer cancels and gets back whatever has not accrued yet.

## The flow (one flow, end to end)

1. Employer connects a wallet on Aevum testnet (chain 44005).
2. Employer starts a stream: freelancer address, pay per second in tUSD8,
   duration in hours. The full amount locks in the contract.
3. The freelancer watches their balance tick up live, once a second.
4. Freelancer presses Withdraw at any time and gets what has accrued.
5. Employer can Cancel at any time: the freelancer keeps what accrued, the
   employer gets the rest back.

## Contract

`contracts/src/Stream.sol` — `PerSecondStream`, Solidity 0.8.24, EVM Shanghai.

- `createStream(freelancer, ratePerSecond, durationSeconds)` — locks
  `rate * duration` tUSD8 (needs an `approve` first).
- `accrued(streamId)` — view of what has been earned minus what was withdrawn.
- `withdraw(streamId)` — freelancer only, pays the accrued amount.
- `cancel(streamId)` — employer only, pays accrued to the freelancer and
  refunds the rest to the employer.
- Events: `StreamCreated`, `Withdrawn`, `StreamCancelled`.

Only standard ERC20 `transfer` / `transferFrom` / `balanceOf` are used, so
the contract works with the real tUSD8 unchanged.

## Verified facts (checked live 2026-11-23)

- Challenge: Aevum Builder Challenge #1 — https://dorahacks.io/hackathon/qday/detail
- Starter kit docs: https://aevum-starter-kit.vercel.app/docs
- Build window: 16 Nov – 11 Dec 2026. **Deadline: 11 Dec 2026, 16:00 HKT
  (08:00 UTC = 09:00 WAT).** Late submissions are not accepted.
- Judging 12–14 Dec; winners 15 Dec 14:00 HKT.
- Prizes: $1,500 USDT — 1st $800, 2nd $500, 3rd $200.
- Solo is fine (solo or teams of 2–4).
- Network: Aevum testnet, chain ID **44005**, RPC
  `https://rpc-test.qday.info` (HTTPS only, no WebSocket), explorer
  `https://explorer-test.qday.info`, gas token tQDAY (18 decimals, ~1 gwei),
  EVM **Shanghai** (no Cancun opcodes).
- tUSD8: `0x456569838f1d43009A91ebA4263147Afd7233483`, 6 decimals, EIP-2612
  permit + EIP-3009. Verified live: chain ID 44005, block 3939152, contract
  code present.
- Faucet: Discord faucet is recommended (1 tQDAY + 5 tUSD8, once per Discord
  account and once per address; join the QDay Discord, react in `#verify`,
  then `/faucet` with your address). The web faucet only pays addresses that
  hold a little ETH, USDT or USDC on Ethereum mainnet.
- Submission needs: public GitHub repo, Aevum integration evidence, a live
  deployment (working demo), documentation, and a demo (top 5 do a 3–5 minute
  live video-call walkthrough). Contract addresses on 44005 with explorer
  links, a link to the exact commit deployed, and a few transaction hashes.
  Explorer contract verification is not working yet — share addresses and the
  commit instead.
- The starter kit is MIT licensed and building on it is allowed with credit
  (see NOTICE).

## Test results

Unit tests (`forge test`): **12 passed, 0 failed.**

- Create locks the exact deposit; accrual grows per second and caps at the
  deposit; withdraw pays accrued and keeps ticking; cancel pays accrued and
  refunds the rest; wrong caller / zero accrued / double cancel / bad inputs
  all revert; two streams are independent.

Fork tests against the real tUSD8 (`forge test --fork-url
https://rpc-test.qday.info --match-contract StreamForkTest`): **2 passed.**

Live end-to-end on a local fork of Aevum (anvil, chain 440050, real tUSD8):

- Deployed the contract: success, 1,054,811 gas (~0.001 tQDAY at 1 gwei).
- Stream 0 (0.01 tUSD8/sec, 1 hour, 36 tUSD8 locked): accrued exactly
  18,000,000 base units after 1,800 seconds; two withdraws paid the full
  36 tUSD8 out; contract balance 0.
- Stream 1: cancelled after 900 seconds; freelancer got exactly 9,000,000
  accrued, employer got the 27,000,000 remainder back; contract balance 0.

Web app (`app/`, Vite + viem): `tsc` clean, `vite build` clean, serves
HTTP 200 with the correct title and bundle.

## Run it

```bash
# Unit + fork tests
forge test
forge test --fork-url https://rpc-test.qday.info --match-contract StreamForkTest

# Web app
cd app
npm install
npm run dev        # http://localhost:5173
```

Paste the deployed Stream address in the app (or set `VITE_STREAM_ADDRESS`
in `app/.env`). The app adds the Aevum testnet to your wallet for you.

## Deployed on Aevum testnet

**Live since 2026-11-24.** Stream contract:
`0xbc6dD8c5c9E2a36A55c716339aBfF404b68F4D97` — see it on the explorer:
https://explorer-test.qday.info (chain 44005). The deployer was funded
via the Discord faucet (1 tQDAY + 5 tUSD8). Amounts are tUSD8 test
tokens with no real value.

The web app is wired to this address (`app/src/main.ts`, fallback
`VITE_STREAM_ADDRESS`).

To deploy again (a fresh TEST key only):

```bash
cast wallet import aevum-deployer --interactive   # paste a TEST key only
forge script script/Deploy.s.sol --rpc-url https://rpc-test.qday.info \
  --account aevum-deployer --legacy --broadcast
```

Aevum uses legacy (type 0) transactions, so always pass `--legacy`.

Fresh testnet-only deployer address (key in `keys/`, never committed):
`0x8f578E6B0B811CE888D3406b0Fd2550e8dE52625` — fund it from the Discord
faucet (1 tQDAY + 5 tUSD8), then run the deploy script.

## Honest limits

- The contract is deployed live on the Aevum testnet (see above) and the
  same flow was proven end to end on a local fork first.
- The live demo site was render-verified 27 Nov 2026 (loads, Start a
  stream and My streams sections present, balances tick once a second);
  the contract calls the app makes are the same ones proven on the fork.
- The demo shows the stream ticking live; it does not do gasless payments
  (no public tQDAY paymaster exists yet) and it does not use ERC-8004 (the
  registry is still in internal testing and is not open for this challenge).
- Amounts are tUSD8 test tokens with no real value.

## Submission checklist

Full checklist: `SUBMISSION-CHECKLIST.md`.

- [x] Contract written, tested (unit + fork + live-fork end to end)
- [x] Web app built, builds clean, serves
- [x] MIT LICENSE, NOTICE crediting the starter kit
- [x] Deployed to Aevum testnet 2026-11-24 (`0xbc6dD8c5c9E2a36A55c716339aBfF404b68F4D97`)
- [x] Public GitHub repo: https://github.com/skymiller1509-blip/per-second-stream (renamed 26 Nov 2026)
- [x] Live demo site: https://skymiller1509-blip.github.io/per-second-stream/ (render-verified 27 Nov 2026)
- [ ] Demo video (script: `VIDEO-SCRIPT.md`)
- [ ] Submit on DoraHacks before 11 Dec 2026 09:00 WAT (Eddie's step; BUIDL draft ready, only the YouTube link is missing)
