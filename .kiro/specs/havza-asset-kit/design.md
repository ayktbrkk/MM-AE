# Teknik Tasarım — Havza Asset Kit

## Genel Bakış

Bu belge, `havza` bölgesi için paper diorama asset kitinin teknik tasarımını tanımlar. Mevcut `_build_havza_world()` fonksiyonu yalnızca `_add_rect()` ve `_add_rift_cloud()` çağrıları içermektedir; bu spec'in amacı 5 SVG dosyasını paper diorama üretim standardına yükseltmek, `textures.gd` içine `HAVZA_PAPER_*` sabitlerini eklemek ve `_build_havza_world()` içine `_add_havza_paper_asset_layer()` çağrısını entegre etmektir.

Havza bölgesi, 1919 Anadolu kasabası atmosferini taşır: dusty afternoon, earthy olive-green tepeler, cream cobblestone yollar, kasaba meydanı çeşmesi.

---

## Mevcut Durum

### `_build_havza_world()` Mevcut Yapısı

```gdscript
func _build_havza_world(world_root: Node) -> void:
    _add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.10, 0.17, 0.13))
    _add_rect(world_root, Vector2(90, 170), Vector2(1420, 1840), Color(0.20, 0.28, 0.18))
    _add_rect(world_root, Vector2(180, 320), Vector2(1240, 1460), Color(0.30, 0.40, 0.24))
    _add_rect(world_root, Vector2(310, 1490), Vector2(290, 230), Color(0.18, 0.30, 0.34))
    _add_rect(world_root, Vector2(1020, 1440), Vector2(270, 250), Color(0.35, 0.30, 0.20))
    _add_rift_cloud(world_root, Vector2(790, 1100), 760, Color(0.95, 0.80, 0.26, 0.12))
    _add_rift_cloud(world_root, Vector2(790, 1100), 900, Color(0.28, 0.50, 0.42, 0.12))
    _decorate_havza(world_root)
```

**Mevcut `textures.gd`'de HAVZA_PAPER_* sabiti yok** — tüm sabitler bu spec kapsamında sıfırdan oluşturulacak.

### Hedef `_build_havza_world()` Yapısı

```gdscript
func _build_havza_world(world_root: Node) -> void:
    _add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.10, 0.17, 0.13))
    _add_havza_paper_asset_layer(world_root)  # YENİ
    _decorate_havza(world_root)
    emit_signal("world_built", "havza")       # YENİ
```

---

## SVG Asset Üretim Planı

### 1. `paper_sky_havza.svg` (1500×760)

**Açıklama:** Dusty afternoon gökyüzü. Earthy brown üst bant, atmosfer geçiş bandı, güneş ışıltısı.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.18 | Gökyüzü kenar gölgesi |
| 2 — Gökyüzü | `<path>` | `#685934` | Ana gökyüzü yüzeyi |
| 3 — Atmosfer bandı | `<path>` | `#D4C5A9` opacity 0.55 | Ufuk geçiş bandı |
| 4 — Güneş ışıltısı | `<path>` | `#F2BE63` opacity 0.30 | Sıcak güneş vurgusu |

**Path sayısı:** 3–4 | **viewBox:** `0 0 1500 760`

---

### 2. `paper_terrain_town.svg` (800×600)

**Açıklama:** Warm tan kasaba arazisi. Organik zemin şekli, sage green bitki örtüsü katmanı, altın vurgu.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.16 | Arazi kenar gölgesi |
| 2 — Arazi | `<path>` | `#D4C5A9` | Ana arazi yüzeyi |
| 3 — Bitki örtüsü | `<path>` | `#8DB572` opacity 0.60 | Sage green katman |
| 4 — Altın vurgu | `<path>` | `#F2BE63` opacity 0.22 | Güneş yansıması |

**Path sayısı:** 4 | **viewBox:** `0 0 800 600`

---

### 3. `paper_main_path.svg` (920×900)

**Açıklama:** Kıvrımlı cream cobblestone patika ve dallanmaları. Organik yol şekli, sage green kenar vurgusu.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.14 | Patika kenar gölgesi |
| 2 — Ana patika | `<path>` | `#E8DFC8` | Cream cobblestone yüzeyi |
| 3 — Dallanma | `<path>` | `#D4C5A9` opacity 0.80 | Yan yol dallanması |
| 4 — Patika vurgusu | `<path>` | `#8DB572` opacity 0.25 | Kenar bitki örtüsü |
| 5 — İkinci dallanma (opsiyonel) | `<path>` | `#E8DFC8` opacity 0.70 | Ek yol kolu |

**Path sayısı:** 4–5 | **viewBox:** `0 0 920 900`

---

### 4. `paper_civic_square.svg` (600×400)

**Açıklama:** Kasaba meydanı: çeşme, ağaçlar, NPC siluetleri. Cream zemin, tan çeşme, sage green ağaçlar.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.16 | Meydan kenar gölgesi |
| 2 — Zemin | `<path>` | `#E8DFC8` | Cream meydan zemini |
| 3 — Çeşme/Anıt | `<path>` | `#D4C5A9` | Kasaba çeşmesi silueti |
| 4 — Ağaçlar | `<path>` | `#8DB572` | Sage green ağaç siluetleri |
| 5 — NPC siluetleri | `<path>` | `#2B2730` opacity 0.30 | İnsan figürleri |

**Path sayısı:** 4–5 | **viewBox:** `0 0 600 400`

---

### 5. `paper_foreground_frame.svg` (1600×780)

**Açıklama:** Ön plan çerçeve: sol ağaç dalları, sağ bina siluetleri, zemin bandı. Yüksek opaklık, diorama derinliği.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Sol ağaç silueti | `<path>` | `#1A2A3A` opacity 0.90 | Sol kenar ağaç dalları |
| 2 — Sağ bina silueti | `<path>` | `#2B2730` opacity 0.88 | Sağ kenar bina silueti |
| 3 — Zemin bandı | `<path>` | `#685934` opacity 0.86 | Alt zemin bandı |

**Path sayısı:** 3 | **viewBox:** `0 0 1600 780`

---

## Renk Paleti

| Sabit | Hex | Kullanım |
|-------|-----|---------|
| `HAVZA_SKY_DUST` | `#685934` | Gökyüzü, zemin bandı |
| `HAVZA_TERRAIN_TAN` | `#D4C5A9` | Arazi, çeşme, atmosfer |
| `HAVZA_SAGE_GREEN` | `#8DB572` | Bitki örtüsü, ağaçlar, patika kenarı |
| `HAVZA_CREAM_PATH` | `#E8DFC8` | Patika, meydan zemini |
| `DESIGN_STORY_INK` | `#2B2730` | Outline, NPC siluetleri, bina |
| `POP_GOLD` | `#F2BE63` | Güneş ışıltısı, vurgu |
| `PAPER_SHADOW` | `#1A2A3A` | Gölge katmanları, ön plan |

---

## SVG Üretim Standardı

Her SVG dosyası şu şablonu takip eder:

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="W" height="H" viewBox="0 0 W H">
  <!-- Katman 1: Gölge -->
  <path d="M..." fill="#1a2a3a" opacity="0.18"/>
  <!-- Katman 2: Ana şekil -->
  <path d="M..." fill="[HAVZA paleti rengi]"/>
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

`_add_havza_paper_asset_layer()` fonksiyonundaki çağrılar için hedef değerler:

| Asset Dosyası | Sabit | Pozisyon | Scale | Opaklık | Z-Index | Parallax | Slot ID |
|--------------|-------|----------|-------|---------|---------|----------|---------|
| `paper_sky_havza.svg` | `HAVZA_PAPER_SKY_TEXTURE` | (800, 380) | 1.05 | 0.88 | -18 | -15.0 | `havza.depth.sky` |
| `paper_terrain_town.svg` | `HAVZA_PAPER_TERRAIN_TEXTURE` | (800, 1100) | 1.10 | 0.90 | -14 | -3.5 | `havza.depth.terrain` |
| `paper_main_path.svg` | `HAVZA_PAPER_MAIN_PATH_TEXTURE` | (800, 1300) | 0.82 | 0.86 | -10 | -1.5 | `havza.path.main` |
| `paper_civic_square.svg` | `HAVZA_PAPER_CIVIC_SQUARE_TEXTURE` | (800, 1450) | 0.88 | 0.84 | -5 | 2.0 | `havza.landmark.civic_square` |
| `paper_foreground_frame.svg` | `HAVZA_PAPER_FOREGROUND_FRAME_TEXTURE` | (800, 1850) | 1.12 | 0.90 | 4 | 18.0 | `havza.foreground.frame` |

---

## `_add_havza_paper_asset_layer()` Hedef Implementasyonu

```gdscript
func _add_havza_paper_asset_layer(world_root: Node) -> void:
    # Gökyüzü — en uzak katman
    _add_paper_cutout_asset(
        world_root, _textures.HAVZA_PAPER_SKY_TEXTURE,
        Vector2(800, 380), Vector2(1.05, 1.05),
        Color(1, 1, 1, 0.88), -18,
        "havza.depth.sky", Vector2.ZERO, -15.0
    )
    # Arazi — kasaba zemin katmanı
    _add_paper_cutout_asset(
        world_root, _textures.HAVZA_PAPER_TERRAIN_TEXTURE,
        Vector2(800, 1100), Vector2(1.10, 1.10),
        Color(1, 1, 1, 0.90), -14,
        "havza.depth.terrain", Vector2.ZERO, -3.5
    )
    # Ana patika — kıvrımlı yol
    _add_paper_cutout_asset(
        world_root, _textures.HAVZA_PAPER_MAIN_PATH_TEXTURE,
        Vector2(800, 1300), Vector2(0.82, 0.82),
        Color(1, 1, 1, 0.86), -10,
        "havza.path.main", Vector2.ZERO, -1.5
    )
    # Kasaba meydanı — civic landmark
    _add_paper_cutout_asset(
        world_root, _textures.HAVZA_PAPER_CIVIC_SQUARE_TEXTURE,
        Vector2(800, 1450), Vector2(0.88, 0.88),
        Color(1, 1, 1, 0.84), -5,
        "havza.landmark.civic_square", Vector2.ZERO, 2.0
    )
    # Ön plan çerçeve — en yakın katman
    _add_paper_cutout_asset(
        world_root, _textures.HAVZA_PAPER_FOREGROUND_FRAME_TEXTURE,
        Vector2(800, 1850), Vector2(1.12, 1.12),
        Color(1, 1, 1, 0.90), 4,
        "havza.foreground.frame", Vector2.ZERO, 18.0
    )
```

---

## `textures.gd` Güncellemesi

Mevcut `textures.gd` dosyasına yeni bölüm eklenir:

```gdscript
# ====================================
# HAVZA PAPER CUTOUT (özel asset)
# ====================================
const HAVZA_PAPER_SKY_TEXTURE := preload("res://assets/art/world/havza/paper_sky_havza.svg")
const HAVZA_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/havza/paper_terrain_town.svg")
const HAVZA_PAPER_MAIN_PATH_TEXTURE := preload("res://assets/art/world/havza/paper_main_path.svg")
const HAVZA_PAPER_CIVIC_SQUARE_TEXTURE := preload("res://assets/art/world/havza/paper_civic_square.svg")
const HAVZA_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/havza/paper_foreground_frame.svg")
```

---

## Mimari

### Değişmeyecek Yapı

- `_decorate_havza()` fonksiyon imzası ve içeriği
- `_add_paper_cutout_asset()` çağrı parametreleri ve meta sistemi
- `world_marker.gd` marker sistemi
- Mevcut `_add_rect()` ve `_add_rift_cloud()` çağrıları (base background için korunabilir)

### Değişecek Yapı

- `assets/art/world/havza/` dizinindeki 5 SVG dosyasının içeriği (yalnızca `<path>` elementleri)
- `scripts/textures.gd` — 5 yeni `HAVZA_PAPER_*` sabiti eklenir
- `scripts/world_builder.gd` — `_add_havza_paper_asset_layer()` fonksiyonu eklenir
- `scripts/world_builder.gd` — `_build_havza_world()` içine `_add_havza_paper_asset_layer(world_root)` ve `emit_signal("world_built", "havza")` eklenir

---

## Performans Tasarımı

### Node Sayısı Analizi

`_add_havza_paper_asset_layer()` 5 `_add_paper_cutout_asset()` = **5 Sprite2D node**.

`_decorate_havza()` ek node'lar ekler (rift cloud'lar, soft blob'lar vb.) — toplam ~30 node, limit 60'ın çok altında.

### Tween Animasyon Kuralı

- `_add_paper_cutout_asset()` `ambient_bob` meta değeri → `world_player.gd` tarafından Tween ile yönetilir
- `_build_havza_world()` içinde `_process()` çağrısı yok
- `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturulmaz

### Bellek Yönetimi

`clear_world()` çağrıldığında `"paperworld.havza_"` önekli tüm node'lar `queue_free()` ile temizlenir — mevcut `_add_paper_cutout_asset()` implementasyonu bu slot_id sistemini kullanıyor.

---

## Portrait 9:16 Kompozisyon

```
WORLD_SIZE = Vector2(1600, 2200)
Kamera zoom = 0.9

Görünür alan (zoom 0.9): ~1778 × 2133 px

Kritik asset pozisyonları:
  sky:           (800, 380)   → arka gökyüzü, tam ekran
  terrain:       (800, 1100)  → zemin katmanı
  main_path:     (800, 1300)  → patika, merkez
  civic_square:  (800, 1450)  → kasaba meydanı, merkez
  foreground:    (800, 1850)  → ön plan, kenarlar kapalı

Tüm asset'ler zoom=0.9'da ekran içinde, kenardan ≥50px uzakta.
paper_civic_square merkez noktası: (800, 1450) → ekran sınırlarından uzakta.
```

---

## PBT Özellikleri

Aşağıdaki özellikler `test/test_havza_svg_validity.gd` dosyasına eklenebilir:

### SVG Geçerlilik Özellikleri

**Validates: Requirements 1.3, 3.1, 3.2, 3.3, 3.4**

```
forall svg in assets/art/world/havza/*.svg:
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
forall svg in assets/art/world/havza/*.svg:
  shadow_paths = svg.paths.filter(p => p.fill in ['#1a2a3a', '#2b2730'] and p.opacity)
  forall sp in shadow_paths:
    sp.opacity in [0.14, 0.22]
    sp.index == 0  # gölge her zaman ilk path
```

### viewBox Boyut Özellikleri

**Validates: Requirements 1.2, 4.3, 5.3, 6.3, 7.5, 8.2**

```
expected_viewboxes = {
  "paper_sky_havza.svg":         "0 0 1500 760",
  "paper_terrain_town.svg":      "0 0 800 600",
  "paper_main_path.svg":         "0 0 920 900",
  "paper_civic_square.svg":      "0 0 600 400",
  "paper_foreground_frame.svg":  "0 0 1600 780",
}
forall (filename, expected) in expected_viewboxes:
  svg = load(filename)
  svg.viewBox == expected
```

### Builder Özellikleri

**Validates: Requirements 10.4, 11.1, 11.3, 12.1**

```
forall call in _build_havza_world():
  sprite2d_count + polygon2d_count < 60
  no _process() call
  world_built signal emitted with "havza" after _decorate_havza()

forall asset in havza_assets:
  asset.position.x in [-100, 1700]
  asset.position.y in [-100, 2300]
  asset.has_meta('base_pos')
  asset.has_meta('asset_slot')
```

### Textures Registry Özellikleri

**Validates: Requirements 9.1, 9.3**

```
havza_svg_files = glob('assets/art/world/havza/*.svg')
havza_constants = textures_gd.constants.filter(c => c.name.starts_with('HAVZA_PAPER_'))
havza_constants.count == havza_svg_files.count

forall const in havza_constants:
  const.path.starts_with('res://assets/art/world/havza/')

world_builder_gd.has_no_direct_preload('res://assets/art/world/havza/')
```

---

## Uygulama Sırası

1. **5 SVG asset'i yükselt** — her dosyayı yalnızca `<path>` elementleriyle yeniden yaz (Wave 0)
2. **Checkpoint** — 5 SVG dosyasını doğrula (Wave 1)
3. **`textures.gd` güncelle** — 5 `HAVZA_PAPER_*` sabiti ekle (Wave 2)
4. **`_add_havza_paper_asset_layer()` oluştur** — 5 asset çağrısı (Wave 2)
5. **`_build_havza_world()` güncelle** — `_add_havza_paper_asset_layer()` ve `emit_signal` ekle (Wave 2)
6. **SVG geçerlilik testleri** — `test/test_havza_svg_validity.gd` oluştur (Wave 3)
7. **Final checkpoint** — tüm testler geçmeli (Wave 4)

---

## Referanslar

- `scripts/world_builder.gd` — `_build_havza_world()`, `_decorate_havza()`, `_add_paper_cutout_asset()`
- `scripts/textures.gd` — `HAVZA_PAPER_*` sabitleri (eklenecek)
- `scripts/colors.gd` — `DESIGN_STORY_INK`, `POP_GOLD`, `PAPER_SHADOW`
- `.kiro/specs/samsun-asset-kit/design.md` — Paper diorama üretim standardı referansı
- `.kiro/specs/room-asset-kit/design.md` — SVG üretim şablonu referansı
- `.kiro/specs/havza-asset-kit/requirements.md` — Gereksinimler
