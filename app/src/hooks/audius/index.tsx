import React from 'react';

import type { AudiusResponse, Track } from '~/types/audius';

const useAudius = () => {
	const url = 'https://audius-discovery-1.cultur3stake.com/v1';

	const getTrendingTracks = async () => {
		const res = await fetch(`${url}/tracks/trending`);
		const data = (await res.json()) as AudiusResponse<Track[]>;
		console.log(data);
		return data.data;
	};

	const getStreamLink = async (trackId: string) => {
		try {
			const res = await fetch(`${url}/tracks/${trackId}/stream`);
			res.headers.forEach((v, k) => {
				console.log(`${k}: ${v}`);
			});
			console.log(await res.json());
			const data = (await res.json()) as AudiusResponse<string>;
			console.log(data);
			return data.data;
		} catch (error) {
			console.log(error);
		}
	};
	return { getTrendingTracks, getStreamLink };
};

export default useAudius;
