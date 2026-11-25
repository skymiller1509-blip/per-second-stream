# Per-Second Freelancer Stream — demo video script

**Length:** 3 minutes (submission demo; top 5 also do a 3–5 minute live
video-call walkthrough — this script works for both).
**Format:** phone screen recording, landscape, captions on. Read aloud in
plain words, at a steady pace. Narrate what is happening, not the labels
on screen.

> **LIVE TESTNET.** This video shows the real contract on the Aevum
> testnet (chain 44005), deployed 2026-11-24 at
> `0xbc6dD8c5c9E2a36A55c716339aBfF404b68F4D97`
> (explorer: https://explorer-test.qday.info). Amounts are tUSD8 test
> tokens with no real value. Nothing in this video is simulated.

## The one sentence a judge should repeat

"A freelancer's pay ticks up every second — and she can withdraw what
she has earned at any time."

## Hook options (pick ONE, say it aloud, keep the clearest)

1. "Watch this number. It goes up every single second — that is a freelancer getting paid, live."
2. "Freelancers wait weeks to get paid. This one gets paid every second."
3. "I start a stream, and the money starts moving — one second at a time."

## Shot-by-shot script

### 0:00–0:05 — HOOK (sound off must still work)

- **On screen (large text, bottom third):** "PAID EVERY SECOND. LIVE ON TESTNET."
- **Show:** the app already open, the balance ticking up once a second.
  No logo, no greeting.
- **Say:** "Watch this number. It goes up every second. That is a
  freelancer getting paid, live on the Aevum testnet."

### 0:05–0:20 — PROBLEM, one sentence, one named user

- **On screen:** the ticking balance, then the stream details.
- **Say:** "Ada is a freelancer. She finishes the work, sends the
  invoice, and waits weeks — then chases it. A stream pays her
  continuously instead: the money is locked up front, it accrues every
  second, and she pulls out what she has earned whenever she wants."
- **Say:** "If the job ends early, the employer cancels and gets back
  whatever has not accrued yet."

### 0:20–2:00 — THE ONE LIVE FLOW (real testnet transactions)

1. **Create the stream.** "I am the employer. I start a stream: the
   freelancer's address, the pay per second in tUSD8, the duration.
   The full amount locks in the contract — that is the guarantee."
2. **Watch it accrue.** "Now watch. Every second, the earned amount
   ticks up. This is the real contract on testnet, not a recording."
3. **Withdraw.** "The freelancer presses Withdraw and gets what has
   accrued so far. The stream keeps ticking after that."
4. **Cancel with refund.** "And if the job ends early: Cancel. The
   freelancer keeps what she earned, and the employer gets the rest
   back. Nothing is stuck."
5. **Show the explorer.** "Every step is on the explorer — the contract
   is at 0xbc6d…D97 on chain 44005, and the transactions are there to check."

> If a transaction stalls on filming day, do NOT keep pressing the
> button on camera. Cut to the explorer record you already captured,
> and say so plainly.

### 2:00–2:30 — HOW IT WORKS (30 seconds)

- **Say:** "Underneath, it is one Solidity contract, PerSecondStream.
  Create locks rate times duration in tUSD8. Accrued is earned minus
  withdrawn, capped at the deposit. Withdraw pays the freelancer,
  cancel pays the accrued amount and refunds the rest. Twelve unit
  tests pass, plus fork tests against the real tUSD8, and the same
  flow was proven end to end on a local fork before it went live."
- **Say:** "The hard part was making it work with the real token
  unchanged — only standard transfer calls, so it works with tUSD8
  exactly as it is."

### 2:30–3:00 — WHAT'S NEXT

- **Say:** "Next, recurring streams — a freelancer paid every second,
  every week, without a new contract each time. Built for the Aevum
  Builder Challenge, Track: Payroll and Vesting, on the Aevum testnet."
- **On screen (end card):** contract address + explorer link + repo link.

## Recording notes (phone)

- Android screen recorder: swipe down twice, tap Screen record,
  microphone ON, wait for the countdown.
- **Do Not Disturb ON first** — no notification mid-take.
- Landscape, browser zoom 100–125%, full screen, bookmarks bar hidden,
  extra tabs closed. Keep the explorer open in a second tab so the
  contract page is one tap away.
- Use a short stream for the demo (small rate, short duration) so
  create, accrue, withdraw and cancel all fit in one take. Fund the
  demo wallet with test tUSD8 from the Discord faucet before filming.
- Record one long take (~90 seconds of the live flow), then trim in
  CapCut: a judge cut at 60–75 seconds and a social cut at 25–35 seconds
  from the same footage.
- Add captions — the video may be watched without sound.
- Never show a real private key or seed phrase on screen. Testnet only,
  test tokens only.

## Before filming — checklist

- [ ] App opens on the phone and connects to Aevum testnet (chain 44005)
- [ ] Demo wallet holds test tUSD8 (Discord faucet: 1 tQDAY + 5 tUSD8)
- [ ] Contract address in the app matches the deployed contract
- [ ] One full practice run: create → accrue → withdraw → cancel, all on testnet
- [ ] Explorer link opens to the contract page
- [ ] 60-second insurance capture of the flow working, saved separately
