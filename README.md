# Loose Pockets

![Loose Pockets Icon](resources/gfx/ui/mod_icon.png)

Loose Pockets is a high-energy gameplay mod for The Binding of Isaac: Repentance that creates instant, shareable moments every time you get hit.

Your build is only as safe as your dodging.

Why players love it:

- Fast, adrenaline-driven consequences for mistakes.
- Streamer- and viewer-friendly chaos that makes highlights.
- Minimal changes to game systems, maximum emergent plays.

Core behavior:

- When the player takes damage, 1–2 random passive items are ejected and become pickups.
- Pickups are flung away from the damage source with a quick impulse and angular spread.
- Pickups flicker shortly before disappearing; if not reclaimed they vanish with a small poof and sound.
- Important story items are protected by a blacklist and never drop.

Install

1. Copy the `loose-pockets` folder into your game's `mods` directory.
2. Start The Binding of Isaac: Repentance and enable the mod from the Mods menu.

Configuration

Open `main.lua` and adjust the following values to taste:

- `DROP_CHANCE` — probability that an eligible hit causes a drop.
- `DESPAWN_TIMER` — frames until a dropped item disappears (default 150 ≈ 5s at 30fps).
- `BLACKLIST` — collectible IDs that will never drop.

Support & Contributions

Found a bug or want a feature? Open an issue or submit a focused pull request. Keep changes small and include reproduction steps.

License

MIT

---

Published and ready for the Steam Workshop or GitHub release. If you want a promo GIF or a custom thumbnail, I can generate one and add it to the repo.
