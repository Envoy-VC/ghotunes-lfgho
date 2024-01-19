import React from 'react';

import TrackCard from '~/components/track-card';

const TopCharts = () => {
	return (
		<div className='w-full'>
			<div className='flex w-full flex-col gap-2'>
				<div className='mt-6 flex w-full flex-col gap-2'>
					<div className='text-2xl font-bold text-[#1D2C39]'>Top Charts</div>
				</div>
				<div className='w-full border-[1px] border-gray-300'></div>
			</div>
			<div className='my-4 flex w-full flex-col gap-2'>
				{Array(20)
					.fill(true)
					.map((_, i) => {
						return <TrackCard key={i} />;
					})}
			</div>
		</div>
	);
};

export default TopCharts;
