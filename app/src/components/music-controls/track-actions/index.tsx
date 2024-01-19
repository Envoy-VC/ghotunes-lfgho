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
	const { track, pause } = useTrack();
	const [value, setValue] = React.useState(75);

	const onChange = (e: React.ChangeEvent<HTMLInputElement>) => {
		setValue(parseInt(e.target.value));
	};

	const onPause = () => {
		pause();
	};
	
	return (
		<div className='mx-16 w-1/3'>
			<div className='flex flex-row items-center justify-end gap-8'>
				<div className='relative flex flex-row items-center justify-between gap-4'>
					{value > 60 ? (
						<ControlButton Icon={FaVolumeHigh} className='!text-3xl' />
					) : value > 0 && value <= 60 ? (
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
							value={value}
							onChange={onChange}
							className='slider-thumb'
						/>
						<div
							className='slider-value'
							style={{
								width:
									value === 0
										? `calc(${value}% + 0px)`
										: value < 30
											? `calc(${value}% + 4px)`
											: `calc(${value}% - 1px)`,
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
