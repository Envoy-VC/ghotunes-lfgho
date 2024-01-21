import React from 'react';
import { Dialog, DialogContent, DialogTrigger } from '~/components/ui/dialog';

import { tierImages } from '~/assets';

import type { Tier } from '~/types';
import Image from 'next/image';

interface Props extends Tier {
	index: number;
}

const SubscribeModal = ({ index, name, price }: Props) => {
	return (
		<div className='w-full'>
			<Dialog>
				<DialogTrigger asChild>
					<button
						className='mt-8 w-full rounded-xl bg-zinc-200 px-8 py-3 font-semibold text-black/80 transition-all duration-300 ease-in-out hover:bg-zinc-300'
						type='button'
					>
						{price === 0 ? 'Go to App' : 'Subscribe'}
					</button>
				</DialogTrigger>
				<DialogContent className='max-w-lg text-gray-50'>
					<div className='flex flex-col items-center gap-4'>
						<Image
							src={tierImages[index]!}
							alt={name}
							width={500}
							height={500}
							className='rounded-xl'
						/>
						<div className='w-full border-2'>
							<div className='flex flex-col gap-3'>
								<button
									className='mt-8 w-full rounded-xl bg-zinc-200 px-4 py-2 font-semibold text-black/80 transition-all duration-300 ease-in-out hover:bg-zinc-300'
									type='button'
								>
									Credit Delegate WETH
								</button>
								<button
									className='w-full rounded-xl bg-zinc-200 px-4 py-2 font-semibold text-black/80 transition-all duration-300 ease-in-out hover:bg-zinc-300'
									type='button'
								>
									Credit Delegate GHO
								</button>
								<button
									className='w-full rounded-xl bg-zinc-200 px-4 py-2 font-semibold text-black/80 transition-all duration-300 ease-in-out hover:bg-zinc-300'
									type='button'
								>
									Subscribe
								</button>
							</div>
						</div>
					</div>
				</DialogContent>
			</Dialog>
		</div>
	);
};

export default SubscribeModal;
