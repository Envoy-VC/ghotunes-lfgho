import React from 'react';
import { FaPlayCircle } from 'react-icons/fa';

import ControlButton from '../music-controls/control-button';

const PlaylistCard = () => {
	return (
		<div className='flex flex-col gap-4'>
			<div className='relative aspect-square min-w-[300px] rounded-xl'>
				<img
					src='https://music351204796.files.wordpress.com/2020/12/niki.jpg?w=1024'
					alt='cover'
					className='h-full w-full rounded-xl object-cover'
				/>
				<div className='absolute bottom-0 right-0 m-4'>
					<ControlButton
						Icon={FaPlayCircle}
						extraCls='!text-red-500 !text-4xl hover:scale-105 transition-all duration-300 ease-out'
					/>
				</div>
			</div>
			<div className='flex flex-col'>
				<div className='text-lg font-bold text-[#1D2C39]'>Playlist Name</div>
				<div className='text-[#536171] text-xs font-semibold'>Playlist Description</div>
			</div>
		</div>
	);
};

export default PlaylistCard;
