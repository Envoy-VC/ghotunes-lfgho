import React from 'react';
import { MusicControls, Navbar } from '~/components';

import { TopCharts, TrendingPlaylists } from '~/sections';

const Browse = () => {
	return (
		<div className='relative mb-[10vh] h-screen overflow-scroll bg-[#e8eaec]'>
			<Navbar />
			<div className='mx-auto w-full max-w-screen-2xl px-4'>
				<TrendingPlaylists />
				<TopCharts />
			</div>
			<MusicControls />
		</div>
	);
};

export default Browse;
