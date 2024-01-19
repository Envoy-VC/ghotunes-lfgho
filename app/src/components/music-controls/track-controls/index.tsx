'use client';

import React from 'react';
import { useTrack } from '~/stores/track';

import {
	FaCirclePause,
	FaCirclePlay,
	FaForward,
	FaBackward,
	FaShuffle,
	FaRepeat,
} from 'react-icons/fa6';

import ControlButton from '../control-button';

const TrackControls = () => {
	const { track, pause, play } = useTrack();
	const [isPlaying, setIsPlaying] = React.useState<boolean>(false);

	React.useEffect(() => {
		if (track) {
			const handlePlay = () => {
				setIsPlaying(true);
			};
			const handlePause = () => {
				setIsPlaying(false);
			};
			track.addEventListener('play', handlePlay);
			track.addEventListener('pause', handlePause);
			return () => {
				track.removeEventListener('play', handlePlay);
				track.removeEventListener('pause', handlePause);
			};
		}
	}, [track]);

	const onClick = () => {
		if (track) {
			if (isPlaying) {
				pause();
			} else {
				play();
			}
		}
	};
	return (
		<div className='w-1/3'>
			<div className='flex flex-row items-center justify-between'>
				<ControlButton Icon={FaRepeat} />
				<ControlButton Icon={FaBackward} />
				<ControlButton
					Icon={isPlaying ? FaCirclePause : FaCirclePlay}
					onClick={onClick}
					extraCls='!text-5xl text-red-500'
				/>
				<ControlButton Icon={FaForward} />
				<ControlButton Icon={FaShuffle} />
			</div>
		</div>
	);
};

export default TrackControls;
