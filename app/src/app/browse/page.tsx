import React from 'react';
import { MusicControls, Navbar } from '~/components';

const Home = () => {
	return (
		<div className='relative h-screen bg-[#e8eaec]'>
			<Navbar />
			<MusicControls />
		</div>
	);
};

export default Home;
