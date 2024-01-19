import React from 'react';
import ArtistDetails from './artist-details';
import TrackControls from './track-controls';
import TrackActions from './track-actions';

const MusicControls = () => {
	return (
		<div className='absolute bottom-0 flex h-[10dvh] w-full items-center border-2 bg-[#F8FAFC] px-4'>
			<div className='flex w-full flex-row items-center justify-between'>
				<ArtistDetails />
				<TrackControls />
				<TrackActions />
			</div>
		</div>
	);
};

export default MusicControls;
