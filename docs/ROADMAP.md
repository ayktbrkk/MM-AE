# Zaman Yolcuları Roadmap

## Core Vision

Arda veya Eda sınav gecesi tarih kitabını okurken uykuya dalar ve kendini tarihsel olayların sanal rüya dünyasında bulur. Oyun; keşif, NPC konuşmaları, görev nesneleri, görsel karar kartları ve Rift Riff tarzı affedici strateji senaryolarını birleştirir.

Oyuncu Atatürk'ün yerine geçmez. Arda/Eda tarihsel kararları anlamaya çalışan öğrenci karakterdir. Atatürk, ileriki sürümlerde yanlış karar sonrası yolu açıklayan bilge rehber olarak konumlanır.

## Product Frame

- Target audience: children ages 5-10.
- Reference design age: 7-8. The game should still be friendly for 5-6 with icons/voice later and satisfying for 9-10 through light strategy, but every prototype decision is judged against a 7-8 year old player's clarity.
- Platform priority: Android first, iOS compatible.
- Orientation: portrait mobile layout (9:16).
- Visual tone: warm, colorful, semi-cartoon, safe, inspiring.
- Story framing: the player supports and understands historical decisions instead of replacing Ataturk.
- Reference direction: cozy narrative mobile adventure, readable educational UX, child-friendly cinematic staging.

## Immediate Product Discipline

The art vision cannot outrun gameplay validation. Until the Samsun loop proves that a child understands why the historical decision matters, the roadmap is gated:

- Do not open new historical worlds beyond the existing prototype path.
- Do not expand the strategy system into more mechanics.
- Do not replace broad asset sets before Arda/Eda emotional readability improves.
- Do not optimize for 10-year-old strategic depth if it weakens 7-8-year-old comprehension.

The current priority is one complete, testable loop:

1. Room framing: the child understands exam anxiety and the dream setup.
2. Bandirma setup: the child inspects 2 clues and reaches the Samsun decision.
3. Samsun diorama: the child explores, notices companion hints, collects 2 side objects, builds support, and starts the wave.
4. Learning payoff: the child can say, in simple words, why observing and building reliable connections was wiser than rushing.
5. Adult review: history and child-development reviewers can approve tone, accuracy, and cognitive load.

## Open World Historical Diorama Direction

Yeni ana dünya formülü 2D portrait mobile kalır: her tarihsel bölüm, küçük ve okunabilir bir "rüya dioraması" açık dünya dilimi olarak tasarlanır. Amaç tam 3D'ye geçmek değil; Dogwalk/Koira'nın keşif ve eşlikçi duygusunu, Rift Riff'in temiz strateji node'larını ve PaperTown'ın modüler paper-world üretim mantığını 2D Godot sahnelerine çevirmektir.

Her bölüm aynı okunabilir şablonu kullanır:

- Güvenli giriş alanı.
- 1 ana patika.
- 2 yan keşif noktası.
- 1 eşlikçi tepki anı.
- 1 tarihsel landmark.
- 1 karar/strateji node'u.
- Yumuşak çıkış ve bilgi kartı.

Referansların proje karşılığı:

- Dogwalk: rahat keşif temposu, küçük obje toplama, başarısızlık baskısı olmayan dolaşım.
- Koira: Arda/Eda bağını güçlendiren eşlikçi takip, kısa duygusal tepkiler ve çevre anlatımı.
- Rift Riff: tek bakışta anlaşılan destek node'ları, aktif hedef parıltısı, minimal strateji HUD'u.
- PaperTown: `floor`, `decoration`, `object`, `house`, `bridge` ayrımının 2D karşılığı; terrain, path, prop cluster, landmark, fx ve interactable modülleri.

PaperTown yerel klonda ve GitHub `LICENSE` dosyasında MIT olarak doğrulanmıştır. Yine de bu projede doğrudan 3D port yapılmaz. Mimari fikirler 2D `Node2D`, `Area2D`, `Camera2D` ve procedural helper sistemiyle yeniden kurulur. Kod veya asset doğrudan alınırsa kaynak ve lisans notu `assets/licenses/` altında tutulmalı, lisans tekrar kontrol edilmelidir.

İlk pilot: `Samsun Rift`.

- Sahil/liman giriş alanı.
- Telgraf yolu.
- Halk meydanı.
- Merkezi rüya-rift node'u.
- 3 destek node'u: liman, telgraf, halk.
- En az 2 yan keşif objesi.
- En az 1 eşlikçi tepki anı.

HUD ilkesi: açık dünyada mini harita ve rota paneli varsayılan kapalıdır. Yönlendirme çevresel olmalıdır: patika, ışık, landmark, aktif node parıltısı ve alttaki tek aksiyon butonu.

## Phase 1 - Samsun Loop Validation

- Arda/Eda karakter seçimi.
- Öğrenci odası keşif alanı.
- Sınav ünite notlarını toplama.
- Rüya geçişi: Bandırma Vapuru.
- Samsun kararı: plansız hareket yerine gözlem ve güvenilir bağlantı.
- Rift Riff inspired mini scenario: liderlik puanı, destek noktaları, kararsızlık dalgası.
- Hard validation question: "Çocuk bu kararın tarihsel nedenini oyun içinde hissediyor mu?"
- Success test: one 7-8 yaş oyuncu ilk 10 dakikada ne yapacağını bulmalı ve Samsun kararını kendi cümlesiyle açıklayabilmeli.

## Phase 2 - Existing Scene Visual Kit

- Apply the visual kit only to already existing prototype scenes: room, Bandirma, Samsun, Havza, Amasya, Kongreler.
- Do not create new historical content until the Samsun loop test passes.
- Reduce clutter before adding detail: one path, one focus, one bottom action.
- Make strategy nodes feel historical by tying each support to a concrete civic function: observe, communicate, gather, represent, decide.

## Phase 3 - Character Emotional Pass

- Move Arda/Eda custom art earlier than broad world asset replacement.
- Minimum first deliverable:
  - idle portrait
  - thinking portrait
  - happy/relieved portrait
- Use these portraits in dialogue, decision feedback, and companion reaction moments.
- Keep current Kenney world props as acceptable placeholders until the emotional loop reads clearly.

## Phase 4 - Unit Worlds, Locked Behind Validation

- Samsun Yolculuğu: rota, gözlem, liman görevleri.
- Havza Genelgesi: halka bilinçli tepkiyi örgütleme.
- Amasya Genelgesi: bağımsızlık fikrini tamamlayan karar kartları.
- Erzurum ve Sivas: temsilcileri ikna etme ve birlik kurma.
- Ankara: merkez seçimi, yolculuk ve Meclis'e hazırlık.
- Each new world must inherit the validated loop instead of inventing a new structure.

## Phase 5 - Shared Child-Facing UX

- One core version for all target players instead of split age modes.
- Very short readable text, strong icon support, and eventual full voice-over.
- Affordances should stay consistent across scenes: explore, inspect, choose, support, continue.
- Difficulty should adapt through softer feedback, simpler interaction pacing, and optional helper prompts, not separate scene branches.

## Phase 6 - Mobile Visual Design System

- Adopt a mobile-first 2D UI/UX system for portrait screens with large touch targets and safe-area compliant spacing.
- Prioritize early-reader clarity: larger text, fewer words per screen, stronger icons, and calmer panel density.
- Build a reusable visual language for:
  - Main menu
  - Dialogue scenes
  - Choice overlays
  - Educational info cards
  - Minimal gameplay HUD
- Keep the art direction colorful, warm, and semi-cartoon with soft light, ocean blues, sunset golds, and gentle historical texture.
- Use stylized child-proportioned characters, not realism.
- Emphasize emotional clarity through portraits, expressions, and clean panel hierarchy.
- Create reusable Godot-friendly component scenes for buttons, cards, overlays, and chapter headers.
- Keep all UI, character, background, and effects layers modular for export-friendly assembly.
- Use the dedicated design spec in `docs/VISUAL_DESIGN_SYSTEM.md` as the source for upcoming UI and art implementation.

## Phase 6.5 - World Art Upgrade: Toca World + Rift Riff Quality Target

Goal: upgrade the current prototype from functional blockout to a polished, child-friendly, highly readable world. The target is not to copy Toca Boca or Rift Riff, but to reach their production qualities: strong silhouettes, low visual clutter, warm expressive rooms, readable interaction points, cozy environmental storytelling, and forgiving strategy surfaces.

### Art Pillars

- Big readable shapes first: every location must be understandable from a phone screen in one glance.
- Cozy object density: use small prop clusters around story moments, not random decoration everywhere.
- Paper-cutout depth: soft blobs, shadow plates, foreground silhouettes, and subtle parallax replace flat rectangles.
- Neo-historical pop-history: deep turquoise sea/sky, crimson historical flag accents, golden-hour light, and clean cel-shaded outlines.
- Magical rift language: glowing blue particles mark dream/time-travel transitions and strategy decision spaces.
- Character-scale worlds: props should feel oversized, friendly, and tactile for ages 5-10.
- Historical softness: Bandırma, Samsun, Havza, Amasya, and Kongreler should feel like dream-stage memories, not dark war scenes.
- One interaction language: clue, NPC, decision, resource, support, and wave markers must stay visually distinct across all worlds.

### Production Roadmap

1. Visual Foundation Pass
   - Add shared world helpers for soft blobs, route ribbons, glints, light pools, label banners, and paper shadows.
   - Apply these helpers only to current locations so every world has depth, not only UI polish.
   - Keep current story and game logic unchanged.
   - Remove redundant arrows, badges, and HUD before adding new decoration.

2. Character & Portrait Pass
   - Produce Arda/Eda portrait states before broad environment replacement.
   - First states: idle, thinking, happy.
   - Use portraits to test emotional connection in the Samsun loop.

3. Asset Replacement Pass
   - Replace placeholder rectangles with modular room, town, harbor, and meeting-hall props.
   - Keep Kenney as prototype-safe base because Kenney's official support page states its game assets are CC0/public domain.
   - Add a curated external asset folder only after checking each pack's license and commercial permissions.

4. World Composition Pass
   - Give each historical unit a unique map silhouette:
     - Room: warm bedroom, desk, book portal, window moonlight.
     - Bandırma: ship deck/cabin hybrid with ocean lanes and mast silhouette.
     - Samsun: rift-like strategic board with support nodes and harbor/telgraf/halk zones.
     - Havza: town square with notice board, telgraf line, gathering plaza.
     - Amasya: meeting house, writing table, river/path flow, statement route.
     - Kongreler: assembly hall, delegate tables, unity stage, shared route.
   - Make interactables pop through light and motion, not text density.

5. Full Character & Animation Pass
   - Commission or generate Arda/Eda sprite sheets in consistent 5-10 age proportions.
   - Add idle, walk, surprised, thinking, happy, and learning poses.
   - Replace current generic Kenney character placeholders when the custom set is ready.

6. Polish & Mobile Validation
   - Test portrait readability at 720x1280 and 1080x1920.
   - Check that markers never hide behind HUD elements.
   - Keep all text large enough for early readers.
   - Profile mobile draw calls after final asset import.

### Asset Shopping List

- Cozy 2D top-down interiors: bedroom, desk, bookcase, rugs, lamps, school objects.
- Cartoon harbor/ship pack: boat deck, ocean, dock props, crates, rope, map table.
- Cozy town exterior: simple houses, paths, signs, trees, fences, plaza props.
- Meeting/interior hall pack: tables, chairs, papers, banners, lamps.
- UI reward pack: stars, badges, sparkles, buttons in consistent rounded style.
- Custom character pack: Arda, Eda, student NPCs, teacher guide, historically inspired but child-proportioned uniforms.

### Recommended Asset Sources To Review

- Kenney: safe prototype base, CC0/public domain game assets according to Kenney's own support page.
- itch.io Godot/CC0 assets: useful for free prototype expansion, but check each pack separately.
- RhosGFX RPG Interiors: cute high-res interiors, Godot-compatible per listing; check commercial license before use.
- Shubibubi Cozy Interior: strong cozy style, but free and paid versions have different commercial permissions.
- CraftPix coastal/fishing village packs: good for harbor/dock scenes; check license and style fit.
- MODI UI packs: useful if you want faster polished mobile UI, but avoid over-glossy elements that fight the current indie softness.

## Phase 7 - Education & Safety

- Map each level to primary school Life Studies and Social Studies outcomes.
- Review all historical text with a history educator.
- Review tone, cognitive load, and feedback loops with a child development specialist.

## Phase 8 - Monetization

- No ads.
- First unit free.
- Full curriculum unlocked with a one-time purchase.

## Current Prototype

- `scenes/world.tscn` is the current entry scene.
- `scripts/world.gd` builds the room, Bandırma, Samsun Rift, and Havza prototype worlds.
- The current loop is: choose Arda/Eda -> collect room unit notes -> enter Bandirma -> inspect ship clues -> make the Samsun decision -> build supports in the Samsun Rift -> enter Havza -> gather clues -> make the Havza call -> overcome the silence wave.
- The current visual pass adds chapter chips, dream-fade transitions, ambient prop dressing from Kenney packs, stronger marker/character feedback, a more authored Havza layout using sketch-town tiles, a staged Bandirma deck with clearer cabin and mast composition, and a reusable decision overlay scene for history-choice moments.
- `scenes/dialogue_overlay.tscn` and `scripts/dialogue_overlay.gd` already implement the current dialogue overlay: left/right portraits, speaker name, chapter label, typewriter reveal, tap-to-continue, active speaker glow, and mobile bottom panel.
- Dialogue's next technical milestone is not creating the overlay from scratch; it is adding portrait expression routing for `idle`, `thinking`, and `happy/relieved` states.
- The visual target file `assets/art/source/concepts/neo_historical_bandirma_reference.png` is present and should remain the concrete art brief reference until a newer approved concept replaces it.
- `scenes/main.tscn` remains as an older decision-panel prototype and can be reused later as a dedicated decision UI.
- Next validation milestone: make the Samsun loop understandable without extra explanation, then test it with one 7-8 yaş child.
- Current art milestone: improve readability and companion emotion inside the existing Samsun/room/Bandirma loop before opening more historical scope.
