import { create } from 'zustand';
import type { Track } from '~/types/audius';

interface State {
	track: HTMLAudioElement | null;
	details: Track | null;
}

interface Actions {
	setTrack: (track: HTMLAudioElement) => void;
	setDetails: (details: Track) => void;
	play: () => void;
	pause: () => void;
	changeVolume: (volume: number) => void;
}

export const useTrack = create<State & Actions>((set, get) => ({
	track: null,
	details: null,
	setTrack: (track) => {
		const currentTrack = get().track;
		if (currentTrack && !currentTrack?.paused) {
			void currentTrack.pause();
		}
		set({ track });
	},
	setDetails: (details) => {
		set({ details });
	},
	play: () => {
		const track = get().track;
		if (!track) return;
		if (track.paused) {
			void track.play();
		}
	},
	pause: () => {
		get().track?.pause();
	},
	changeVolume: (volume) => {
		const track = get().track;
		if (!track) return;
		track.volume = volume / 100;
	},
}));
