import React from 'react';
import Image from 'next/image';

import { MusicPlaceholder } from '~/assets';
import ControlButton from '../music-controls/control-button';

import { FaPlayCircle } from 'react-icons/fa';

const TrackCard = () => {
	return (
		<div className='w-full rounded-lg p-2 shadow-sm'>
			<div className='flex flex-row items-start justify-between gap-4'>
				<div className='flex items-center gap-4'>
					<div className='h-14 w-14'>
						<Image
							alt='Title Cover'
							width={64}
							height={64}
							src={MusicPlaceholder.src}
							className='h-full w-full rounded-md object-cover'
						/>
					</div>
					<div className='flex flex-col'>
						<div className='font-lg font-medium'>Havana</div>
						<div className='text-xs font-semibold text-gray-400'>
							Camila Cabello - Havana ft. Young Thug
						</div>
					</div>
				</div>
                <div className='flex items-center gap-4'>
                    <div className='text-gray-600 text-sm font-medium'>4:26</div>
					<ControlButton
						Icon={FaPlayCircle}
						extraCls='!text-red-500 !text-4xl hover:scale-105 transition-all duration-300 ease-out'
					/>
				</div>
			</div>
		</div>
	);
};

export default TrackCard;
