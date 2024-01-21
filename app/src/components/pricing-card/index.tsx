/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
'use client';

import React from 'react';
import Image from 'next/image';
import { useRouter } from 'next/navigation';

import { parseEther } from 'viem';
import { readContract } from '@wagmi/core';
import { useContractWrite, useAccount } from 'wagmi';
import { AaveV3Sepolia } from '@bgd-labs/aave-address-book';

import { getCreditDelegationSignature } from '~/helpers/signature';

import { Meteors } from '../meteor';

import { FaCheck } from 'react-icons/fa6';

import type { Tier } from '~/types';

import { ABI, GHOTUNES_ADDRESS } from '~/data';
import { GHOLogo } from '~/assets';
import SubscribeModal from '../subscribe-modal';

const PricingCard = ({
	name,
	description,
	price,
	features,
	index,
}: Tier & { index: number }) => {
	const { address } = useAccount();

	const { write: subscribeWithETH } = useContractWrite({
		address: GHOTUNES_ADDRESS,
		abi: ABI,
		functionName: 'subscribeWithETH',
	});

	const router = useRouter();
	const onClick = async () => {
		if (!address) return;
		if (price === 0) {
			void router.push('/browse');
		}
		const ethPrice = await readContract({
			address: GHOTUNES_ADDRESS,
			abi: ABI,
			functionName: 'calculateETHRequired',
			args: [BigInt(index)],
		});

		const deadline = Math.floor(Date.now() / 1000) + 24 * 60 * 60 * 60;

		const sig1 = await getCreditDelegationSignature({
			owner: address,
			asset: AaveV3Sepolia.ASSETS.WETH.V_TOKEN,
			spender: AaveV3Sepolia.WETH_GATEWAY,
			amount: BigInt(ethPrice),
			deadline: BigInt(deadline),
		});

		const sig2 = await getCreditDelegationSignature({
			owner: address,
			asset: AaveV3Sepolia.ASSETS.GHO.V_TOKEN,
			spender: GHOTUNES_ADDRESS,
			amount: parseEther(price.toString()),
			deadline: BigInt(deadline),
		});

		subscribeWithETH({
			value: ethPrice,
			args: [address, 1, BigInt(1), sig1, sig2],
		});
	};

	return (
		<div className='w-full rounded-2xl bg-[#0a0a0a]'>
			<div className='relative flex h-full w-full flex-col items-start justify-center overflow-hidden rounded-2xl border border-gray-800 px-4 py-8 shadow-xl'>
				<div className='flex flex-col gap-4'>
					<h1 className='text-4xl font-semibold'>{name}</h1>
					<h2>{description}</h2>
				</div>
				<div className='mt-8 flex flex-row items-end justify-end gap-2'>
					<div className='flex flex-row items-center gap-3 text-5xl font-semibold'>
						{price}
						<Image
							src={GHOLogo}
							alt='GHO'
							width={56}
							height={56}
							className='rounded-full'
						/>
					</div>
					<div className='text-lg font-medium'>/per month</div>
				</div>
				<div className='mt-8 flex flex-col gap-1'>
					{features.map((feature, index) => (
						<div key={index} className='flex flex-row items-center gap-2'>
							<FaCheck className='text-xl text-[#C9B3FE]' />
							<div className='text-lg'>{feature}</div>
						</div>
					))}
				</div>
				<Meteors />
				<SubscribeModal
					name={name}
					description={description}
					price={price}
					features={features}
					index={index}
				/>
			</div>
		</div>
	);
};

export default PricingCard;
