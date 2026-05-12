# Uygulama Planı: Bandırma Asset Kit

## Genel Bakış

Bu plan, Bandırma Vapuru sahnesi için mevcut düşük kaliteli SVG setini ve prosedürel gemi plakalarını, artwork referanslarına daha yakın bir paper diorama katman sistemine dönüştürür. Hedef sahne anahtarı `ship`, asset klasörü ise `assets/art/world/bandirma/` olarak kalır. Samsun örneğindeki gibi önce SVG seti tamamlanır, ardından `textures.gd`, `world_builder.gd` ve test dosyaları güncellenir.

Uygulama dili: **GDScript 2.0** (Godot 4.6.2)

---

## Görevler

- [ ] 1. Gökyüzü ve Ufuk SVG Grubu — 3 dosya hazırla/yükselt
  - [ ] 1.1 `paper_sky_bandirma.svg` dosyasını yükselt
    - `viewBox="0 0 1800 900"`
    - Sisli gece/şafak geçişi; warm navy + gold + cream dengesi
    - 3-4 `<path>` elementi
    - `style`, `<defs>`, `<text>`, `<image>` yok
    - _Gereksinimler: 1.1, 1.2, 1.3, 1.6, 2.1, 2.2, 2.3, 7.1, 12.3, 13.1, 13.2, 13.3_

  - [ ] 1.2 `paper_fog_bands.svg` dosyasını oluştur
    - `viewBox="0 0 1800 520"`
    - En az 2 sis bandı + 1 sıcak vurgu katmanı
    - `opacity` 0.20–0.55 aralığında
    - 2-4 `<path>` elementi
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.2, 7.2, 13.1, 13.2, 13.3_

  - [ ] 1.3 `paper_distant_coast.svg` dosyasını oluştur
    - `viewBox="0 0 1600 420"`
    - Uzak kıyı çizgisi, iskele gölgeleri, düşük detaylı yapı silüetleri
    - `opacity` 0.38–0.62 aralığında
    - 2-5 `<path>` elementi
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.2, 7.3, 13.1, 13.2, 13.3_

- [ ] 2. Kamara ve Güverte SVG Grubu — 4 dosya hazırla/yükselt
  - [ ] 2.1 `paper_cabin_wall.svg` dosyasını oluştur
    - `viewBox="0 0 1500 900"`
    - Koyu gemi iç duvarı, kiriş/kesit hissi
    - En az 1 pencere boşluğu okuması
    - 3-5 `<path>` elementi
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.1, 2.2, 8.1, 13.1, 13.2_

  - [ ] 2.2 `paper_sea_window.svg` dosyasını oluştur
    - `viewBox="0 0 640 760"`
    - Deniz yansıması, altın/turkuaz glow, iç gölge
    - 3-5 `<path>` elementi
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.4, 6.4, 8.2, 13.1, 13.2_

  - [ ] 2.3 `paper_terrain_harbor.svg` dosyasını yükselt
    - `viewBox="0 0 1400 900"`
    - Ahşap güverte zemini, liman yönüne açılan sıcak yüzey
    - 3-5 `<path>` elementi
    - `stroke-width` 8-18 arası outline
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.1, 2.2, 8.3, 13.1, 13.2_

  - [ ] 2.4 `paper_main_path.svg` dosyasını yükselt
    - `viewBox="0 0 900 900"`
    - Güvertede rota şeridi/ışık akışı
    - 2-5 `<path>` elementi
    - Oyuncuyu rota masası ve çıkış yönüne bağlayan kompozisyon
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.4, 8.4, 13.1, 13.2_

- [ ] 3. Hero Ship ve Prop SVG Grubu — 6 dosya hazırla/yükselt
  - [ ] 3.1 `paper_bandirma_ship.svg` dosyasını yükselt
    - `viewBox="0 0 1200 760"`
    - Gövde, güverte, baca, direk/yelken, su gölgesi
    - Toplam 4-5 `<path>`
    - `<text>` elementi kaldırılmalı
    - `<metadata><slot_id>ship.bandirma_hero</slot_id></metadata>` eklenmeli
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.1, 2.2, 9.1, 9.2, 9.3, 9.4, 13.1, 13.2, 13.5_

  - [ ] 3.2 `paper_map_table.svg` dosyasını oluştur
    - `viewBox="0 0 700 420"`
    - Masa yüzeyi, açık rota haritası, belge/işaret katmanı
    - 3-5 `<path>` elementi
    - `<metadata><slot_id>ship.map_table</slot_id></metadata>`
    - _Gereksinimler: 1.1, 1.2, 1.3, 10.1, 13.1, 13.2_

  - [ ] 3.3 `paper_uniform_stand.svg` dosyasını oluştur
    - `viewBox="0 0 420 620"`
    - Üniforma askılığı, şapka/aksesuar silüeti
    - 3-5 `<path>` elementi
    - `<metadata><slot_id>ship.uniform_stand</slot_id></metadata>`
    - _Gereksinimler: 1.1, 1.2, 1.3, 10.2, 13.1, 13.2_

  - [ ] 3.4 `paper_compass.svg` dosyasını oluştur
    - `viewBox="0 0 320 320"`
    - Pusula gövdesi, yön oku, düşük opaklıklı glow
    - 3-5 `<path>` elementi
    - `<metadata><slot_id>ship.compass</slot_id></metadata>`
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.6, 10.3, 13.1, 13.2_

  - [ ] 3.5 `paper_telegraph_props.svg` dosyasını yükselt
    - `viewBox="0 0 560 360"`
    - Sinyal lambası, halat, küçük işaret/dock prop kümesi
    - 2-5 `<path>` elementi
    - `ship.dock_glow` çevresini tamamlayacak görsel rol
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.6, 10.4, 13.1, 13.2_

  - [ ] 3.6 `paper_foreground_frame.svg` dosyasını oluştur
    - `viewBox="0 0 1800 780"`
    - Koyu borda/perde/ip silüetleri
    - `opacity > 0.85`
    - 2-4 `<path>` elementi
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.5, 12.2, 13.1, 13.2_

- [ ] 4. Checkpoint — Tüm Bandırma SVG'lerini doğrula
  - 13 SVG dosyasının tamamı `assets/art/world/bandirma/` altında bulunmalı
  - `xmlns` bildirimi mevcut olmalı
  - `style`, `<defs>`, `<text>`, `<image>`, `<use>`, `<symbol>` bulunmamalı
  - Her dosya 50 KB altında olmalı
  - Soru varsa kullanıcıya sor

- [ ] 5. Kod Güncellemeleri — Textures ve World Builder
  - [ ] 5.1 `textures.gd` güncelle — 13 `BANDIRMA_PAPER_*` sabiti ekle
    - Yeni bölüm başlığı `# BANDIRMA PAPER CUTOUT (özel asset)` formatında olmalı
    - `world_builder.gd` doğrudan `preload("res://assets/art/world/bandirma/` kullanmamalı
    - Dosya: `scripts/textures.gd`
    - _Gereksinimler: 4.1, 4.2, 4.3, 4.4_

  - [ ] 5.2 `_add_bandirma_paper_asset_layer()` fonksiyonunu oluştur
    - Parallax tablosundaki 13 asset `_add_paper_cutout_asset()` çağrısıyla eklenmeli
    - `paper_foreground_frame.svg` foreground helper ile eklenmeli
    - Her çağrı `base_pos` meta değerini korumalı
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 3.1, 3.2, 3.3, 6.1_

  - [ ] 5.3 `_build_ship()` fonksiyonunu güncelle
    - `_add_bandirma_paper_asset_layer(world_root)` çağrısı ekle
    - Büyük prosedürel plakaları kaldır veya fallback'e indir
    - Tema rengini `_colors.THEME_BANDIRMA["bg"]` ile kullan
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 5.2, 6.2, 6.5, 6.6_

  - [ ] 5.4 `_decorate_ship()` tekrarlarını temizle
    - Büyük ship hull/mast/sail/flag sprite tekrarlarını kaldır veya görünmeyecek düzeye indir
    - `ship.map_table`, `ship.uniform_stand`, `ship.compass`, `ship.dock_glow` akışı korunmalı
    - Dosya: `scripts/world_builder.gd`
    - _Gereksinimler: 6.3, 6.4_

- [ ] 6. Testler
  - [ ] 6.1 `test/test_bandirma_svg_validity.gd` dosyasını oluştur
    - Tüm Bandırma SVG'lerinde `xmlns`, path count, yasak elementler, viewBox ve dosya boyutu doğrulanmalı
    - `paper_bandirma_ship.svg` için `<text>` yokluğu ayrıca doğrulanmalı
    - _Gereksinimler: 1.3, 1.6, 9.2, 11.3, 13.1, 13.2, 13.3, 13.5_

  - [ ]* 6.2 PBT: Builder özelliklerini test et
    - `BANDIRMA_PAPER_*` sabit sayısı ile klasördeki SVG sayısı eşleşmeli
    - `_build_ship()` sonrası sahnede tekrar eden büyük ship sprite yapısı bulunmamalı
    - Landmark odak noktaları ekran içinde kalmalı
    - Test dosyası: `test/test_bandirma_builder_properties.gd`
    - _Gereksinimler: 3.1, 6.4, 11.2, 12.4_

- [ ] 7. Final Checkpoint — Tüm testler geçmeli
  - Bandırma asset seti tam olmalı
  - `textures.gd` içinde `BANDIRMA_PAPER_*` sabitleri mevcut olmalı
  - `_build_ship()` paper layer ile çalışmalı
  - `test/test_bandirma_svg_validity.gd` mevcut olmalı ve geçmeli
  - Soru varsa kullanıcıya sor

---

## Notlar

- `ship` area key'i korunur; asset klasörü ve spec adı `bandirma` olarak kalır
- `*` ile işaretli görevler opsiyoneldir; MVP için atlanabilir
- `paper_bandirma_ship.svg` mevcut sürümündeki `<text>` öğesi mutlaka kaldırılmalıdır
- `paper_telegraph_props.svg` dosya adı korunabilir, ancak içerik ship scene'e uygun dock signal/rota prop grubu olarak yeniden tasarlanmalıdır
- `_decorate_ship()` içindeki küçük atmosferik bulut/smoke detayları tamamen kaldırılmak zorunda değildir; yalnızca büyük yapısal tekrarlar temizlenmelidir

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "2.1", "2.2", "2.3", "2.4", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6"] },
    { "id": 1, "tasks": ["4"] },
    { "id": 2, "tasks": ["5.1", "5.2", "5.3", "5.4"] },
    { "id": 3, "tasks": ["6.1", "6.2"] },
    { "id": 4, "tasks": ["7"] }
  ]
}
```