import React from 'react';
import {interpolate, useCurrentFrame} from 'remotion';
import {MIDNIGHT, MOSS, PAPER} from './theme.js';

// Title tag that identifies the demo as it opens, then gets out of the way.
export const ChapterTag = ({title, inAt = 10, outAt = 120}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [inAt, inAt + 15, outAt, outAt + 20], [0, 1, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const slide = interpolate(frame, [inAt, inAt + 15], [24, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});

  if (opacity <= 0) return null;

  // Sits top-right, clear of the top-left corner where the terminal's own
  // prompt and typed command live in every take we shot this over.
  return (
    <div
      style={{
        position: 'absolute',
        right: 64,
        top: 48,
        opacity,
        transform: `translateY(${slide}px)`,
        display: 'flex',
        alignItems: 'stretch',
        fontFamily: 'Helvetica, Arial, sans-serif',
      }}
    >
      <div style={{background: MIDNIGHT, padding: '10px 24px'}}>
        <div style={{color: PAPER, fontSize: 26, fontWeight: 700}}>{title}</div>
      </div>
      <div style={{width: 6, background: MOSS}} />
    </div>
  );
};
