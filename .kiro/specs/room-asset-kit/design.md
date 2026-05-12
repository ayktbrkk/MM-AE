# Teknik Tasarım — Room Asset Kit

## Genel Bakış

Bu belge, `room` bölgesi için paper diorama asset kitinin teknik tasarımını tanımlar. Mevcut `_build_room()` → `_decorate_room()` zinciri çalışıyor; bu spec'in amacı `assets/art/world/room/` dizinindeki 10 SVG dosyasını Samsun Asset Kit ile belirlenen paper diorama üretim standardına yükseltmektir.

`room` bölgesi oyuncunun yolculuğuna başladığı ilk sahnedir: gece vakti, sıcak lamba ışığıyla aydınlatılmış, 1919 dönemine ait kitaplıklı ve masalı bir öğrenci yatak odası. Mevcut SVG dosyaları `<rect>`, `<circle>`, `<ellipse>`, `<g>` gibi yasak elementler içermektedir; bu spec kapsamında tüm dosyalar yalnızca `<path>` elementleri kullanılarak yeniden yazılacaktır.

---

## Mevcut Durum

### `_build_room()` Çağrı Zinciri

```
_build_room(world_root)
  └── _add_open_world_start_depth_pass(world_root)   # opening sahne arka planı (korunacak)
  └── _add_open_world_start_asset_layer(world_root)  # opening benchmark asset (korunacak)
  └── _snap_room_characters_to_floor(world_root)     # karakter konumlandırma
  └── _decorate_room(world_root)                     # atmosferik efektler
        └── _add_soft_blob(...)                      # sıcak ışık bloblari
        └── _add_light_pool(...)                     # merkez alan aydınlatması
        └── _add_mote_cluster(...)                   # altın tozu parçacıkları
```

**Mevcut `_add_room_paper_asset_layer()`** — şu an yalnızca 1 asset yüklüyor:

```gdscript
func _add_room_paper_asset_layer(world_root: Node) -> void:
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_WALL_TEXTURE,
        Vector2(800, 410), Vector2(1.0, 1.0), Color(1, 1, 1, 0.86), -6,
        "paperroom.wall_window", Vector2.ZERO, -2.0)
```

Bu spec kapsamında `_add_room_paper_asset_layer()` 10 asset'i yükleyecek şekilde genişletilecek ve `_build_room()` içinden çağrılacak.

### Mevcut `textures.gd` ROOM_PAPER_* Sabitleri

```gdscript
# ====================================
# ROOM PAPER CUTOUT (özel asset)
# ====================================
const ROOM_PAPER_WALL_TEXTURE := preload("res://assets/art/world/room/paper_wall_window.svg")
const ROOM_PAPER_STUDY_NOOK_TEXTURE := preload("res://assets/art/world/room/paper_study_nook.svg")
const ROOM_PAPER_FLOOR_RUG_TEXTURE := preload("res://assets/art/world/room/paper_floor_rug.svg")
const ROOM_PAPER_BOOK_PORTAL_TEXTURE := preload("res://assets/art/world/room/paper_book_portal.svg")
const ROOM_PAPER_SHELF_TEXTURE := preload("res://assets/art/world/room/paper_shelf.svg")
const ROOM_PAPER_BED_TEXTURE := preload("res://assets/art/world/room/paper_bed.svg")
const ROOM_PAPER_WALL_STORY_TEXTURE := preload("res://assets/art/world/room/paper_wall_story.svg")
const ROOM_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/room/paper_foreground_frame.svg")
const ROOM_PAPER_DESK_CLUTTER_TEXTURE := preload("res://assets/art/world/room/paper_desk_clutter.svg")
```

**Eksik sabit:** `ROOM_PAPER_TERRAIN_TEXTURE` (`paper_terrain_room.svg`) — bu spec kapsamında eklenecek.

---
## SVG Asset Üretim Planı

### 1. `paper_wall_window.svg` (1500×780)

**Açıklama:** Gece vakti oda duvarı ve penceresi. Koyu lacivert duvar yüzeyi, mavi-yeşil cam yüzeyli pencere çerçevesi, gece atmosferi gölgesi.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.18 | Duvar kenar gölgesi |
| 2 — Duvar | `<path>` | `#20344F` | Tüm viewBox'ı kaplayan arka plan |
| 3 — Pencere camı | `<path>` | `#47B2C2` opacity 0.72 | Dikdörtgen cam yüzeyi |
| 4 — Pencere çerçevesi | `<path>` | `#7A5A42` stroke | Ahşap çerçeve outline |

**Path sayısı:** 4 | **viewBox:** `0 0 1500 780`

---

### 2. `paper_wall_story.svg` (900×420)

**Açıklama:** Duvarda asılı 2–3 hikaye çerçevesi. Ceviz/mürekkep rengi çerçeve siluetleri, 1919 dönemi atmosferi.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#2b2730` opacity 0.16 | Çerçeve altı gölge |
| 2 — Çerçeve 1 | `<path>` | `#7A5A42` | Sol çerçeve silueti |
| 3 — Çerçeve 2 | `<path>` | `#2B2730` | Orta çerçeve silueti |
| 4 — Çerçeve 3 (opsiyonel) | `<path>` | `#7A5A42` opacity 0.80 | Sağ küçük çerçeve |

**Path sayısı:** 3–4 | **viewBox:** `0 0 900 420`

---

### 3. `paper_terrain_room.svg` (800×600)

**Açıklama:** Sıcak turuncu zemin yüzeyi. Organik zemin şekli, hafif doku hissi.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.14 | Zemin kenar gölgesi |
| 2 — Zemin | `<path>` | `#E89863` | Ana zemin yüzeyi |
| 3 — Zemin vurgusu | `<path>` | `#F2BE63` opacity 0.30 | Lamba ışığı yansıması |

**Path sayısı:** 3 | **viewBox:** `0 0 800 600`

---

### 4. `paper_shelf.svg` (520×760)

**Açıklama:** Ahşap kitaplık gövdesi ve üzerindeki kitap siluetleri. Dikey format, raf bölmeleri.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.20 | Kitaplık yan gölgesi |
| 2 — Gövde | `<path>` | `#7A5A42` | Kitaplık çerçevesi ve raflar |
| 3 — Kitaplar | `<path>` | `#F5E8D3` | Kitap sırtı siluetleri |
| 4 — Vurgu kitap | `<path>` | `#F2BE63` opacity 0.85 | Öne çıkan kitap |

**Path sayısı:** 4 | **viewBox:** `0 0 520 760`

---

### 5. `paper_desk_clutter.svg` (520×300)

**Açıklama:** Masa üstü eşyaları: kitaplar, mürekkep hokkası, tüy kalem. Yatay format, detaylı siluetler.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#2b2730` opacity 0.16 | Eşya altı gölge |
| 2 — Kitaplar | `<path>` | `#F5E8D3` | İstiflenmiş kitap silueti |
| 3 — Hokka | `<path>` | `#2B2730` | Mürekkep hokkası silueti |
| 4 — Kalem | `<path>` | `#F2BE63` opacity 0.90 | Tüy kalem silueti |
| 5 — Vurgu | `<path>` | `#7A5A42` opacity 0.70 | Ahşap masa yüzeyi detayı |

**Path sayısı:** 5 | **viewBox:** `0 0 520 300`

---

### 6. `paper_study_nook.svg` (720×520)

**Açıklama:** Çalışma köşesi: masa ve lamba silueti. Altın lamba ışıltısı, sıcak atmosfer.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.18 | Masa altı gölge |
| 2 — Masa | `<path>` | `#7A5A42` | Ahşap masa silueti |
| 3 — Lamba | `<path>` | `#2B2730` | Lamba gövdesi silueti |
| 4 — Lamba ışıltısı | `<path>` | `#F2BE63` opacity 0.55 | Altın ışık halesi |

**Path sayısı:** 4 | **viewBox:** `0 0 720 520`

---

### 7. `paper_bed.svg` (720×520)

**Açıklama:** Ahşap çerçeveli yatak. Ceviz rengi çerçeve, krem yatak örtüsü ve yastık.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.20 | Yatak altı gölge |
| 2 — Çerçeve | `<path>` | `#7A5A42` | Ahşap yatak çerçevesi |
| 3 — Örtü | `<path>` | `#F5E8D3` | Yatak örtüsü yüzeyi |
| 4 — Yastık | `<path>` | `#E89863` opacity 0.80 | Yastık silueti |

**Path sayısı:** 4 | **viewBox:** `0 0 720 520`

---

### 8. `paper_floor_rug.svg` (980×560)

**Açıklama:** Dekoratif oval halı. Geometrik desen, oda paleti renkleri.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.14 | Halı kenar gölgesi |
| 2 — Halı gövdesi | `<path>` | `#E89863` | Oval halı ana yüzeyi |
| 3 — Desen | `<path>` | `#7A5A42` opacity 0.65 | Geometrik iç desen |
| 4 — Kenar şeridi | `<path>` | `#F2BE63` opacity 0.70 | Halı kenar bordürü |

**Path sayısı:** 4 | **viewBox:** `0 0 980 560`

---

### 9. `paper_book_portal.svg` (420×340)

**Açıklama:** Açık parlayan kitap — zaman yolculuğu portalı. Özel: altın + mavi ışıltı path'leri. Bu asset `paper_book_portal.svg` için 5 benzersiz renk kuralı istisnası geçerlidir.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Gölge | `<path>` | `#1a2a3a` opacity 0.18 | Kitap altı gölge |
| 2 — Kitap gövdesi | `<path>` | `#F5E8D3` | Açık kitap silueti |
| 3 — Altın ışıltı | `<path>` | `#F2BE63` opacity 0.42 | Portal altın parıltısı |
| 4 — Mavi ışıltı | `<path>` | `#47B2C2` opacity 0.35 | Portal mavi parıltısı |
| 5 — Vurgu (opsiyonel) | `<path>` | `#F5E8D3` opacity 0.80 | Sayfa kenar vurgusu |

**Path sayısı:** 4–5 | **viewBox:** `0 0 420 340`

---

### 10. `paper_foreground_frame.svg` (1600×780)

**Açıklama:** Ekranın sol ve sağ kenarlarını kapatan koyu ön plan siluetleri. Diorama derinlik hissi için yüksek opaklık.

| Katman | Element | Renk | Notlar |
|--------|---------|------|--------|
| 1 — Sol siluet | `<path>` | `#2B2730` opacity 0.92 | Sol kenar ön plan |
| 2 — Sağ siluet | `<path>` | `#20344F` opacity 0.90 | Sağ kenar ön plan |
| 3 — Üst bant (opsiyonel) | `<path>` | `#2B2730` opacity 0.88 | Üst kenar karartma |

**Path sayısı:** 2–3 | **viewBox:** `0 0 1600 780`

---
## Renk Paleti

| Sabit | Hex | Kullanım |
|-------|-----|---------|
| `DESIGN_DEEP_NAVY` | `#20344F` | Duvar arka planı, koyu alanlar |
| `DESIGN_WEATHERED_WALNUT` | `#7A5A42` | Ahşap mobilya, raflar, çerçeveler |
| `DESIGN_CREAM_PAPER` | `#F5E8D3` | Kağıt, kitaplar, açık yüzeyler |
| `DESIGN_ROOM_FLOOR` | `#E89863` | Zemin, sıcak turuncu tonlar, halı |
| `DESIGN_STORY_INK` | `#2B2730` | Outline, koyu siluetler, hokka |
| `POP_GOLD` | `#F2BE63` | Vurgu, lamba ışıltısı, portal altın |
| `RIFT_BLUE` | `#47B2C2` | Pencere camı, portal mavi ışıltı |
| `PAPER_SHADOW` | `#1A2A3A` | Gölge katmanları (palette dışı) |

---

## SVG Üretim Standardı

Her SVG dosyası şu şablonu takip eder:

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="W" height="H" viewBox="0 0 W H">
  <!-- Katman 1: Gölge -->
  <path d="M..." fill="#1a2a3a" opacity="0.18"/>
  <!-- Katman 2: Ana şekil -->
  <path d="M..." fill="[oda paleti rengi]"/>
  <!-- Katman 3: Vurgu (opsiyonel) -->
  <path d="M..." fill="[vurgu]" opacity="0.65"/>
  <!-- Katman 4: Outline (opsiyonel) -->
  <path d="M..." fill="none" stroke="#2B2730" stroke-width="10"/>
</svg>
```

**Kurallar:**
- Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
- `style` attribute veya `<defs>` yok
- `<text>`, `<tspan>`, `<image>`, `<use>`, `<symbol>` yok
- Maksimum 5 benzersiz renk değeri (`paper_book_portal.svg` hariç)
- Disk boyutu < 50 KB
- `stroke` kullanan path'lerde `stroke-width` 8–18 piksel arasında
- Gölge path'leri her zaman diğer path'lerin önünde (SVG belgesinde ilk sırada)

---

## Parallax Katman Tablosu

Mevcut `_add_room_paper_asset_layer()` fonksiyonu ve `_add_paper_cutout_asset()` çağrı parametrelerinden türetilmiştir. `_build_room()` içinde `_add_room_paper_asset_layer()` çağrısı eklenerek tüm asset'ler sahnelere yüklenecek.

| Asset Dosyası | Sabit | Pozisyon | Scale | Opaklık | Z-Index | Parallax | Slot ID |
|--------------|-------|----------|-------|---------|---------|----------|---------|
| `paper_wall_window.svg` | `ROOM_PAPER_WALL_TEXTURE` | (800, 410) | 1.0 | 0.86 | -6 | -2.0 | `paperroom.wall_window` |
| `paper_wall_story.svg` | `ROOM_PAPER_WALL_STORY_TEXTURE` | (460, 320) | 0.90 | 0.78 | -5 | -1.8 | `paperroom.wall_story` |
| `paper_terrain_room.svg` | `ROOM_PAPER_TERRAIN_TEXTURE` | (800, 1580) | 1.05 | 0.88 | -9 | -3.0 | `paperroom.terrain` |
| `paper_shelf.svg` | `ROOM_PAPER_SHELF_TEXTURE` | (60, 900) | 0.82 | 0.84 | -7 | -1.5 | `paperroom.shelf` |
| `paper_desk_clutter.svg` | `ROOM_PAPER_DESK_CLUTTER_TEXTURE` | (1100, 1260) | 0.78 | 0.82 | -4 | -1.0 | `paperroom.desk_clutter` |
| `paper_study_nook.svg` | `ROOM_PAPER_STUDY_NOOK_TEXTURE` | (860, 1280) | 0.80 | 0.86 | -3 | -0.8 | `paperroom.study_nook` |
| `paper_bed.svg` | `ROOM_PAPER_BED_TEXTURE` | (340, 1380) | 0.84 | 0.88 | -4 | -1.2 | `paperroom.bed` |
| `paper_floor_rug.svg` | `ROOM_PAPER_FLOOR_RUG_TEXTURE` | (800, 1620) | 0.92 | 0.76 | -8 | -2.5 | `paperroom.floor_rug` |
| `paper_book_portal.svg` | `ROOM_PAPER_BOOK_PORTAL_TEXTURE` | (800, 1100) | 0.72 | 0.92 | -2 | 0.5 | `paperroom.book_portal` |
| `paper_foreground_frame.svg` | `ROOM_PAPER_FOREGROUND_FRAME_TEXTURE` | (800, 1850) | 1.10 | 0.88 | 4 | 2.0 | `paperroom.foreground_frame` |

### `_add_room_paper_asset_layer()` Hedef Implementasyonu

```gdscript
func _add_room_paper_asset_layer(world_root: Node) -> void:
    # Duvar arka planı — en uzak katman
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_WALL_TEXTURE,
        Vector2(800, 410), Vector2(1.0, 1.0), Color(1, 1, 1, 0.86), -6,
        "paperroom.wall_window", Vector2.ZERO, -2.0)
    # Duvar hikaye çerçeveleri
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_WALL_STORY_TEXTURE,
        Vector2(460, 320), Vector2(0.90, 0.90), Color(1, 1, 1, 0.78), -5,
        "paperroom.wall_story", Vector2.ZERO, -1.8)
    # Zemin yüzeyi
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_TERRAIN_TEXTURE,
        Vector2(800, 1580), Vector2(1.05, 1.05), Color(1, 1, 1, 0.88), -9,
        "paperroom.terrain", Vector2.ZERO, -3.0)
    # Kitaplık — sol kenar
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_SHELF_TEXTURE,
        Vector2(60, 900), Vector2(0.82, 0.82), Color(1, 1, 1, 0.84), -7,
        "paperroom.shelf", Vector2.ZERO, -1.5)
    # Masa eşyaları
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_DESK_CLUTTER_TEXTURE,
        Vector2(1100, 1260), Vector2(0.78, 0.78), Color(1, 1, 1, 0.82), -4,
        "paperroom.desk_clutter", Vector2.ZERO, -1.0)
    # Çalışma köşesi
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_STUDY_NOOK_TEXTURE,
        Vector2(860, 1280), Vector2(0.80, 0.80), Color(1, 1, 1, 0.86), -3,
        "paperroom.study_nook", Vector2.ZERO, -0.8)
    # Yatak
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_BED_TEXTURE,
        Vector2(340, 1380), Vector2(0.84, 0.84), Color(1, 1, 1, 0.88), -4,
        "paperroom.bed", Vector2.ZERO, -1.2)
    # Halı
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_FLOOR_RUG_TEXTURE,
        Vector2(800, 1620), Vector2(0.92, 0.92), Color(1, 1, 1, 0.76), -8,
        "paperroom.floor_rug", Vector2.ZERO, -2.5)
    # Kitap portalı — zaman yolculuğu geçiş noktası
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_BOOK_PORTAL_TEXTURE,
        Vector2(800, 1100), Vector2(0.72, 0.72), Color(1, 1, 1, 0.92), -2,
        "paperroom.book_portal", Vector2.ZERO, 0.5)
    # Ön plan çerçeve — en yakın katman
    _add_paper_cutout_asset(world_root, _textures.ROOM_PAPER_FOREGROUND_FRAME_TEXTURE,
        Vector2(800, 1850), Vector2(1.10, 1.10), Color(1, 1, 1, 0.88), 4,
        "paperroom.foreground_frame", Vector2.ZERO, 2.0)
```

---
## Mimari

### Değişmeyecek Yapı

- `_build_room()` fonksiyon imzası
- `_decorate_room()` atmosferik efekt çağrıları
- `textures.gd` mevcut `ROOM_PAPER_*` sabit isimleri
- `_add_paper_cutout_asset()` çağrı parametreleri
- `_add_open_world_start_depth_pass()` ve `_add_open_world_start_asset_layer()` çağrıları

### Değişecek Yapı

- `assets/art/world/room/` dizinindeki 10 SVG dosyasının içeriği (yalnızca `<path>` elementleri)
- `_build_room()` içine `_add_room_paper_asset_layer(world_root)` çağrısı eklenir
- `_add_room_paper_asset_layer()` 10 asset'i yükleyecek şekilde genişletilir
- `textures.gd` içine `ROOM_PAPER_TERRAIN_TEXTURE` sabiti eklenir

### `_build_room()` Hedef Yapısı

```gdscript
func _build_room(world_root: Node) -> void:
    _add_open_world_start_depth_pass(world_root)   # korunuyor
    _add_open_world_start_asset_layer(world_root)  # korunuyor
    _add_room_paper_asset_layer(world_root)        # YENİ: 10 paper asset
    _add_room_depth_pass(world_root)               # YENİ: derinlik katmanları
    _snap_room_characters_to_floor(world_root)     # korunuyor
    _decorate_room(world_root)                     # korunuyor
```

### `textures.gd` Güncellemesi

Mevcut `ROOM PAPER CUTOUT` bölümüne eksik sabit eklenir:

```gdscript
# ====================================
# ROOM PAPER CUTOUT (özel asset)
# ====================================
# ... mevcut 9 sabit korunur ...
# Yeni sabit — paper_terrain_room.svg için:
const ROOM_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/room/paper_terrain_room.svg")
```

---

## Performans Tasarımı

### Node Sayısı Analizi

`_add_room_paper_asset_layer()` 10 `_add_paper_cutout_asset()` = **10 Sprite2D node**.

`_decorate_room()` ek node'lar ekler (soft blob'lar, ışık havuzları, mote cluster'lar) — toplam ~45 node, limit 60'ın altında.

### Tween Animasyon Kuralı

- `_add_paper_cutout_asset()` `ambient_bob` meta değeri → `world_player.gd` tarafından Tween ile yönetilir
- `_build_room()` içinde `_process()` çağrısı yok
- `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturulmaz

---

## Portrait 9:16 Kompozisyon

```
WORLD_SIZE = Vector2(1600, 2200)
Kamera zoom = 0.9

Görünür alan (zoom 0.9): ~1778 x 2133 px

Kritik asset pozisyonları:
  wall_window:       (800, 410)   -> arka duvar, tam ekran
  terrain:           (800, 1580)  -> zemin katmanı
  shelf:             (60, 900)    -> sol kenar kitaplık
  book_portal:       (800, 1100)  -> merkez, ekran icinde
  foreground_frame:  (800, 1850)  -> on plan, kenarlar kapali

Tum asset'ler zoom=0.9'da ekran icinde, kenardan >=50px uzakta.
paper_book_portal merkez noktasi: (800, 1100) -> ekran sinirlarindan uzakta.
```

---

## Property-Based Testing (PBT) Özellikleri

Aşağıdaki özellikler `test/` klasöründeki testlere eklenebilir:

### SVG Geçerlilik Özellikleri

**Validates: Requirements 1.3, 3.1, 3.2, 3.3, 3.4**

```
forall svg in assets/art/world/room/*.svg:
  svg.contains('xmlns="http://www.w3.org/2000/svg"')
  svg.path_count in [2, 5]
  svg.unique_colors <= 5  # paper_book_portal.svg haric
  svg.file_size < 50_000  # bytes
  svg.has_no_style_attribute
  svg.has_no_text_element
  svg.uses_only_absolute_commands  # M, L, C, Q, A, Z
  svg.has_no_forbidden_elements     # rect, circle, ellipse, g, use, symbol
```

### Gölge Path Özellikleri

**Validates: Requirements 2.2**

```
forall svg in assets/art/world/room/*.svg:
  shadow_paths = svg.paths.filter(p => p.fill in ['#1a2a3a', '#2b2730'] and p.opacity)
  forall sp in shadow_paths:
    sp.opacity in [0.14, 0.22]
    sp.index < min(non_shadow_path.index for non_shadow_path in svg.paths)
```

### Stroke Genişliği Özellikleri

**Validates: Requirements 2.4**

```
forall svg in assets/art/world/room/*.svg:
  forall path in svg.paths.filter(p => p.has_stroke):
    path.stroke_width in [8, 18]
```

### viewBox Boyut Özellikleri

**Validates: Requirements 1.2, 4.4, 5.2, 6.2, 6.4, 7.3, 8.2, 8.4, 9.3, 10.3, 11.2**

```
expected_viewboxes = {
  "paper_wall_window.svg":     "0 0 1500 780",
  "paper_wall_story.svg":      "0 0 900 420",
  "paper_terrain_room.svg":    "0 0 800 600",
  "paper_shelf.svg":           "0 0 520 760",
  "paper_desk_clutter.svg":    "0 0 520 300",
  "paper_study_nook.svg":      "0 0 720 520",
  "paper_bed.svg":             "0 0 720 520",
  "paper_floor_rug.svg":       "0 0 980 560",
  "paper_book_portal.svg":     "0 0 420 340",
  "paper_foreground_frame.svg":"0 0 1600 780",
}
forall (filename, expected) in expected_viewboxes:
  svg = load(filename)
  svg.viewBox == expected
```

### Builder Özellikleri

**Validates: Requirements 13.1, 14.1, 14.3**

```
forall call in _build_room():
  sprite2d_count + polygon2d_count < 60
  no _process() call
  no AnimationPlayer node created
  no Timer node created
  all assets use _add_paper_cutout_asset()

forall asset in room_assets:
  asset.position.x in [-100, 1700]
  asset.position.y in [-100, 2300]
  asset.has_meta('base_pos')
  asset.has_meta('asset_slot')
```

### Textures Registry Özellikleri

**Validates: Requirements 12.1, 12.3**

```
room_svg_files = glob('assets/art/world/room/*.svg')
room_constants = textures_gd.constants.filter(c => c.name.starts_with('ROOM_PAPER_'))
room_constants.count == room_svg_files.count

forall const in room_constants:
  const.path.starts_with('res://assets/art/world/room/')

world_builder_gd.has_no_direct_preload('res://assets/art/world/room/')
```

---

## Uygulama Sırası

1. **`textures.gd` güncelle** — `ROOM_PAPER_TERRAIN_TEXTURE` sabitini ekle
2. **10 SVG asset'i yükselt** — her dosyayı yalnızca `<path>` elementleriyle yeniden yaz
   - `paper_wall_window.svg` (4 path)
   - `paper_wall_story.svg` (3–4 path)
   - `paper_terrain_room.svg` (3 path)
   - `paper_shelf.svg` (4 path)
   - `paper_desk_clutter.svg` (5 path)
   - `paper_study_nook.svg` (4 path)
   - `paper_bed.svg` (4 path)
   - `paper_floor_rug.svg` (4 path)
   - `paper_book_portal.svg` (4–5 path, özel ışıltı)
   - `paper_foreground_frame.svg` (2–3 path)
3. **`_add_room_paper_asset_layer()` genişlet** — 10 asset çağrısı ekle
4. **`_build_room()` güncelle** — `_add_room_paper_asset_layer()` ve `_add_room_depth_pass()` çağrılarını ekle
5. **Godot headless doğrulama** — import hataları yok
6. **PBT testleri** — SVG geçerlilik, node sayısı, viewBox boyutları

---

## Referanslar

- `scripts/world_builder.gd` — `_build_room()`, `_add_room_paper_asset_layer()`, `_decorate_room()`
- `scripts/textures.gd` — `ROOM_PAPER_*` sabitleri
- `scripts/colors.gd` — `DESIGN_DEEP_NAVY`, `DESIGN_WEATHERED_WALNUT`, `DESIGN_CREAM_PAPER`, `DESIGN_ROOM_FLOOR`, `DESIGN_STORY_INK`, `POP_GOLD`, `RIFT_BLUE`
- `.kiro/specs/samsun-asset-kit/design.md` — Paper diorama üretim standardı referansı
- `.kiro/specs/room-asset-kit/requirements.md` — Gereksinimler