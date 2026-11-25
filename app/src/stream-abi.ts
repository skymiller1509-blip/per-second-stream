// Minimal ABI for PerSecondStream (contracts/src/Stream.sol).
export const STREAM_ABI = [
  {
    type: "function",
    name: "createStream",
    stateMutability: "nonpayable",
    inputs: [
      { name: "freelancer", type: "address" },
      { name: "ratePerSecond", type: "uint256" },
      { name: "durationSeconds", type: "uint256" },
    ],
    outputs: [{ name: "streamId", type: "uint256" }],
  },
  {
    type: "function",
    name: "accrued",
    stateMutability: "view",
    inputs: [{ name: "streamId", type: "uint256" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "totalPayout",
    stateMutability: "view",
    inputs: [{ name: "streamId", type: "uint256" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "withdraw",
    stateMutability: "nonpayable",
    inputs: [{ name: "streamId", type: "uint256" }],
    outputs: [{ name: "amount", type: "uint256" }],
  },
  {
    type: "function",
    name: "cancel",
    stateMutability: "nonpayable",
    inputs: [{ name: "streamId", type: "uint256" }],
    outputs: [],
  },
  {
    type: "function",
    name: "nextStreamId",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "streams",
    stateMutability: "view",
    inputs: [{ name: "", type: "uint256" }],
    outputs: [
      { name: "employer", type: "address" },
      { name: "freelancer", type: "address" },
      { name: "ratePerSecond", type: "uint256" },
      { name: "startTime", type: "uint256" },
      { name: "duration", type: "uint256" },
      { name: "deposited", type: "uint256" },
      { name: "withdrawn", type: "uint256" },
      { name: "cancelled", type: "boolean" },
    ],
  },
  {
    type: "function",
    name: "token",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "address" }],
  },
] as const;

export const ERC20_ABI = [
  {
    type: "function",
    name: "balanceOf",
    stateMutability: "view",
    inputs: [{ name: "account", type: "address" }],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "allowance",
    stateMutability: "view",
    inputs: [
      { name: "owner", type: "address" },
      { name: "spender", type: "address" },
    ],
    outputs: [{ name: "", type: "uint256" }],
  },
  {
    type: "function",
    name: "approve",
    stateMutability: "nonpayable",
    inputs: [
      { name: "spender", type: "address" },
      { name: "amount", type: "uint256" },
    ],
    outputs: [{ name: "", type: "bool" }],
  },
  {
    type: "function",
    name: "decimals",
    stateMutability: "view",
    inputs: [],
    outputs: [{ name: "", type: "uint8" }],
  },
] as const;
