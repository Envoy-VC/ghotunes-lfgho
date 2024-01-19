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
}

export const useTrack = create<State & Actions>((set, get) => ({
	track: null,
	details: null,
	setTrack: (track) => {
		set({ track });
	},
	setDetails: (details) => {
		set({ details });
	},
	play: () => {
		void get().track?.play();
	},
	pause: () => {
		get().track?.pause();
	},
}));
