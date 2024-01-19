import React from 'react';
import Image from 'next/image';
import { Navbar } from '~/components';

import { Pricing } from '~/sections';

const Home = () => {
	return (
		<main className='h-screen'>
			<Navbar />
			<Pricing />
		</main>
	);
};

export default Home;
