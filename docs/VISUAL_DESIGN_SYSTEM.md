# Zaman Yolculari Visual Art Direction And UI System

## Purpose

This document defines the production-ready visual language for `Zaman Yolculari`.

It is inspired by the readability, atmosphere, and elegant simplicity associated with premium minimalist indie games such as Rift Riff, while remaining fully original in composition, asset design, and UI treatment.

The goal is not to imitate another game's assets, but to preserve these qualities:

- minimalist but atmospheric visuals
- high mobile readability
- clean silhouettes
- low-detail but expressive environments
- soft animated world feeling
- emotionally immersive presentation
- strong visual hierarchy
- cozy modern indie tone

## Product Frame

- Platform: Android first, iOS compatible
- Engine: Godot Engine
- Orientation: portrait mobile, 9:16
- Audience: ages 5-10
- Genre: educational narrative adventure
- Core actions:
  - exploration
  - dialogue
  - historical decision making
  - educational info cards
  - cinematic chapter transitions

### Age Range Impact

- Prioritize early and mid-reader clarity over dense written storytelling.
- Favor short sentences, direct verbs, and icon-supported meaning.
- Use larger touch zones and calmer screen density than a 10-14 design would require.
- Let emotion, portraits, motion, and color do more of the teaching work.
- Use 7-8 yaş as the visual readability anchor. If a composition is clear for this reference player, support 5-6 with voice/icons later and 9-10 with optional depth rather than denser default UI.

## Experience Pillars

1. Read instantly on a phone.
2. Feel warm, mysterious, and hopeful.
3. Teach through mood, icons, and play, not lecture-like density.
4. Keep every scene visually calm and emotionally directed.
5. Make history feel alive through atmosphere rather than realism.

## High-Level Art Direction

### Core Style

- modern stylized 2D
- minimalist indie readability
- painterly pixel-art inspired texturing, but not noisy pixel art
- simplified geometry with soft lighting
- cozy historical atmosphere
- cinematic front/side mixed compositions
- neo-historical pop-history color and lighting for dream-history scenes
- cel-shaded 2D treatment with clean outlines and bold readable silhouettes

### Neo-Historical Pop-History Layer

Use the generated concept reference at `assets/art/source/concepts/neo_historical_bandirma_reference.png` as the current quality target.

The production style should translate that image into Godot-friendly 2D:

- deep turquoise sea and sky fields
- vibrant crimson historical flag accents
- golden-hour sunlight and cream highlights
- sharp ink-like outlines around major props, buildings, ships, and markers
- blue rift particles around dream transitions, decision nodes, and time-travel moments
- low-poly/cel-shaded feeling through flat shapes, strong shadow plates, and soft gradient-like glows

This layer should make history feel vivid and adventurous for ages 5-10. It should not become realistic war art.

### Paper Diorama + Neo-Historical Rule

Open-world scenes should now read as paper dioramas: layered, tactile, soft-edged, and deliberately simplified. The player should understand the path and active objective before reading any UI text.

Each world composition uses three large layers:

- Background mood: sea, sky, hills, distant town shapes, fog, and dream light.
- Playable path: one clear ribbon that connects entrance, discovery points, landmark, strategy node, and exit.
- Foreground frame: large silhouettes at screen edges that create depth without blocking the player or action button.

The "pop-history" palette remains the emotional layer: deep turquoise, warm sand/gold, crimson accents, cream highlights, and selective blue rift glow.

### One Main Focus Rule

At any moment the screen should show only one primary visual focus. The active focus can be a glowing marker, a landmark, a decision node, or a companion reaction bubble. Avoid stacking arrows, labels, badges, and panels over the same area.

World guidance priority:

1. Environmental path and light.
2. Active node halo.
3. Companion hint near relevant object.
4. Bottom action button.
5. Full overlay only after interaction.

### Character Emotion Dependency

Arda/Eda portrait readability is a first-loop requirement, not late polish. Before broad environment replacement, create at least three expression states for each:

- idle
- thinking
- happy/relieved

These portraits should carry decision feedback and companion feeling so the historical lesson lands emotionally, not only through world props.

### Dialogue Overlay Technical Contract

Current implementation:

- Scene: `scenes/dialogue_overlay.tscn`
- Script: `scripts/dialogue_overlay.gd`
- Used by: `scripts/world.gd` through `dialogue_overlay.present({...})`
- Existing behavior: left/right portraits, active speaker glow, chapter label, speaker name capsule, large body text, typewriter reveal, tap-to-complete, tap-to-continue.

Current `present(config)` keys:

- `chapter`: short location or chapter label.
- `speaker`: visible speaker name.
- `text`: dialogue body.
- `speaker_side`: `left` or `right`.

Next required extension:

- Add `speaker_expression`: `idle`, `thinking`, `happy`, or `neutral`.
- Add portrait slot lookup:
  - `characters.arda_portrait_idle`
  - `characters.arda_portrait_thinking`
  - `characters.arda_portrait_happy`
  - `characters.eda_portrait_idle`
  - `characters.eda_portrait_thinking`
  - `characters.eda_portrait_happy`
- Keep Kenney standing textures as fallback until custom portraits exist.
- Do not add more dialogue UI chrome before the expression routing is working.

### What To Embrace

- large readable shapes
- soft fog and glow layers
- selective saturation
- bold turquoise, crimson, and gold focal accents
- clean dark outlines on major world objects
- elegant empty space
- readable props with clear purpose
- emotional color shifts by scene
- subtle environmental animation
- simplified scene logic children can parse quickly

### What To Avoid

- hyper realism
- dark military realism
- muddy or over-textured scenes
- dense interface chrome
- tiny text
- cluttered silhouettes
- gritty war imagery
- long explanation-heavy screens

## Visual Tone By Story Phase

### Student Room

- intimate, sleepy, quiet
- moonlight blue with warm lamp gold
- modern cozy shapes and simple props

### Bandirma Vapuru

- navy sea, warm wood, foggy horizon
- heroic but calm
- mystery and anticipation

### Samsun Harbor

- arrival light, pale sunrise gold
- civic atmosphere instead of battle mood
- hopeful openness

### Havza / Amasya / Congress Spaces

- more grounded earth and civic colors
- strong focal architecture
- people, notice boards, meeting tables, telegraph stations
- emotional weight through lighting, not darkness

## Color System

### Primary Palette

- `Deep Navy` `#20344F`
- `Ocean Slate` `#355D78`
- `Muted Teal` `#5D8F92`
- `Sunset Gold` `#F2BE63`
- `Warm Apricot` `#E89863`
- `Cream Paper` `#F5E8D3`
- `Weathered Walnut` `#7A5A42`
- `Story Ink` `#2B2730`

### Character Accents

- `Arda Coral` `#D6674B`
- `Arda Amber` `#F0A24A`
- `Eda Teal` `#438A87`
- `Eda Mist` `#9DD3C8`

### UI Feedback Colors

- `Correct Green` `#8CCB74`
- `Retry Blue` `#74A8D7`
- `Badge Gold` `#FFD768`
- `Soft Alert Plum` `#7A6AA8`
- `Disabled Grey` `#9196A0`

### Palette Rules

- backgrounds stay desaturated
- one hero color per screen
- cream or fog-tinted panels behind text
- contrast should feel gentle, never harsh
- use bright saturation only for rewards, choices, and interactive emphasis

## World Art Technical Contract

This section is the reusable production contract for the world-art upgrade wave. It exists so pilot and rollout work can happen without re-deciding outline, contrast, import, or token ownership on each zone.

### Source Of Truth

| Decision Area | Owner File | Notes |
|------|------|------|
| world palette, shadow, theme grouping | `scripts/colors.gd` | `POP_*`, `ART_*`, `SHADOW_*`, `THEME_*` families |
| spacing, border, safe area, readable UI scale | `scripts/ui_tokens.gd` | `BORDER_*`, `SPACE_*`, `SAFE_AREA_*`, `FONT_*` |
| zone audit and pilot order | `docs/WORLD_ART_UPGRADE_PLAN.md` | Bandirma pilot, Samsun second wave |
| historical/art reference direction | `docs/ART_ANALYSIS.md` | paper diorama style guide and palette notes |

### Asset Role Model

Every new world asset must be designed for one primary role:

- Background mood: sky, sea, distant town silhouettes, fog, hill masses.
- Playable path: readable ground ribbon that tells the player where to move next.
- Landmark: one scene-defining ship, building, congress hall, frontline structure, or finale symbol.
- Foreground frame: edge silhouettes that add depth without covering the player, markers, or action affordances.
- Marker support: small accent props that help active-node focus without becoming a second landmark.

Do not combine landmark and foreground duties into the same noisy shape. If an asset tries to do both jobs, split it.

### SVG And Paper Diorama Rules

1. Keep one master vector source per production asset under `assets/art/`; capture PNGs remain review artifacts, not source.
2. Preserve the original SVG `viewBox` and aspect ratio during export; scale in builder/layout code, not by rewriting proportions in multiple files.
3. Use 2-4 visible fill layers plus one optional shadow plate for world props so the result reads as paper cutout instead of flat placeholder.
4. Use dark ink-like outlines only on landmark and foreground assets. Background masses should use softer edges or no hard stroke.
5. Target `stroke-width: 8-18` for readable paper-diorama outlines on major world props, consistent with the current art analysis guide.
6. Keep paper-shadow opacity in the `0.2-0.3` band so depth is visible but not muddy.
7. When a new SVG is added to a preloaded path, commit the matching `.svg.import` file and run `--headless --import --path .` before parse validation.

### Contrast Contract

World art must defer to gameplay readability. Use the following contract instead of hardcoded per-scene guesses:

| Visual Role | Token Source | Contract |
|------|------|------|
| world background mass | `THEME_*["bg"]` | background stays calmer and less bright than the active gameplay cue |
| active landmark / key highlight | `THEME_*["accent"]` | only one strong accent family should dominate a zone focus at a time |
| panel / card / readable paper surface | `THEME_*["panel"]`, `DESIGN_CREAM_PAPER`, `ART_CREAM_LIGHT` | text and buttons should sit on paper surfaces, not raw scenery |
| deep shadow / separation | `SHADOW_WARM`, `SHADOW_COOL`, `PAPER_SHADOW` | shadows separate planes, not paint large black masses |
| text / icon ink | `DESIGN_STORY_INK` | default readable dark tone for labels and world-adjacent copy |

### Collision Warnings

- `RIFT_BLUE` is reserved for time-travel, dream energy, and rift emphasis. Do not use it as a generic terrain fill.
- `POP_CRIMSON` and `POP_GOLD` should not compete at equal weight in the same focal area; one must be primary and the other secondary.
- Character bodies, companion bubbles, and world markers must not sit directly on the same hue-value family as the zone accent behind them.
- If a world background needs brighter contrast to read, lift the panel or marker surface first instead of saturating the entire scene.

### Standard Production Flow

1. Start from the relevant zone audit in `docs/WORLD_ART_UPGRADE_PLAN.md`.
2. Choose the target theme family from `scripts/colors.gd`; do not invent new inline colors in builder or overlay code.
3. Produce or update the SVG asset with the role model and outline rules above.
4. Add or update import metadata, then run `--headless --import --path .` if a new SVG asset enters the repo.
5. Validate parse safety with `--headless --check-only --path . --quit`.
6. Capture the affected zone and compare against the audit goals before opening the next zone.

### Done Definition For Pilot And Rollout

- A new asset uses existing token ownership instead of scene-local hardcoded colors.
- Landmark, path, and foreground roles remain readable at portrait mobile size.
- Character/UI readability is still intact on top of the updated world art.
- Import and parse validation have been rerun after the asset landed.

## Lighting And Atmosphere

### Lighting Rules

- diffuse ambient base light
- subtle bloom only on focal moments
- warm bounce light on characters
- cool atmospheric depth in far background
- fog layers to separate planes

### Environmental Effects

- water shimmer
- drifting fog
- moving cloud bands
- low-amplitude ship sway
- tiny sparkles or glow on important history moments

### Cinematic Principle

Each screen should have one obvious focal point:

- a face
- a choice
- a landmark
- a reward card

Never more than one major focal area at the same time.

## Character Art Direction

## Arda

- energetic middle school boy
- rounded, warm silhouette
- short dark hair
- lively eyebrows and broad expressions
- active stance, slight forward lean
- modern clothing: hoodie, school trousers, sneakers
- dream sections: simplified child-scaled historical uniform accents

### Arda Visual Keywords

- warmth
- motion
- courage
- curiosity

## Eda

- analytical middle school girl
- clean, balanced silhouette
- tidy hair shape
- calm, observant eyes
- more stable posture
- practical clothing with neat structure
- dream sections: stylized historical uniform with clean lines

### Eda Visual Keywords

- clarity
- composure
- intelligence
- trust

## Character Rules

- head-to-body ratio slightly enlarged for expression
- silhouettes readable at thumbnail size
- faces must support emotional states:
  - curious
  - worried
  - determined
  - relieved
  - inspired
- avoid over-detail in uniform trim

## Character Turnaround Direction

For both Arda and Eda, art production should include:

- front pose
- 3/4 pose
- side pose
- neutral portrait
- happy portrait
- worried portrait
- determined portrait
- dream-uniform variant

## Environment Art Direction

### Shape Language

- large readable masses
- soft corner variation
- simple rooflines, decks, docks, doors, windows
- avoid decorative micro-detail

### Surface Treatment

- painterly flat fills
- very light texture grain
- broad highlight strokes
- no heavy outline clutter

### Depth Strategy

- foreground: stronger contrast, darker edges
- midground: main interaction zone
- background: soft fog and reduced detail

### Bandirma Vapuru Design

- clear deck silhouette
- readable mast and sail shapes
- warm wood planks
- navy sea below
- pale horizon line
- child-safe atmosphere

### Samsun Harbor Design

- docks and town masses as large blocks
- soft cranes, boats, and roofs
- arriving morning light
- open feeling of a new chapter

## Animation Language

- subtle idle motion
- UI panels ease in gently
- dialogue indicators pulse softly
- choice cards float by 1-3 px
- reward stars pop with scale and glow
- chapter transitions fade with map movement and fog

Animation should feel alive but quiet.

## Typography System

### Font Direction

- Heading font: rounded geometric display
- Body font: clean rounded sans
- Number font: same family, semibold

### Suggested Pairing

- Headings: Kenney Future or Baloo-like rounded display
- Body: Nunito Sans, Inter Rounded, or equivalent

### Type Scale

- Main menu logo: 56-64 px
- Chapter title: 30-36 px
- Dialogue speaker: 24-28 px
- Dialogue body: 24-28 px
- Choice card title: 24-28 px
- Choice body: 22-24 px
- HUD labels: 20-22 px
- Badge counts: 22-24 px

### Typography Rules

- short paragraphs only
- no dense walls of text
- use line height generously
- keep important words near line starts when possible
- prefer 2-3 short lines over 1 long dense block

## UI/UX Principles

### Overall UX Tone

- premium but friendly
- modern but not sterile
- simple but not empty
- game-like, never worksheet-like
- child-readable before "advanced" or "serious"

### Mobile Rules

- all core buttons thumb-friendly
- minimum primary button height: 104 px
- strong safe-area compliance
- large spacing between tappable elements
- dialogue and choices must remain readable in bright light conditions
- important decisions should fit on one screen without scrolling

### Visual Hierarchy Rules

1. Current story focal point
2. Player action
3. Progress context
4. Optional supporting info

If two elements compete, simplify one.

## Main Menu

### Goal

Deliver immediate emotional identity in one screen.

### Composition

- cinematic animated sea background
- Bandirma silhouette on horizon
- Arda and Eda in foreground, slightly offset
- title in upper-middle
- CTA stack in lower-middle

### UI Elements

- `Start Game`
- `Continue`
- `Settings`

### Visual Notes

- title should feel storybook-cinematic
- background should gently move
- menu should feel premium and calm, not busy

### Wireframe

```text
--------------------------------
|                              |
|        Game Logo             |
|                              |
|    sky / fog / horizon       |
|      Bandirma silhouette     |
|                              |
|        Arda    Eda           |
|                              |
|      [ Start Game ]          |
|       [ Continue ]           |
|       [ Settings ]           |
--------------------------------
```

## Dialogue Screen

### Goal

Make emotional narrative feel intimate without overwhelming the screen.

### Structure

- world remains visible
- active portrait highlighted
- inactive portrait softened
- bottom dialogue panel with soft rounded card
- speaker name capsule
- gentle continue hint
- keep each spoken line compact enough for quick reading

### Behavior

- portrait expression swaps by line
- text reveals quickly or appears in full
- tap indicator only when line is ready

### Wireframe

```text
--------------------------------
| chapter badge     stars      |
|                              |
|  portrait           portrait |
|                              |
|  [ speaker name ]            |
|  dialogue text line 1        |
|  dialogue text line 2    >>  |
--------------------------------
```

## Decision Screen

### Goal

Turn history choices into important emotional beats.

### Structure

- chapter label
- tension prompt
- two large choice cards
- Arda option warm and energetic
- Eda option calm and analytical

### Interaction

- hover/tap glow
- slight card lift on focus
- after choice, feedback arrives with reward or retry framing

### Wireframe

```text
--------------------------------
| chapter                      |
| decision title               |
| short prompt                 |
| [ Arda Card ] [ Eda Card ]   |
| [ Arda Choice ]              |
| [ Eda Choice ]               |
--------------------------------
```

## Info Card System

### Goal

Make learning feel like discovery.

### Card Anatomy

- title
- icon or illustration
- simplified fact text
- reward star or badge
- continue button

### Tone

- one core takeaway
- explain why the event mattered
- plain language, emotionally supportive
- one fact per card is better than several smaller facts

## Chapter Transitions

### Goal

Create pacing and wonder between locations.

### Visual Treatment

- soft fade
- moving map line
- chapter title card
- drifting fog or paper-texture glow
- short pause before next scene

## HUD

### Design Rules

- minimal and elegant
- top aligned
- low visual weight
- never interrupt dialogue focus

### Contents

- chapter marker
- progress indicator
- collectible stars or badges

### Example

```text
[ Bandirma ]         [2/6]   [Star x3]
```

## UI Components To Build In Godot

- `MainMenu.tscn`
- `HudBar.tscn`
- `DialogueOverlay.tscn`
- `DecisionOverlay.tscn`
- `InfoCardOverlay.tscn`
- `PrimaryButton.tscn`
- `SecondaryButton.tscn`
- `ChoiceCard.tscn`
- `CharacterPortraitPanel.tscn`
- `ChapterTransitionOverlay.tscn`

## Scene Concepts

### Scene Concept 1: Bandirma Night Deck

- navy sky
- warm cabin glow
- mast silhouette
- slow ocean movement
- decision tension before arrival

### Scene Concept 2: Samsun Dawn Arrival

- pale gold fog
- harbor silhouettes
- hopeful arrival light
- wide open composition

### Scene Concept 3: Havza Civic Square

- simplified town shapes
- gathering area
- notice boards and telegraph point
- warm civic atmosphere

## Environmental Mood Board Notes

### Mood Keywords

- navy sea
- warm lantern wood
- foggy sunrise
- quiet courage
- hopeful civic energy
- storybook history

### Texture Keywords

- brushed paper
- matte paint
- soft grain
- clean edges
- gentle shadow bands

## Mobile Wireframes

### Exploration

```text
--------------------------------
| chapter chip     progress     |
|                              |
|      environment space       |
|      player + companion      |
|      props + markers         |
|                              |
|     [ inspect / interact ]   |
--------------------------------
```

### Dialogue

```text
--------------------------------
| chapter chip     stars       |
|                              |
|  active story frame          |
|                              |
| portrait   dialogue panel    |
| lines of text           >>   |
--------------------------------
```

### Info Card

```text
--------------------------------
|        fact title            |
|                              |
|     icon / illustration      |
|                              |
| simplified explanation       |
|                              |
|       [ continue ]           |
--------------------------------
```

## Asset Organization

```text
assets/
  ui/
    buttons/
    cards/
    badges/
    icons/
    overlays/
    transitions/
  characters/
    arda/
      portraits/
      expressions/
      sprites/
      uniforms/
    eda/
      portraits/
      expressions/
      sprites/
      uniforms/
  environments/
    bandirma/
      background/
      props/
      fx/
    samsun/
      background/
      props/
      fx/
    havza/
      background/
      props/
      fx/
  effects/
    stars/
    glow/
    fog/
    dream/
  fonts/
  audio/
    ui/
    ambience/
    music/
```

## Naming Convention

- `ui_button_primary_gold.png`
- `ui_choicecard_arda_idle.png`
- `char_arda_portrait_determined.png`
- `char_eda_portrait_thoughtful.png`
- `env_bandirma_deck_mid.png`
- `env_samsun_harbor_back.png`
- `fx_transition_fog_01.png`

## Production Priorities

1. Build the shared mobile UI scenes.
2. Upgrade dialogue and info-card presentation to match this guide.
3. Create portrait sets for Arda and Eda.
4. Bring Bandirma and Samsun to benchmark visual quality before expanding more chapters.
5. Keep all future assets aligned with this document.

## Deliverables To Produce Next

- main menu mockup
- dialogue overlay polish
- info card overlay
- HUD scene
- chapter transition overlay
- Arda/Eda portrait set
- Bandirma and Samsun benchmark compositions
