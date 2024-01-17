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
			colors: {
				background: '#fafae3',
				primary: '#f76263',
				secondary: '#f77d79',
			},
		},
	},
	plugins: [],
} satisfies Config;
