'use client';

import React from 'react';
import { ConnectKitButton } from 'connectkit';

const Home = () => {
	return (
		<div className='h-screen bg-[#fafae3]'>
			<ConnectKitButton />
			<div className='font-mario logo text-6xl tracking-wider text-[#f76263]'>
				GHO Tunes
			</div>
		</div>
	);
};

export default Home;
