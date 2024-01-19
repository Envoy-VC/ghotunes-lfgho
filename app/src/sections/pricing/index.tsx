import React from 'react';

import PricingCard from '~/components/pricing-card';
import { tiers } from '~/data';

const Pricing = () => {
	return (
		<div id='pricing' className='absolute top-0 h-full w-full'>
			<div className='flex h-full w-full flex-col items-center justify-center gap-8'>
				<div className='flex max-w-lg flex-col gap-4 text-center'>
					<h1 className='text-7xl font-medium'>Pricing plans</h1>
					<h2>
						Lorem ipsum dolor sit amet consectetur. Pulvinar eu rhoncus
						tincidunt eget mattis netus ridiculus.
					</h2>
				</div>
				<div className='flex w-full max-w-screen-xl flex-row items-center gap-6'>
					{tiers.map((tier, index) => (
						<PricingCard key={index} {...tier} />
					))}
				</div>
			</div>
		</div>
	);
};

export default Pricing;
