# Bandırma Yolculuğu — Product Roadmap

## ✅ Tamamlanan Çalışmalar

### Package 1: P10 Android Lifecycle Smoke Gate ✓
- 6 gate'li smoke test pipeline
- ADB device smoke test
- App lifecycle contract verification
- **Çıktı:** [`tools/run_p10_smoke_gate.ps1`](tools/run_p10_smoke_gate.ps1), [`docs/ANDROID_RELEASE_CHECKLIST.md`](docs/ANDROID_RELEASE_CHECKLIST.md)

### Package 2: Repository Hygiene ✓
- `.gitignore` güncellemesi
- Artifact policy (artifacts/logs/)
- Repo hygiene dokümantasyonu
- Log temizleme aracı
- **Çıktı:** [`docs/REPO_HYGIENE.md`](docs/REPO_HYGIENE.md), [`tools/clean_temp_logs.ps1`](tools/clean_temp_logs.ps1)

### Package 3: Zone Definition Resource ✓
- `ZoneDefinition` ve `ZoneMarkerDefinition` Resource class'ları
- `ZoneLoader` static helper
- `ship.tres` ve `samsun_rift.tres` örnek resource'ları
- Zone definition contract verification tool
- **Çıktı:** [`scripts/data/zone_definition.gd`](scripts/data/zone_definition.gd), [`scripts/data/zone_marker_definition.gd`](scripts/data/zone_marker_definition.gd), [`scripts/data/zone_loader.gd`](scripts/data/zone_loader.gd)

### Package 4: Marker Visual Split ✓
- `world_marker_visuals.gd` ayrıştırması
- `world_marker.gd` %60 küçültme (881→349 satır)
- **Çıktı:** [`scripts/world_marker_visuals.gd`](scripts/world_marker_visuals.gd)

### Package 5: World Builder Decomposition ✓
- `room_builder.gd` ayrıştırması
- `world_builder.gd` 177 satır küçültme (3535→3358)
- **Çıktı:** `scripts/world_builders/room_builder.gd`

### Package 6: Tutorial Layer ✓
- `tutorial_controller.gd` (5-phase, non-blocking)
- Save/load entegrasyonu
- 12 kategorili GUT testleri
- **Çıktı:** [`scripts/tutorial_controller.gd`](scripts/tutorial_controller.gd)

### Package 7: Journal / Tarih Defteri ✓
- `journal_overlay.gd` (TabContainer: Kartlar + Bölümler)
- 13 dosya güncellendi/oluşturuldu
- OverlayManager entegrasyonu
- **Çıktı:** [`scripts/journal_overlay.gd`](scripts/journal_overlay.gd), [`scenes/journal_overlay.tscn`](scenes/journal_overlay.tscn)

### Package 8: Audio Infrastructure ✓
- `assets/audio/bgm/` ve `assets/audio/sfx/` dizinleri
- `AUDIO_INVENTORY.md` ve `AUDIO_PRODUCTION_GUIDE.md`
- `verify_audio_production.gd` headless verification tool
- AudioManager test güncellemeleri
- **Çıktı:** [`docs/AUDIO_INVENTORY.md`](docs/AUDIO_INVENTORY.md), [`docs/AUDIO_PRODUCTION_GUIDE.md`](docs/AUDIO_PRODUCTION_GUIDE.md)

### Package 9: Performance Gate ✓
- `measure_world_complexity.gd` (9 zone metrik)
- Performance gate pipeline
- `PERFORMANCE_OBSERVATION.md` (baseline thresholds)
- **Çıktı:** [`tools/measure_world_complexity.gd`](tools/measure_world_complexity.gd), [`docs/PERFORMANCE_OBSERVATION.md`](docs/PERFORMANCE_OBSERVATION.md)

### Package 10: Accessibility ✓
- Text speed (slow/normal/fast)
- Large text mode
- High contrast mode
- Save/load persistence
- 11 accessibility GUT testleri
- **Çıktı:** [`test/test_accessibility.gd`](test/test_accessibility.gd), [`scenes/accessibility_panel.tscn`](scenes/accessibility_panel.tscn)

### Package 11: Release Pipeline ✓
- Android signing prosedürü
- Debug/Release APK build script'leri
- Version bump kuralları
- 20+ maddelik RC checklist
- **Çıktı:** [`tools/build_android_debug.ps1`](tools/build_android_debug.ps1), [`tools/build_android_release_candidate.ps1`](tools/build_android_release_candidate.ps1)

### Package 12: Commercial Polish Backlog Grooming ✓
- Kapsamlı polish backlog (7 kategori, 35 kart)
- Release gate kriterleri (6 gate)
- Güncellenmiş roadmap
- **Çıktı:** [`docs/POLISH_BACKLOG.md`](docs/POLISH_BACKLOG.md), [`docs/RELEASE_GATES.md`](docs/RELEASE_GATES.md)

---

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

## Phase 6.5 — World Art Upgrade: Toca World + Paper Town + Dog Walk Quality Target

> 📝 Bu aşama sonraki sprint'ler için — mevcut prototip yeterli.

Ana yurutme plani:

- `docs/EXECUTION_PACKAGES_PLAN.md`

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

### Yakın Donem World Art Backlog'u

- [ ] Kritik 5 zone icin art replacement sirasi cikar: Bandirma, Samsun, Ankara, Sakarya, Final
- [ ] `world_builder.gd` kompozisyonlarini yeni asset oranlarina gore ayarla
- [ ] Outline, golge ve vurgu kontrastini `colors.gd` ve `ui_tokens.gd` seviyesinde yeniden hizala
- [ ] Zone once/sonra screenshot setleri ile gorsel kalite farkini dokumante et
- [ ] UI regression capture'lari ile yeni art pass'in okunurlugu bozmadigini dogrula

### Sprint Kartlari

- [ ] Kart A: World art audit ve hedef kalite panosu
- [ ] Kart B: Asset pipeline standardizasyonu
- [ ] Kart C: Pilot zone replacement
- [ ] Kart D: Builder kompozisyon uyarlama dalgasi
- [ ] Kart E: Kontrast ve okunurluk kalibrasyonu
- [ ] Kart F: Regression ve kabul paketi



### Ilk Yurutme Paketi

- [ ] Issue 10A: World Art Audit ve Hedef Kalite Panosu
- [ ] Calisma dosyasi: `docs/WORLD_ART_UPGRADE_PLAN.md`
- [ ] Issue 10B: Asset Pipeline Standardizasyonu

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

## Phase 9.5 — Android Release Polish

> 📝 Teknik temel hazir; sonraki odak export'u release davranisina tasimak.

Ana yurutme plani:

- `docs/EXECUTION_PACKAGES_PLAN.md`

### Release Polish Backlog'u

- [ ] Export ve package metadata checklist'ini netlestir
- [ ] Safe-area, system bar ve portrait cihaz davranisini cihaz-ustu smoke-test ile dogrula
- [x] Start, continue, loading, exit confirm ve save/load akislari icin Android smoke checklist'i olustur
- [ ] Fiziksel cihaz veya emulator uzerinde temel performans gozlemi yap
- [ ] Release APK icin tekrar edilebilir kontrol listesi hazirla

### Sprint Kartlari

- [x] Kart A: Export config audit
- [x] Kart B: Mobil UX smoke checklist
- [ ] Kart C: Safe-area ve system bar polish
- [ ] Kart D: Navigation ve app lifecycle sertlestirme
- [ ] Kart E: Performans ve cihaz gozlemi
- [ ] Kart F: Release candidate checklist ve APK dogrulamasi

### Onerilen Siralama

| Kart | Oncelik | Efor | Bagimlilik |
|------|---------|------|------------|
| Kart A | P0 | S | Yok |
| Kart B | P0 | S | Kart A |
| Kart C | P1 | M | Kart A |
| Kart D | P1 | M | Kart B |
| Kart E | P1 | S-M | Kart B, Kart D |
| Kart F | P2 | S | Kart A, Kart B, Kart C, Kart D |

### Ilk Yurutme Paketi

- [x] Issue 11A: Export Config Audit
- [ ] Issue 11B: Mobil UX Smoke Checklist

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
| **M8: Android Release Polish** | 📝 | cihaz smoke test + export checklist |
| **M9: Infrastructure Packages** (P1-P12) | ✅ | Paket 1-12 tamamlandı |

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
- Tutorial layer (5-phase, non-blocking)
- Journal / Tarih Defteri (kartlar + bölümler)
- Erişilebilirlik (text speed, large text, high contrast)
- Resource-driven zone definitions (ship, samsun_rift)
- P10-P11-P12 pipeline (smoke gate, performance gate, release preflight)

**Gereksinimler:**
- Godot 4.6.2
- Android export template
- Minimum 1080×1920 portrait

---

## 🎯 Kısa Vade — MVP Release (Q2 2026)

### Production Audio
- [ ] BGM dosyalarını üret ve [`assets/audio/bgm/`](assets/audio/bgm/) klasörüne ekle
- [ ] SFX dosyalarını üret ve [`assets/audio/sfx/`](assets/audio/sfx/) klasörüne ekle
- [ ] [`tools/verify_audio_production.gd`](tools/verify_audio_production.gd) ile doğrula

### Alpha Test
- [ ] Dahili test grubuna APK dağıt
- [ ] Geri bildirim topla
- [ ] Kritik hataları düzelt

### MVP Release
- [ ] [`docs/RELEASE_GATES.md`](docs/RELEASE_GATES.md) release gates'in tamamını geç
- [ ] [`docs/ANDROID_RELEASE_CHECKLIST.md`](docs/ANDROID_RELEASE_CHECKLIST.md) tamamla
- [ ] İmzalı APK/AAB oluştur
- [ ] Google Play Console'a yükle (veya sideload)

---

## 🚀 Orta Vade — Polish & İçerik (Q3 2026)

### Polish Backlog (bkz: [`docs/POLISH_BACKLOG.md`](docs/POLISH_BACKLOG.md))
- [ ] Animasyon iyileştirmeleri (A01-A09)
- [ ] Görsel efektler (V01-V09)
- [ ] Partikül sistemleri (kar, yaprak, deniz spreyi)
- [ ] UI micro-interaction'lar (haptik, loading bar)

### İçerik Zenginleştirme
- [ ] Ek hikaye event'leri (31 → 49 event)
- [ ] Ek collectible kartlar (tarihi figürler)
- [ ] Replay değeri artırma (farklı karar → farklı sonuç)
- [ ] Başarım sistemi (achievement)

### Performans
- [ ] Texture atlas kullanımı
- [ ] Gereksiz `_process()` döngülerini temizle
- [ ] Object pooling (marker/wave)
- [ ] Mobile GPU instancing

---

## 🌟 Uzun Vade — Genişleme (Q4 2026+)

- [ ] Yeni bölümler ekle (İç Anadolu, Güney Cephesi)
- [ ] Çoklu dil desteği (İngilizce başta)
- [ ] Voice-over (NPC selamlaşmaları, rehber)
- [ ] Ekran okuyucu desteği (TalkBack)
- [ ] Oyun içi screenshot/paylaşım
- [ ] Oyun içi geri bildirim formu
- [ ] Crash reporting (Firebase veya custom)
- [ ] Analytics entegrasyonu (gizlilik politikası ile)
- [ ] Rate my app prompt
- [ ] World Art Upgrade: Toca World kalitesinde diorama
