import React from 'react';
import Image from 'next/image';

import { MusicPlaceholder } from '~/assets';

const ArtistDetails = () => {
	return (
		<div className='flex w-1/3 flex-row items-center gap-8'>
			<div className='flex flex-row items-start gap-3'>
				<div className='h-16 w-16'>
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
					<div className='text-sm font-semibold text-gray-400'>
						Camila Cabello - Havana ft. Young Thug
					</div>
				</div>
			</div>
			{/* <div className='text-xs font-medium text-gray-500'>00:43/03:29</div> */}
		</div>
	);
};

export default ArtistDetails;
