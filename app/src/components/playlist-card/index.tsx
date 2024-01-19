/* eslint-disable @next/next/no-img-element */

import React from 'react';
import { FaPlayCircle } from 'react-icons/fa';

import ControlButton from '../music-controls/control-button';

import type { Playlist } from '~/types/audius';

const PlaylistCard = ({ artwork, playlistName, description }: Playlist) => {
	console.log({
		artwork,
		playlistName,
		description,
	});
	return (
		<div className='flex flex-col gap-4'>
			<div className='relative aspect-square min-w-[300px] rounded-xl'>
				<img
					src={
						artwork?.['480x480'] ??
						artwork?.['150x150'] ??
						artwork?.['1000x1000']
					}
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
				<div className='text-lg font-bold text-[#1D2C39]'>{playlistName}</div>
				<div className='text-xs font-semibold text-[#536171]'>
					{description ?? ''}
				</div>
			</div>
		</div>
	);
};

export default PlaylistCard;
