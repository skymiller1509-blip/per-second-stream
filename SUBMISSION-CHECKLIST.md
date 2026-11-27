# Per-Second Freelancer Stream — submission checklist

Aevum Builder Challenge #1 (QDay), DoraHacks — **deadline 11 Dec 2026,
16:00 HKT (08:00 UTC = 09:00 WAT)**. Late submissions are not accepted.
Judging 12–14 Dec; winners 15 Dec 14:00 HKT.
Prizes: **$1,500 USDT** — 1st $800, 2nd $500, 3rd $200.
Challenge page: https://dorahacks.io/hackathon/qday/detail

## Deployed contract (live, verified facts)

- Stream contract: `0xbc6dD8c5c9E2a36A55c716339aBfF404b68F4D97`
- Explorer: https://explorer-test.qday.info (chain 44005, Aevum testnet)
- tUSD8: `0x456569838f1d43009A91ebA4263147Afd7233483` (6 decimals)
- Deployed **2026-11-24**; deployer funded via the Discord faucet
  (1 tQDAY + 5 tUSD8). Amounts are test tokens with no real value.

## Status

- [x] Contract written, tested (12 unit tests pass, 2 fork tests pass,
      live-fork end to end proven)
- [x] Web app built, builds clean, serves; wired to the deployed
      Stream address
- [x] **Deployed to the Aevum testnet 2026-11-24** (address above)
- [x] MIT LICENSE, NOTICE crediting the starter kit
- [x] Public GitHub repo — https://github.com/skymiller1509-blip/per-second-stream (renamed 26 Nov 2026)
- [x] Live demo site — https://skymiller1509-blip.github.io/per-second-stream/ (render-verified 27 Nov 2026)
- [ ] Demo video — script in `VIDEO-SCRIPT.md`, Eddie films on his phone
      (live testnet flow: create → accrue → withdraw → cancel)
- [ ] DoraHacks BUIDL page filled and submitted before **11 Dec 2026 09:00 WAT**
      — **Eddie's step** (form + BUIDL page; draft ready in `BUIDL-DRAFT.md`, only the YouTube link is missing)

## Submission needs (from the challenge rules)

- Public GitHub repo
- Aevum integration evidence
- A live deployment (working demo)
- Documentation (this README)
- A demo (top 5 do a 3–5 minute live video-call walkthrough)
- Contract addresses on 44005 with explorer links, a link to the exact
  commit deployed, and a few transaction hashes. Explorer contract
  verification is not working yet — share addresses and the commit instead.

## Eddie's steps, in order

1. Create the public GitHub repo and push this folder.
2. Film the demo video from `VIDEO-SCRIPT.md` and upload it.
3. Fill in the DoraHacks BUIDL page (problem, working flow, contract
   address + explorer link, honest limits) and submit before
   **11 Dec 2026 09:00 WAT**. Submit at least 30 minutes early.

## Mabel's steps

- [x] Contract, app, deploy, video script, checklist
- [ ] After the repo exists: verify the repo link and the exact deployed commit
- [ ] Collect a few transaction hashes from the explorer for the BUIDL page
- [ ] After submission: open every link (repo, demo, video, explorer) and confirm they work

## Honest limits (say these in the submission, do not hide them)

- The web app was never click-tested in a real browser here; the contract
  calls it makes are the same ones proven on the fork and now live on testnet.
- The demo shows the stream ticking live; it does not do gasless payments
  (no public tQDAY paymaster exists yet) and it does not use ERC-8004 (the
  registry is still in internal testing and is not open for this challenge).
- Amounts are tUSD8 test tokens with no real value.

## Payout / KYC

- $1,500 USDT as listed above. No payout route or KYC step verified yet —
  check the DoraHacks page before submitting and record it here.
