import React from 'react';
import {interpolate, useCurrentFrame} from 'remotion';
import {MIDNIGHT, MOSS, PAPER} from './theme.js';

// Name-plate for the talking-head open: slides in a beat after the cut,
// holds through the introduction, and clears well before the wipe to demo.
export const LowerThird = ({inAt, outAt, name, role}) => {
  const frame = useCurrentFrame();
  const slide = interpolate(frame, [inAt, inAt + 14], [40, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const opacity = interpolate(
    frame,
    [inAt, inAt + 10, outAt, outAt + 14],
    [0, 1, 1, 0],
    {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}
  );

  if (opacity <= 0) return null;

  return (
    <div
      style={{
        position: 'absolute',
        left: 80,
        bottom: 96,
        transform: `translateX(${slide}px)`,
        opacity,
        display: 'flex',
        alignItems: 'stretch',
        fontFamily: 'Helvetica, Arial, sans-serif',
      }}
    >
      <div style={{width: 6, background: MOSS}} />
      <div style={{background: MIDNIGHT, padding: '14px 28px'}}>
        <div style={{color: PAPER, fontSize: 34, fontWeight: 700, letterSpacing: 0.3}}>{name}</div>
        <div style={{color: MOSS, fontSize: 20, fontWeight: 500, marginTop: 2}}>{role}</div>
      </div>
    </div>
  );
};
