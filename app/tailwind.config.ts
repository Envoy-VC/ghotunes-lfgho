import { type Config } from 'tailwindcss';
import { fontFamily } from 'tailwindcss/defaultTheme';

export default {
	content: ['./src/**/*.tsx'],
	theme: {
		extend: {
			animation: {
				'meteor-effect': 'meteor 5s linear infinite',
			},
			keyframes: {
				meteor: {
					'0%': { transform: 'rotate(215deg) translateX(0)', opacity: '1' },
					'70%': { opacity: '1' },
					'100%': {
						transform: 'rotate(215deg) translateX(-500px)',
						opacity: '0',
					},
				},
			},
			fontFamily: {
				sans: ['var(--font-sans)', ...fontFamily.sans],
				boldFont: ['Bold Font', 'sans-serif'],
			},
			colors: {
				background: '#',
				primary: '#',
				secondary: '#f7d79',
			},
		},
	},
	plugins: [],
} satisfies Config;
