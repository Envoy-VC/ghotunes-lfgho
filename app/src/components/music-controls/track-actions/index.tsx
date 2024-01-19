'use client';

import React from 'react';

import ControlButton from '../control-button';

import {
	FaHeart,
	FaDownload,
	FaVolumeOff,
	FaVolumeLow,
	FaVolumeHigh,
} from 'react-icons/fa6';
import { TbPlaylistAdd } from 'react-icons/tb';

import { useTrack } from '~/stores/track';

const TrackActions = () => {
	const { track, changeVolume } = useTrack();
	const [volume, setVolume] = React.useState(100);

	// Event listeners for volume change
	React.useEffect(() => {
		if (track) {
			const handleVolumeChange = () => {
				setVolume(track.volume * 100);
			};

			track.addEventListener('volumechange', handleVolumeChange);

			return () => {
				track.removeEventListener('volumechange', handleVolumeChange);
			};
		}
	}, [track]);

	const onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		changeVolume(Number(e.target.value));
	};

	return (
		<div className='mx-16 w-1/3'>
			<div className='flex flex-row items-center justify-end gap-8'>
				<div className='relative flex flex-row items-center justify-between gap-4'>
					{volume > 60 ? (
						<ControlButton Icon={FaVolumeHigh} className='!text-3xl' />
					) : volume > 0 && volume <= 60 ? (
						<ControlButton Icon={FaVolumeLow} className='!text-xl' />
					) : (
						<ControlButton Icon={FaVolumeOff} className='!text-xl' />
					)}
					<div className='relative'>
						<div className='absolute h-3 w-full'></div>
						<input
							type='range'
							min='0'
							max='100'
							value={volume}
							onChange={onChange}
							className='slider-thumb'
						/>
						<div
							className='slider-value'
							style={{
								width:
									volume === 0
										? `calc(${volume}% + 0px)`
										: volume < 30
											? `calc(${volume}% + 4px)`
											: `calc(${volume}% - 1px)`,
							}}
						></div>
					</div>
				</div>
				<div className='flex flex-row items-center gap-8'>
					<ControlButton Icon={FaHeart} />
					<ControlButton Icon={TbPlaylistAdd} />
					<ControlButton Icon={FaDownload} />
				</div>
			</div>
		</div>
	);
};

export default TrackActions;
