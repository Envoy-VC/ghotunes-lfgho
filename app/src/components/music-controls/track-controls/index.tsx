'use client';

import React from 'react';
import { useTrack } from '~/stores/track';

import {
	FaCirclePlay,
	FaForward,
	FaBackward,
	FaShuffle,
	FaRepeat,
} from 'react-icons/fa6';

import ControlButton from '../control-button';

const TrackControls = () => {
	const { track, pause } = useTrack();

	const onPause = () => {
		pause();
	};
	return (
		<div className='w-1/3'>
			<div className='flex flex-row items-center justify-between'>
				<ControlButton Icon={FaRepeat} />
				<ControlButton Icon={FaBackward} />
				<ControlButton
					Icon={track?.paused ? FaCirclePlay : FaCirclePlay}
					onClick={onPause}
					extraCls='!text-5xl text-red-500'
				/>
				<ControlButton Icon={FaForward} />
				<ControlButton Icon={FaShuffle} />
			</div>
		</div>
	);
};

export default TrackControls;
