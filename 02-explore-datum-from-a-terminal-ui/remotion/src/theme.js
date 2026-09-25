export const FPS = 30;
export const WIDTH = 1920;
export const HEIGHT = 1080;

export const MIDNIGHT = '#0c1d31';
export const MOSS = '#e6f59e';
export const PAPER = '#faf3ea';

export const BUMPER_FRAMES = 60; // 2s, open/out
export const TITLE_BUMPER_FRAMES = 90; // 3s, carries the episode title card

// Frame counts lifted from ffprobe against the transcoded takes, after
// silence-trimming. A plain silencedetect(d=3) run missed dead air that was
// fragmented by tiny click/breath blips (each under 3s alone, but adding up
// to a real multi-second hole once bridged), so the cut list comes from a
// fine-grained pass (noise=-35dB, d=0.15) with adjacent silences merged
// across gaps under 0.35s, then filtered to spans over 3s. TK01 additionally
// has the false start cut: David paused after "...into Datum Cloud", added
// "and the tooling(s)", paused again, then restarted the line -- cut back to
// the first clean "into Datum Cloud" and jumped straight to the next line,
// dropping the stumble and the redundant restart both.
export const TK01_FRAMES = 1293; // 43.099s -- cold open, webcam only
export const TK03_FRAMES = 2130; // 71.000s -- console walkthrough part 1
export const TK04_FRAMES = 1507; // 50.222s -- console walkthrough part 2 + close

export const OUTRO_AUDIO_FRAMES = 1152; // 38.386s
export const OUTRO_TAIL_FADE_FRAMES = 30;

export const OPEN_BUMPER_START = 0;
export const TK01_START = OPEN_BUMPER_START + BUMPER_FRAMES;
export const TITLE_BUMPER_START = TK01_START + TK01_FRAMES;
export const TK03_START = TITLE_BUMPER_START + TITLE_BUMPER_FRAMES;
export const TK04_START = TK03_START + TK03_FRAMES;
export const OUT_BUMPER_START = TK04_START + TK04_FRAMES;
export const OUTRO_START = OUT_BUMPER_START + BUMPER_FRAMES;

// The outro music is a quiet bed under the closing lines, then a swell.
// It fades in (1s) to a low, audible bed level ~2s before "So go check it
// out...", HOLDS FLAT at that level through the whole closing line -- it
// does not rise while he's talking -- then, a beat after "time." ends,
// ramps up to the 40% cap, landing well into the outro card.
export const MUSIC_START_LOCAL_TK04 = 1268; // 42.267s -- bed fades in from here
export const MUSIC_BED_FADE_FRAMES = 30; // 1s fade-in to the bed level
export const MUSIC_BED_UNTIL_LOCAL_TK04 = 1525; // 50.833s -- hold the bed until ~1s after "time."
export const MUSIC_RAMP_FRAMES = 222; // ~7.4s swell, landing 6s into the outro card
export const MUSIC_BED_VOLUME = 0.05; // quiet but present under speech
export const MUSIC_SWELL_VOLUME = 0.4;
export const MUSIC_START = TK04_START + MUSIC_START_LOCAL_TK04;
export const MUSIC_BED_UNTIL_FRAME = MUSIC_BED_UNTIL_LOCAL_TK04 - MUSIC_START_LOCAL_TK04;

// The song plays once, in full, from MUSIC_START -- the video's length is
// however long that take + the outro card's music actually is.
export const TOTAL_FRAMES = MUSIC_START + OUTRO_AUDIO_FRAMES;

// Outro.jsx fades its card to black in the song's last OUTRO_TAIL_FADE_FRAMES,
// expressed relative to the outro card's own Sequence start (OUTRO_START),
// even though the song itself started earlier, back in TK04.
export const OUTRO_FADE_START = TOTAL_FRAMES - OUTRO_TAIL_FADE_FRAMES - OUTRO_START;
