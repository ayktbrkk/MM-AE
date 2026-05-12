# Uygulama Planı: Samsun Asset Kit

## Genel Bakış

Bu plan, `samsun_rift` bölgesi için mevcut düşük kaliteli SVG asset'lerini artwork referanslarına göre yükseltir, `_build_samsun_rift()` fonksiyonunu temizler ve `_decorate_samsun_diorama_pilot()` fonksiyonuna marker ışıltıları ekler. `textures.gd`, `colors.gd` ve `_add_samsun_paper_asset_layer()` zinciri değişmez; yalnızca SVG içerikleri ve iki GDScript fonksiyonu güncellenir.

Uygulama dili: **GDScript 2.0** (Godot 4.6.2)

---

## Görevler

- [x] 1. Gökyüzü SVG Grubu — 4 dosya yükselt
  - [x] 1.1 `paper_sky_samsun.svg` dosyasını yükselt
    - `viewBox="0 0 1800 900"` — genişlik > 1600px (kamera overscan), yükseklik ≥ 800px
    - Üst bant: `fill="#067078"` (POP_DEEP_TURQUOISE), alt bant: `fill="#F5E8D3"` (DESIGN_CREAM_PAPER)
    - En az 2 yatay bant `<path>` + 1 gölge `<path>` (`fill="#10202d"`, `opacity="0.22"`)
    - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
    - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
    - Disk boyutu < 50 KB
    - _Gereksinimler: 1.1, 1.2, 1.3, 1.6, 2.1, 2.2, 2.3, 11.1, 11.3, 14.3, 15.1, 15.2, 15.4_

  - [x] 1.2 `paper_sky_life.svg` dosyasını yükselt
    - `viewBox="0 0 1800 600"`
    - Martı siluetleri ve hafif bulut şekilleri; `opacity` 0.40–0.60 arası
    - 2–5 `<path>` elementi; maksimum 5 benzersiz renk
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 1.3 `paper_distant_town.svg` dosyasını yükselt
    - `viewBox="0 0 1600 500"`
    - Kule, kubbe, bayrak direği siluetleri; `opacity` 0.40–0.60
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 11.2, 15.1, 15.2, 15.4_

  - [x] 1.4 `paper_skyline_depth.svg` dosyasını yükselt
    - `viewBox="0 0 1600 400"`
    - Orta derinlik şehir silueti; `opacity` 0.55–0.70
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

- [x] 2. Deniz ve Kıyı SVG Grubu — 5 dosya yükselt
  - [x] 2.1 `paper_harbor_water.svg` dosyasını yükselt
    - `viewBox="0 0 900 600"`
    - `#067078` renk ailesinden turkuaz deniz yüzeyi
    - En az 3 yatay dalga bandı; `opacity` değerleri: 0.40, 0.60, 0.80 (±0.05)
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.2, 2.3, 7.2, 15.1, 15.2, 15.4_

  - [x] 2.2 `paper_coast_details.svg` dosyasını yükselt
    - `viewBox="0 0 1200 500"`
    - Kıyı taşları ve kayalık detaylar; organik path şekilleri
    - 2–5 `<path>` elementi; gölge `<path>` dahil
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.2, 2.3, 15.1, 15.2, 15.4_

  - [x] 2.3 `paper_harbor_dock_props.svg` dosyasını yükselt
    - `viewBox="0 0 700 400"`
    - İskele platformu, halat, sandık detayları
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.2, 15.1, 15.2, 15.4_

  - [x] 2.4 `paper_coastal_life.svg` dosyasını yükselt
    - `viewBox="0 0 800 400"`
    - Kıyı bitki örtüsü ve küçük detaylar
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 2.5 `paper_harbor_boats.svg` dosyasını yükselt
    - `viewBox="0 0 600 300"`
    - 1 sandal `<path>` + 1 martı `<path>` (her biri ayrı element)
    - `paper_harbor_landmark.svg` ve `paper_harbor_water.svg` ile birlikte görsel bütünlük
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.2, 7.3, 15.1, 15.2, 15.4_

- [x] 3. Checkpoint — Gökyüzü ve Deniz/Kıyı SVG'leri
  - Görevler 1.1–2.5 tamamlandıktan sonra 9 SVG dosyasını Godot editöründe açarak import hatası olmadığını doğrula. Soru varsa kullanıcıya sor.

- [x] 4. Arazi SVG Grubu — 3 dosya yükselt
  - [x] 4.1 `paper_terrain_island.svg` dosyasını yükselt
    - `viewBox="0 0 1400 800"`
    - Ana zemin katmanı; organik ada şekli
    - `DESIGN_CREAM_PAPER` (`#F5E8D3`) ve toprak tonları; `stroke-width="12"` outline
    - 2–5 `<path>` elementi; `opacity` 0.94 (yüksek görünürlük)
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.2, 2.3, 15.1, 15.2, 15.4_

  - [x] 4.2 `paper_side_paths.svg` dosyasını yükselt
    - `viewBox="0 0 1200 600"`
    - Yan patikalar ve yol dallanmaları; krem/bej tonlar
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 4.3 `paper_main_path.svg` dosyasını yükselt
    - `viewBox="0 0 900 700"`
    - Kıvrımlı taş yol; krem/bej tonlar, taş doku hissi
    - 2–5 `<path>` elementi; `stroke-width` 8–18 arası
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.3, 15.1, 15.2, 15.4_

- [x] 5. Landmark SVG Grubu — 4 dosya yükselt
  - [x] 5.1 `paper_harbor_landmark.svg` dosyasını yükselt
    - `viewBox="0 0 600 500"`
    - İskele platformu + 1 sandık + 1 vapur silüeti + 1 deniz feneri silüeti (her biri ayrı `<path>`)
    - `<metadata><slot_id>samsun.harbor_landmark</slot_id></metadata>` ekle
    - Gölge `<path>`: `fill="#10202d"`, `opacity="0.22"`
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.2, 7.1, 7.4, 15.1, 15.2, 15.4_

  - [x] 5.2 `paper_telegraph_landmark.svg` dosyasını yükselt
    - `viewBox="0 0 500 600"`
    - Telgraf direği + küçük bina (direğin max %50 yüksekliği) + bayrak direği (her biri ayrı `<path>`)
    - `<metadata><slot_id>samsun.telegraph_landmark</slot_id></metadata>` ekle
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.2, 8.1, 8.3, 15.1, 15.2, 15.4_

  - [x] 5.3 `paper_people_plaza.svg` dosyasını yükselt
    - `viewBox="0 0 700 600"`
    - 1 heykel (kaide + figür) + 1 bank + 1 ağaç + 2 NPC silueti (her biri ayrı `<path>`)
    - NPC siluetleri: `fill="#2B2730"`, tek `<path>`, iç detay yok
    - `<metadata><slot_id>samsun.people_plaza</slot_id></metadata>` ekle
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.1, 2.2, 9.1, 9.2, 9.3, 15.1, 15.2, 15.4_

  - [x] 5.4 `paper_rift_core.svg` dosyasını yükselt
    - `viewBox="0 0 400 400"`
    - Tam 4 `<path>`: merkezi kristal + 2 enerji halkası + ışıltı efekti
    - Enerji halkaları: `fill="#53c6df"`, `opacity` 0.58–0.82
    - Kristal çekirdek: `fill="#f9eec5"`, `opacity` 0.70–0.82
    - `<metadata><slot_id>samsun.rift_core</slot_id></metadata>` ekle
    - _Gereksinimler: 1.2, 1.3, 1.6, 2.5, 10.1, 10.2, 10.4, 15.1, 15.2, 15.4_

- [x] 6. Checkpoint — Arazi ve Landmark SVG'leri
  - Görevler 4.1–5.4 tamamlandıktan sonra 7 SVG dosyasını Godot editöründe açarak import hatası olmadığını doğrula. Soru varsa kullanıcıya sor.

- [x] 7. Dekoratif SVG Grubu — 9 dosya yükselt
  - [x] 7.1 `paper_signal_ridge.svg` dosyasını yükselt
    - `viewBox="0 0 500 400"`
    - Sinyal tepesi, uzak siluet; düşük opaklık
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 7.2 `paper_vista_flags.svg` dosyasını yükselt
    - `viewBox="0 0 600 400"`
    - 1 Türk bayrağı + 1 flama; bayrak `fill="#B82E1F"` (POP_CRIMSON)
    - Core palette + ek kırmızı renk (additive permission)
    - _Gereksinimler: 1.2, 1.3, 1.6, 2.4, 8.2, 15.1, 15.2, 15.4_

  - [x] 7.3 `paper_route_beads.svg` dosyasını yükselt
    - `viewBox="0 0 800 300"`
    - Rota boncukları ve yol işaretçileri
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 7.4 `paper_safe_clearings.svg` dosyasını yükselt
    - `viewBox="0 0 700 400"`
    - Güvenli açıklık alanları; organik şekiller
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 7.5 `paper_civic_cluster.svg` dosyasını yükselt
    - `viewBox="0 0 500 400"`
    - Sivil bina kümesi; krem/bej tonlar
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 7.6 `paper_discovery_props.svg` dosyasını yükselt
    - `viewBox="0 0 600 400"`
    - Keşif prop'ları (sandık, işaret taşı vb.)
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 7.7 `paper_wave_gate.svg` dosyasını yükselt
    - `viewBox="0 0 600 400"`
    - Dalga kapısı, geçiş noktası; turkuaz tonlar
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 7.8 `paper_map_compass.svg` dosyasını yükselt
    - `viewBox="0 0 300 300"`
    - Dekoratif pusula; düşük opaklık (0.34), harita hissi
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.5, 1.6, 2.3, 15.1, 15.2, 15.4_

  - [x] 7.9 `paper_foreground_frame.svg` dosyasını yükselt
    - `viewBox="0 0 1800 600"` — genişlik ≥ 1600px
    - Ön plan silüetleri; `fill="#2B2730"` veya `fill="#10202d"`, `opacity > 0.85`
    - 2–5 `<path>` elementi
    - _Gereksinimler: 1.2, 1.3, 1.6, 2.6, 14.2, 15.1, 15.2, 15.4_

- [x] 8. Checkpoint — Dekoratif SVG'ler
  - Görevler 7.1–7.9 tamamlandıktan sonra 9 SVG dosyasını Godot editöründe açarak import hatası olmadığını doğrula. Soru varsa kullanıcıya sor.

- [x] 9. `_build_samsun_rift()` Kod Güncellemesi
  - [x] 9.1 `_build_samsun_rift()` fonksiyonunu güncelle
    - `_add_samsun_ground_plates(world_root)` çağrısını kaldır (paper asset layer yeterli, plate'ler SVG'lerle çakışıyor)
    - `_add_rect()` çağrısındaki `Color(0.04, 0.11, 0.22)` literalini `_colors.THEME_SAMSUN["bg"]` ile değiştir
    - `_decorate_samsun_rift(world_root)` çağrısından sonra `emit_signal("world_built", "samsun_rift")` ekle
    - Tüm yerel değişkenleri GDScript 2.0 statik tipleme sözdizimi ile tanımla (`var pos: Vector2 := Vector2(...)`)
    - Fonksiyon içinde `_process()` çağrısı, `while` döngüsü, `AnimationPlayer`, `AnimationTree` veya `Timer` node'u bulunmamalı
    - `_build_samsun_rift()` içinde `Sprite2D.new()` veya `Node2D.new()` gibi doğrudan node oluşturma çağrısı bulunmamalı
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 5.2, 6.1, 6.4, 6.5, 6.6, 13.1, 13.2_

  - [x] 9.2 `_add_paper_cutout_asset()` çağrılarında `set_meta("base_pos", position)` doğrulaması
    - Her `_add_paper_cutout_asset()` çağrısının `set_meta("base_pos", position)` ile asset pozisyonunu kaydettiğini doğrula; eksikse ekle
    - Tween tabanlı sallanma animasyonu bu değeri referans alabilmeli
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 3.3_

  - [x] 9.3 `clear_world()` içinde Samsun node temizleme mantığını doğrula
    - `clear_world(world_root)` çağrıldığında `"paperworld.samsun_"` önekiyle `set_meta("asset_slot", ...)` ile işaretlenmiş tüm node'ların `queue_free()` ile serbest bırakıldığını doğrula; eksikse ekle
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 13.5_

- [x] 10. `_decorate_samsun_diorama_pilot()` Marker Işıltıları ve Rift Efekti
  - [x] 10.1 `_decorate_samsun_diorama_pilot()` fonksiyonuna 3 marker ışıltısı ekle
    - Harbor landmark (başlangıç noktası): `_add_soft_blob(_cached_world_root, Vector2(360, 760), Vector2(100, 60), _colors.POP_GOLD, 20, 0.0, false, -2)`
    - Telegraph landmark (durak noktası): `_add_soft_blob(_cached_world_root, Vector2(1190, 770), Vector2(100, 60), _colors.RIFT_BLUE, 20, 0.0, false, -2)`
    - People plaza (görev noktası): `_add_soft_blob(_cached_world_root, Vector2(530, 1455), Vector2(110, 65), _colors.POP_CRIMSON, 20, 0.0, false, -2)`
    - `animate` parametresi `false` — statik glow, Timer/process yok
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 12.1, 12.2, 12.3, 12.4_

  - [x] 10.2 `_decorate_samsun_rift()` içine rift core ışıltısı ekle
    - `paper_rift_core.svg` asset konumuna `_add_soft_blob()` çağrısı ekle; renk `_colors.RIFT_BLUE`, yarıçap 80–140 piksel arası
    - `animate` parametresi `false` — statik glow
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 10.3_

- [x] 11. SVG Geçerlilik Testleri
  - [x] 11.1 SVG XML geçerlilik test dosyasını oluştur
    - `test/test_samsun_svg_validity.gd` dosyasını oluştur
    - Her SVG dosyasında `xmlns="http://www.w3.org/2000/svg"` mevcut olduğunu doğrula
    - `style` attribute, `<defs>`, `<text>`, `<image>`, `<use>`, `<symbol>` olmadığını doğrula
    - Yalnızca mutlak koordinat komutları (`M`, `L`, `C`, `Q`, `A`, `Z`) kullanıldığını doğrula
    - `<path>` sayısının her dosyada 2–5 arasında olduğunu doğrula (`paper_rift_core.svg`: tam 4)
    - _Gereksinimler: 1.3, 1.6, 15.1, 15.2, 15.3, 15.4, 15.5_

  - [ ]* 11.2 PBT: SVG geçerlilik özelliklerini test et
    - **Property 1: Her SVG dosyası `xmlns` bildirimi içermeli**
    - **Validates: Gereksinim 1.6, 15.1**
    - **Property 2: Her SVG dosyasında `<path>` sayısı 2–5 arasında (`paper_rift_core.svg`: tam 4)**
    - **Validates: Gereksinim 1.3, 10.1**
    - **Property 3: Her SVG dosyasında benzersiz renk sayısı ≤ 5 (rift ve bayrak hariç)**
    - **Validates: Gereksinim 1.5**
    - **Property 4: Her SVG dosyasının disk boyutu < 50 KB**
    - **Validates: Gereksinim 13.4**
    - **Property 5: Her SVG dosyasında `style` attribute, `<defs>`, `<text>`, `<image>` yok**
    - **Validates: Gereksinim 15.2, 15.3, 15.5**
    - **Property 6: Her SVG `<path>` `d` attribute'unda yalnızca büyük harf komutları**
    - **Validates: Gereksinim 15.4**
    - Test dosyası: `test/test_samsun_svg_properties.gd`
    - _Gereksinimler: 1.3, 1.5, 1.6, 13.4, 15.1, 15.2, 15.3, 15.4, 15.5_

  - [ ]* 11.3 PBT: Builder özelliklerini test et
    - **Property 7: `_build_samsun_rift()` tamamlandığında Sprite2D + Polygon2D node sayısı < 60**
    - **Validates: Gereksinim 13.3**
    - **Property 8: Her asset'in `position.x` ∈ [-100, 1700], `position.y` ∈ [-100, 2300]**
    - **Validates: Gereksinim 14.1**
    - **Property 9: `world_built` sinyali `_decorate_samsun_rift()` tamamlandıktan sonra yayılır**
    - **Validates: Gereksinim 6.5**
    - Test dosyası: `test/test_samsun_builder_properties.gd`
    - _Gereksinimler: 6.5, 13.3, 14.1_

  - [ ]* 11.4 PBT: Renk sabiti özelliklerini test et
    - **Property 10: `RIFT_BLUE.r == 0.22`, `RIFT_BLUE.g == 0.78`, `RIFT_BLUE.b == 1.0`**
    - **Validates: Gereksinim 5.4**
    - **Property 11: `THEME_SAMSUN.keys()` == ["bg", "accent", "panel", "shadow", "text"]**
    - **Validates: Gereksinim 5.1**
    - **Property 12: `THEME_SAMSUN["bg"] == POP_DEEP_TURQUOISE`**
    - **Validates: Gereksinim 5.1**
    - Test dosyası: `test/test_samsun_color_properties.gd`
    - _Gereksinimler: 5.1, 5.4_

- [x] 12. Final Checkpoint — Tüm testler geçmeli
  - Tüm görevler tamamlandıktan sonra Godot editöründe `samsun_rift` sahnesini çalıştır ve görsel bütünlüğü doğrula. Soru varsa kullanıcıya sor.

---

## Notlar

- `*` ile işaretli alt görevler opsiyoneldir; MVP için atlanabilir
- `textures.gd` ve `colors.gd` değişmez — 25 `SAMSUN_PAPER_*` sabiti ve `THEME_SAMSUN`/`RIFT_BLUE` zaten mevcut (Gereksinim 4 ve 5 karşılanmış)
- `_add_samsun_paper_asset_layer()` çağrı parametreleri (pozisyon, scale, z-index, parallax) değişmez
- Her SVG görevi bağımsız olarak tamamlanabilir; paralel çalışmaya uygundur
- Landmark SVG'lerindeki `<metadata>` elementi Godot import'unu etkilemez, marker sistemi için gereklidir
- `_add_soft_blob()` son parametresi `animate: bool` — `false` olarak ayarlanmalı (statik, Tween/Timer yok)
- Gereksinim 6.3 (`_spawn_samsun_rift_markers()`) mevcut `world_marker.gd` implementasyonunda zaten karşılanmış olabilir; 9.1 görevi sırasında doğrula
- Gereksinim 3.4 (sıfır parallax = sabit pozisyon): `_add_paper_cutout_asset()` implementasyonu bu davranışı zaten sağlıyorsa ek değişiklik gerekmez; 9.2 sırasında doğrula

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4", "2.1", "2.2", "2.3", "2.4", "2.5"] },
    { "id": 1, "tasks": ["4.1", "4.2", "4.3", "5.1", "5.2", "5.3", "5.4"] },
    { "id": 2, "tasks": ["7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9"] },
    { "id": 3, "tasks": ["9.1", "9.2", "9.3", "10.1", "10.2"] },
    { "id": 4, "tasks": ["11.1", "11.2", "11.3", "11.4"] }
  ]
}
```
