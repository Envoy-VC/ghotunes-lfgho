import type { Tier } from '~/types';
import { ABI, EIP712_ABI } from './abi';
export { ABI, EIP712_ABI };

export const GHOTUNES_ADDRESS = '0x766EcD241899AbA389a999D01527afd7B55F999D';
export const GHO_V_TOKEN = '0xd4FEA5bD40cE7d0f7b269678541fF0a95FCb4b68';
export const WETH_V_TOKEN = '0x54bdE009156053108E73E2401aEA755e38f92098';

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
