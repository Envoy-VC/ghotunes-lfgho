'use client';

import React from 'react';

import ArtistDetails from './artist-details';
import TrackControls from './track-controls';
import TrackActions from './track-actions';

import { useTrack } from '~/stores/track';

const MusicControls = () => {
	const { track } = useTrack();

	const [currentTime, setCurrentTime] = React.useState(0);
	const [duration, setDuration] = React.useState(0);

	React.useEffect(() => {
		if (track) {
			// Update the duration when the metadata is loaded
			const handleLoadedMetadata = () => {
				setDuration(track.duration);
			};

			// Update the current time during playback
			const handleTimeUpdate = () => {
				setCurrentTime(track.currentTime);
				console.log(currentTime);
			};

			track.addEventListener('loadedmetadata', handleLoadedMetadata);
			track.addEventListener('timeupdate', handleTimeUpdate);

			return () => {
				track.removeEventListener('loadedmetadata', handleLoadedMetadata);
				track.removeEventListener('timeupdate', handleTimeUpdate);
			};
		}
	}, [track]);

	return (
		<div className='fixed bottom-0 flex h-[10dvh] w-full flex-col border-2 bg-[#F8FAFC]'>
			<div className='h-2 w-full'>
				<div
					className='h-full bg-red-500'
					style={{
						width: track ? `${(currentTime / duration) * 100}%` : `0%`,
					}}
				></div>
			</div>

			<div className='flex h-full w-full flex-col items-center justify-center '>
				<div className='flex w-full flex-row items-center justify-between px-4'>
					<ArtistDetails />
					<TrackControls />
					<TrackActions />
				</div>
			</div>
		</div>
	);
};

export default MusicControls;
