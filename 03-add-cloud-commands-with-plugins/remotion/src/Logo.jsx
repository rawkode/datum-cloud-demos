import React from 'react';
import {Img, staticFile} from 'remotion';
import {MOSS} from './theme.js';

// The stacked light-on-transparent Datum mark, revealed left-to-right with a
// glowing moss leading rule -- the same wipe motif used across the Datum
// brand's transition stingers.
export const Logo = ({progress, width = 420, height = 337.5}) => {
  const revealWidth = width * progress;
  return (
    <div style={{position: 'relative', width, height}}>
      <div style={{position: 'absolute', left: 0, top: 0, width: revealWidth, height, overflow: 'hidden'}}>
        <Img
          src={staticFile('logo/logo-datum-light.png')}
          style={{position: 'absolute', left: 0, top: 0, width, height, objectFit: 'contain'}}
        />
      </div>
      {progress > 0 && progress < 1 ? (
        <div
          style={{
            position: 'absolute',
            left: revealWidth - 2,
            top: -18,
            width: 4,
            height: height + 36,
            background: MOSS,
            boxShadow: `0 0 22px ${MOSS}`,
          }}
        />
      ) : null}
    </div>
  );
};
