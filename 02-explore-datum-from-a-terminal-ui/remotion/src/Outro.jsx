import React from 'react';
import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';
import {MIDNIGHT, MOSS, PAPER, OUTRO_FADE_START, OUTRO_TAIL_FADE_FRAMES} from './theme.js';
import {Logo} from './Logo.jsx';

// The music itself starts earlier, back in TK04 -- see MUSIC_START in
// theme.js and the top-level <Audio> in Video.jsx. This is just the visual
// card, timed to fade to black as that same song runs out.
export const Outro = () => {
  const frame = useCurrentFrame();

  const logoProgress = interpolate(frame, [0, 20], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const textOpacity = interpolate(frame, [24, 44], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const tailFade = interpolate(frame, [OUTRO_FADE_START, OUTRO_FADE_START + OUTRO_TAIL_FADE_FRAMES], [1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{background: MIDNIGHT}}>
      <AbsoluteFill style={{opacity: tailFade, alignItems: 'center', justifyContent: 'center'}}>
        <div style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 28}}>
          <Logo progress={logoProgress} width={360} height={289} />
          <div
            style={{
              opacity: textOpacity,
              fontFamily: 'Helvetica, Arial, sans-serif',
              textAlign: 'center',
            }}
          >
            <div style={{color: PAPER, fontSize: 30, fontWeight: 600}}>Explore Datum from a terminal UI</div>
            <div style={{color: MOSS, fontSize: 22, marginTop: 10, letterSpacing: 1}}>datum.net</div>
          </div>
        </div>
      </AbsoluteFill>
      <AbsoluteFill style={{background: '#000', opacity: 1 - tailFade}} />
    </AbsoluteFill>
  );
};
