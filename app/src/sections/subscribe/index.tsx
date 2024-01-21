import React from 'react';

import PricingCard from '~/components/pricing-card';
import { tiers } from '~/data';

const Subscribe = () => {
	return (
		<div id='pricing' className='h-full w-full px-3 mt-24'>
			<div className='flex h-full w-full flex-col items-center justify-center gap-8'>
				<div className='flex max-w-lg flex-col gap-4 text-center'>
					<h1 className='text-5xl font-medium md:text-7xl'>Pricing plans</h1>
					<h2>
						Lorem ipsum dolor sit amet consectetur. Pulvinar eu rhoncus
						tincidunt eget mattis netus ridiculus.
					</h2>
				</div>
				<div className='flex w-full max-w-screen-xl flex-col items-center gap-6 lg:flex-row'>
					{tiers.map((tier, index) => (
						<PricingCard key={index} {...tier} index={index} />
					))}
				</div>
			</div>
		</div>
	);
};

export default Subscribe;
