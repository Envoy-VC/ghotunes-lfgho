'use client';

import React from 'react';

import { ConnectKitButton } from 'connectkit';
import Link from 'next/link';

const Navbar = () => {
	return (
		<div className='z-[100] flex h-[10dvh] items-center justify-between px-8'>
			<div className='font-boldFont z-[100]  text-4xl tracking-wider text-gray-100'>
				GHO Tunes
			</div>
			<div className='flex items-center gap-5'>
				<Link
					href='#pricing'
					className='z-[100] rounded-xl bg-slate-50 px-4 py-[6px] font-bold uppercase text-[#61615F]'
				>
					Pricing
				</Link>
				<ConnectKitButton />
			</div>
		</div>
	);
};

export default Navbar;
