import Web3Provider from '~/providers/web3';

export default function Template({ children }: { children: React.ReactNode }) {
	return <Web3Provider>{children}</Web3Provider>;
}
