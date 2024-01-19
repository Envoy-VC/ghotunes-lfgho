import React from 'react';
import Image from 'next/image';
import { Navbar } from '~/components';

import { Pricing } from '~/sections';

const Home = () => {
	return (
		<div className='relative h-screen bg-black/95 text-white'>
			<Navbar />
			<Pricing />
		</div>
	);
};

export default Home;
