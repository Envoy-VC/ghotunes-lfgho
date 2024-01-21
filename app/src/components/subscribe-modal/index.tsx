'use client';

import React from 'react';
import { Dialog, DialogContent, DialogTrigger } from '~/components/ui/dialog';
import { Button } from '~/components/ui/button';

import { useContractWrite, useAccount } from 'wagmi';
import { parseEther } from 'viem';
import { readContract } from '@wagmi/core';
import { AaveV3Sepolia } from '@bgd-labs/aave-address-book';

import { getCreditDelegationSignature } from '~/helpers/signature';

import { tierImages, GHOLogo } from '~/assets';
import { ABI, GHOTUNES_ADDRESS } from '~/data';

import type { Tier } from '~/types';
import Image from 'next/image';

import { FaCircleCheck } from 'react-icons/fa6';
import Link from 'next/link';

interface Props extends Tier {
	index: number;
}

interface Signature {
	deadline: bigint;
	v: number;
	r: `0x${string}`;
	s: `0x${string}`;
}

const SubscribeModal = ({ index, name, price }: Props) => {
	const { address } = useAccount();
	const { writeAsync: subscribeWithETH } = useContractWrite({
		address: GHOTUNES_ADDRESS,
		abi: ABI,
		functionName: 'subscribeWithETH',
	});

	const [wETHSig, setWETHSig] = React.useState<Signature | null>(null);
	const [gHOSig, setGHOSig] = React.useState<Signature | null>(null);
	const [hash, setHash] = React.useState<string>('');

	const onWETH = async () => {
		if (wETHSig) return;
		try {
			if (!address) {
				throw new Error('No address');
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
			setWETHSig(sig1);
		} catch (error) {
			console.log(error);
		}
	};
	const onGHO = async () => {
		if (gHOSig) return;
		try {
			if (!address) {
				throw new Error('No address');
			}
			const deadline = Math.floor(Date.now() / 1000) + 24 * 60 * 60 * 60;

			const sig2 = await getCreditDelegationSignature({
				owner: address,
				asset: AaveV3Sepolia.ASSETS.GHO.V_TOKEN,
				spender: GHOTUNES_ADDRESS,
				amount: parseEther(price.toString()),
				deadline: BigInt(deadline),
			});
			setGHOSig(sig2);
		} catch (error) {
			console.log(error);
		}
	};

	const onSubscribe = async () => {
		try {
			if (!address) {
				throw new Error('No address');
			}
			if (!wETHSig || !gHOSig) {
				throw new Error('No signatures');
			}
			const ethPrice = await readContract({
				address: GHOTUNES_ADDRESS,
				abi: ABI,
				functionName: 'calculateETHRequired',
				args: [BigInt(index)],
			});

			const res = await subscribeWithETH({
				value: ethPrice,
				args: [address, 1, BigInt(1), wETHSig, gHOSig],
			});

			setHash(res.hash);
		} catch (error) {
			console.log(error);
		}
	};

	return (
		<div className='dark w-full'>
			<Dialog>
				<DialogTrigger asChild>
					<Button className='mt-8 w-full'>
						{price === 0 ? 'Go to App' : 'Subscribe'}
					</Button>
				</DialogTrigger>
				<DialogContent className='dark max-w-lg'>
					<div className='flex flex-col items-center gap-4'>
						<Image
							src={tierImages[index]!}
							alt={name}
							width={500}
							height={500}
							className='rounded-xl'
						/>
						<div className='w-full'>
							<div className='flex flex-col gap-3'>
								<Button className='w-full' onClick={onWETH}>
									{wETHSig === null ? (
										'Credit Delegate WETH'
									) : (
										<FaCircleCheck className='text-2xl text-[#C9B3FE]' />
									)}
								</Button>
								<Button
									className='w-full'
									disabled={wETHSig === null}
									onClick={onGHO}
								>
									{gHOSig === null ? (
										'Credit Delegate GHO'
									) : (
										<FaCircleCheck className='text-2xl text-[#C9B3FE]' />
									)}
								</Button>
								<Button
									className='w-full'
									onClick={onSubscribe}
									disabled={wETHSig === null || gHOSig === null}
								>
									{hash === '' ? (
										<div className='flex flex-row items-center gap-2'>
											<div className='text-lg'>PAY {price}</div>
											<Image
												src={GHOLogo}
												alt='GHO'
												width={32}
												height={32}
												className='rounded-full'
											/>
										</div>
									) : (
										<FaCircleCheck className='text-2xl text-[#C9B3FE]' />
									)}
								</Button>
								<div className='text-center text-[#C9B3FE]'>
									{hash && (
										<Link
											href={`https://sepolia.etherscan.io/tx/${hash}`}
											target='_blank'
											rel='noreferrer'
										>
											View on Etherscan
										</Link>
									)}
								</div>
							</div>
						</div>
					</div>
				</DialogContent>
			</Dialog>
		</div>
	);
};

export default SubscribeModal;
