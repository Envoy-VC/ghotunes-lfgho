/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import React from 'react';
import Image from 'next/image';

import { Meteors } from '../meteor';

import { FaCheck } from 'react-icons/fa6';

import type { Tier } from '~/types';

import { GHOLogo } from '~/assets';
import SubscribeModal from '../subscribe-modal';

const PricingCard = ({
	name,
	description,
	price,
	features,
	index,
}: Tier & { index: number }) => {
	return (
		<div className='h-full w-full rounded-2xl bg-[#0a0a0a]'>
			<div className='relative flex h-full w-full flex-col items-start justify-center overflow-hidden rounded-2xl border border-gray-800 px-4 py-8 shadow-xl'>
				<div className='flex flex-col'>
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
					<SubscribeModal
						name={name}
						description={description}
						price={price}
						features={features}
						index={index}
					/>
				</div>
				<Meteors />
			</div>
		</div>
	);
};

export default PricingCard;
