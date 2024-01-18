import { createEnv } from '@t3-oss/env-nextjs';
import { z } from 'zod';

export const env = createEnv({
	server: {
		NODE_ENV: z.enum(['development', 'test', 'production']),
	},
	client: {
		NEXT_PUBLIC_WALLETCONNECT_ID: z.string().min(1),
		NEXT_PUBLIC_ALCHEMY_KEY: z.string().min(1),
		// NEXT_PUBLIC_AUDIUS_KEY: z.string().min(1),
		// NEXT_PUBLIC_AUDIUS_SECRET: z.string().min(1),
	},
	runtimeEnv: {
		NODE_ENV: process.env.NODE_ENV,
		NEXT_PUBLIC_WALLETCONNECT_ID: process.env.NEXT_PUBLIC_WALLETCONNECT_ID,
		NEXT_PUBLIC_ALCHEMY_KEY: process.env.NEXT_PUBLIC_ALCHEMY_KEY,
		// NEXT_PUBLIC_AUDIUS_KEY: process.env.NEXT_PUBLIC_AUDIUS_KEY,
		// NEXT_PUBLIC_AUDIUS_SECRET: process.env.NEXT_PUBLIC_AUDIUS_SECRET,
	},
	skipValidation: !!process.env.SKIP_ENV_VALIDATION,
	emptyStringAsUndefined: true,
});
