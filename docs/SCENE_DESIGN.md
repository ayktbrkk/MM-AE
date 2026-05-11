# Bandırma Yolculuğu — Dış Dünya Sahne Tasarımı

## 1. Mevcut Durum Analizi

### Mevcut `area_key` → Bölüm Eşlemesi

| area_key | Bölüm | Mekan | Tip | Durum |
|----------|-------|-------|-----|-------|
| `room` | Giriş: Sınav Gecesi | Öğrenci Odası | İç mekan | ✅ Mevcut |
| `ship` | Giriş: Bandırma Vapuru | Vapur Kamarası | Yarı-açık | ✅ Mevcut |
| `samsun_rift` | Bölüm 1: Samsun | Samsun Limanı | **Dış mekan** | ✅ Mevcut (ama rift teması) |
| `havza` | Bölüm 2: Havza | Havza Kasabası | **Dış mekan** | ✅ Mevcut |
| `amasya` | Bölüm 3: Amasya | Amasya Şehri | **Dış mekan** | ✅ Mevcut |
| `kongreler` | Bölüm 4+5: Erzurum & Sivas | Kongre Salonları | İç mekan | ✅ Mevcut |
| ❌ `erzurum` | Bölüm 4: Erzurum | Erzurum Ovası | **Dış mekan** | 🆕 **EKLE** |
| ❌ `sivas` | Bölüm 5: Sivas | Sivas Şehri | **Dış mekan** | 🆕 **EKLE** |
| ❌ `ankara_road` | Bölüm 6: Ankara & Meclis | Ankara Bozkırı | **Dış mekan** | 🆕 **EKLE** |
| ❌ `sakarya` | Bölüm 7: Sakarya & Taarruz | Sakarya Cephesi | **Dış mekan** | 🆕 **EKLE** |
| ❌ `final` | Final: Cumhuriyet | Ankara Meclis Önü | **Dış mekan** | 🆕 **EKLE** |

### Mevcut `_build_*` Fonksiyonları

```gdscript
# world_builder.gd satır 165-182 — build_world() match-case
"room"        → _build_room()         # İç mekan: öğrenci odası
"ship"        → _build_ship()         # Yarı-açık: vapur kamarası
"samsun_rift" → _build_samsun_rift()  # DIŞ MEKAN: liman, kıyı, dalgalar
"havza"       → _build_havza_world()  # DIŞ MEKAN: yeşil tepeler, kasaba
"amasya"      → _build_amasya_world() # DIŞ MEKAN: nehir kenarı, taş yapılar
"kongreler"   → _build_kongreler_world() # İç mekan: kongre salonları
```

### Mevcut Route Sistemi (`world.gd` satır 1541-1548)

```gdscript
func _route_steps() -> Array:
    return [
        {"area": "room", "label": "Oda"},
        {"area": "ship", "label": "Bandırma"},
        {"area": "samsun_rift", "label": "Samsun"},
        {"area": "havza", "label": "Havza"},
        {"area": "amasya", "label": "Amasya"},
        {"area": "kongreler", "label": "Kongre"},
    ]
```

---

## 2. Yeni Sahne Mimarisi (Dış Dünya Odaklı)

### 2.1 Tasarım Felsefesi

- **Dış dünya = Açık hava diorama**: Her bölüm oyuncunun keşfettiği bir outdoor diorama
- **Paper cutout stili**: SVG-based katmanlı terrain, organik path şekilleri
- **Her bölüm 3 katman**: Arkaplan (sky/depth) → Orta alan (terrain/path/props) → Ön plan (foreground frame)
- **Portrait (9:16) odaklı**: `WORLD_SIZE = Vector2(1600, 2200)`, kamera zoom 0.9
- **Composition**: `_add_*` yardımcılarıyla modüler inşa

### 2.2 Yeni `area_key` Sistemi

| area_key | Chapter (questions.gd) | Event Index | Mood |
|----------|----------------------|-------------|------|
| `room` | Giriş: Sınav Gecesi | 0-1 | `room` |
| `ship` | Giriş: Bandırma Vapuru | 2 | `ship` |
| `samsun_rift` | Bölüm 1: Samsun | 3-6 | `arrival`, `city` |
| `havza` | Bölüm 2: Havza | 7-9 | `road`, `city` |
| `amasya` | Bölüm 3: Amasya | 10-13 | `city` |
| `erzurum` | Bölüm 4: Erzurum | 14-16 | `hall` (outdoor kongre) |
| `sivas` | Bölüm 5: Sivas | 17-19 | `hall` (outdoor kongre) |
| `ankara_road` | Bölüm 6: Ankara | 20-23 | `road`, `hall` |
| `sakarya` | Bölüm 7: Sakarya | 24-27 | `war`, `arrival` |
| `final` | Final: Cumhuriyet | 28-30 | `hall` (outdoor) |

---

## 3. Bölüm Bölüm Dış Dünya Tasarımı

### 3.1 Giriş: Sınav Gecesi → `room` (İç mekan — DOKUNMA)

Mevcut haliyle korunur. İç mekan olduğu için dış dünya dönüşümü gerekmez.

### 3.2 Giriş: Bandırma Vapuru → `ship` (Yarı-açık — DOKUNMA)

Mevcut haliyle korunur. Gemi kamarası + deniz manzarası.

### 3.3 Bölüm 1: Samsun → `samsun_rift` (DIŞ MEKAN)

**Mevcut durum**: Rift teması ağırlıklı (fantastik öğeler). Hafifletilip daha tarihsel liman atmosferine çekilebilir.

**Kompozisyon**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_samsun.svg            | -20
Depth      | paper_skyline_depth.svg         | -18
Distant    | paper_distant_town.svg          | -16
Terrain    | paper_terrain_island.svg        | -14
Path       | paper_main_path.svg             | -12
Water      | paper_harbor_water.svg          | -10
Props      | paper_harbor_boats.svg          | -8
Props      | paper_civic_cluster.svg         | -6
Props      | paper_discovery_props.svg       | -4
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `harbor_landmark` — Liman girişi (event index 3)
- `telegraph_landmark` — Telgraf ofisi (event index 4-5)
- `people_plaza` — Halk meydanı (event index 5-6)

**Renk paleti**: [`THEME_SAMSUN`](scripts/colors.gd)

### 3.4 Bölüm 2: Havza → `havza` (DIŞ MEKAN)

**Mevcut durum**: Temel dış mekan yapısı var. Yeşil tonlar, rift cloud efektleri.

**Kompozisyon**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_havza.svg             | -20
Terrain    | paper_terrain_town.svg          | -14
Path       | paper_main_path.svg             | -12
Props      | paper_civic_square.svg          | -6
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `notice_board` — İlan tahtası (event 7)
- `telegraph_table` — Telgraf ofisi (event 8-9)

**Renk paleti**: [`THEME_HAVZA`](scripts/colors.gd)

### 3.5 Bölüm 3: Amasya → `amasya` (DIŞ MEKAN)

**Mevcut durum**: Temel dış mekan yapısı var. Yeşilırmak kenarı, taş yapılar.

**Kompozisyon**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_amasya.svg            | -20
Terrain    | paper_terrain_amasya.svg        | -14
Path       | paper_main_path.svg             | -12
Props      | paper_congress_hall.svg         | -6
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `meeting_house` — Toplantı evi (event 10-11)
- `statement_draft` — Bildiri taslağı (event 12-13)

**Renk paleti**: [`THEME_AMASYA`](scripts/colors.gd)

### 3.6 🆕 Bölüm 4: Erzurum → `erzurum` (DIŞ MEKAN)

**Yeni dış dünya**: Doğu Anadolu yaylası, kongre binası önü açık alan.

**Diyagram**:
```
    ☁️  ☁️        ☁️                — Gökyüzü
   ═══════════════════════════════  — Uzak dağ silueti (paper_sky_erzurum.svg)
   ╱╲       ╱╲       ╱╲           — Palandöken dağları
  ┌────────────────────────────┐
  │   🏛️  Kongre Binası       │  — Kongre meydanı (outdoor)
  │   ⚑  Bayrak direği       │
  │   ─── ─── ─── ───        │  — Taş yol
  │  🧑‍🤝‍🧑 Temsilciler         │
  └────────────────────────────┘
   ═══════════════════════════════  — Foreground frame
```

**Kompozisyon planı**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_erzurum.svg           | -20
Depth      | paper_mountains_erzurum.svg     | -18
Terrain    | paper_terrain_erzurum.svg       | -14
Path       | paper_main_path.svg             | -12
Props      | paper_congress_building.svg     | -6
Props      | paper_flag_props.svg            | -4
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `congress_square` — Kongre meydanı (event 14-15)
- `delegate_table` — Temsilci masası (event 16)
- `unity_stage` — Birlik kürsüsü

**Renk paleti**: `THEME_ERZURUM` — toprak/sarı tonları, mavi gökyüzü

### 3.7 🆕 Bölüm 5: Sivas → `sivas` (DIŞ MEKAN)

**Yeni dış dünya**: Orta Anadolu bozkırı, taş kongre binası önü meydan.

**Diyagram**:
```
   ☀️                           — Güneşli bozkır gökyüzü
  ┌────────────────────────────┐
  │   🏛️  Sivas Kongre Binası │  — Taş yapı, geniş meydan
  │   ⚑  Türk bayrakları     │
  │   ─── ─── ─── ───        │  — Parke taşlı yol
  │  🧑‍🤝‍🧑 Delegeler           │
  │   📜  Bildiri masası     │
  └────────────────────────────┘
   🌾🌾🌾 Bozkır çimen 🌾🌾🌾   — Foreground frame
```

**Kompozisyon planı**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_sivas.svg             | -20
Depth      | paper_steppe_depth.svg          | -18
Terrain    | paper_terrain_sivas.svg         | -14
Path       | paper_main_path.svg             | -12
Props      | paper_congress_building.svg     | -6
Props      | paper_flag_props.svg            | -4
Props      | paper_unity_banner.svg          | -4
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `congress_hall` — Kongre salonu (event 17-18)
- `unity_banner` — Birlik pankartı (event 19)
- `shared_goal` — Ortak hedef noktası

**Renk paleti**: `THEME_SIVAS` — bozkır sarısı, kahverengi, kiremit

### 3.8 🆕 Bölüm 6: Ankara & Meclis → `ankara_road` (DIŞ MEKAN)

**Yeni dış dünya**: Anadolu bozkırında yolculuk + Meclis binası önü.

**Diyagram**:
```
   ☀️                           — Bozkır güneşi
   ╱╲       ╱╲                 — Uzak tepeler
  ┌────────────────────────────┐
  │   🛤️  Ankara Yolu        │  — Patika, yolculuk
  │   🏛️  Meclis Binası      │  — 23 Nisan 1920
  │   ⚑  Egemenlik bayrağı  │
  │   ─── ─── ─── ───        │  — Bozkır yolu
  │  🧑‍🤝‍🧑 Vekiller           │
  └────────────────────────────┘
   🌾🌾🌾 Bozkır otları 🌾🌾🌾   — Foreground
```

**Kompozisyon planı**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_ankara.svg            | -20
Depth      | paper_steppe_depth.svg          | -18
Terrain    | paper_terrain_ankara.svg        | -14
Path       | paper_main_path.svg             | -12
Props      | paper_meclis_building.svg       | -6
Props      | paper_steppe_props.svg          | -4
Props      | paper_bozkir_props.svg          | -4
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `road_marker` — Ankara yolu (event 20-21)
- `meclis_gate` — Meclis girişi (event 22-23)
- `steppe_camp` — Bozkır kamp alanı

**Renk paleti**: `THEME_ANKARA` — bozkır yeşili, sarı, mavi

### 3.9 🆕 Bölüm 7: Sakarya & Taarruz → `sakarya` (DIŞ MEKAN)

**Yeni dış dünya**: Savaş alanı, cephe karargahı, Dumlupınar.

**Diyagram**:
```
   ☁️☁️☁️  Savaş dumanı ☁️☁️☁️       — Gri gökyüzü
  ┌────────────────────────────┐
  │   ⚔️ Cephe Karargahı      │  — Çadır, strateji masası
  │   🗺️  Harita çadırı      │
  │   🌊 Sakarya Nehri        │  — Savunma hattı
  │   ⚑ Zafer sancağı        │
  │   ─── ─── ─── ───        │  — Askeri yol
  └────────────────────────────┘
   🏔️🏔️ Dumlupınar dağları 🏔️🏔️  — Foreground
```

**Kompozisyon planı**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_sakarya.svg           | -20
Depth      | paper_mountains_war.svg         | -18
Terrain    | paper_terrain_sakarya.svg       | -14
Path       | paper_main_path.svg             | -12
Props      | paper_war_tent.svg              | -6
Props      | paper_flag_props.svg            | -4
Props      | paper_strategy_table.svg        | -4
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `war_tent` — Karargah çadırı (event 24-25)
- `sakarya_river` — Nehir savunma hattı (event 26)
- `dumlupinar_gate` — Zafer anıtı (event 27)

**Renk paleti**: `THEME_SAKARYA` — gri, haki, kırmızı

### 3.10 🆕 Final: Cumhuriyet → `final` (DIŞ MEKAN)

**Yeni dış dünya**: Ankara Meclis önü, bayraklar, kutlama.

**Diyagram**:
```
   ☀️✨✨  Zafer ışıkları ✨✨☀️        — Aydınlık gökyüzü
  ┌────────────────────────────┐
  │   🏛️  Meclis Binası      │  — 29 Ekim 1923
  │   ⚑⚑⚑  Bayraklar ⚑⚑⚑    │
  │   ─── ─── ─── ───        │  — Kutlama yolu
  │  🧑‍🤝‍🧑🧑‍🤝‍🧑  Halk          │  — Coşkulu kalabalık
  │   🎉  Kutlama alanı      │
  └────────────────────────────┘
   🌟🌟  Işık hüzmeleri 🌟🌟     — Foreground
```

**Kompozisyon planı**:
```
Katman     | İçerik                          | Z-index
-----------|----------------------------------|--------
Sky        | paper_sky_final.svg             | -20
Depth      | paper_celebration_depth.svg     | -18
Terrain    | paper_terrain_final.svg         | -14
Path       | paper_main_path.svg             | -12
Props      | paper_meclis_building.svg       | -6
Props      | paper_flag_props.svg            | -4
Props      | paper_celebration_props.svg     | -4
Foreground | paper_foreground_frame.svg      | 5
```

**Landmark marker'ları**:
- `meclis_final` — Meclis önü (event 28-29)
- `celebration_square` — Kutlama meydanı (event 30)
- `future_path` — Gelecek vizyonu

**Renk paleti**: `THEME_FINAL` — kırmızı/beyaz, altın, parlak mavi

---

## 4. Route Sistemi Güncelleme Planı

Mevcut 6 adımlı rota → **10 adımlı rota**:

```gdscript
func _route_steps() -> Array:
    return [
        {"area": "room", "label": "Oda"},
        {"area": "ship", "label": "Bandırma"},
        {"area": "samsun_rift", "label": "Samsun"},
        {"area": "havza", "label": "Havza"},
        {"area": "amasya", "label": "Amasya"},
        {"area": "erzurum", "label": "Erzurum"},       # 🆕
        {"area": "sivas", "label": "Sivas"},            # 🆕
        {"area": "ankara_road", "label": "Ankara"},     # 🆕
        {"area": "sakarya", "label": "Sakarya"},        # 🆕
        {"area": "final", "label": "Cumhuriyet"},       # 🆕
    ]
```

---

## 5. `build_world()` Match-Case Güncelleme Planı

Mevcut (`world_builder.gd` satır 165-182):

```gdscript
match area_key:
    "room":        _build_room()
    "ship":        _build_ship()
    "samsun_rift": _build_samsun_rift()
    "havza":       _build_havza_world()
    "amasya":      _build_amasya_world()
    "kongreler":   _build_kongreler_world()
```

Yeni:

```gdscript
match area_key:
    "room":        _build_room()
    "ship":        _build_ship()
    "samsun_rift": _build_samsun_rift()
    "havza":       _build_havza_world()
    "amasya":      _build_amasya_world()
    "erzurum":     _build_erzurum_world()      # 🆕 Dış mekan
    "sivas":       _build_sivas_world()         # 🆕 Dış mekan
    "ankara_road": _build_ankara_world()        # 🆕 Dış mekan
    "sakarya":     _build_sakarya_world()       # 🆕 Dış mekan
    "final":       _build_final_world()         # 🆕 Dış mekan
```

Not: Mevcut `_build_kongreler_world()` fonksiyonu `erzurum` ve `sivas` için referans olarak korunur, iç mekandan dış mekana dönüştürülür.

---

## 6. Gerekli Yeni SVG Asset Listesi

### 6.1 Erzurum (`assets/art/world/erzurum/`)

| Dosya | Açıklama | Referans |
|-------|----------|----------|
| `paper_sky_erzurum.svg` | Doğu Anadolu gökyüzü, mavi tonlar | mevcut `paper_sky_congress.svg` |
| `paper_terrain_erzurum.svg` | Yayla, Palandöken dağ silueti | mevcut `paper_terrain_town.svg` |
| `paper_main_path.svg` | Taş yol, kongreye giden patika | mevcut pattern |
| `paper_congress_building.svg` | Erzurum Kongre Binası dış cephe | - |
| `paper_mountains_erzurum.svg` | Palandöken dağ derinlik katmanı | - |
| `paper_foreground_frame.svg` | Ön plan bitki örtüsü | mevcut `congress/` |

### 6.2 Sivas (`assets/art/world/sivas/`)

| Dosya | Açıklama | Referans |
|-------|----------|----------|
| `paper_sky_sivas.svg` | Orta Anadolu bozkır gökyüzü | - |
| `paper_terrain_sivas.svg` | Bozkır, taş binalar | - |
| `paper_main_path.svg` | Parke taşlı meydan yolu | mevcut pattern |
| `paper_congress_building.svg` | Sivas Kongre Binası dış cephe | - |
| `paper_unity_banner.svg` | Birlik pankartı dekorasyon | mevcut `paper_flag_props.svg` |
| `paper_steppe_depth.svg` | Bozkır derinlik katmanı | - |
| `paper_foreground_frame.svg` | Ön plan bozkır otları | mevcut `congress/` |

### 6.3 Ankara (`assets/art/world/ankara/`)

| Dosya | Açıklama | Referans |
|-------|----------|----------|
| `paper_sky_ankara.svg` | Bozkır gökyüzü, beyaz bulutlar | - |
| `paper_terrain_ankara.svg` | Ankara bozkırı, tepeler | - |
| `paper_main_path.svg` | Ankara yolu patikası | mevcut pattern |
| `paper_meclis_building.svg` | Meclis Binası dış cephe | - |
| `paper_bozkir_props.svg` | Bozkırda kamp, yol işaretleri | - |
| `paper_steppe_depth.svg` | Bozkır derinlik | Sivas ile paylaşılabilir |
| `paper_foreground_frame.svg` | Ön plan otlar, taşlar | mevcut pattern |

### 6.4 Sakarya (`assets/art/world/sakarya/`)

| Dosya | Açıklama | Referans |
|-------|----------|----------|
| `paper_sky_sakarya.svg` | Savaş gökyüzü, gri/bulutlu | - |
| `paper_terrain_sakarya.svg` | Savaş alanı, siperler | - |
| `paper_main_path.svg` | Askeri yol | mevcut pattern |
| `paper_war_tent.svg` | Karargah çadırı | - |
| `paper_strategy_table.svg` | Harita masası | mevcut `ship.map_table` |
| `paper_mountains_war.svg` | Dumlupınar dağ silueti | - |
| `paper_foreground_frame.svg` | Ön plan siper, dikenli tel | - |

### 6.5 Final (`assets/art/world/final/`)

| Dosya | Açıklama | Referans |
|-------|----------|----------|
| `paper_sky_final.svg` | Aydınlık, bayram gökyüzü | - |
| `paper_terrain_final.svg` | Ankara Meclis önü meydan | - |
| `paper_main_path.svg` | Kutlama yolu | mevcut pattern |
| `paper_celebration_props.svg` | Bayraklar, pankartlar, ışıklar | mevcut `paper_flag_props.svg` |
| `paper_celebration_depth.svg` | Derinlik katmanı, coşkulu kalabalık | - |
| `paper_foreground_frame.svg` | Ön plan kutlama dekoru | - |

---

## 7. Uygulama Planı (Öncelik Sırası)

| # | Adım | Dosya | Süre |
|---|------|-------|------|
| 1 | `build_world()` match-case genişletme | [`world_builder.gd`](scripts/world_builder.gd) | ~5 dk |
| 2 | `_route_steps()` 10 adıma genişletme | [`world.gd`](scripts/world.gd) | ~5 dk |
| 3 | `erzurum` world builder fonksiyonu | [`world_builder.gd`](scripts/world_builder.gd) | ~30 dk |
| 4 | `sivas` world builder fonksiyonu | [`world_builder.gd`](scripts/world_builder.gd) | ~30 dk |
| 5 | `ankara_road` world builder fonksiyonu | [`world_builder.gd`](scripts/world_builder.gd) | ~30 dk |
| 6 | `sakarya` world builder fonksiyonu | [`world_builder.gd`](scripts/world_builder.gd) | ~30 dk |
| 7 | `final` world builder fonksiyonu | [`world_builder.gd`](scripts/world_builder.gd) | ~30 dk |
| 8 | Her bölüm için SVG asset üretimi | `assets/art/world/` | ~2 saat |
| 9 | Marker/spawn mapping güncellemesi | [`world_marker.gd`](scripts/world_marker.gd) | ~15 dk |
| 10 | HUD / zone başlık güncellemesi | [`world.gd`](scripts/world.gd) | ~15 dk |

---

## 8. Notlar & Riskler

1. **`kongreler` → `erzurum` + `sivas` ayrımı**: Mevcut `_build_kongreler_world()` fonksiyonu referans alınarak iç mekandan dış mekana dönüşüm yapılacak. İç mekan polygon'ları dış mekan terrain/outdoor kompozisyona çevrilecek.

2. **`samsun_rift` dönüşümü**: Mevcut Samsun dış mekanı "rift" (fantastik yarık) teması ağırlıklı. Tarihsel dış mekan limanına dönüştürmek için rift efektleri azaltılabilir.

3. **Mevcut decorator fonksiyonları**: `_decorate_havza()`, `_decorate_amasya()`, `_decorate_kongreler()` fonksiyonlarındaki pattern (`_add_*` helper'ları) yeni bölgeler için de kullanılabilir.

4. **Mobile performans**: Her bölümde `_add_soft_blob`, `_add_rift_cloud` gibi Polygon2D çağrıları minimize edilmeli. Outdoor dünyalarda SVG paper cutout texture'lar tercih edilmeli.

5. **Renk paleti**: Her yeni bölüm için [`colors.gd`](scripts/colors.gd) dosyasına `THEME_ERZURUM`, `THEME_SIVAS`, `THEME_ANKARA`, `THEME_SAKARYA`, `THEME_FINAL` sabitleri eklenecek.
