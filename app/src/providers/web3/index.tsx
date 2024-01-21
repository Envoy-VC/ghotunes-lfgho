/* eslint-disable @typescript-eslint/no-explicit-any */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-member-access */
/* eslint-disable @typescript-eslint/no-unsafe-call */
/* eslint-disable @typescript-eslint/no-unsafe-argument */
'use client';

import { WagmiConfig, createConfig } from 'wagmi';
import { supportedSocialConnectors } from '@zerodev/wagmi/connectkit';
import {
	supportedConnectors,
	getDefaultConfig,
	ConnectKitProvider,
	getDefaultConnectors,
} from 'connectkit';
supportedConnectors.push(...supportedSocialConnectors);

import theme from '~/assets/theme.json';

import { sepolia } from 'wagmi/chains';

import {
	GithubSocialWalletConnector,
	TwitterSocialWalletConnector,
} from '@zerodev/wagmi';

import { env } from '~/env';

const chains = [sepolia];

const defaultConnectors = [
	...getDefaultConnectors({
		chains,
		app: { name: 'GHO Tunes' },
		walletConnectProjectId: env.NEXT_PUBLIC_WALLETCONNECT_ID,
	}),
];

const socialConnectors = defaultConnectors.slice(0, 1);
const otherConnectors = defaultConnectors.slice(2);

const options = {
	chains: [sepolia],
	options: { projectId: env.NEXT_PUBLIC_WALLETCONNECT_ID },
};

const config = createConfig(
	getDefaultConfig({
		alchemyId: env.NEXT_PUBLIC_ALCHEMY_KEY,
		walletConnectProjectId: env.NEXT_PUBLIC_WALLETCONNECT_ID,
		appName: 'GHO Tunes',
		chains,
		connectors: [
			...socialConnectors,
			new GithubSocialWalletConnector(options),
			new TwitterSocialWalletConnector(options),
			...otherConnectors,
		],
	})
);

interface Props {
	children: React.ReactNode;
}
const Web3Provider = ({ children }: Props) => {
	return (
		<WagmiConfig config={config}>
			<ConnectKitProvider
				customTheme={{ ...theme }}
				options={{
					embedGoogleFonts: true,
				}}
			>
				{children}
			</ConnectKitProvider>
		</WagmiConfig>
	);
};

export default Web3Provider;
