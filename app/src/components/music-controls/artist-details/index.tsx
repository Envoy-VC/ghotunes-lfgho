/* eslint-disable @next/next/no-img-element */
'use client';

import React from 'react';

import { MusicPlaceholder } from '~/assets';
import { useTrack } from '~/stores/track';

const ArtistDetails = () => {
	const { details } = useTrack();
	return (
		<div className='flex w-1/3 flex-row items-center gap-8'>
			<div className='flex flex-row items-start gap-3'>
				<div className='h-16 w-16'>
					<img
						alt='Title Cover'
						width={64}
						height={64}
						src={
							details?.artwork?.['480x480'] ??
							details?.artwork?.['150x150'] ??
							details?.artwork?.['1000x1000'] ??
							MusicPlaceholder.src
						}
						className='h-full w-full rounded-md object-cover'
					/>
				</div>
				<div className='flex flex-col'>
					<div className='font-lg font-medium'>
						{details?.title ?? 'Track Name'}
					</div>
					<div className='text-sm font-semibold text-gray-400'>
						{details?.user.name ?? 'User Name'}
					</div>
				</div>
			</div>
		</div>
	);
};

export default ArtistDetails;