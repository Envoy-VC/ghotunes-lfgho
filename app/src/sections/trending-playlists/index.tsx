'use client';

import React from 'react';

import PlaylistCard from '~/components/playlist-card';

import { FaCaretLeft, FaCaretRight } from 'react-icons/fa6';

const TrendingPlaylists = () => {
	const ref = React.useRef<HTMLDivElement>(null);

	const onClick = (direction: 'right' | 'left') => {
		const el = ref.current;
		if (!el) return;

		const scrollAmount = 500;
		const scrollDirection = direction === 'right' ? 1 : -1;

		el.scrollBy({
			left: scrollAmount * scrollDirection,
			behavior: 'smooth',
		});
	};
	return (
		<div className='w-full py-4'>
			<div className='text-3xl font-bold text-[#1D2C39]'>Explore</div>
			<div className='flex w-full flex-row items-center justify-between '>
				<div className='mt-6 flex w-full flex-col gap-2'>
					<div className='text-2xl font-bold text-[#1D2C39]'>
						Trending Playlists
					</div>
					<div className='text-[#536171]'>
						Here are some of the trending playlists
					</div>
				</div>
				<div className='w-full border-[1px] border-gray-300' />
				<div className='flex flex-row items-center'>
					<FaCaretLeft
						className='cursor-pointer text-3xl text-[#1D2C39]'
						onClick={() => onClick('left')}
					/>
					<FaCaretRight
						className='cursor-pointer text-3xl text-[#1D2C39]'
						onClick={() => onClick('right')}
					/>
				</div>
			</div>
			<div
				className='hideScrollbar my-4 flex w-full flex-row gap-4 overflow-scroll'
				ref={ref}
			>
				{Array(20)
					.fill(true)
					.map((_, i) => {
						return <PlaylistCard key={i} />;
					})}
			</div>
		</div>
	);
};

export default TrendingPlaylists;
