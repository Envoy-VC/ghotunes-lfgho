import React from 'react';

import {
	FaCirclePlay,
	FaForward,
	FaBackward,
	FaShuffle,
	FaRepeat,
} from 'react-icons/fa6';

import ControlButton from '../control-button';

const TrackControls = () => {
	return (
		<div className='w-1/3'>
			<div className='flex flex-row items-center justify-between'>
				<ControlButton Icon={FaRepeat} />
				<ControlButton Icon={FaBackward} />
				<ControlButton Icon={FaCirclePlay} extraCls='!text-5xl text-red-500' />
				<ControlButton Icon={FaForward} />
				<ControlButton Icon={FaShuffle} />
			</div>
		</div>
	);
};

export default TrackControls;
