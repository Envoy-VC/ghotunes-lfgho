'use client';

import React from 'react';
import { usePathname } from 'next/navigation';
import { ConnectKitButton } from 'connectkit';
import Link from 'next/link';
import clsx from 'clsx';

const Navbar = () => {
	const pathname = usePathname();
	return (
		<div className='z-[100] flex h-[10dvh] items-center justify-between px-8'>
			<Link
				className={clsx(
					'z-[100] font-boldFont  text-4xl tracking-wide',
					pathname === '/browse' ? 'text-gray-700' : 'text-gray-100'
				)}
				href='/'
			>
				GHO Tunes
			</Link>
			<div className='flex items-center gap-5'>
				<Link
					href='/pricing'
					className='z-[100] rounded-xl bg-slate-50 px-4 py-[6px] font-bold uppercase text-[#61615F]'
				>
					Pricing
				</Link>
				<div className='z-[100]'>
					<ConnectKitButton />
				</div>
			</div>
		</div>
	);
};

export default Navbar;
