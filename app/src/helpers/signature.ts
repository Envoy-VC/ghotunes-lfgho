/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import { signTypedData, readContracts } from '@wagmi/core';
import { hexToSignature } from 'viem';

import { DEBT_TOKEN_ABI } from '~/data';

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
	const contract = {
		address: asset as `0x${string}`,
		abi: DEBT_TOKEN_ABI,
	};

	const data = await readContracts({
		contracts: [
			{
				...contract,
				functionName: 'nonces',
				args: [owner as `0x${string}`],
			},
			{
				...contract,
				functionName: 'EIP712_REVISION',
			},
			{
				...contract,
				functionName: 'name',
			},
		],
	});

	const [nonce, revision, tokenName] = [
		data[0].result,
		data[1].result,
		data[2].result,
	];
	console.log({
		nonce,
		revision,
		tokenName,
	});
	if (nonce === undefined) throw new Error('Failed to get nonce');
	if (revision === undefined) throw new Error('Failed to get revision');
	if (tokenName === undefined) throw new Error('Failed to get token name');

	const revisionHex = revision.slice(2);
	const version = String(parseInt(revisionHex, 16));

	console.log(version);

	const domain = {
		name: tokenName,
		version: '1',
		chainId: 11155111,
		verifyingContract: asset as `0x${string}`,
	} as const;

	const sig = await signTypedData({
		types,
		domain: domain as any,
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
