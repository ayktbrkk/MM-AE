# Teknik Tasarım — Bandırma Asset Kit

## Genel Bakış

Bu belge, Bandırma Vapuru sahnesi için paper diorama asset kitinin teknik tasarımını tanımlar. Sahne oyun içinde `ship` area key'i ile inşa edilir; ancak asset klasörü `assets/art/world/bandirma/` altındadır. Mevcut `_build_ship()` zinciri büyük ölçüde prosedürel dikdörtgen plakalar, Kenney gemi sprite'ları ve birkaç düşük kaliteli SVG üzerine kuruludur. Bu spec'in amacı, Bandırma sahnesini Samsun'daki paper layer yaklaşımına yaklaştırmaktır.

### Mevcut Durum

```text
_build_ship(world_root)
  └── _add_ship_room_plates(world_root)   # büyük dikdörtgen plakalar
  └── _decorate_ship(world_root)
        └── asset slot props              # ship.map_table, ship.uniform_stand, ship.compass
        └── kenney ship sprites           # hull, mast, sail, flag, cannon
        └── glow, light pool, water glints
```

### Sorunlar

- `assets/art/world/bandirma/` klasöründe yalnızca 5 SVG dosyası var; sahne hacmi için yetersiz.
- `paper_bandirma_ship.svg` içinde `<text>` elementi var; Godot-friendly paper SVG standardıyla uyumlu değil.
- `_build_ship()` halen büyük oranda `_add_room_rect()` plakalarına dayanıyor; paper cutout katman mantığına tam geçilmiş değil.
- `_decorate_ship()` içindeki büyük gövde/mast/yelken sprite'ları, ileride eklenecek hero ship SVG ile çakışacak.

---

## Mimari

### Değişmeyecek Yapı

- `_build_ship()` fonksiyon imzası
- `_decorate_ship()` içindeki görev odaklı logic akışı
- `ship.map_table`, `ship.uniform_stand`, `ship.compass`, `ship.dock_glow` asset slot isimleri
- `THEME_BANDIRMA` renk sözlüğü
- `WORLD_SIZE = Vector2(1600, 2200)` koordinat sistemi

### Değişecek Yapı

- `assets/art/world/bandirma/` dizinindeki SVG seti 5 dosyadan 13 dosyaya genişletilecek
- `scripts/textures.gd` içine `BANDIRMA_PAPER_*` sabitleri eklenecek
- `_add_bandirma_paper_asset_layer(world_root)` fonksiyonu eklenecek
- `_build_ship()` prosedürel plakalar yerine paper katmanlarını çağıracak
- `_decorate_ship()` içindeki tekrar eden büyük ship sprite'ları azaltılacak

---

## SVG Asset Üretim Planı

### Parallax Katman Tablosu

| Asset Dosyası | Pozisyon | Scale | Opaklık | Z-Index | Parallax |
|--------------|----------|-------|---------|---------|----------|
| `paper_sky_bandirma.svg` | (800, 380) | 1.05 | 0.86 | -18 | -16.0 |
| `paper_fog_bands.svg` | (800, 430) | 1.04 | 0.54 | -17 | -13.0 |
| `paper_distant_coast.svg` | (800, 560) | 1.02 | 0.62 | -16 | -9.0 |
| `paper_cabin_wall.svg` | (800, 590) | 1.08 | 0.88 | -14 | -4.0 |
| `paper_sea_window.svg` | (1160, 1290) | 0.92 | 0.78 | -13 | -6.0 |
| `paper_terrain_harbor.svg` | (800, 1450) | 1.08 | 0.90 | -11 | -2.5 |
| `paper_main_path.svg` | (830, 1260) | 0.88 | 0.84 | -10 | -0.5 |
| `paper_bandirma_ship.svg` | (820, 1180) | 1.18 | 0.90 | -8 | 0.5 |
| `paper_uniform_stand.svg` | (455, 535) | 0.82 | 0.88 | -6 | 1.0 |
| `paper_map_table.svg` | (690, 1170) | 0.90 | 0.92 | -5 | 2.0 |
| `paper_compass.svg` | (1020, 1370) | 0.72 | 0.88 | -3 | 3.5 |
| `paper_telegraph_props.svg` | (1110, 1510) | 0.82 | 0.84 | -2 | 4.0 |
| `paper_foreground_frame.svg` | (800, 1835) | 1.10 | 0.90 | 4 | 14.0 |

### Katman Mantığı

- Arka plan: gökyüzü, sis ve uzak kıyı birlikte sahnenin arka nefesini kurar.
- Orta derinlik: kamara duvarı ve deniz penceresi yarı açık mekansal çerçeveyi oluşturur.
- Oynanış alanı: güverte zemini, rota yolu, gemi silüeti ve görev prop'ları burada bulunur.
- Ön plan: kalın koyu çerçeve, mobil portre kompozisyonunu sıkıştırır ve odak kazandırır.

---

## SVG Üretim Standardı

Her SVG aşağıdaki şablonu izler:

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="W" height="H" viewBox="0 0 W H">
  <path d="M..." fill="#1A1510" opacity="0.22"/>
  <path d="M..." fill="[ana renk]"/>
  <path d="M..." fill="[ikincil vurgu]" opacity="0.60"/>
  <path d="M..." fill="none" stroke="#2B2730" stroke-width="10"/>
</svg>
```

### Kurallar

- Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
- `style` attribute yok
- `<defs>`, `<text>`, `<image>`, `<use>`, `<symbol>` yok
- Maksimum 5 benzersiz renk
- Disk boyutu 50 KB altında
- `paper_bandirma_ship.svg` dahil tüm dosyalar round-trip import uyumlu

---

## Renk Paleti (THEME_BANDIRMA)

| Sabit | Hex | Kullanım |
|------|-----|----------|
| `ART_WAR_NAVY` | `#292c39` | Gece/şafak gökyüzü, derin deniz |
| `ART_WARM_EARTH` | `#856536` | Ahşap gövde, sıcak sis geçişleri |
| `ART_CREAM_LIGHT` | `#ecdec8` | Harita, panel, açık yüzeyler |
| `SHADOW_WARM` | `#1A1510` | Gölge katmanları |
| `DESIGN_STORY_INK` | `#2B2730` | Outline ve silüetler |
| `POP_GOLD` | `#FFB340` | Rota vurgusu, sıcak lamba, pusula |
| `POP_DEEP_TURQUOISE` | `#067078` | Deniz/parıltı ikincil vurgu |
| `RIFT_BLUE` | `#38C7FF` | Dock glow / navigasyon glow |
| `POP_CRIMSON` | `#B82E1F` | Bayrak ve uyarı vurgusu |

---

## Asset Grubu Tasarımları

### 1. Gökyüzü ve Ufuk Grubu

**`paper_sky_bandirma.svg`** (1800×900)
- Sisli gece ile sıcak altın geçiş arasında duran geniş gökyüzü
- Overscan şartı nedeniyle genişlik 1600 pikselin üzerinde olmalı

**`paper_fog_bands.svg`** (1800×520)
- İki veya üç sis şeridi
- Altın ve krem sis kırılmaları

**`paper_distant_coast.svg`** (1600×420)
- Uzak kıyı çizgisi, liman kütlesi, düşük detaylı yapı silüetleri

### 2. Kamara ve Güverte Grubu

**`paper_cabin_wall.svg`** (1500×900)
- Güverte/kamara birleşim duvarı
- Koyu lacivert çerçeve, pencere boşluğu hissi, ahşap destekler

**`paper_sea_window.svg`** (640×760)
- Pencere içinden görünen deniz yansıması
- Turkuaz parıltı ve altın sıcak ışık balansı

**`paper_terrain_harbor.svg`** (1400×900)
- Ahşap güverte zemini, liman yönüne eğimli kütle, gölge alanlar

**`paper_main_path.svg`** (900×900)
- Oyuncu yönlendirmesi sağlayan rota/ışık şeridi
- Güverte üstünde yumuşak S-eğrili akış

### 3. Hero Ship ve Landmark Grubu

**`paper_bandirma_ship.svg`** (1200×760)
- Gövde, güverte, baca, direk/yelken, su gölgesi
- Tek hero asset olarak büyük okunabilirlik
- `<metadata><slot_id>ship.bandirma_hero</slot_id></metadata>`

**`paper_map_table.svg`** (700×420)
- Harita masası, rota kâğıdı, belge köşeleri
- `<metadata><slot_id>ship.map_table</slot_id></metadata>`

**`paper_uniform_stand.svg`** (420×620)
- Üniforma askılığı, şapka/aksesuar silüeti
- `<metadata><slot_id>ship.uniform_stand</slot_id></metadata>`

**`paper_compass.svg`** (320×320)
- Pusula gövdesi, yön oku, düşük opaklıklı glow
- `<metadata><slot_id>ship.compass</slot_id></metadata>`

**`paper_telegraph_props.svg`** (560×360)
- Dock signal / rota mesaj prop grubu
- Halat, küçük sinyal lambası, sandık veya işaret direği

### 4. Ön Plan Grubu

**`paper_foreground_frame.svg`** (1800×780)
- Sol ve sağ kenar koyu silüetleri
- İp, direk, perde veya karanlık borda kesiti hissi
- Portre kompozisyonu sıkıştıran karanlık çerçeve

---

## Kod Değişiklikleri

### `textures.gd` — Yeni Bölüm

```gdscript
# ====================================
# BANDIRMA PAPER CUTOUT (özel asset)
# ====================================
const BANDIRMA_PAPER_SKY_TEXTURE := preload("res://assets/art/world/bandirma/paper_sky_bandirma.svg")
const BANDIRMA_PAPER_FOG_BANDS_TEXTURE := preload("res://assets/art/world/bandirma/paper_fog_bands.svg")
const BANDIRMA_PAPER_DISTANT_COAST_TEXTURE := preload("res://assets/art/world/bandirma/paper_distant_coast.svg")
const BANDIRMA_PAPER_CABIN_WALL_TEXTURE := preload("res://assets/art/world/bandirma/paper_cabin_wall.svg")
const BANDIRMA_PAPER_SEA_WINDOW_TEXTURE := preload("res://assets/art/world/bandirma/paper_sea_window.svg")
const BANDIRMA_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/bandirma/paper_terrain_harbor.svg")
const BANDIRMA_PAPER_MAIN_PATH_TEXTURE := preload("res://assets/art/world/bandirma/paper_main_path.svg")
const BANDIRMA_PAPER_SHIP_TEXTURE := preload("res://assets/art/world/bandirma/paper_bandirma_ship.svg")
const BANDIRMA_PAPER_MAP_TABLE_TEXTURE := preload("res://assets/art/world/bandirma/paper_map_table.svg")
const BANDIRMA_PAPER_UNIFORM_STAND_TEXTURE := preload("res://assets/art/world/bandirma/paper_uniform_stand.svg")
const BANDIRMA_PAPER_COMPASS_TEXTURE := preload("res://assets/art/world/bandirma/paper_compass.svg")
const BANDIRMA_PAPER_SIGNAL_PROPS_TEXTURE := preload("res://assets/art/world/bandirma/paper_telegraph_props.svg")
const BANDIRMA_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/bandirma/paper_foreground_frame.svg")
```

### `_add_bandirma_paper_asset_layer()`

Yeni helper, yukarıdaki parallax tablosundaki tüm SVG'leri yükler. Tüm çağrılar `_add_paper_cutout_asset()` veya foreground helper ile yapılır; `ship.*` slot'ları SVG landmark'larda saklanır.

### `_build_ship()` Hedef Hali

```gdscript
func _build_ship(world_root: Node) -> void:
    _add_rect(world_root, Vector2.ZERO, WORLD_SIZE, _colors.THEME_BANDIRMA["bg"])
    _add_bandirma_paper_asset_layer(world_root)
    _decorate_ship(world_root)
```

### `_decorate_ship()` Temizliği

Korunacaklar:
- `ship.map_table`, `ship.uniform_stand`, `ship.compass`, `ship.dock_glow`
- light pools, story banner, subtle cloud/smoke accents, NPC'ler

Kaldırılacak veya azaltılacaklar:
- `SHIP_HULL_TEXTURE`, `SHIP_HULL_ALT_TEXTURE`
- `SHIP_MAST_TEXTURE`, `SHIP_SAIL_TEXTURE`, `SHIP_SMALL_SAIL_TEXTURE`
- `SHIP_FLAG_TEXTURE`, `SHIP_FLAG_ALT_TEXTURE`, `SHIP_NEST_TEXTURE`
- büyük yapısal `_add_rect()` çağrıları (kamara duvarı ve güverte zeminini tekrar edenler)

---

## Performans Tasarımı

- 13 paper asset + mevcut görev prop'ları ile hedef toplam sahne yoğunluğu 65 render node altında kalır.
- Paper katmanlar büyük ölçüde statik kalır; yalnızca mevcut ambience helper'ları kullanılabilir.
- `base_pos` meta anahtarı tüm katmanlarda mevcut kalır; varsa hafif bob animasyonu bu referansı kullanır.

---

## Test Tasarımı

### SVG Geçerlilik Testi

`test/test_bandirma_svg_validity.gd` aşağıdakileri doğrular:

- tüm SVG dosyalarında `xmlns` bildirimi var
- yasak elementler yok
- yalnızca büyük harf path komutları var
- `<path>` sayısı 2-5 aralığında
- tüm dosya boyutları 50 KB altında
- beklenen viewBox değerleri eşleşiyor

### Builder Doğrulaması

Opsiyonel property testi:

- `BANDIRMA_PAPER_*` sabit sayısı ile klasördeki SVG sayısı eşleşiyor
- `_build_ship()` sonrası büyük gemi sprite tekrarları kaldırılmış
- `ship.map_table`, `ship.uniform_stand`, `ship.compass` odak noktaları ekran içinde kalıyor