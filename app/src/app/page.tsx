import React from 'react';
import Image from 'next/image';
import { Navbar } from '~/components';

import { BackgroundImage } from '~/assets';

const Home = () => {
	return (
		<div className=''>
			<div className='relative h-screen'>
				<Image
					src={BackgroundImage}
					alt='Background Image'
					className='absolute top-0 h-screen w-full object-cover'
				/>
				<Navbar />
			</div>
		</div>
	);
};

export default Home;
