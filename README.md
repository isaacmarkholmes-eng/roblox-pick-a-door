# Pick a Door — Roblox

A simple Roblox game: pick the correct door each round. Wrong door = you lose. Survive all rounds to win.

## Setup in Roblox Studio

1. Open Roblox Studio → **New** → **Baseplate** (or Empty).
2. In **ServerScriptService**, create a **Folder** named `PickADoor`.
3. Insert a **Script** named `GameManager` and paste in `src/ServerScriptService/GameManager.server.lua`.
4. In **ReplicatedStorage**, create a **Folder** named `PickADoor`.
5. Insert a **ModuleScript** named `Config` and paste in `src/ReplicatedStorage/Config.module.lua`.
6. In **StarterPlayer** → **StarterPlayerScripts**, insert a **LocalScript** named `GameUI` and paste in `src/StarterPlayerScripts/GameUI.client.lua`.
7. Press **Play** (F5).

The server builds the lobby and door rooms automatically. No manual parts required.

## How it works

| Round | Doors | Correct door |
|-------|-------|----------------|
| 1–5   | 3     | Random each round |

- **Wrong door:** player respawns at lobby; round resets for that player.
- **Correct door:** advance to the next round.
- **Round 5 cleared:** win message and confetti colour on the win pad.

## Customization

Edit `Config.module.lua`:

- `TOTAL_ROUNDS` — number of rounds to win
- `DOORS_PER_ROUND` — doors per room (3–6 works well)
- `ROOM_COLORS` — door colours

## Optional polish

- Add sound IDs to `Config` for win/lose sounds.
- Replace baseplate with your own map; scripts still work if `PickADoor` folders exist.
