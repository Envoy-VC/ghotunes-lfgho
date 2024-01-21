import type { Tier } from '~/types';
import { ABI, EIP712_ABI, DEBT_TOKEN_ABI } from './abi';
export { ABI, EIP712_ABI, DEBT_TOKEN_ABI };

export const GHOTUNES_ADDRESS = '0x766EcD241899AbA389a999D01527afd7B55F999D';

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
			'Offline Mode',
			'No High Quality Audio',
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
