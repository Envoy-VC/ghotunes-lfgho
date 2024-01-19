'use client';

import React from 'react';
import { useAudius } from '~/hooks';
import TrackCard from '~/components/track-card';

import type { Track } from '~/types/audius';

const TopCharts = () => {
	const { getTrendingTracks } = useAudius();

	const [trendingTracks, setTrendingTracks] = React.useState<Track[]>([]);

	React.useEffect(() => {
		getTrendingTracks()
			.then((res) => {
				setTrendingTracks(res);
			})
			.catch((err) => {
				console.log(err);
			});
	}, []);
	return (
		<div className='w-full'>
			<div className='flex w-full flex-col gap-2'>
				<div className='mt-6 flex w-full flex-col gap-2'>
					<div className='text-2xl font-bold text-[#1D2C39]'>Top Charts</div>
				</div>
				<div className='w-full border-[1px] border-gray-300'></div>
			</div>
			<div className='my-4 flex w-full flex-col gap-2'>
				{trendingTracks.map((track, i) => {
					return <TrackCard key={i} {...track} />;
				})}
			</div>
		</div>
	);
};

export default TopCharts;
