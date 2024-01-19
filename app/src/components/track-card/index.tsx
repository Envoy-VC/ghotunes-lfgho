/* eslint-disable @next/next/no-img-element */
import React from 'react';

import { MusicPlaceholder } from '~/assets';
import ControlButton from '../music-controls/control-button';
import { formatTrackDuration } from '~/utils';
import { FaPlayCircle } from 'react-icons/fa';

import type { Track } from '~/types/audius';

import { useTrack } from '~/stores/track';

const TrackCard = (track: Track) => {
	const { id, title, artwork, user, duration } = track;
	const { setDetails, setTrack, play } = useTrack();

	const onPlay = () => {
		setDetails(track);
		setTrack(
			new Audio(
				`https://audius-discovery-1.cultur3stake.com/v1/tracks/${id}/stream`
			)
		);
		play();
	};

	return (
		<div className='w-full rounded-lg p-2 shadow-sm'>
			<div className='flex flex-row items-start justify-between gap-4'>
				<div className='flex items-center gap-4'>
					<div className='h-14 w-14'>
						<img
							alt='Title Cover'
							width={64}
							height={64}
							src={
								artwork?.['480x480'] ??
								artwork?.['150x150'] ??
								artwork?.['1000x1000'] ??
								MusicPlaceholder.src
							}
							className='h-full w-full rounded-md object-cover'
						/>
					</div>
					<div className='flex flex-col'>
						<div className='font-lg font-medium'>{title}</div>
						<div className='text-xs font-semibold text-gray-400'>
							{user.name}
						</div>
					</div>
				</div>
				<div className='flex items-center gap-4'>
					<div className='text-sm font-medium text-gray-600'>
						{formatTrackDuration(duration)}
					</div>
					<ControlButton
						Icon={FaPlayCircle}
						extraCls='!text-red-500 !text-4xl hover:scale-105 transition-all duration-300 ease-out'
						onClick={onPlay}
					/>
				</div>
			</div>
		</div>
	);
};

export default TrackCard;
