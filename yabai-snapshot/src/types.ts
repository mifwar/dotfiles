export interface WindowState {
  id: number;
  app: string;
  title: string;
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
  floating: boolean;
  layer: string;
}

export interface SpaceProfile {
  name: string;
  createdAt: string;
  spaceIndex: number;
  layout: string;
  windows: WindowState[];
}

export interface YabaiWindow {
  id: number;
  pid: number;
  app: string;
  title: string;
  frame: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
  floating: number;
  layer: string;
  "is-visible": boolean;
  "has-focus": boolean;
}

export interface YabaiSpace {
  id: number;
  index: number;
  label: string;
  type: string;
  display: number;
  windows: number[];
  "first-window": number;
  "last-window": number;
  "has-focus": boolean;
  "is-visible": boolean;
  "is-native-fullscreen": boolean;
}
