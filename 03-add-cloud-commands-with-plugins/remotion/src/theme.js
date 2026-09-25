export const FPS = 30;
export const WIDTH = 1920;
export const HEIGHT = 1080;

export const MIDNIGHT = '#0c1d31';
export const MOSS = '#e6f59e';
export const PAPER = '#faf3ea';

export const BUMPER_FRAMES = 60; // 2s

// Frame counts from ffprobe against the transcoded takes, after the same
// bridged silence-trim as episodes 01/02 (fine pass noise=-35dB/d=0.15,
// merge gaps under 0.35s, then cut anything over 3s down to 0.35-0.9s).
// TK01 covers the cold open through the terminal beats (search, install,
// zone create); TK02+TK03 are a real detour into the Datum console (browser)
// to verify domain ownership via Cloudflare; TK05 is back in the terminal
// for records, describe, and the close.
// TK02 additionally has the failed first go at the verify-domain button
// cut out ("I just push the button, / log into my account, / [hum]"),
// jumping from "...offers automatic setup." to "You can just click this
// button...".
export const TK01_FRAMES = 4615; // 153.840s
export const TK02_FRAMES = 1351; // 45.040s
export const TK03_FRAMES = 274; // 9.120s
export const TK05_FRAMES = 3454; // 115.133s

export const OUTRO_AUDIO_FRAMES = 1152; // 38.386s
export const OUTRO_TAIL_FADE_FRAMES = 30;

export const OPEN_BUMPER_START = 0;
export const TK01_START = OPEN_BUMPER_START + BUMPER_FRAMES;
export const BUMPER1_START = TK01_START + TK01_FRAMES; // terminal -> browser
export const TK02_START = BUMPER1_START + BUMPER_FRAMES;
export const TK03_START = TK02_START + TK02_FRAMES;
export const BUMPER2_START = TK03_START + TK03_FRAMES; // browser -> terminal
export const TK05_START = BUMPER2_START + BUMPER_FRAMES;
export const OUT_BUMPER_START = TK05_START + TK05_FRAMES;
export const OUTRO_START = OUT_BUMPER_START + BUMPER_FRAMES;

// TK01 is one continuous take spanning the cold open and the beats after
// it, so the episode-title card can't sit on its own take boundary the way
// it did in episode 02. Instead a ChapterTag badge carries the title,
// timed to fade in right where SCRIPT.md calls for the title card (just
// after "Let's do it properly. Find it, install it, use it.", ~39.1s into
// TK01's trimmed timeline).
export const TITLE_TAG_IN = 1173; // 39.1s
export const TITLE_TAG_OUT = 1313; // ~4.7s hold

// Same quiet-bed-then-swell pattern as episode 02: fades in (1s) to a low,
// audible bed ~2s before "So join me in the next video...", HOLDS FLAT at
// that level through the whole closing line (which runs right to the end
// of TK05) -- no rise while he's talking -- then, a second after TK05's
// last frame, swells up to the 40% cap.
export const MUSIC_START_LOCAL_TK05 = 3165; // 105.5s -- bed fades in from here
export const MUSIC_BED_FADE_FRAMES = 30; // 1s fade-in to the bed level
export const MUSIC_BED_UNTIL_LOCAL_TK05 = 3484; // TK05_FRAMES + 30 (1s past the end)
export const MUSIC_RAMP_FRAMES = 220; // ~7.3s swell
export const MUSIC_BED_VOLUME = 0.05; // quiet but present under speech
export const MUSIC_SWELL_VOLUME = 0.4;
export const MUSIC_START = TK05_START + MUSIC_START_LOCAL_TK05;
export const MUSIC_BED_UNTIL_FRAME = MUSIC_BED_UNTIL_LOCAL_TK05 - MUSIC_START_LOCAL_TK05;

export const TOTAL_FRAMES = MUSIC_START + OUTRO_AUDIO_FRAMES;
export const OUTRO_FADE_START = TOTAL_FRAMES - OUTRO_TAIL_FADE_FRAMES - OUTRO_START;
