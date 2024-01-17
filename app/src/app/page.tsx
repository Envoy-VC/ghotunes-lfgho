'use client';

import React from 'react';
import { ConnectKitButton } from 'connectkit';

const Home = () => {
	return (
		<div className=''>
			<ConnectKitButton />
			<div className='text-primary font-mario text-6xl tracking-wider'>
				GHO Tunes
			</div>
		</div>
	);
};

export default Home;
