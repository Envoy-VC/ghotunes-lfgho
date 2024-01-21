import React from 'react';
import {
	Dialog,
	DialogContent,
	DialogDescription,
	DialogFooter,
	DialogHeader,
	DialogTitle,
	DialogTrigger,
} from '~/components/ui/dialog';

import type { Tier } from '~/types';

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
				<DialogContent className='sm:max-w-[425px]'>
					<DialogHeader>
						<DialogTitle>Edit profile</DialogTitle>
						<DialogDescription>
							Make changes to your profile here. Click save when done.
						</DialogDescription>
					</DialogHeader>
					<div>content</div>
					<DialogFooter>footer</DialogFooter>
				</DialogContent>
			</Dialog>
		</div>
	);
};

export default SubscribeModal;
