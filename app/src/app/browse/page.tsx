import React from 'react';
import { MusicControls, Navbar } from '~/components';

import { TrendingPlaylists } from '~/sections';

const Home = () => {
	return (
		<div className='relative h-screen bg-[#e8eaec]'>
			<Navbar />
			<div className='mx-auto w-full max-w-screen-2xl px-4'>
				<TrendingPlaylists />
			</div>
			<MusicControls />
		</div>
	);
};

export default Home;
