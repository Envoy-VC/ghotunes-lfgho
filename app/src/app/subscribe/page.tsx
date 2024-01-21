import React from 'react';
import { Navbar } from '~/components';

import { Subscribe } from '~/sections';

const SubscribePage = () => {
	return (
		<div className='min-h-screen bg-black/95 text-white'>
			<Navbar />
			<Subscribe />
		</div>
	);
};

export default SubscribePage;
