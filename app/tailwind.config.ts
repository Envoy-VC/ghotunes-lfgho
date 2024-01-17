import { type Config } from 'tailwindcss';
import { fontFamily } from 'tailwindcss/defaultTheme';

export default {
	content: ['./src/**/*.tsx'],
	theme: {
		extend: {
			fontFamily: {
				sans: ['var(--font-sans)', ...fontFamily.sans],
				mario: ['Super Mario', 'sans-serif'],
			},
		},
	},
	plugins: [],
} satisfies Config;
