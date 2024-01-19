import React from 'react';
import axios from 'axios';

import type { AudiusResponse, Track, Playlist } from '~/types/audius';

const useAudius = () => {
	const audius = axios.create({
		baseURL: 'https://audius-discovery-1.cultur3stake.com/v1/',
		timeout: 10000,
	});

	const getTrendingTracks = async () => {
		const res = await audius.get('/tracks/trending?app_name=gho_tunes');
		const tracks = res.data as AudiusResponse<Track[]>;
		return tracks.data;
	};

	const getTrendingPlaylists = async () => {
		const res = await audius.get('/playlists/trending?app_name=gho_tunes');
		const data = res.data as AudiusResponse<Playlist[]>;
		return data.data;
	};
	return { getTrendingTracks, getTrendingPlaylists };
};

export default useAudius;
