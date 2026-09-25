import React from 'react';
import {AbsoluteFill, interpolate, useCurrentFrame} from 'remotion';
import {MIDNIGHT, MOSS, PAPER} from './theme.js';
import {Logo} from './Logo.jsx';

// A self-contained brand beat used to punctuate hard cuts: the outgoing
// scene is covered by a quick moss-lined wipe to midnight, the Datum mark
// draws on, holds for a beat (longer when carrying a title card), then the
// wipe clears to black for the next cut.
export const Bumper = ({title}) => {
  const frame = useCurrentFrame();
  const holdEnd = title ? 70 : 40;
  const wipeOutEnd = holdEnd + 15;

  const coverIn = interpolate(frame, [0, 6], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const logoProgress = interpolate(frame, [8, 26], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'});
  const titleOpacity = title
    ? interpolate(frame, [30, 42], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})
    : 0;
  const wipeOut = interpolate(frame, [holdEnd, wipeOutEnd], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const wipeOutWidth = wipeOut * 1920;

  return (
    <AbsoluteFill style={{background: MIDNIGHT, opacity: coverIn, overflow: 'hidden'}}>
      <AbsoluteFill style={{alignItems: 'center', justifyContent: 'center'}}>
        <div style={{display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24}}>
          <Logo progress={logoProgress} />
          {title ? (
            <div
              style={{
                opacity: titleOpacity,
                color: PAPER,
                fontFamily: 'Helvetica, Arial, sans-serif',
                fontSize: 30,
                fontWeight: 600,
                textAlign: 'center',
              }}
            >
              {title}
            </div>
          ) : null}
        </div>
      </AbsoluteFill>
      {wipeOut > 0 ? (
        <>
          <div style={{position: 'absolute', left: 0, top: 0, width: wipeOutWidth, height: 1080, background: '#000'}} />
          {wipeOut < 1 ? (
            <div
              style={{
                position: 'absolute',
                left: Math.max(0, wipeOutWidth - 2),
                top: 0,
                width: 4,
                height: 1080,
                background: MOSS,
                boxShadow: `0 0 22px ${MOSS}`,
              }}
            />
          ) : null}
        </>
      ) : null}
    </AbsoluteFill>
  );
};
