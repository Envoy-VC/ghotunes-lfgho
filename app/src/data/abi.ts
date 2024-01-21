export const ABI = [
	{
		type: 'constructor',
		inputs: [
			{ name: '_owner', type: 'address', internalType: 'address' },
			{
				name: '_accountRegistry',
				type: 'address',
				internalType: 'address',
			},
			{ name: '_implementation', type: 'address', internalType: 'address' },
			{
				name: '_tiers',
				type: 'tuple[]',
				internalType: 'struct TIER[]',
				components: [
					{ name: 'name', type: 'string', internalType: 'string' },
					{ name: 'image', type: 'string', internalType: 'string' },
					{ name: 'price', type: 'uint256', internalType: 'uint256' },
				],
			},
			{ name: '_token', type: 'address', internalType: 'address' },
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'GHO_PRICE_USD',
		inputs: [],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'accountRegistry',
		inputs: [],
		outputs: [
			{
				name: '',
				type: 'address',
				internalType: 'contract IERC6551Registry',
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'accounts',
		inputs: [{ name: '', type: 'address', internalType: 'address' }],
		outputs: [
			{ name: 'currentTier', type: 'uint8', internalType: 'uint8' },
			{ name: 'nextTier', type: 'uint8', internalType: 'uint8' },
			{ name: 'accountAddress', type: 'address', internalType: 'address' },
			{ name: 'validUntil', type: 'uint256', internalType: 'uint256' },
			{
				name: 'upkeepDetails',
				type: 'tuple',
				internalType: 'struct UpkeepDetails',
				components: [
					{
						name: 'upkeepAddress',
						type: 'address',
						internalType: 'address',
					},
					{
						name: 'forwarderAddress',
						type: 'address',
						internalType: 'address',
					},
					{ name: 'upkeepId', type: 'uint256', internalType: 'uint256' },
				],
			},
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'calculateETHRequired',
		inputs: [{ name: '_tier', type: 'uint256', internalType: 'uint256' }],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'changeTier',
		inputs: [
			{ name: 'tokenId', type: 'uint256', internalType: 'uint256' },
			{ name: 'nextTier', type: 'uint8', internalType: 'uint8' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'createCronUpkeep',
		inputs: [{ name: '_for', type: 'address', internalType: 'address' }],
		outputs: [
			{
				name: '',
				type: 'tuple',
				internalType: 'struct UpkeepDetails',
				components: [
					{
						name: 'upkeepAddress',
						type: 'address',
						internalType: 'address',
					},
					{
						name: 'forwarderAddress',
						type: 'address',
						internalType: 'address',
					},
					{ name: 'upkeepId', type: 'uint256', internalType: 'uint256' },
				],
			},
		],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'delegateGHO',
		inputs: [
			{ name: 'user', type: 'address', internalType: 'address' },
			{
				name: 'permit',
				type: 'tuple',
				internalType: 'struct Signature',
				components: [
					{ name: 'deadline', type: 'uint256', internalType: 'uint256' },
					{ name: 'v', type: 'uint8', internalType: 'uint8' },
					{ name: 'r', type: 'bytes32', internalType: 'bytes32' },
					{ name: 's', type: 'bytes32', internalType: 'bytes32' },
				],
			},
			{ name: 'tier', type: 'uint8', internalType: 'uint8' },
			{
				name: 'durationInMonths',
				type: 'uint256',
				internalType: 'uint256',
			},
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'handleRenewFail',
		inputs: [{ name: 'tokenId', type: 'uint256', internalType: 'uint256' }],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'implementation',
		inputs: [],
		outputs: [{ name: '', type: 'address', internalType: 'address' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'owner',
		inputs: [],
		outputs: [{ name: '', type: 'address', internalType: 'address' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'renew',
		inputs: [{ name: 'tokenId', type: 'uint256', internalType: 'uint256' }],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'subscribe',
		inputs: [
			{ name: 'user', type: 'address', internalType: 'address' },
			{ name: 'tier', type: 'uint8', internalType: 'uint8' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'subscribeWithETH',
		inputs: [
			{ name: 'user', type: 'address', internalType: 'address' },
			{ name: 'tier', type: 'uint8', internalType: 'uint8' },
			{
				name: 'durationInMonths',
				type: 'uint256',
				internalType: 'uint256',
			},
			{
				name: 'wETHPermit',
				type: 'tuple',
				internalType: 'struct Signature',
				components: [
					{ name: 'deadline', type: 'uint256', internalType: 'uint256' },
					{ name: 'v', type: 'uint8', internalType: 'uint8' },
					{ name: 'r', type: 'bytes32', internalType: 'bytes32' },
					{ name: 's', type: 'bytes32', internalType: 'bytes32' },
				],
			},
			{
				name: 'ghoPermit',
				type: 'tuple',
				internalType: 'struct Signature',
				components: [
					{ name: 'deadline', type: 'uint256', internalType: 'uint256' },
					{ name: 'v', type: 'uint8', internalType: 'uint8' },
					{ name: 'r', type: 'bytes32', internalType: 'bytes32' },
					{ name: 's', type: 'bytes32', internalType: 'bytes32' },
				],
			},
		],
		outputs: [],
		stateMutability: 'payable',
	},
	{
		type: 'function',
		name: 'subscribeWithGHO',
		inputs: [
			{ name: 'user', type: 'address', internalType: 'address' },
			{ name: 'tier', type: 'uint8', internalType: 'uint8' },
		],
		outputs: [],
		stateMutability: 'nonpayable',
	},
	{
		type: 'function',
		name: 'tiers',
		inputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		outputs: [
			{ name: 'name', type: 'string', internalType: 'string' },
			{ name: 'image', type: 'string', internalType: 'string' },
			{ name: 'price', type: 'uint256', internalType: 'uint256' },
		],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'token',
		inputs: [],
		outputs: [{ name: '', type: 'address', internalType: 'contract IToken' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'totalTiers',
		inputs: [],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'withdrawLink',
		inputs: [],
		outputs: [],
		stateMutability: 'nonpayable',
	},
] as const;

export const EIP712_ABI = [
	{
		type: 'function',
		name: 'DOMAIN_SEPARATOR',
		inputs: [],
		outputs: [{ name: '', type: 'bytes32', internalType: 'bytes32' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'EIP712_REVISION',
		inputs: [],
		outputs: [{ name: '', type: 'bytes', internalType: 'bytes' }],
		stateMutability: 'view',
	},
	{
		type: 'function',
		name: 'nonces',
		inputs: [{ name: 'owner', type: 'address', internalType: 'address' }],
		outputs: [{ name: '', type: 'uint256', internalType: 'uint256' }],
		stateMutability: 'view',
	},
] as const;
