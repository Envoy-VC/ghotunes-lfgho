'use client';

import React from 'react';

import { ConnectKitButton } from 'connectkit';
import { useAudius } from '~/hooks';

const Navbar = () => {
	const { getTrendingTracks, getStreamLink } = useAudius();
	return (
		<div className='flex h-[7dvh] items-center justify-between border-2 px-8'>
			<div className='font-mario text-4xl tracking-wider text-primary'>
				GHO Tunes
			</div>
			<ConnectKitButton />
			<button
				onClick={() => {
					void getStreamLink('MgrM3b9');
					console.log('audius');
				}}
			>
				click
			</button>
			<audio controls>
				<source src='https://audius-discovery-1.cultur3stake.com/v1/tracks/MgrM3b9/stream' />
			</audio>
		</div>
	);
};

export default Navbar;
