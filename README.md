# Loose Pockets

![Loose Pockets Icon](resources/gfx/ui/mod_icon.png)

Loose Pockets turns every hit into a tense moment: when you take damage, part of your passive build flies out of your hands and becomes recoverable loot. Fail to grab it in time and it's gone for good.

## Catchy One-Liner

Your build is only as safe as your dodging.

## Why Play

- High-stakes immediate tension on every hit.
- Spectator-friendly moments that make great clips.
- Simple, low-overhead mod that changes decision-making without rewriting item systems.

## Features

- Drops 1–2 random passive items from the player's inventory when damaged.
- Drops are thrown away from the damage source with velocity and spread.
- Dropped items flicker shortly before despawning and create a poof effect + sound on loss.
- Story-critical items are blacklisted and will never drop.

## Quick Start

1. Copy the `loose-pockets` folder to your game's `mods` directory.
2. Launch The Binding of Isaac: Repentance and enable the mod in the Mods menu.

## Visuals & Screenshots

Add screenshots to `resources/screenshots/` and they will render below. For now this repo uses the mod icon as a placeholder.

![Promo placeholder](resources/gfx/ui/mod_icon.png)

## Configuration

Edit `main.lua` to tweak:

- `DROP_CHANCE` — probability that an eligible hit causes a drop.
- `DESPAWN_TIMER` — frames until a dropped item disappears (default 150 = ~5s at 30fps).
- `BLACKLIST` — a table of collectible IDs that will never drop.

## Development

Clone the repository, modify `main.lua`, and test by copying the mod folder to your local `mods` folder. No build step is required.

## Contribute

Open issues for bugs or feature ideas. Fork and send focused PRs — include testing steps and a short description of behavior.

## License

MIT

---

If you want, I can create a polished thumbnail, an animated GIF for the README, and add a Steam Workshop blurb.
# Loose Pockets

Loose Pockets is a gameplay mod for The Binding of Isaac: Repentance that turns your passive inventory into a temporary, recoverable resource. When the player takes damage, one or more passive items are ejected from the player and become pickups in the room for a short time. If they are not recovered within the timer, they vanish permanently.

## Key Features

- Drops 1–2 random passive items from the player's inventory when damaged (configurable). 
- Dropped items are thrown away from the damage source with a short-lived physics impulse and angular spread. 
- Items flicker before despawning and play a small poof effect and sound when they disappear. 
- Important story items (Polaroid, Negative, Key Pieces) are blacklisted and cannot be dropped.

## Installation

1. Copy the `loose-pockets` folder into your game's `mods` directory.
2. Start The Binding of Isaac: Repentance and enable the mod from the Mods menu.

## Configuration

Configuration constants are defined in `main.lua`. You can tweak:

- `DROP_CHANCE` — probability an eligible hit causes a drop.
- `DESPAWN_TIMER` — number of frames before a dropped item disappears.
- `BLACKLIST` — a table of collectible IDs that will never drop.

## Development

Clone the repo, make changes to `main.lua` and push pull requests to the upstream repository. The mod uses plain Lua and the game's mod API; no external build steps are required. To test changes, copy the folder to your local `mods` folder and launch the game.

## Contributing

Contributions are welcome. Open issues for bugs and feature ideas. Use clear, focused pull requests and follow the Lua style used in this repository.

## License

This project is released under the MIT License. See `LICENSE` for details.
