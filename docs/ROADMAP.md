# Bandırma Yolculuğu — Product Roadmap

## Core Vision

"Bandırma Yolculuğu" is a **pop-history educational adventure** for 5-10 year olds, covering the Turkish War of Independence (1919-1923) through a **paper diorama open world** design.

> **Kuzey Yıldızı (North Star):** A child playing as Arda (or Eda) steps into key moments of the War of Independence — not as a commander, but as a **time-traveling observer** who helps people, makes ethical choices, and experiences history through everyday challenges.

### Genişletilmiş Hikaye Yapısı (v2.0)

- 3 Ana Perde → 9 Bölge → 31 Event ✅
- Perde 1: Uyanış (room → bandirma → samsun) ✅
- Perde 2: Örgütlenme (havza → amasya → kongreler) ✅
- Perde 3: Mücadele (ankara → sakarya → final/lozan/cumhuriyet) ✅

## Product Frame

| Alan | Hedef 5-10 yaş | Gerçekçi MVP |
|------|----------------|--------------|
| UX | Tek bakışta anlaşılır | Karakter seçimi + harita +
  diyalog + karar |
| İçerik | 31 event | 31 event ✅ |
| Sanat | Paper diorama, sıcak tonlar | 9 bölge SVG asset ✅ |
| Ses | Ortam + geri bildirim | 13 procedural ses ✅ |
| Süre | 20-30 dk oyun | ~15 dk loop |
| Platform | Android portrait | Android 5.0+ |

## Immediate Product Discipline

1. ✅ Herhangi bir anda çalıştırılabilir olmalı
2. ✅ Static typing — tüm değişkenler tipli
3. ✅ Compositon over Inheritance — modüler mimari
4. ✅ Signal tabanlı iletişim — modüller arası gevşek bağlı
5. ✅ _process sadece gerektiğinde — mobil performans
6. ✅ Tüm metinler Türkçe (Türkiye Türkçesi)
7. 📝 Gerçek ses dosyaları (.ogg) — placeholder'ları değiştir

## Open World Historical Diorama Direction

The game's "open world" is a **horizontal scrolling diorama** where each zone represents a historical region:

1. Room → Bandırma → Samsun → Havza → Amasya → Kongreler → Ankara → Sakarya → Final

### Art Pillars (from VISUAL_DESIGN_SYSTEM.md + artwork analysis)

- **Paper Diorama stili:** Organik path şekilleri, katmanlı opaklık, kalın outline (stroke-width: 8-18)
- **4-renk paleti:** 1 gölge + 2 ana renk + 1 vurgu + outline
- **Portre standardı:** 520×520px, rx=80, #f5e8d3 background
- **Bölüm temaları:** THEME_ROOM, THEME_BANDIRMA, THEME_SAMSUN, THEME_TOWN, THEME_CONGRESS

## Phase 1 — Samsun Loop Validation ✅
- ✅ Diyalog sistemi (typewriter + portre)
- ✅ Karar kartları (A/B seçenekleri)
- ✅ Event zinciri (3 event: room → bandirma → samsun)
- ✅ Temel player movement (touch/drag)
- ✅ HUD (bölüm başlığı, ilerleme)

## Phase 2 — Existing Scene Visual Kit ✅
- ✅ SVG world asset'leri (9 bölge, ~40 SVG)
- ✅ Paper diorama katmanları (sky, terrain, path, landmark, foreground, character)
- ✅ Procedural SVG generation pattern

## Phase 3 — Character Emotional Pass ✅
- ✅ Arda/Eda portreleri (idle, happy, thinking)
- ✅ Portre ekspresyon routing
- ✅ Dialogue portrait mapping

## Phase 4 — Unit Worlds, Locked Behind Validation ✅
- ✅ 6 region implemented (room → kongreler) → then expanded to 9
- ✅ Ankara/Meclis (5 SVG, 11 builder functions)
- ✅ Sakarya/Büyük Taarruz (6 SVG, 11 builder functions)
- ✅ Final/Lozan/Cumhuriyet (6 SVG, 11 builder functions)
- ✅ All 9 zones fully built

## Phase 5 — Shared Child-Facing UX ✅
- ✅ OverlayManager (stack-based, CanvasLayer 50-110)
- ✅ Loading screen (10 history hints)
- ✅ Exit confirm dialog (Android back button)
- ✅ Settings audio sliders (BGM/SFX)
- ✅ Touch target compliance (104×104 minimum)

## Phase 6 — Mobile Visual Design System ✅
- ✅ Renk sistemi (colors.gd — merkezi)
- ✅ Texture DRY (textures.gd — merkezi sabitler)
- ✅ Tween-based animation (no _process loops)
- ✅ Performance: mobile-first, no unnecessary _process

## Phase 6.5 — World Art Upgrade: Toca World + Rift Riff Quality Target

> 📝 Bu aşama sonraki sprint'ler için — mevcut prototip yeterli.

### Art Pillars
- Paper diorama stili (kalın outline, organik path)
- 4 renk paleti
- Portrait orientation 9:16 (1080×1920)
- Sıcak, yarı-çizgi film tonu

### Production Roadmap
- [ ] 1. Prototype Visual Kit — __mevcut__
- [ ] 2. Character Emotion Kit — Arda/Eda portreleri __hazır__
- [ ] 3. Asset Integration Kit — tutorials
- [ ] 4. World Replacement Pass — higher quality diorama
- [ ] 5. Full Character Pass — animation + expression
- [ ] 6. Polish Pass — particles, lighting

## Phase 7 — Education & Safety ✅
- ✅ Tarih bilgisi kartları (info_card_overlay)
- ✅ Doğru/yanlış geri bildirimi (decision retry)
- ✅ Öğretici diyaloglar

## Phase 8 — Monetization
> 📝 v2.0 hedefi — MVP öncelikli değil.

## Phase 9 — Infrastructure ✅
- ✅ Modular architecture (7 modules)
- ✅ Audio system (procedural placeholder)
- ✅ Save system (JSON settings)
- ✅ Event routing (CHAPTER_EVENT_CHAINS)
- ✅ Feature flags (BUILT_ZONES)
- ✅ Godot headless validation (3 tests, 0 errors)

---

## Milestone Durumu

| Milestone | Durum | Notlar |
|-----------|-------|--------|
| **M1: Giriş Loop** (room→bandirma→samsun) | ✅ | 3 zone, 6 event |
| **M2: Örgütlenme** (havza→amasya→kongreler) | ✅ | 3 zone, 13 event |
| **M3: Mücadele** (ankara→sakarya→final) | ✅ | 3 zone, 11 event |
| **M4: Ses Sistemi** | ✅ | 13 procedural ses |
| **M5: Android Build** | ✅ | APK başarıyla oluşturuldu |
| **M6: World Art Upgrade** | 📝 | Toca World kalitesi |
| **M7: E2E Test** | ✅ | 22/22 test geçti |

## Current Prototype (v1.0 — First Milestone)

**Oynanabilir İçerik:**
- 9 bölge, 31 event, tümü built ve wired
- Karakter seçimi (Arda/Eda)
- Dialogue + Decision + InfoCard + ChapterTransition overlay'leri
- Typewriter metin + portre gösterimi
- A/B karar kartları + doğru/yanlış geri bildirimi
- Goal sistemi (zone bazlı hedefler)
- Zone transition + chapter transition
- Settings (BGM/SFX volume slider)
- Loading screen (10 history facts)
- Exit confirm dialog (Android back button)
- 13 procedural placeholder ses
- 22 E2E test (test/ klasörü)
- Android debug APK mevcut (builds/BandirmaYolculugu_debug.apk)

**Gereksinimler:**
- Godot 4.6.2
- Android export template
- Minimum 1080×1920 portrait

**Sonraki Adımlar:**
1. Gerçek ses dosyaları (.ogg) — placeholder'ları değiştir
2. World art upgrade (Toca World kalitesi)
3. Achievement sistemi
4. Oyun içi tutorial
5. Analytics entegrasyonu
