# Teknik Tasarım — Amasya Asset Kit

## Genel Bakış

Bu belge, `amasya` bölgesi için paper diorama asset kitinin teknik tasarımını tanımlar. Mevcut `_build_amasya_world()` fonksiyonu yalnızca `_add_rect()` ve `_add_rift_cloud()` çağrıları içermektedir; bu spec'in amacı 5 SVG dosyasını paper diorama üretim standardına yükseltmek, `textures.gd` içine `AMASYA_PAPER_*` sabitlerini eklemek ve `_build_amasya_world()` içine `_add_amasya_paper_asset_layer()` çağrısını entegre etmektir.

Amasya bölgesi, 1919 akşamı tarihi Osmanlı şehri atmosferini taşır: derin lacivert gökyüzü, hilal ay, Yeşilırmak vadisi, taş binalar, minareler, kongre salonu kızıl alınlığı.

---

## Mevcut Durum

### `_build_amasya_world()` Mevcut Yapısı

```gdscript
func _build_amasya_world(world_root: Node) -> void:
    _add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.12, 0.15, 0.20))
    _add_rift_cloud(world_root, Vector2(790, 1100), 760, Color(0.95, 0.80, 0.26, 0.12))
    _decorate_amasya(world_root)
```

**Mevcut `textures.gd`'de AMASYA_PAPER_* sabiti yok** — tüm sabitler bu spec kapsamında sıfırdan oluşturulacak.

### Hedef `_build_amasya_world()` Yapısı

```gdscript
func _build_amasya_world(world_root: Node) -> void:
    _add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.12, 0.15, 0.20))
    _add_amasya_paper_asset_layer(world_root)  # YENİ
    _decorate_amasya(world_root)
    emit_signal("world_built", "amasya")       # YENİ
```

---

## SVG Asset Üretim Planı

### 1. `paper_sky_amasya.svg` (1500×760)

**Açıklama:** Derin lacivert akşam gökyüzü. Hilal ay parıltısı, uzak dağ silüetleri, gece atmosferi.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.18 | Gökyüzü kenar gölgesi |
| 2 — Gökyüzü | `<path>` | `#292C39` | Ana gökyüzü yüzeyi, tüm viewBox |
| 3 — Dağ silüeti | `<path>` | `#1A2A3A` opacity 0.28 | Uzak dağ tepeleri |
| 4 — Ay parıltısı | `<path>` | `#F2BE63` opacity 0.28 | Hilal/parıltı vurgusu |

**Path sayısı:** 3–4 | **viewBox:** `0 0 1500 760`

---

### 2. `paper_terrain_amasya.svg` (800×600)

**Açıklama:** Koyu ceviz/kızıl arazi. Yeşilırmak vadisi zemin katmanı, akşam ışığı vurgusu.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.18 | Arazi kenar gölgesi |
| 2 — Arazi | `<path>` | `#7A5A42` | Ceviz kahvesi vadi zemini |
| 3 — Koyu vurgu | `<path>` | `#4A3A2A` opacity 0.80 | Derin arazi katmanı |
| 4 — Kızıl vurgu | `<path>` | `#C84B3D` opacity 0.26 | Akşam ışığı yansıması |

**Path sayısı:** 4 | **viewBox:** `0 0 800 600`

---

### 3. `paper_main_path.svg` (920×900)

**Açıklama:** Kıvrımlı krem taş döşeli yol ve dallanmaları. Gece vurgusu, Osmanlı sokak dokusu.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.14 | Patika kenar gölgesi |
| 2 — Ana patika | `<path>` | `#E8DFC8` | Krem taş döşeli yüzey |
| 3 — Sol dallanma | `<path>` | `#E8DFC8` opacity 0.80 | Sol yol kolu |
| 4 — Sağ dallanma | `<path>` | `#E8DFC8` opacity 0.78 | Sağ yol kolu |
| 5 — Gece vurgusu | `<path>` | `#292C39` opacity 0.25 | Patika gölge örtüsü |

**Path sayısı:** 4–5 | **viewBox:** `0 0 920 900`

---

### 4. `paper_congress_hall.svg` (600×400)

**Açıklama:** Tarihi kongre binası: krem taş cephe, kızıl üçgen alınlık, altın sütun vurguları, koyu kapı/pencereler.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.18 | Bina kenar gölgesi |
| 2 — Bina gövdesi | `<path>` | `#E8DFC8` | Krem taş cephe |
| 3 — Alınlık | `<path>` | `#C84B3D` | Kızıl üçgen alınlık |
| 4 — Sütunlar | `<path>` | `#F2BE63` opacity 0.85 | Altın sütun vurguları |
| 5 — Kapı/Pencereler | `<path>` | `#2B2730` opacity 0.70 | Koyu giriş detayları |

**Path sayısı:** 4–5 | **viewBox:** `0 0 600 400`

---

### 5. `paper_foreground_frame.svg` (1600×780)

**Açıklama:** Ön plan çerçeve: sol dağ silüeti, sağ dağ/minare silüeti, zemin bandı. Yüksek opaklık, diorama derinliği.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Sol dağ | `<path>` | `#1A2A3A` opacity 0.90 | Sol dağ silüeti |
| 2 — Sağ dağ | `<path>` | `#1A2A3A` opacity 0.88 | Sağ dağ/minare silüeti |
| 3 — Zemin bandı | `<path>` | `#292C39` opacity 0.86 | Alt zemin bandı |

**Path sayısı:** 3 | **viewBox:** `0 0 1600 780`

---

## Renk Paleti

| Sabit | Hex | Kullanım |
|-------|-----|---------|
| `AMASYA_NIGHT_SKY` | `#292C39` | Gökyüzü, zemin bandı |
| `DESIGN_WEATHERED_WALNUT` | `#7A5A42` | Arazi, ceviz tonları |
| `AMASYA_CREAM_PATH` | `#E8DFC8` | Patika, bina cephesi |
| `POP_CRIMSON` | `#C84B3D` | Kongre alınlığı, kızıl vurgular |
| `DESIGN_STORY_INK` | `#2B2730` | Outline, kapı/pencere detayları |
| `POP_GOLD` | `#F2BE63` | Ay parıltısı, sütun vurguları |
| `PAPER_SHADOW` | `#1A2A3A` | Gölge katmanları, dağ silüetleri |

---

## SVG Üretim Standardı

Her SVG dosyası şu şablonu takip eder:

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="W" height="H" viewBox="0 0 W H">
  <!-- Katman 1: Gölge -->
  <path d="M..." fill="#1a2a3a" opacity="0.18"/>
  <!-- Katman 2: Ana şekil -->
  <path d="M..." fill="[AMASYA paleti rengi]"/>
  <!-- Katman 3: Vurgu (opsiyonel) -->
  <path d="M..." fill="[vurgu]" opacity="0.60"/>
  <!-- Katman 4: Outline (opsiyonel) -->
  <path d="M..." fill="none" stroke="#2B2730" stroke-width="10"/>
</svg>
```

**Kurallar:**
- Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
- `style` attribute veya `<defs>` yok
- `<text>` veya `<tspan>` yok
- `<image>`, `<use>`, `<symbol>` yok
- Maksimum 5 benzersiz renk değeri
- Disk boyutu < 50 KB
- Gölge path'leri her zaman diğer path'lerin önünde (SVG belgesinde ilk sırada)

---

## Parallax Katman Tablosu

`_add_amasya_paper_asset_layer()` fonksiyonundaki çağrılar için hedef değerler:

| Asset Dosyası | Sabit | Pozisyon | Scale | Opaklık | Z-Index | Parallax | Slot ID |
|--------------|-------|----------|-------|---------|---------|----------|---------|
| `paper_sky_amasya.svg` | `AMASYA_PAPER_SKY_TEXTURE` | (800, 380) | 1.05 | 0.88 | -18 | -15.0 | `amasya.depth.sky` |
| `paper_terrain_amasya.svg` | `AMASYA_PAPER_TERRAIN_TEXTURE` | (800, 1100) | 1.10 | 0.90 | -14 | -3.5 | `amasya.depth.terrain` |
| `paper_main_path.svg` | `AMASYA_PAPER_MAIN_PATH_TEXTURE` | (800, 1300) | 0.82 | 0.86 | -10 | -1.5 | `amasya.path.main` |
| `paper_congress_hall.svg` | `AMASYA_PAPER_CONGRESS_HALL_TEXTURE` | (800, 1450) | 0.88 | 0.90 | -5 | 2.0 | `amasya.landmark.congress_hall` |
| `paper_foreground_frame.svg` | `AMASYA_PAPER_FOREGROUND_FRAME_TEXTURE` | (800, 1850) | 1.12 | 0.90 | 4 | 18.0 | `amasya.foreground.frame` |

---

## `_add_amasya_paper_asset_layer()` Hedef Implementasyonu

```gdscript
func _add_amasya_paper_asset_layer(world_root: Node) -> void:
    # Gökyüzü — en uzak katman
    _add_paper_cutout_asset(
        world_root, _textures.AMASYA_PAPER_SKY_TEXTURE,
        Vector2(800, 380), Vector2(1.05, 1.05),
        Color(1, 1, 1, 0.88), -18,
        "amasya.depth.sky", Vector2.ZERO, -15.0
    )
    # Arazi — Yeşilırmak vadisi zemin katmanı
    _add_paper_cutout_asset(
        world_root, _textures.AMASYA_PAPER_TERRAIN_TEXTURE,
        Vector2(800, 1100), Vector2(1.10, 1.10),
        Color(1, 1, 1, 0.90), -14,
        "amasya.depth.terrain", Vector2.ZERO, -3.5
    )
    # Ana patika — tarihi taş döşeli yol
    _add_paper_cutout_asset(
        world_root, _textures.AMASYA_PAPER_MAIN_PATH_TEXTURE,
        Vector2(800, 1300), Vector2(0.82, 0.82),
        Color(1, 1, 1, 0.86), -10,
        "amasya.path.main", Vector2.ZERO, -1.5
    )
    # Kongre salonu — tarihi landmark
    _add_paper_cutout_asset(
        world_root, _textures.AMASYA_PAPER_CONGRESS_HALL_TEXTURE,
        Vector2(800, 1450), Vector2(0.88, 0.88),
        Color(1, 1, 1, 0.90), -5,
        "amasya.landmark.congress_hall", Vector2.ZERO, 2.0
    )
    # Ön plan çerçeve — en yakın katman
    _add_paper_cutout_asset(
        world_root, _textures.AMASYA_PAPER_FOREGROUND_FRAME_TEXTURE,
        Vector2(800, 1850), Vector2(1.12, 1.12),
        Color(1, 1, 1, 0.90), 4,
        "amasya.foreground.frame", Vector2.ZERO, 18.0
    )
```

---

## `textures.gd` Güncellemesi

Mevcut `textures.gd` dosyasına yeni bölüm eklenir:

```gdscript
# ====================================
# AMASYA PAPER CUTOUT (özel asset)
# ====================================
const AMASYA_PAPER_SKY_TEXTURE := preload("res://assets/art/world/amasya/paper_sky_amasya.svg")
const AMASYA_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/amasya/paper_terrain_amasya.svg")
const AMASYA_PAPER_MAIN_PATH_TEXTURE := preload("res://assets/art/world/amasya/paper_main_path.svg")
const AMASYA_PAPER_CONGRESS_HALL_TEXTURE := preload("res://assets/art/world/amasya/paper_congress_hall.svg")
const AMASYA_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/amasya/paper_foreground_frame.svg")
```

---

## Mimari

### Değişmeyecek Yapı

- `_decorate_amasya()` fonksiyon imzası ve içeriği
- `_add_paper_cutout_asset()` çağrı parametreleri ve meta sistemi
- `world_marker.gd` marker sistemi
- Mevcut `_add_rect()` ve `_add_rift_cloud()` çağrıları (base background için korunabilir)

### Değişecek Yapı

- `assets/art/world/amasya/` dizinindeki 5 SVG dosyasının içeriği (yalnızca `<path>` elementleri)
- `scripts/textures.gd` — 5 yeni `AMASYA_PAPER_*` sabiti eklenir
- `scripts/world_builder.gd` — `_add_amasya_paper_asset_layer()` fonksiyonu eklenir
- `scripts/world_builder.gd` — `_build_amasya_world()` içine `_add_amasya_paper_asset_layer(world_root)` ve `emit_signal("world_built", "amasya")` eklenir

---

## Performans Tasarımı

### Node Sayısı Analizi

`_add_amasya_paper_asset_layer()` 5 `_add_paper_cutout_asset()` = **5 Sprite2D node**.

`_decorate_amasya()` ek node'lar ekler (rift cloud'lar, soft blob'lar vb.) — toplam ~30 node, limit 60'ın çok altında.

### Tween Animasyon Kuralı

- `_add_paper_cutout_asset()` `ambient_bob` meta değeri → `world_player.gd` tarafından Tween ile yönetilir
- `_build_amasya_world()` içinde `_process()` çağrısı yok
- `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturulmaz

### Bellek Yönetimi

`clear_world()` çağrıldığında `"paperworld.amasya_"` önekli tüm node'lar `queue_free()` ile temizlenir — mevcut `_add_paper_cutout_asset()` implementasyonu bu slot_id sistemini kullanıyor.

---

## Portrait 9:16 Kompozisyon

```
WORLD_SIZE = Vector2(1600, 2200)
Kamera zoom = 0.9

Görünür alan (zoom 0.9): ~1778 × 2133 px

Kritik asset pozisyonları:
  sky:            (800, 380)   → arka gökyüzü, tam ekran
  terrain:        (800, 1100)  → zemin katmanı
  main_path:      (800, 1300)  → patika, merkez
  congress_hall:  (800, 1450)  → kongre salonu, merkez
  foreground:     (800, 1850)  → ön plan, kenarlar kapalı

Tüm asset'ler zoom=0.9'da ekran içinde, kenardan ≥50px uzakta.
paper_congress_hall merkez noktası: (800, 1450) → ekran sınırlarından uzakta.
```

---

## PBT Özellikleri

Aşağıdaki özellikler `test/test_amasya_svg_validity.gd` dosyasına eklenebilir:

### SVG Geçerlilik Özellikleri

**Validates: Requirements 1.3, 3.1, 3.2, 3.3, 3.4**

```
forall svg in assets/art/world/amasya/*.svg:
  svg.contains('xmlns="http://www.w3.org/2000/svg"')
  svg.path_count in [2, 5]
  svg.unique_colors <= 5
  svg.file_size < 50_000  # bytes
  svg.has_no_style_attribute
  svg.has_no_text_element
  svg.uses_only_absolute_commands  # M, L, C, Q, A, Z
  svg.has_no_forbidden_elements    # rect, circle, ellipse, g, use, symbol
```

### Gölge Path Özellikleri

**Validates: Requirements 2.2**

```
forall svg in assets/art/world/amasya/*.svg:
  shadow_paths = svg.paths.filter(p => p.fill in ['#1a2a3a', '#2b2730'] and p.opacity)
  forall sp in shadow_paths:
    sp.opacity in [0.14, 0.22]
    sp.index == 0  # gölge her zaman ilk path
```

### viewBox Boyut Özellikleri

**Validates: Requirements 1.2, 4.3, 5.3, 6.3, 7.5, 8.2**

```
expected_viewboxes = {
  "paper_sky_amasya.svg":        "0 0 1500 760",
  "paper_terrain_amasya.svg":    "0 0 800 600",
  "paper_main_path.svg":         "0 0 920 900",
  "paper_congress_hall.svg":     "0 0 600 400",
  "paper_foreground_frame.svg":  "0 0 1600 780",
}
forall (filename, expected) in expected_viewboxes:
  svg = load(filename)
  svg.viewBox == expected
```

### Builder Özellikleri

**Validates: Requirements 10.4, 11.1, 11.3, 12.1**

```
forall call in _build_amasya_world():
  sprite2d_count + polygon2d_count < 60
  no _process() call
  world_built signal emitted with "amasya" after _decorate_amasya()

forall asset in amasya_assets:
  asset.position.x in [-100, 1700]
  asset.position.y in [-100, 2300]
  asset.has_meta('base_pos')
  asset.has_meta('asset_slot')
```

### Textures Registry Özellikleri

**Validates: Requirements 9.1, 9.3**

```
amasya_svg_files = glob('assets/art/world/amasya/*.svg')
amasya_constants = textures_gd.constants.filter(c => c.name.starts_with('AMASYA_PAPER_'))
amasya_constants.count == amasya_svg_files.count

forall const in amasya_constants:
  const.path.starts_with('res://assets/art/world/amasya/')

world_builder_gd.has_no_direct_preload('res://assets/art/world/amasya/')
```

---

## Uygulama Sırası

1. **5 SVG asset'i yükselt** — her dosyayı yalnızca `<path>` elementleriyle yeniden yaz (Wave 0)
2. **Checkpoint** — 5 SVG dosyasını doğrula (Wave 1)
3. **`textures.gd` güncelle** — 5 `AMASYA_PAPER_*` sabiti ekle (Wave 2)
4. **`_add_amasya_paper_asset_layer()` oluştur** — 5 asset çağrısı (Wave 2)
5. **`_build_amasya_world()` güncelle** — `_add_amasya_paper_asset_layer()` ve `emit_signal` ekle (Wave 2)
6. **SVG geçerlilik testleri** — `test/test_amasya_svg_validity.gd` oluştur (Wave 3)
7. **Final checkpoint** — tüm testler geçmeli (Wave 4)

---

## Referanslar

- `scripts/world_builder.gd` — `_build_amasya_world()`, `_decorate_amasya()`, `_add_paper_cutout_asset()`
- `scripts/textures.gd` — `AMASYA_PAPER_*` sabitleri (eklenecek)
- `scripts/colors.gd` — `DESIGN_STORY_INK`, `POP_GOLD`, `PAPER_SHADOW`, `POP_CRIMSON`
- `.kiro/specs/samsun-asset-kit/design.md` — Paper diorama üretim standardı referansı
- `.kiro/specs/havza-asset-kit/design.md` — SVG üretim şablonu referansı
- `.kiro/specs/amasya-asset-kit/requirements.md` — Gereksinimler
