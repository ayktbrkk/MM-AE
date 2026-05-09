# Zaman Yolcuları World Art Roadmap

This document defines the visual production path for reaching a polished mobile world quality inspired by cozy toy-world games and highly readable indie strategy games. It does not copy any reference game's assets or exact compositions.

## Quality Target

The world should feel like a warm dream diorama: big silhouettes, soft paper-cutout forms, calm atmospheric motion, child-safe historical details, and interaction markers that are readable on a portrait phone screen.

## Validation First Constraint

World art is now subordinate to the first playable loop. The goal is not to build all six historical worlds quickly; it is to make one Samsun loop emotionally clear, readable, and educationally meaningful.

Before broad art expansion:

- A 7-8 yaş player should understand where to go in the first 10 seconds of Samsun.
- The child should understand why "observe and connect" beats "rush forward."
- Arda/Eda should feel present through portrait states or companion reactions.
- The strategy node layer should feel like civic support, not generic tower defense.
- Any new prop must improve the loop's readability or emotion.

## Neo-Historical Pop-History Direction

The current target concept is stored at `assets/art/source/concepts/neo_historical_bandirma_reference.png`.

This file is present in the project and becomes the current world-art north star:

- 1919 Turkey as a vivid dream, not a muted museum reconstruction.
- Bandırma Vapuru and future Ankara/Samsun landscapes should use deep turquoise sea/sky, crimson flag accents, and golden-hour light.
- Characters remain modern children, with subtle period accessories such as a pilot cap, scout scarf, satchel, or child-scaled uniform detail.
- Use cel-shaded forms in 2D: clean dark outlines, flat color masses, soft gradient-like light pools, and readable ambient shadows.
- Add blue rift particles near major transitions and strategic decision spaces to signal dream/time-travel mechanics.
- Avoid grey, muddy, militaristic, violent, or grim historical mood.

## Reference Translation

- Toca-style quality means tactile rooms, playful object scale, expressive props, and safe colorful environments.
- Rift Riff-style quality means clear strategy nodes, readable build spots, forgiving feedback, and strong visual hierarchy.
- DOGWALK-style quality means a miniature world with no harsh failure state and environmental objects that invite curiosity.
- The Garden Path-style quality means slow cozy pacing, small discoveries, and short-session comfort.
- Koira-style quality means companion presence, emotional response, and environmental storytelling instead of exposition-heavy instruction.
- PaperTown-style quality means modular paper-world production, but adapted to this project's 2D `Node2D` world instead of importing Sprite3D/NavigationAgent3D systems.

## Open World Diorama Production Model

Each historical unit should be produced from reusable asset families:

- Terrain tiles: large soft ground blobs for room, deck, harbor, town, river, and meeting areas.
- Path ribbons: readable route strips that replace cluttered arrows and breadcrumbs.
- Foreground frames: edge silhouettes, trees, rocks, ship parts, curtains, or crowd shapes that add depth.
- Prop clusters: 3-5 related props around story moments, never random scatter.
- Historical landmarks: one large educational anchor per area, such as harbor, telegraph, notice board, meeting table, or congress stage.
- Companion reaction spots: invisible proximity circles that trigger one short Arda/Eda observation.
- Strategy nodes: active support/build/wave nodes with one clean halo and limited text.

The first full application is `Samsun Rift`: harbor entrance, telegraph path, people square, central rift, and three support nodes.

## Roadmap

### 1. Prototype Visual Kit

- Add reusable Godot helpers for:
  - soft terrain blobs
  - paper shadows
  - cel-shade outlines
  - route ribbons
  - light pools
  - water glints
  - crimson flag accents
  - blue rift shards
  - story banners
  - decorative speckles
- Apply them to every current world without changing story or gameplay.
- Keep application limited to current prototype scenes until the Samsun validation test passes.
- Remove visual redundancy before adding more detail.

### 2. Character Emotion Kit

- Create Arda/Eda first portrait states:
  - idle
  - thinking
  - happy/relieved
- Add these to dialogue and decision feedback before commissioning full walk cycles.
- Treat character emotion as a dependency for the educational loop, not late polish.
- This step has priority over replacing world props such as `samsun.rift_core` or `ship.map_table`.

### 3. Asset Integration Kit

- Create consistent folders:
  - `assets/art/source`
  - `assets/art/world`
  - `assets/art/characters`
  - `assets/art/ui`
  - `assets/art/fx`
  - `assets/licenses`
- Every imported pack must include license notes and source URL.
- Keep Kenney assets in `kenney/` as prototype foundation.

### 4. World Replacement Pass

- Replace room rectangles with cozy bedroom assets.
- Replace Bandırma placeholders with deck/cabin/dock props.
- Replace town environments with modular top-down houses, paths, signs, trees, and indoor meeting props.
- Replace marker setpieces with custom illustrated object sprites.
- Start only after the first portrait states are usable in dialogue.
- Then replace only the objects in the validated loop: study book, Bandırma map table, Samsun rift core, harbor, telegraph, people square.

### 5. Full Character Pass

- Produce Arda and Eda as custom sprites first.
- Required states:
  - idle
  - walk
  - surprised
  - thinking
  - happy
  - learning
  - dream-uniform variant
- Keep proportions friendly and childlike.

### 6. Polish Pass

- Add parallax background layers in each location.
- Add subtle idle animation to flags, ocean, lights, and rift nodes.
- Validate mobile portrait readability at 720x1280 and 1080x1920.
- Reduce any object that competes with interaction markers.

## Asset Needs

Priority 1:

- Arda/Eda portrait states: idle, thinking, happy/relieved.
- Cozy child bedroom interior.
- Top-down school/study props.
- Cartoon ship/deck/harbor props.
- Cozy town exterior and paths.
- Meeting hall furniture.

Priority 2:

- Custom Arda/Eda walk sprites.
- Child-friendly student NPCs.
- Historical guide portrait.
- Reward badge and sticker set.

Priority 3:

- Turkish historical decorative objects.
- Dream fog and soft particle sheets.
- Map transition illustrations.

## License Rules

- Prefer CC0 or paid commercial-use packs.
- For itch.io packs, read free vs paid license separately.
- Store every downloaded pack's license in `assets/licenses/`.
- Avoid mixing clashing pixel densities unless the asset will be repainted or filtered into a unified style.

## Current Implementation Status

- Main scenario is stable and should remain intact.
- UI overlays have a warm mobile-first polish pass.
- The first world-art implementation step is the reusable visual kit in `scripts/world.gd`.
