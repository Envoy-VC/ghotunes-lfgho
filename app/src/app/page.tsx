import React from 'react';
import { Navbar, ImagesSlider } from '~/components';

import { backgroundImages } from '~/assets';

const Home = () => {
	return (
		<main>
			<div className='relative h-screen'>
				<ImagesSlider
					images={backgroundImages}
					autoplay
					// eslint-disable-next-line react/no-children-prop
					children={<></>}
				/>

				<Navbar />
			</div>
		</main>
	);
};

export default Home;
