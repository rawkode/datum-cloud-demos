import React from 'react';
import {OffthreadVideo, staticFile} from 'remotion';
import {MOSS} from './theme.js';

const DOCKED = {right: 48, top: 1080 - 270 - 48, width: 480, height: 270, radius: 20, border: 3};

// A steady, bordered webcam bubble docked bottom-right for the length of a
// screen-share segment -- the presenter stays present without competing
// with the terminal content.
export const PipBubble = ({src}) => (
  <div
    style={{
      position: 'absolute',
      right: DOCKED.right,
      top: DOCKED.top,
      width: DOCKED.width,
      height: DOCKED.height,
      borderRadius: DOCKED.radius,
      overflow: 'hidden',
      border: `${DOCKED.border}px solid ${MOSS}`,
      boxShadow: '0 8px 28px rgba(0,0,0,0.45)',
    }}
  >
    <OffthreadVideo
      src={staticFile(src)}
      style={{width: '100%', height: '100%', objectFit: 'cover', transform: 'scaleX(-1)'}}
    />
  </div>
);
