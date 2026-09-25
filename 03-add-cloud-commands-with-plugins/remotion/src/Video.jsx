import React from 'react';
import {AbsoluteFill, Audio, Easing, OffthreadVideo, Sequence, interpolate, staticFile} from 'remotion';
import {
  OPEN_BUMPER_START,
  TK01_START,
  TK01_FRAMES,
  BUMPER1_START,
  TK02_START,
  TK02_FRAMES,
  TK03_START,
  TK03_FRAMES,
  BUMPER2_START,
  TK05_START,
  TK05_FRAMES,
  OUT_BUMPER_START,
  OUTRO_START,
  BUMPER_FRAMES,
  MIDNIGHT,
  TITLE_TAG_IN,
  TITLE_TAG_OUT,
  MUSIC_START,
  MUSIC_BED_FADE_FRAMES,
  MUSIC_BED_UNTIL_FRAME,
  MUSIC_RAMP_FRAMES,
  MUSIC_BED_VOLUME,
  MUSIC_SWELL_VOLUME,
  OUTRO_AUDIO_FRAMES,
} from './theme.js';
import {Bumper} from './Bumper.jsx';
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

export const PluginsDemo = () => (
  <AbsoluteFill style={{background: MIDNIGHT}}>
    <Sequence from={OPEN_BUMPER_START} durationInFrames={BUMPER_FRAMES} name="Open bumper">
      <Bumper />
    </Sequence>

    <Sequence from={TK01_START} durationInFrames={TK01_FRAMES} name="TK01 cold open + terminal beats">
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile('media/tk01-screen.mp4')}
          style={{width: '100%', height: '100%', objectFit: 'contain'}}
        />
        <ChapterTag title="Add cloud commands with plugins" inAt={TITLE_TAG_IN} outAt={TITLE_TAG_OUT} />
        <PipBubble src="media/tk01-cam.mp4" />
      </AbsoluteFill>
    </Sequence>

    <Sequence from={BUMPER1_START} durationInFrames={BUMPER_FRAMES} name="Bumper: terminal to console">
      <Bumper />
    </Sequence>

    <Sequence from={TK02_START} durationInFrames={TK02_FRAMES} name="TK02 console: verify domain">
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile('media/tk02-screen.mp4')}
          style={{width: '100%', height: '100%', objectFit: 'contain'}}
        />
        <PipBubble src="media/tk02-cam.mp4" />
      </AbsoluteFill>
    </Sequence>

    <Sequence from={TK03_START} durationInFrames={TK03_FRAMES} name="TK03 console: verified">
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile('media/tk03-screen.mp4')}
          style={{width: '100%', height: '100%', objectFit: 'contain'}}
        />
        <PipBubble src="media/tk03-cam.mp4" />
      </AbsoluteFill>
    </Sequence>

    <Sequence from={BUMPER2_START} durationInFrames={BUMPER_FRAMES} name="Bumper: console to terminal">
      <Bumper />
    </Sequence>

    <Sequence from={TK05_START} durationInFrames={TK05_FRAMES} name="TK05 terminal: records + close">
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile('media/tk05-screen.mp4')}
          style={{width: '100%', height: '100%', objectFit: 'contain'}}
        />
        <PipBubble src="media/tk05-cam.mp4" />
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
