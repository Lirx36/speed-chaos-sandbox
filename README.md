# Speed Chaos Sandbox

A Roblox sandbox where the fun *is* going stupid fast. Keep moving to build **momentum**
(bonus WalkSpeed that stacks up), hold **Shift** to sprint, **double-jump**, and get flung
around by launch pads, bumpers, and speed rings. There's an optional gamepass that raises
your momentum ceiling — a normal perk, not a paywall.

## What's in here

```
src/
  ReplicatedStorage/Config.luau                 all tuning numbers live here
  ServerScriptService/
    SpeedService.server.luau                    momentum -> WalkSpeed, the core loop
    ObstacleService.server.luau                 launch pads / bumpers / rings / buy pad
    GamepassService.server.luau                 grants the Mega Momentum perk
    MapBuilder.server.luau                      builds a test map on Play (delete later)
  StarterPlayer/
    StarterPlayerScripts/SpeedClient.client.luau    sprint input + HUD bar + speed trail
    StarterCharacterScripts/DoubleJump.client.luau  the mid-air jump
default.project.json                            Rojo mapping
rokit.toml                                      pins the Rojo version
```

## Setup — option A: Rojo (recommended, syncs code from these files into Studio)

On each machine:

1. Install **Rokit**: https://github.com/rojo-rbx/rokit — then in this folder run:
   ```bash
   rokit install
   ```
2. Install the **Rojo** plugin in Roblox Studio (Studio → Toolbox → Plugins, search "Rojo").
3. In this folder, start the server:
   ```bash
   rojo serve
   ```
4. In Studio: open the Rojo plugin panel → **Connect**. Your scripts appear in the right
   services. Press **Play**. Editing a `.luau` file here updates Studio live.
5. Build your real map in Studio, then **File → Publish to Roblox** (first time: create a
   new place). After that the place lives on your account in the cloud.

## Setup — option B: no tooling, just paste the scripts

1. In Studio, recreate the tree by hand (drag `Script`/`LocalScript` objects into the
   matching services) and paste each file's contents in.
   - `*.server.luau` → **Script** in `ServerScriptService`
   - `SpeedClient.client.luau` → **LocalScript** in `StarterPlayer > StarterPlayerScripts`
   - `DoubleJump.client.luau` → **LocalScript** in `StarterPlayer > StarterCharacterScripts`
   - `Config.luau` → **ModuleScript** named `Config` in `ReplicatedStorage`
2. Publish to Roblox. From then on, use Studio's own cloud save to move between machines.

## Working from two computers

- **The game/map:** publish to Roblox. It's cloud-saved to your account — open Studio on the
  other machine, sign in, it's under your creations. Nothing to copy.
- **This code:** it's a git repo. Push it to GitHub (steps below), `git clone` on the other
  machine, run `rojo serve` there. That's the whole sync story.

### Push to GitHub

```bash
git remote add origin https://github.com/<your-username>/speed-chaos-sandbox.git
git branch -M main
git push -u origin main
```

(Create the empty repo first at github.com/new, or with the GitHub CLI:
`gh repo create speed-chaos-sandbox --private --source . --push`.)

On the other machine:

```bash
git clone https://github.com/<your-username>/speed-chaos-sandbox.git
cd speed-chaos-sandbox
rokit install
rojo serve
```

## Controls

| Action | Keyboard | Gamepad |
| --- | --- | --- |
| Move | WASD | Left stick |
| Sprint (hold) | Left Shift | L3 (click left stick) |
| Jump / double-jump | Space (twice) | A (twice) |

## Tuning

Everything is in `src/ReplicatedStorage/Config.luau`. Common tweaks:

- **Feels too fast / clips through walls:** lower `MomentumMax` (try 60) and
  `MomentumMaxWithPass` (try 140). Very high WalkSpeed makes the physics engine miss thin
  walls — keep total speed under ~200 unless you want the chaos.
- **Momentum builds too slowly:** raise `MomentumGainPerSec`, lower `MomentumMoveThreshold`.
- **Momentum vanishes the instant you stop:** lower `MomentumDecayPerSec`.
- **Launch pads too weak/strong:** `LaunchPadPower`.

## The optional gamepass

1. In Studio: **Game Settings** or the Creator Dashboard → create a **Game Pass** called
   e.g. "Mega Momentum", set a price.
2. Copy its ID into `Config.GamepassId`.
3. That's it — `GamepassService` grants owners the higher `MomentumMaxWithPass` ceiling, and
   the gold pad in the test map (`BuyPassPad`) prompts the purchase. With `GamepassId = 0`
   the pad and perk are simply inert.

Keep it a perk. Roblox prohibits requiring payment to escape a bad game state; a pass that
just makes a fun thing *more* fun is fine.

## Notes

- `MapBuilder` only builds if there's no `GeneratedMap` folder in Workspace, so once you
  build your own map you can delete the script (or leave it — it'll no-op).
- Movement in Roblox is client-authoritative by design; this project sets WalkSpeed on the
  server so it replicates, which is the normal approach for a sandbox like this.
