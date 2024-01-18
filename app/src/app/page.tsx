import React from 'react';
import Image from 'next/image';
import { Navbar, ImagesSlider } from '~/components';

import { backgroundImages } from '~/assets';
import { Pricing } from '~/sections';

const Home = () => {
	return (
		<main className='bg-[#6A6A6A]'>
			<div className='relative h-screen'>
				<ImagesSlider
					images={backgroundImages}
					autoplay
					// eslint-disable-next-line react/no-children-prop
					children={<>d</>}
				/>
				{/* <Image
					src={BackgroundImage}
					alt='Background Image'
					className='absolute top-0 h-screen w-full object-cover'
				/> */}
				<Navbar />
			</div>
			<Pricing />
		</main>
	);
};

export default Home;
