# yabai-snapshot

[![npm](https://img.shields.io/npm/v/@mifwar/yabai-snapshot)](https://www.npmjs.com/package/@mifwar/yabai-snapshot)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)](https://nodejs.org)

Save and restore yabai window layouts with a TUI.

Built with [Ink](https://github.com/vadimdemedes/ink) + [React](https://react.dev).

## Install

```bash
npx @mifwar/yabai-snapshot
# or
npm install -g @mifwar/yabai-snapshot
ysnap
```

Requires [yabai](https://github.com/koekeishiya/yabai) to be installed and running.

## Usage

```bash
ysnap
```

**Keys**

| Key | Action |
|-----|--------|
| `↑/k` `↓/j` | Navigate profiles |
| `Enter` | Restore selected profile to current space |
| `s` | Save current space layout (prompts for name) |
| `d` | Delete selected profile |
| `q` / `Esc` | Quit |

Profiles are stored in `~/.config/ysnap/profiles/`.

## How it works

- **Save** queries `yabai -m query --windows --space` and stores app names, frames, and float state as JSON.
- **Restore** matches apps on the focused space, reapplies the yabai layout, and fixes floating window positions.

## Roadmap

- [ ] Auto-launch missing apps (`open -a`)
- [ ] Title-based matching for multi-window apps
- [ ] Display-level profiles (save/restore multiple spaces)

## License

MIT
