# Home Defenders (ホーディ)

3D TPS × Tower Defense × Online Co-op — built with **Godot 4.3** and deployed to **Vercel** as a WebGL build.

> Defend your home from the demon king's legions with build-anywhere towers,
> a 40-job action kit, and up to 4-player WebRTC co-op.

## Quick start (desktop)

1. Install [Godot 4.3](https://godotengine.org/) (standard build).
2. Open `project.godot` and press **F5** (or run from the editor).
3. Pick a job → Start Game. WASD to move, mouse to aim, **LMB** to attack,
   **Shift** to dodge, **Q/E/F** for skills, **B** for build mode
   (1/2/3 selects tower kind, LMB places, B again to exit).

## Web build

```bash
godot --headless --export-release "Web" public/index.html
cd public && python3 -m http.server 8000
```

The Web build requires `Cross-Origin-Embedder-Policy: require-corp` and
`Cross-Origin-Opener-Policy: same-origin` to enable `SharedArrayBuffer`.
The included `vercel.json` configures this for Vercel hosting.

## Multiplayer (WebRTC)

- On the title screen, type a Room ID to host or join.
- Default signaling endpoint is `wss://YOUR-VERCEL-DEPLOYMENT/api/signal`.
  Update `SIGNALING_URL_DEFAULT` in `scripts/autoload/network_manager.gd`
  once you deploy `signaling/api/signal.ts`.
- Current sync scope: position-only RPC (first iteration). Client-side
  prediction is TODO in `network_manager.gd`.

## Data-driven balance

All numbers live in `data/*.json` — edit & reload, no code changes needed.

| File | Purpose |
| --- | --- |
| `data/jobs.json` | All 40 jobs |
| `data/enemies.json` | Enemy archetypes |
| `data/towers.json` | Tower kinds (Arrow / Cannon / Slow) |
| `data/waves.json` | Wave composition |
| `data/balance.json` | Global tuning |

## Project layout

```
scenes/      Title, Game, HUD, Player, Enemy, Tower, Home, Projectile, Settings
scripts/     Gameplay GDScript
  autoload/  GameState, EventBus, DataLoader, JobRegistry, SaveSystem,
             ObjectPool, NetworkManager, SettingsManager
  jobs/      Per-job skill logic (5 specialised + universal stub)
data/        JSON balance & content
signaling/   Vercel Edge Function for WebRTC signalling
tests/       GUT unit tests
.github/     CI/CD (Godot Headless build + Vercel deploy)
```

## Roadmap

This commit lands **Phase 1 (core mechanics)** and **Phase 2 skeleton**
(40 jobs defined; 5 with custom skills, 35 share an AOE stub).

Follow-ups:

- Full WebRTC ICE/SDP plumbing + client-side prediction
- 35 remaining jobs' bespoke skill logic
- Multi-area level content + 50-wave survival
- High-fidelity art (currently primitives)
- Sentry error reporting, cloud save (Vercel KV / Postgres)
