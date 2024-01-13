'use client';

import { WagmiConfig, createConfig } from 'wagmi';
import { ConnectKitProvider, getDefaultConfig } from 'connectkit';
import { sepolia } from 'wagmi/chains';

import { env } from '~/env';

const config = createConfig(
	getDefaultConfig({
		alchemyId: env.NEXT_PUBLIC_ALCHEMY_KEY,
		walletConnectProjectId: env.NEXT_PUBLIC_WALLETCONNECT_ID,
		chains: [sepolia],
		appName: 'GHOTUNES',
		appDescription: 'Your App Description',
		appUrl: 'https://family.co',
		appIcon: 'https://family.co/logo.png',
	})
);

interface Props {
	children: React.ReactNode;
}

const Web3Provider = ({ children }: Props) => {
	return (
		<WagmiConfig config={config}>
			<ConnectKitProvider>{children}</ConnectKitProvider>
		</WagmiConfig>
	);
};

export default Web3Provider;
