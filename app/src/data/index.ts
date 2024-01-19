import type { Tier } from '~/types';

export const tiers: Tier[] = [
	{
		name: 'Free',
		description: 'Basic Music Streaming',
		price: 0,
		features: [
			'Unlimited Music',
			'Ads',
			'No Offline Mode',
			'No High Quality Audio',
		],
	},
	{
		name: 'Silver',
		description: 'Premium Music Streaming',
		price: 5,
		features: [
			'Unlimited Music',
			'No Ads',
			'No Offline Mode',
			'High Quality Audio',
		],
	},
	{
		name: 'Gold',
		description: 'Premium Music Streaming with Offline Mode',
		price: 10,
		features: [
			'Unlimited Music',
			'No Ads',
			'Offline Mode',
			'High Quality Audio',
		],
	},
];
