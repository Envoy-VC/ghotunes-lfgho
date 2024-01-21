import { readContract, signTypedData } from '@wagmi/core';
import { hexToSignature } from 'viem';

import { EIP712_ABI } from '~/data';

interface Props {
	owner: string;
	spender: string;
	amount: bigint;
	asset: string;
	deadline: bigint;
}

export const getCreditDelegationSignature = async ({
	owner,
	spender,
	amount,
	asset,
	deadline,
}: Props) => {
	const nonce = await readContract({
		address: asset as `0x${string}`,
		abi: EIP712_ABI,
		functionName: 'nonces',
		args: [owner as `0x${string}`],
	});

	const name = 'Aave Ethereum Variable Debt WETH' as const;

	const domain = {
		name: name,
		version: '1',
		chainId: BigInt(11155111),
		verifyingContract: asset as `0x${string}`,
	} as const;

	const sig = await signTypedData({
		types,
		domain,
		primaryType: 'DelegationWithSig',
		message: {
			delegatee: spender as `0x${string}`,
			nonce,
			deadline,
			value: amount,
		},
	});

	const { v, r, s } = hexToSignature(sig);

	return {
		deadline,
		v: Number(v),
		r,
		s,
	};
};

const types = {
	EIP712Domain: [
		{
			name: 'name',
			type: 'string',
		},
		{
			name: 'version',
			type: 'string',
		},
		{
			name: 'chainId',
			type: 'uint256',
		},
		{
			name: 'verifyingContract',
			type: 'address',
		},
	],
	DelegationWithSig: [
		{
			name: 'delegatee',
			type: 'address',
		},
		{
			name: 'value',
			type: 'uint256',
		},
		{
			name: 'nonce',
			type: 'uint256',
		},
		{
			name: 'deadline',
			type: 'uint256',
		},
	],
} as const;
