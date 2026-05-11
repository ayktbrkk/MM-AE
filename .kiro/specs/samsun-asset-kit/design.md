# Teknik Tasarım — Samsun Asset Kit

## Genel Bakış

Bu belge, `samsun_rift` bölgesi için paper diorama asset kitinin teknik tasarımını tanımlar. Mevcut `_build_samsun_rift()` → `_decorate_samsun_rift()` → `_decorate_samsun_diorama_pilot()` → `_add_samsun_paper_asset_layer()` zinciri **zaten çalışıyor**; bu spec'in amacı mevcut SVG asset'lerin kalitesini artwork referanslarına uygun şekilde yükseltmek ve eksik asset'leri tamamlamaktır.

### Mevcut Durum

```
_build_samsun_rift(world_root)
  └── _add_rect(...)                    # base background
  └── _add_samsun_ground_plates(...)    # eski plate sistemi (korunacak)
  └── _decorate_samsun_rift(world_root)
        └── _decorate_samsun_diorama_pilot(world_root)
              └── _add_samsun_paper_asset_layer()   # 24 asset, textures.gd'den
              └── _add_samsun_atmosphere_washes()
              └── _add_samsun_light_pools()
              └── ... (diğer dekorasyon fonksiyonları)
```

**Mevcut `textures.gd`'de 25 SAMSUN_PAPER_* sabiti var** — tümü `assets/art/world/samsun/` dizinindeki SVG dosyalarına işaret ediyor. Bu spec kapsamında SVG dosyalarının içeriği yükseltilecek, kod yapısı korunacak.

---

## Mimari

### Değişmeyecek Yapı

- `_build_samsun_rift()` fonksiyon imzası ve çağrı zinciri
- `textures.gd` sabit isimleri (`SAMSUN_PAPER_*`)
- `colors.gd` `THEME_SAMSUN` ve `RIFT_BLUE` sabitleri (zaten mevcut)
- `_add_paper_cutout_asset()` çağrı parametreleri ve z-index değerleri
- `world_marker.gd` marker sistemi

### Değişecek Yapı

- `assets/art/world/samsun/` dizinindeki 25 SVG dosyasının içeriği (görsel kalite yükseltme)
- `_build_samsun_rift()` içindeki `_add_samsun_ground_plates()` çağrısı — paper asset layer ile çakışan eski plate'ler kaldırılacak veya z-index'leri düzeltilecek

---

## SVG Asset Üretim Planı

### Parallax Katman Tablosu

Mevcut `_add_samsun_paper_asset_layer()` fonksiyonundaki çağrılardan türetilmiştir:

| Asset Dosyası | Pozisyon | Scale | Opaklık | Z-Index | Parallax |
|--------------|----------|-------|---------|---------|----------|
| `paper_sky_samsun.svg` | (800, 380) | 1.0 | 0.50 | -18 | -20.0 |
| `paper_sky_life.svg` | (800, 360) | 1.08 | 0.62 | -17 | -18.0 |
| `paper_distant_town.svg` | (800, 565) | 1.05 | 0.62 | -16 | -13.0 |
| `paper_skyline_depth.svg` | (805, 615) | 1.08 | 0.70 | -15 | -10.0 |
| `paper_harbor_water.svg` | (390, 760) | 0.84 | 0.76 | -14 | -8.0 |
| `paper_coast_details.svg` | (790, 825) | 1.0 | 0.66 | -13 | -6.0 |
| `paper_terrain_island.svg` | (794, 1114) | 1.18 | 0.94 | -15 | -3.5 |
| `paper_side_paths.svg` | (760, 1160) | 1.06 | 0.64 | -12 | -2.0 |
| `paper_main_path.svg` | (726, 1370) | 0.78 | 0.86 | -13 | -1.5 |
| `paper_harbor_dock_props.svg` | (392, 820) | 0.96 | 0.78 | -7 | 2.5 |
| `paper_coastal_life.svg` | (940, 1015) | 1.02 | 0.66 | -7 | 3.0 |
| `paper_route_beads.svg` | (775, 1250) | 1.02 | 0.72 | -9 | 1.0 |
| `paper_safe_clearings.svg` | (805, 1335) | 1.0 | 0.66 | -8 | 1.5 |
| `paper_civic_cluster.svg` | (1015, 1360) | 0.58 | 0.72 | -6 | 2.0 |
| `paper_discovery_props.svg` | (795, 1110) | 0.92 | 0.72 | -4 | 3.0 |
| `paper_harbor_boats.svg` | (360, 650) | 0.82 | 0.72 | -5 | 3.0 |
| `paper_signal_ridge.svg` | (1130, 660) | 0.78 | 0.62 | -6 | -5.0 |
| `paper_vista_flags.svg` | (800, 900) | 0.98 | 0.76 | -4 | 4.5 |
| `paper_harbor_landmark.svg` | (360, 760) | 0.86 | 0.90 | -3 | 4.0 |
| `paper_telegraph_landmark.svg` | (1190, 770) | 0.78 | 0.88 | -3 | 4.0 |
| `paper_people_plaza.svg` | (530, 1455) | 0.78 | 0.90 | -3 | 5.0 |
| `paper_rift_core.svg` | (800, 980) | 0.72 | 0.90 | -2 | 5.0 |
| `paper_wave_gate.svg` | (820, 1478) | 0.76 | 0.86 | -2 | 5.0 |
| `paper_map_compass.svg` | (1280, 240) | 0.48 | 0.34 | 2 | 12.0 |
| `paper_foreground_frame.svg` | (800, 1835) | 1.34 | 0.88 | 4 | 18.0 |

### SVG Üretim Standardı

Her SVG dosyası şu şablonu takip eder:

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="W" height="H" viewBox="0 0 W H">
  <!-- Katman 1: Gölge -->
  <path d="M..." fill="#10202d" opacity="0.22"/>
  <!-- Katman 2: Ana şekil -->
  <path d="M..." fill="[THEME_SAMSUN rengi]"/>
  <!-- Katman 3: Vurgu (opsiyonel) -->
  <path d="M..." fill="[vurgu]" opacity="0.65"/>
  <!-- Katman 4: Outline (opsiyonel) -->
  <path d="M..." fill="none" stroke="#2B2730" stroke-width="10"/>
</svg>
```

**Kurallar:**
- Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
- `style` attribute veya `<defs>` yok
- `<text>` veya `<tspan>` yok
- `<image>`, `<use>`, `<symbol>` yok
- Maksimum 5 benzersiz renk değeri (rift ve bayrak asset'leri hariç)
- Disk boyutu < 50 KB

### Renk Paleti (THEME_SAMSUN)

| Sabit | Hex | Kullanım |
|-------|-----|---------|
| `POP_DEEP_TURQUOISE` | `#067078` | Gökyüzü, deniz ana rengi |
| `POP_GOLD` | `#FFB340` | Vurgu, güneş ışığı |
| `DESIGN_CREAM_PAPER` | `#F5E8D3` | Zemin, yol, krem tonlar |
| `PAPER_SHADOW` | `#10202d` | Gölge katmanları |
| `DESIGN_STORY_INK` | `#2B2730` | Outline, NPC siluetleri |
| `RIFT_BLUE` | `#38C7FF` | Rift çekirdeği efekti |
| `POP_CRIMSON` | `#B82E1F` | Türk bayrağı |

---

## Asset Grubu Tasarımları

### 1. Gökyüzü Grubu

**`paper_sky_samsun.svg`** (1800×900)
- Sabah ışığı: üst bant `#067078` (turkuaz), alt bant `#F5E8D3` (krem)
- En az 2 yatay bant `<path>` elementi
- viewBox genişliği > 1600px (kamera hareketi için overscan)

**`paper_sky_life.svg`** (1800×600)
- Martı siluetleri, hafif bulut şekilleri
- Düşük opaklık (0.40-0.60), uzaklık hissi

**`paper_distant_town.svg`** (1600×500)
- Kule, kubbe, bayrak direği siluetleri
- `opacity: 0.40-0.60` — uzak şehir derinliği

**`paper_skyline_depth.svg`** (1600×400)
- Orta derinlik şehir silueti
- `opacity: 0.55-0.70`

### 2. Deniz ve Kıyı Grubu

**`paper_harbor_water.svg`** (900×600)
- Turkuaz deniz yüzeyi (`#067078` ailesi)
- En az 3 yatay dalga bandı, farklı opaklıklar: 0.40, 0.60, 0.80

**`paper_coast_details.svg`** (1200×500)
- Kıyı taşları, kayalık detaylar
- Organik path şekilleri

**`paper_harbor_dock_props.svg`** (700×400)
- İskele platformu, halat, sandık detayları

**`paper_coastal_life.svg`** (800×400)
- Kıyı bitki örtüsü, küçük detaylar

### 3. Arazi Grubu

**`paper_terrain_island.svg`** (1400×800)
- Ana zemin katmanı, organik ada şekli
- `DESIGN_CREAM_PAPER` ve `ART_SAND_BEIGE` tonları
- Kalın outline: `stroke-width: 12`

**`paper_side_paths.svg`** (1200×600)
- Yan patikalar, yol dallanmaları

**`paper_main_path.svg`** (900×700)
- Kıvrımlı taş yol (artwork'teki gibi)
- Krem/bej tonlar, taş doku hissi

### 4. Landmark Grubu

**`paper_harbor_landmark.svg`** (600×500)
- İskele platformu + 1 sandık + 1 vapur silüeti + 1 deniz feneri
- Her öğe ayrı `<path>` elementi
- `<metadata><slot_id>samsun.harbor_landmark</slot_id></metadata>`

**`paper_telegraph_landmark.svg`** (500×600)
- Telgraf direği + küçük bina (direğin max %50 yüksekliği) + bayrak direği
- `<metadata><slot_id>samsun.telegraph_landmark</slot_id></metadata>`

**`paper_people_plaza.svg`** (700×600)
- 1 heykel (kaide + figür) + 1 bank + 1 ağaç + 2 NPC silueti
- NPC: `fill="#2B2730"`, tek `<path>`, iç detay yok
- `<metadata><slot_id>samsun.people_plaza</slot_id></metadata>`

**`paper_rift_core.svg`** (400×400)
- Merkezi kristal `<path>` + 2 enerji halkası `<path>` + ışıltı `<path>` = tam 4 `<path>`
- Enerji halkaları: `fill="#53c6df"`, `opacity: 0.58-0.82`
- Kristal çekirdek: `fill="#f9eec5"`, `opacity: 0.70-0.82`
- `<metadata><slot_id>samsun.rift_core</slot_id></metadata>`

### 5. Dekoratif Grup

**`paper_harbor_boats.svg`** (600×300)
- 1 sandal `<path>` + 1 martı `<path>`
- Liman asset'leriyle birlikte görsel bütünlük sağlar

**`paper_signal_ridge.svg`** (500×400)
- Sinyal tepesi, uzak siluet

**`paper_vista_flags.svg`** (600×400)
- 1 Türk bayrağı + 1 flama
- Bayrak: `fill="#B82E1F"` (POP_CRIMSON)
- Core palette + ek kırmızı renk (additive permission)

**`paper_route_beads.svg`** (800×300)
- Rota boncukları, yol işaretçileri

**`paper_safe_clearings.svg`** (700×400)
- Güvenli açıklık alanları

**`paper_civic_cluster.svg`** (500×400)
- Sivil bina kümesi

**`paper_discovery_props.svg`** (600×400)
- Keşif prop'ları

**`paper_wave_gate.svg`** (600×400)
- Dalga kapısı, geçiş noktası

**`paper_map_compass.svg`** (300×300)
- Dekoratif pusula, harita hissi
- Düşük opaklık (0.34) — arka plan detayı

**`paper_foreground_frame.svg`** (1800×600)
- Ön plan silüetleri, ekran kenarlarını kapatır
- viewBox genişliği ≥ 1600px
- `fill="#2B2730"` veya `fill="#10202d"`, `opacity > 0.85`

---

## Kod Değişiklikleri

### `_build_samsun_rift()` Güncellemesi

Mevcut fonksiyon:
```gdscript
func _build_samsun_rift(world_root: Node) -> void:
    _add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.04, 0.11, 0.22))
    _add_samsun_ground_plates(world_root)
    _decorate_samsun_rift(world_root)
```

Hedef fonksiyon (ground plates kaldırılır, paper asset layer yeterli):
```gdscript
func _build_samsun_rift(world_root: Node) -> void:
    # Base background — koyu deniz rengi
    _add_rect(world_root, Vector2.ZERO, WORLD_SIZE, _colors.THEME_SAMSUN["bg"])
    # Paper asset layer + dekorasyon
    _decorate_samsun_rift(world_root)
    emit_signal("world_built", "samsun_rift")
```

**Not:** `_add_samsun_ground_plates()` kaldırılır çünkü `_add_samsun_paper_asset_layer()` tüm zemin katmanlarını SVG olarak sağlar. Eski plate'ler SVG'lerle çakışıyor.

### `_decorate_samsun_rift()` — Sinyal Zamanlaması

```gdscript
func _decorate_samsun_rift(world_root: Node) -> void:
    _decorate_samsun_diorama_pilot(world_root)
    # world_built sinyali _build_samsun_rift() içinde,
    # _decorate_samsun_rift() tamamlandıktan SONRA yayılır
```

### `_decorate_samsun_diorama_pilot()` — Marker Işıltıları

Mevcut fonksiyona eklenmesi gereken marker ışıltıları:

```gdscript
# Harbor landmark — başlangıç noktası (POP_GOLD)
_add_soft_blob(_cached_world_root, Vector2(360, 760),
    Vector2(100, 60), _colors.POP_GOLD, 20, 0.0, false, -2)

# Telegraph landmark — durak noktası (RIFT_BLUE)
_add_soft_blob(_cached_world_root, Vector2(1190, 770),
    Vector2(100, 60), _colors.RIFT_BLUE, 20, 0.0, false, -2)

# People plaza — görev noktası (POP_CRIMSON)
_add_soft_blob(_cached_world_root, Vector2(530, 1455),
    Vector2(110, 65), _colors.POP_CRIMSON, 20, 0.0, false, -2)
```

**Not:** `_add_soft_blob()` son parametresi `animate: bool` — `false` olarak ayarlanır (statik glow, Timer/process yok).

### `colors.gd` — Mevcut Durum

`THEME_SAMSUN` ve `RIFT_BLUE` **zaten mevcut**:

```gdscript
const RIFT_BLUE := Color(0.22, 0.78, 1.0)  # #38C7FF — zaten var

const THEME_SAMSUN := {
    "bg": POP_DEEP_TURQUOISE,
    "accent": POP_GOLD,
    "panel": DESIGN_CREAM_PAPER,
    "shadow": PAPER_SHADOW,
    "text": DESIGN_STORY_INK,
}  # zaten var
```

**Değişiklik gerekmez.** Gereksinim 5 zaten karşılanmış durumda.

### `textures.gd` — Mevcut Durum

25 `SAMSUN_PAPER_*` sabiti **zaten mevcut**. Yeni SVG dosyası eklenmediği sürece değişiklik gerekmez. Eğer yeni dosya eklenirse, mevcut bölüm başlığı altına eklenir:

```gdscript
# ====================================
# SAMSUN PAPER CUTOUT (özel asset)
# ====================================
# ... mevcut sabitler ...
# Yeni sabit buraya eklenir
```

---

## Performans Tasarımı

### Node Sayısı Analizi

`_add_samsun_paper_asset_layer()` 24 `_add_paper_cutout_asset()` + 1 `_add_foreground_paper_cutout_asset()` = **25 Sprite2D node**.

`_decorate_samsun_diorama_pilot()` ek node'lar ekler (backdrop, props, NPC'ler vb.) — toplam ~55 node, limit 60'ın altında.

### Tween Animasyon Kuralı

- `_add_soft_blob()` son parametresi `animate: bool = false` → statik, Tween yok
- `_add_paper_cutout_asset()` `ambient_bob` meta değeri → `world_player.gd` tarafından Tween ile yönetilir
- `_build_samsun_rift()` içinde `_process()` çağrısı yok

### Bellek Yönetimi

`clear_world()` çağrıldığında `"paperworld.samsun_"` önekli tüm node'lar `queue_free()` ile temizlenir — mevcut `_add_paper_cutout_asset()` implementasyonu bu slot_id sistemini kullanıyor.

---

## Portrait 9:16 Kompozisyon

```
WORLD_SIZE = Vector2(1600, 2200)
Kamera zoom = 0.9

Görünür alan (zoom 0.9): ~1778 × 2133 px

Kritik landmark pozisyonları:
  harbor_landmark:    (360, 760)   → sol-üst bölge
  telegraph_landmark: (1190, 770)  → sağ-üst bölge
  people_plaza:       (530, 1455)  → sol-orta bölge
  rift_core:          (800, 980)   → merkez

Tüm landmark'lar zoom=0.9'da ekran içinde, kenardan ≥50px uzakta.
```

---

## Property-Based Testing (PBT) Özellikleri

Aşağıdaki özellikler `test/` klasöründeki E2E testlerine eklenebilir:

### SVG Geçerlilik Özellikleri

```
∀ svg ∈ assets/art/world/samsun/*.svg:
  svg.contains('xmlns="http://www.w3.org/2000/svg"')
  svg.path_count ∈ [2, 5]
  svg.unique_colors ≤ 5  (rift ve bayrak hariç)
  svg.file_size < 50_000 bytes
  svg.has_no_style_attribute
  svg.has_no_text_element
  svg.uses_only_absolute_commands  (M, L, C, Q, A, Z)
```

### Builder Özellikleri

```
∀ call ∈ _build_samsun_rift():
  sprite2d_count + polygon2d_count < 60
  no _process() call
  world_built signal emitted after _decorate_samsun_rift()

∀ asset ∈ samsun_assets:
  asset.position.x ∈ [-100, 1700]
  asset.position.y ∈ [-100, 2300]
```

### Renk Özellikleri

```
RIFT_BLUE.r == 0.22
RIFT_BLUE.g == 0.78
RIFT_BLUE.b == 1.0

THEME_SAMSUN.keys() == ["bg", "accent", "panel", "shadow", "text"]
THEME_SAMSUN["bg"] == POP_DEEP_TURQUOISE
```

---

## Uygulama Sırası

1. **SVG asset'leri yükselt** — 25 dosya, artwork referanslarına göre
2. **`_build_samsun_rift()` güncelle** — ground plates kaldır, sinyal ekle
3. **`_decorate_samsun_diorama_pilot()` güncelle** — marker ışıltıları ekle
4. **Godot headless doğrulama** — import hataları yok
5. **E2E test** — node sayısı, sinyal zamanlaması, renk değerleri

---

## Referanslar

- `scripts/world_builder.gd` — `_build_samsun_rift()`, `_add_samsun_paper_asset_layer()`, `_decorate_samsun_diorama_pilot()`
- `scripts/textures.gd` — `SAMSUN_PAPER_*` sabitleri
- `scripts/colors.gd` — `THEME_SAMSUN`, `RIFT_BLUE`
- `docs/SCENE_DESIGN.md` — Samsun bölge tasarımı
- `docs/VISUAL_DESIGN_SYSTEM.md` — Paper diorama stili
- `docs/ART_ANALYSIS.md` — Renk paleti analizi
- `.kiro/specs/samsun-asset-kit/requirements.md` — Gereksinimler
