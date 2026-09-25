import React from 'react';
import {AbsoluteFill, Audio, Easing, OffthreadVideo, Sequence, interpolate, staticFile} from 'remotion';
import {
  OPEN_BUMPER_START,
  TK01_START,
  TK01_FRAMES,
  TITLE_BUMPER_START,
  TITLE_BUMPER_FRAMES,
  TK03_START,
  TK03_FRAMES,
  TK04_START,
  TK04_FRAMES,
  OUT_BUMPER_START,
  OUTRO_START,
  BUMPER_FRAMES,
  MIDNIGHT,
  MUSIC_START,
  MUSIC_BED_FADE_FRAMES,
  MUSIC_BED_UNTIL_FRAME,
  MUSIC_RAMP_FRAMES,
  MUSIC_BED_VOLUME,
  MUSIC_SWELL_VOLUME,
  OUTRO_AUDIO_FRAMES,
} from './theme.js';
import {Bumper} from './Bumper.jsx';
import {LowerThird} from './LowerThird.jsx';
import {ChapterTag} from './ChapterTag.jsx';
import {PipBubble} from './PipBubble.jsx';
import {Outro} from './Outro.jsx';

// Quick fade-in to a low bed, held FLAT under the whole closing line (no
// rise while he's talking), then a swell to the cap once he's done.
// interpolate applies the easing to each segment on its own, so the flat
// hold stays flat.
const musicVolume = (f) =>
  interpolate(
    f,
    [0, MUSIC_BED_FADE_FRAMES, MUSIC_BED_UNTIL_FRAME, MUSIC_BED_UNTIL_FRAME + MUSIC_RAMP_FRAMES],
    [0, MUSIC_BED_VOLUME, MUSIC_BED_VOLUME, MUSIC_SWELL_VOLUME],
    {
      easing: Easing.inOut(Easing.quad),
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    }
  );

export const ConsoleDemo = () => (
  <AbsoluteFill style={{background: MIDNIGHT}}>
    <Sequence from={OPEN_BUMPER_START} durationInFrames={BUMPER_FRAMES} name="Open bumper">
      <Bumper />
    </Sequence>

    <Sequence from={TK01_START} durationInFrames={TK01_FRAMES} name="TK01 cold open">
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile('media/tk01-cam.mp4')}
          style={{width: '100%', height: '100%', objectFit: 'cover'}}
        />
        <LowerThird inAt={15} outAt={100} name="David Flanagan" role="Rawkode Academy" />
      </AbsoluteFill>
    </Sequence>

    <Sequence from={TITLE_BUMPER_START} durationInFrames={TITLE_BUMPER_FRAMES} name="Title bumper">
      <Bumper title="Explore Datum from a terminal UI" />
    </Sequence>

    <Sequence from={TK03_START} durationInFrames={TK03_FRAMES} name="TK03 console walkthrough">
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile('media/tk03-screen.mp4')}
          style={{width: '100%', height: '100%', objectFit: 'contain'}}
        />
        <ChapterTag title="datumctl console" inAt={15} outAt={160} />
        <PipBubble src="media/tk03-cam.mp4" />
      </AbsoluteFill>
    </Sequence>

    <Sequence from={TK04_START} durationInFrames={TK04_FRAMES} name="TK04 console walkthrough cont.">
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile('media/tk04-screen.mp4')}
          style={{width: '100%', height: '100%', objectFit: 'contain'}}
        />
        <PipBubble src="media/tk04-cam.mp4" />
      </AbsoluteFill>
    </Sequence>

    <Sequence from={OUT_BUMPER_START} durationInFrames={BUMPER_FRAMES} name="Out bumper">
      <Bumper />
    </Sequence>

    <Sequence from={OUTRO_START} name="Outro">
      <Outro />
    </Sequence>

    <Sequence from={MUSIC_START} durationInFrames={OUTRO_AUDIO_FRAMES} name="Outro music">
      <Audio src={staticFile('media/outro.wav')} volume={musicVolume} />
    </Sequence>
  </AbsoluteFill>
);
