import React from 'react';
import Image from 'next/image';
import { Navbar } from '~/components';

import { Subscribe } from '~/sections';

const SubscribePage = () => {
	return (
		<div className='h-screen bg-black/95 text-white'>
			<Navbar />
			<Subscribe />
		</div>
	);
};

export default SubscribePage;
