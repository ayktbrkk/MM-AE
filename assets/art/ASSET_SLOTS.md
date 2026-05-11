# Asset Slots

These slots are live in `scripts/world.gd` through `_add_asset_slot_prop(...)`. They are intentionally visible prototype placeholders now, and later they can be replaced with downloaded or custom art without changing the story flow.

## Folder Rule

- Put raw downloads in `assets/art/source/`.
- Put cleaned game-ready sprites in the matching `assets/art/world/...`, `assets/art/characters`, `assets/art/ui`, or `assets/art/fx` folder.
- Put license files or source notes in `assets/licenses/`.
- Keep filenames lowercase with underscores.

## Priority Slots

| Slot | Replacement Need |
| --- | --- |
| `characters.arda_portrait_idle` | Arda idle dialogue portrait |
| `characters.arda_portrait_thinking` | Arda thinking/hesitating dialogue portrait |
| `characters.arda_portrait_happy` | Arda relieved/happy feedback portrait |
| `characters.eda_portrait_idle` | Eda idle dialogue portrait |
| `characters.eda_portrait_thinking` | Eda analytical/thinking dialogue portrait |
| `characters.eda_portrait_happy` | Eda satisfied/happy feedback portrait |
| `room.study_book` | Open glowing history book |
| `room.tablet` | Modern tablet/game device |
| `room.lamp` | Warm desk lamp |
| `room.book_portal` | Blue dream portal from book |
| `ship.map_table` | Bandirma route map table |
| `ship.uniform_stand` | Child-scaled uniform/accessory stand |
| `ship.compass` | Compass/navigation prop |
| `ship.dock_glow` | Samsun harbor arrival glow |
| `samsun.rift_core` | Blue rift strategy core |
| `samsun.harbor_node` | Harbor support node |
| `samsun.telegraph_node` | Telegraph support node |
| `samsun.people_node` | Civic/people support node |
| `havza.notice_board` | Havza Genelgesi notice board |
| `havza.telegraph_table` | Telegraph desk |
| `havza.town_square` | Town square focal point |
| `amasya.meeting_table` | Meeting table |
| `amasya.statement_draft` | Amasya statement draft |
| `amasya.river_marker` | River/route art |
| `kongre.delegate_table` | Delegate table |
| `kongre.unity_stage` | Unity stage |
| `kongre.shared_goal_banner` | Shared goal banner |

## Replacement Process

1. Import the asset into Godot.
2. Keep the slot id in the scene or script metadata.
3. Replace the prototype polygon group with a sprite or small scene.
4. Preserve the slot position and touch readability.
5. Run `world.tscn` headless after replacement.

## Diorama Open World Slots

These slots translate the PaperTown-style modular world idea into 2D. They are not direct PaperTown imports.

| Slot | Target Folder | Replacement Need |
| --- | --- | --- |
| `world_tiles.diorama_ground_blob` | `assets/art/world/world_tiles` | Large soft terrain plates for each historical area |
| `world_tiles.paper_path` | `assets/art/world/world_tiles` | Readable main route ribbons |
| `world_props.foreground_frame` | `assets/art/world/world_props` | Edge silhouettes that add depth without blocking play |
| `world_props.prop_cluster` | `assets/art/world/world_props` | Small themed prop groups around discoveries |
| `landmarks.historical_landmark` | `assets/art/world/landmarks` | One large history anchor per unit |
| `interactables.strategy_node` | `assets/art/world/interactables` | Support/build/wave node art with clean halo |
| `interactables.companion_reaction_spot` | `assets/art/world/interactables` | Visual hint spot for Arda/Eda observations |
| `fx.rift_focus_ring` | `assets/art/fx` | Active dream/decision node glow |
| `samsun.harbor_landmark` | `assets/art/world/landmarks/samsun` | Liman/dock focal landmark |
| `samsun.telegraph_landmark` | `assets/art/world/landmarks/samsun` | Telegraph line or station focal landmark |
| `samsun.people_landmark` | `assets/art/world/landmarks/samsun` | Civic gathering square focal landmark |

## Current Kenney Fallback Layer

The open-world prototype now uses the local open-source Kenney packs as a first-pass visual layer. These sprites are intentionally tagged with `kenney_fallback` metadata in `scripts/world.gd`, so they can be replaced later with custom Neo-Historical art while preserving composition.

| Area | Kenney Packs Used | Purpose |
| --- | --- | --- |
| Student room | `kenney_block-pack`, `kenney_background-elements` | Desk surface, storage boxes, plant, window mood props |
| Bandirma ship | `kenney_pirate-pack`, `kenney_block-pack` | Ship body, mast, sails, deck crates, rails, map table surface |
| Samsun dream hub | `kenney_block-pack`, `kenney_background-elements` | Harbor water, bridge/pier, support-node market stall, building, trees |
| Havza | `kenney_sketch-town`, `kenney_block-pack` | Path tiles, buildings, notice-board supports, town square stall, carts, fences |
| Amasya | `kenney_sketch-town`, `kenney_block-pack` | Meeting table surface, statement stack, river water, bridge, town buildings |
| Kongreler | `kenney_sketch-town`, `kenney_block-pack` | Delegate table surface, unity canopy, banner base, fences, civic buildings |

Next replacement priority is portrait-first:

1. `characters.arda_portrait_idle`
2. `characters.arda_portrait_thinking`
3. `characters.arda_portrait_happy`
4. `characters.eda_portrait_idle`
5. `characters.eda_portrait_thinking`
6. `characters.eda_portrait_happy`

Only after these are usable in the dialogue overlay should the most visible world fallback sprites be replaced: `samsun.rift_core`, `ship.map_table`, `samsun.harbor_node`, `samsun.telegraph_node`, and `samsun.people_node`.

## New Open-World Dressing Types

| Type | Current Kenney Source | Design Use |
| --- | --- | --- |
| Ambient NPCs | `kenney_block-pack/character_man`, `character_woman`, `character_horse` | Gives each location a friendly civic presence without adding heavy dialogue yet |
| Strategy cards | `kenney_boardgame-pack/Cards/cardBack_*` | Visualizes historical decision points as touch-readable choice objects |
| Strategy tokens | `kenney_boardgame-pack/Chips/chip*` | Shows support, focus, route, and shared-goal resources near important hotspots |
| Town props | `kenney_block-pack/market_stall*`, `cart`, `fence*`, `tileBridge`, `tileWater_*` | Makes each historical area feel explorable and spatially distinct |
| Location signs | Procedural panels + `kenney_game-icons` | Names each world area and clarifies the immediate learning goal |
| Way arrows | `kenney_game-icons/arrowRight` | Guides young players toward important hotspots without adding extra tutorial text |
| Discovery badges | `kenney_game-icons/information`, `checkmark` | Marks readable points of interest such as route, decision, support, and shared goal |
| Breadcrumb trails | `kenney_game-icons/star`, `kenney_boardgame-pack/Chips/chip*` | Creates a gentle visual path between story hotspots and reinforces the intended exploration route |
| Backdrop bands | `kenney_background-elements/PNG/Flat` | Adds distant hills, mountains, trees, and town silhouettes for readable world depth |
| Mini map HUD | Procedural `PanelContainer` + marker dots | Gives young players a compact view of player position, target tap, and remaining hotspots |
| Reward bursts | `kenney_game-icons/star`, `target` | Adds immediate positive feedback after collecting clues, resources, and building support nodes |
| Guidance arrow | `kenney_game-icons/arrowUp` | Points from the player toward the next relevant objective when they are far away |
| Route timeline HUD | Procedural dots and labels | Shows the full chapter journey from the room to Bandirma, Samsun, Havza, Amasya, and Kongreler |
| Marker focus states | Procedural beacon, halo, label alpha | Makes active and nearby objectives brighter while inactive markers stay quieter |
| Context action button | Existing bottom mobile button | Changes action copy by marker type: collect, take, build, choose, start, talk, or inspect |

These fallback props should remain child-safe, bright, and low-detail. When replacing them, keep the same large silhouettes and avoid tiny historically realistic details that would reduce mobile readability.

## Current Gameplay-Readable Visual Systems

The prototype still contains several guidance systems from earlier passes:

1. `Location signs` explain the current area and goal in one short phrase.
2. `Way arrows` and `Breadcrumb trails` lead the player toward important hotspots inside the world.
3. `Mini map HUD` shows the player's position, current tap target, and active markers from a distance.
4. `Guidance arrow` helps when the player is far from the next objective.
5. `Route timeline HUD` gives a stable sense of story progression across chapters.
6. `Marker focus states` reduce visual noise by emphasizing only the current goal and nearby interactable.
7. `Context action button` turns the bottom button into a readable verb for each interaction.

This redundancy is no longer the target direction. Under the One Main Focus Rule, Samsun and future open-world pilot scenes should prefer:

1. Environmental path and light.
2. Active node halo.
3. Companion hint when useful.
4. Bottom action button.

Mini map, route timeline, extra arrows, breadcrumbs, and repeated badges should be disabled or removed in validated open-world scenes unless playtesting proves they are needed.
