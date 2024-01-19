'use client';

import React from 'react';
import { useRouter } from 'next/navigation';
import { Meteors } from '../meteor';

import { FaCheck } from 'react-icons/fa6';

import type { Tier } from '~/types';

const PricingCard = ({ name, description, price, features }: Tier) => {
	const router = useRouter();
	const onClick = () => {
		if (price === 0) {
			void router.push('/browse');
		}
	};

	return (
		<div className='w-full'>
			<div className='relative flex h-full w-full flex-col items-start justify-center overflow-hidden rounded-2xl border border-gray-800 bg-black/75 px-4 py-8 shadow-xl'>
				<div className='flex flex-col gap-4'>
					<h1 className='text-4xl font-semibold'>{name}</h1>
					<h2>{description}</h2>
				</div>
				<div className='mt-8 flex flex-row items-end justify-end gap-2'>
					<div className='text-5xl font-semibold'>{price} GHO</div>
					<div className='text-lg font-medium'>/per month</div>
				</div>
				<div className='mt-8 flex flex-col gap-4'>
					{features.map((feature, index) => (
						<div key={index} className='flex flex-row items-center gap-2'>
							<FaCheck className='text-2xl text-green-500' />
							<div className='text-lg'>{feature}</div>
						</div>
					))}
				</div>
				<button
					className='mt-8 w-full rounded-xl bg-zinc-200 px-8 py-4 font-semibold text-black/80 transition-all duration-300 ease-in-out hover:bg-zinc-300'
					type='button'
					onClick={onClick}
				>
					{price === 0 ? 'Go to App' : 'Subscribe'}
				</button>
				<Meteors />
			</div>
		</div>
	);
};

export default PricingCard;
