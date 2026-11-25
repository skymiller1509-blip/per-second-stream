import {
  createPublicClient,
  createWalletClient,
  custom,
  formatUnits,
  http,
  parseUnits,
  type Address,
  type Chain,
} from "viem";
import { ERC20_ABI, STREAM_ABI } from "./stream-abi";
import "./style.css";

// ---- Aevum testnet, verified against the official starter kit docs ----
// Chain 44005, RPC https://rpc-test.qday.info (HTTPS only, no WebSocket),
// explorer https://explorer-test.qday.info, gas token tQDAY (18 decimals).
export const AEVUM: Chain = {
  id: 44005,
  name: "Aevum Testnet",
  nativeCurrency: { name: "tQDAY", symbol: "tQDAY", decimals: 18 },
  rpcUrls: { default: { http: ["https://rpc-test.qday.info"] } },
  blockExplorers: {
    default: { name: "Aevum Explorer", url: "https://explorer-test.qday.info" },
  },
};

export const TUSD8 = "0x456569838f1d43009A91ebA4263147Afd7233483" as Address;
const TUSD8_DECIMALS = 6;

const $ = (id: string) => document.getElementById(id) as HTMLElement;
const input = (id: string) => document.getElementById(id) as HTMLInputElement;

const publicClient = createPublicClient({ chain: AEVUM, transport: http() });

let account: Address | null = null;
let streamAddress: Address | null = null;

function loadStreamAddress() {
  const saved =
    localStorage.getItem("streamAddress") ||
    import.meta.env.VITE_STREAM_ADDRESS ||
    "0xbc6dD8c5c9E2a36A55c716339aBfF404b68F4D97";
  if (/^0x[0-9a-fA-F]{40}$/.test(saved)) {
    streamAddress = saved as Address;
    input("contract-address").value = saved;
    $("contract-status").textContent = "Saved.";
  } else {
    $("contract-status").textContent =
      "No contract set yet — paste the deployed Stream address.";
  }
}

function fmtTusd8(amount: bigint): string {
  return formatUnits(amount, TUSD8_DECIMALS);
}

function short(addr: string): string {
  return addr.slice(0, 6) + "…" + addr.slice(-4);
}

async function refreshBalances() {
  if (!account) return;
  const [tusd8, gas] = await Promise.all([
    publicClient.readContract({
      address: TUSD8,
      abi: ERC20_ABI,
      functionName: "balanceOf",
      args: [account],
    }),
    publicClient.getBalance({ address: account }),
  ]);
  $("balances").textContent =
    `tUSD8: ${fmtTusd8(tusd8)} · tQDAY (gas): ${formatUnits(gas, 18)}`;
}

type StreamRow = {
  id: bigint;
  employer: Address;
  freelancer: Address;
  ratePerSecond: bigint;
  startTime: bigint;
  duration: bigint;
  deposited: bigint;
  withdrawn: bigint;
  cancelled: boolean;
};

async function loadStreams(): Promise<StreamRow[]> {
  if (!streamAddress || !account) return [];
  const next = await publicClient.readContract({
    address: streamAddress,
    abi: STREAM_ABI,
    functionName: "nextStreamId",
  });
  const rows: StreamRow[] = [];
  for (let i = 0n; i < next; i++) {
    const s = (await publicClient.readContract({
      address: streamAddress,
      abi: STREAM_ABI,
      functionName: "streams",
      args: [i],
    })) as readonly [Address, Address, bigint, bigint, bigint, bigint, bigint, boolean];
    const [employer, freelancer, ratePerSecond, startTime, duration, deposited, withdrawn, cancelled] = s;
    if (employer === account || freelancer === account) {
      rows.push({ id: i, employer, freelancer, ratePerSecond, startTime, duration, deposited, withdrawn, cancelled });
    }
  }
  return rows;
}

async function renderStreams() {
  const box = $("streams");
  if (!streamAddress) {
    box.innerHTML = "<p class='muted'>Set the Stream contract address first.</p>";
    return;
  }
  if (!account) {
    box.innerHTML = "<p class='muted'>Connect your wallet to see your streams.</p>";
    return;
  }
  const rows = await loadStreams();
  if (rows.length === 0) {
    box.innerHTML = "<p class='muted'>No streams yet. Start one above.</p>";
    return;
  }
  box.innerHTML = "";
  for (const r of rows) {
    const accrued = await publicClient.readContract({
      address: streamAddress,
      abi: STREAM_ABI,
      functionName: "accrued",
      args: [r.id],
    });
    const now = BigInt(Math.floor(Date.now() / 1000));
    const elapsed = now > r.startTime ? now - r.startTime : 0n;
    const capped = elapsed > r.duration ? r.duration : elapsed;
    const progress = Number((capped * 100n) / r.duration);
    const isFreelancer = r.freelancer === account;
    const isEmployer = r.employer === account;

    const card = document.createElement("div");
    card.className = "card";
    card.innerHTML = `
      <div><strong>Stream #${r.id}</strong> ${r.cancelled ? "· cancelled" : ""}</div>
      <div>Freelancer: ${short(r.freelancer)} ${isFreelancer ? "(you)" : ""}</div>
      <div>Employer: ${short(r.employer)} ${isEmployer ? "(you)" : ""}</div>
      <div>Rate: ${fmtTusd8(r.ratePerSecond)} tUSD8 / second</div>
      <div>Deposited: ${fmtTusd8(r.deposited)} tUSD8 · Withdrawn: ${fmtTusd8(r.withdrawn)} tUSD8</div>
      <div>Elapsed: ${capped.toString()}s of ${r.duration.toString()}s (${progress}%)</div>
      <div class="bar"><div class="fill" style="width:${progress}%"></div></div>
      <div class="accrued">Accrued now: <strong>${fmtTusd8(accrued)} tUSD8</strong></div>
    `;
    if (isFreelancer && !r.cancelled && accrued > 0n) {
      const b = document.createElement("button");
      b.textContent = `Withdraw ${fmtTusd8(accrued)} tUSD8`;
      b.onclick = () => doWithdraw(r.id);
      card.appendChild(b);
    }
    if (isEmployer && !r.cancelled) {
      const b = document.createElement("button");
      b.textContent = "Cancel stream (refund unaccrued)";
      b.onclick = () => doCancel(r.id);
      card.appendChild(b);
    }
    box.appendChild(card);
  }
}

function walletClient() {
  const eth = (window as unknown as { ethereum?: unknown }).ethereum;
  if (!eth) throw new Error("No wallet found. Install MetaMask first.");
  return createWalletClient({ chain: AEVUM, transport: custom(eth as never) });
}

async function doWithdraw(id: bigint) {
  if (!streamAddress || !account) return;
  const client = walletClient();
  const hash = await client.writeContract({
    address: streamAddress,
    abi: STREAM_ABI,
    functionName: "withdraw",
    args: [id],
    account,
    chain: AEVUM,
    type: "legacy", // Aevum uses legacy (type 0) transactions
  });
  await publicClient.waitForTransactionReceipt({ hash });
  await renderStreams();
  await refreshBalances();
}

async function doCancel(id: bigint) {
  if (!streamAddress || !account) return;
  const client = walletClient();
  const hash = await client.writeContract({
    address: streamAddress,
    abi: STREAM_ABI,
    functionName: "cancel",
    args: [id],
    account,
    chain: AEVUM,
    type: "legacy",
  });
  await publicClient.waitForTransactionReceipt({ hash });
  await renderStreams();
  await refreshBalances();
}

function updateDepositPreview() {
  const rate = input("rate").value;
  const hours = input("duration-hours").value;
  if (!rate || !hours) {
    $("deposit-preview").textContent = "";
    return;
  }
  try {
    const deposit = parseUnits(rate, TUSD8_DECIMALS) * BigInt(Math.round(Number(hours) * 3600));
    $("deposit-preview").textContent = `Total locked in the stream: ${fmtTusd8(deposit)} tUSD8.`;
  } catch {
    $("deposit-preview").textContent = "";
  }
}

$("save-contract").onclick = () => {
  const v = input("contract-address").value.trim();
  if (!/^0x[0-9a-fA-F]{40}$/.test(v)) {
    $("contract-status").textContent = "That is not a valid address.";
    return;
  }
  localStorage.setItem("streamAddress", v);
  streamAddress = v as Address;
  $("contract-status").textContent = "Saved.";
  renderStreams();
};

$("add-network").onclick = async () => {
  const eth = (window as unknown as { ethereum?: { request: (a: unknown) => Promise<unknown> } }).ethereum;
  if (!eth) {
    $("wallet-info").textContent = "No wallet found. Install MetaMask first.";
    return;
  }
  await eth.request({
    method: "wallet_addEthereumChain",
    params: [
      {
        chainId: "0xabe5",
        chainName: "Aevum Testnet",
        nativeCurrency: { name: "tQDAY", symbol: "tQDAY", decimals: 18 },
        rpcUrls: ["https://rpc-test.qday.info"],
        blockExplorerUrls: ["https://explorer-test.qday.info"],
      },
    ],
  });
  $("wallet-info").textContent = "Aevum testnet added. Now connect your wallet.";
};

$("connect").onclick = async () => {
  try {
    const client = walletClient();
    const [addr] = await client.requestAddresses();
    account = addr;
    $("wallet-info").textContent = `Connected: ${short(addr)}`;
    await refreshBalances();
    await renderStreams();
  } catch (e) {
    $("wallet-info").textContent = `Could not connect: ${(e as Error).message}`;
  }
};

$("approve").onclick = async () => {
  if (!streamAddress || !account) {
    $("create-status").textContent = "Set the contract address and connect your wallet first.";
    return;
  }
  const rate = parseUnits(input("rate").value, TUSD8_DECIMALS);
  const duration = BigInt(Math.round(Number(input("duration-hours").value) * 3600));
  const deposit = rate * duration;
  $("create-status").textContent = "Sending approval…";
  const client = walletClient();
  const hash = await client.writeContract({
    address: TUSD8,
    abi: ERC20_ABI,
    functionName: "approve",
    args: [streamAddress, deposit],
    account,
    chain: AEVUM,
    type: "legacy",
  });
  await publicClient.waitForTransactionReceipt({ hash });
  $("create-status").textContent = `Approved ${fmtTusd8(deposit)} tUSD8. Now press "Start stream".`;
};

$("create").onclick = async () => {
  if (!streamAddress || !account) {
    $("create-status").textContent = "Set the contract address and connect your wallet first.";
    return;
  }
  const freelancer = input("freelancer").value.trim() as Address;
  if (!/^0x[0-9a-fA-F]{40}$/.test(freelancer)) {
    $("create-status").textContent = "Freelancer address is not valid.";
    return;
  }
  const rate = parseUnits(input("rate").value, TUSD8_DECIMALS);
  const duration = BigInt(Math.round(Number(input("duration-hours").value) * 3600));
  $("create-status").textContent = "Starting stream…";
  try {
    const client = walletClient();
    const hash = await client.writeContract({
      address: streamAddress,
      abi: STREAM_ABI,
      functionName: "createStream",
      args: [freelancer, rate, duration],
      account,
      chain: AEVUM,
      type: "legacy",
    });
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    $("create-status").textContent = `Stream started. Tx: ${receipt.transactionHash}`;
    await renderStreams();
    await refreshBalances();
  } catch (e) {
    $("create-status").textContent = `Failed: ${(e as Error).message}`;
  }
};

$("refresh").onclick = () => renderStreams();
input("rate").oninput = updateDepositPreview;
input("duration-hours").oninput = updateDepositPreview;

loadStreamAddress();
// Balances tick live: re-read the chain every second.
setInterval(() => {
  if (account && streamAddress) {
    renderStreams().catch(() => undefined);
    refreshBalances().catch(() => undefined);
  }
}, 1000);
