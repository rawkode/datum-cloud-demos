import React from 'react';
import {Composition, registerRoot} from 'remotion';
import {PluginsDemo} from './Video.jsx';
import {FPS, WIDTH, HEIGHT, TOTAL_FRAMES} from './theme.js';

const Root = () => (
  <Composition
    id="PluginsDemo"
    component={PluginsDemo}
    durationInFrames={TOTAL_FRAMES}
    fps={FPS}
    width={WIDTH}
    height={HEIGHT}
  />
);

registerRoot(Root);
