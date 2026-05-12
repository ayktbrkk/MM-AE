# Uygulama Planı: Amasya Asset Kit

## Genel Bakış

Bu plan, `amasya` bölgesi için mevcut 5 SVG dosyasını paper diorama üretim standardına yükseltir, `textures.gd` içine 5 yeni `AMASYA_PAPER_*` sabiti ekler, `_add_amasya_paper_asset_layer()` fonksiyonunu oluşturur ve `_build_amasya_world()` içine entegre eder. `_decorate_amasya()` ve `_add_paper_cutout_asset()` çağrı parametreleri değişmez; yalnızca SVG içerikleri ve üç GDScript değişikliği uygulanır.

Uygulama dili: **GDScript 2.0** (Godot 4.6.2)

---

## Görevler

### Wave 0 — SVG Yükseltme (Paralel)

- [ ] 1. `paper_sky_amasya.svg` dosyasını yükselt
  - `viewBox="0 0 1500 760"` — genişlik 1500px, yükseklik 760px
  - 3–4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.18"` (gökyüzü kenar gölgesi)
    - Katman 2 — Gökyüzü: `fill="#292C39"` (derin lacivert akşam gökyüzü, tüm viewBox)
    - Katman 3 — Dağ silüeti: `fill="#1A2A3A"` `opacity="0.28"` (uzak dağ tepeleri)
    - Katman 4 — Ay parıltısı: `fill="#F2BE63"` `opacity="0.28"` (hilal/parıltı vurgusu)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Yasak elementler yok: `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>`
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.1, 1.2, 1.3, 1.5, 1.6, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4, 12.3, 13.1, 13.4_

- [ ] 2. `paper_terrain_amasya.svg` dosyasını yükselt
  - `viewBox="0 0 800 600"` — genişlik 800px, yükseklik 600px
  - 4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.18"` (arazi kenar gölgesi)
    - Katman 2 — Arazi: `fill="#7A5A42"` (ceviz kahvesi vadi zemini)
    - Katman 3 — Koyu vurgu: `fill="#4A3A2A"` `opacity="0.80"` (derin arazi katmanı)
    - Katman 4 — Kızıl vurgu: `fill="#C84B3D"` `opacity="0.26"` (akşam ışığı yansıması)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Yasak elementler yok: `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>`
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.1, 1.2, 1.3, 1.5, 1.6, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 5.4, 13.4_

- [ ] 3. `paper_main_path.svg` dosyasını yükselt
  - `viewBox="0 0 920 900"` — genişlik 920px, yükseklik 900px
  - 4–5 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.14"` (patika kenar gölgesi)
    - Katman 2 — Ana patika: `fill="#E8DFC8"` (krem taş döşeli yüzey)
    - Katman 3 — Sol dallanma: `fill="#E8DFC8"` `opacity="0.80"` (sol yol kolu)
    - Katman 4 — Sağ dallanma: `fill="#E8DFC8"` `opacity="0.78"` (sağ yol kolu)
    - Katman 5 — Gece vurgusu (opsiyonel): `fill="#292C39"` `opacity="0.25"` (patika gölge örtüsü)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Yasak elementler yok: `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>`
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.1, 1.2, 1.3, 1.5, 1.6, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5, 6.1, 6.2, 6.3, 6.4, 13.4_

- [ ] 4. `paper_congress_hall.svg` dosyasını yükselt
  - `viewBox="0 0 600 400"` — genişlik 600px, yükseklik 400px
  - 4–5 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.18"` (bina kenar gölgesi)
    - Katman 2 — Bina gövdesi: `fill="#E8DFC8"` (krem taş cephe)
    - Katman 3 — Alınlık: `fill="#C84B3D"` (kızıl üçgen alınlık)
    - Katman 4 — Sütunlar: `fill="#F2BE63"` `opacity="0.85"` (altın sütun vurguları)
    - Katman 5 — Kapı/Pencereler: `fill="#2B2730"` `opacity="0.70"` (koyu giriş detayları)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Yasak elementler yok: `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>`
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.1, 1.2, 1.3, 1.5, 1.6, 2.2, 3.1, 3.2, 3.3, 3.4, 3.5, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 13.4_

- [ ] 5. `paper_foreground_frame.svg` dosyasını yükselt
  - `viewBox="0 0 1600 780"` — genişlik 1600px, yükseklik 780px
  - 3 `<path>` elementi:
    - Katman 1 — Sol dağ silueti: `fill="#1A2A3A"` `opacity="0.90"` (sol dağ silüeti)
    - Katman 2 — Sağ dağ silueti: `fill="#1A2A3A"` `opacity="0.88"` (sağ dağ/minare silüeti)
    - Katman 3 — Zemin bandı: `fill="#292C39"` `opacity="0.86"` (alt zemin bandı)
  - Tüm `<path>` elementlerinde `opacity > 0.85`
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Yasak elementler yok: `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>`
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.1, 1.2, 1.3, 1.5, 1.6, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5, 8.1, 8.2, 8.3, 8.4, 12.2, 13.4_

---

### Wave 1 — Checkpoint

- [ ] 6. Checkpoint — 5 SVG dosyasını doğrula
  - Görevler 1–5 tamamlandıktan sonra tüm SVG dosyalarını doğrula
  - Her dosyada `xmlns="http://www.w3.org/2000/svg"` mevcut
  - Her dosyada `<path>` sayısı 2–5 arasında
  - Yasak elementler yok: `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>`
  - Yalnızca büyük harf (mutlak) koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - Her dosyanın disk boyutu < 50 KB
  - viewBox boyutları design.md'deki tabloya uygun:
    - `paper_sky_amasya.svg` → `"0 0 1500 760"`
    - `paper_terrain_amasya.svg` → `"0 0 800 600"`
    - `paper_main_path.svg` → `"0 0 920 900"`
    - `paper_congress_hall.svg` → `"0 0 600 400"`
    - `paper_foreground_frame.svg` → `"0 0 1600 780"`
  - Soru varsa kullanıcıya sor

---

### Wave 2 — Kod Güncellemeleri (Paralel)

- [ ] 7. `textures.gd` güncelle — 5 `AMASYA_PAPER_*` sabiti ekle
  - `scripts/textures.gd` içine yeni bölüm ekle:
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
  - Mevcut sabitlerden hiçbirini silme veya yeniden adlandırma
  - Bölüm başlığı formatı diğer bölümlerle aynı olmalı
  - Dosya: `scripts/textures.gd`
  - _Gereksinimler: 9.1, 9.2, 9.4_

- [ ] 8. `_add_amasya_paper_asset_layer()` fonksiyonunu oluştur
  - `scripts/world_builder.gd` içine yeni fonksiyon ekle
  - design.md'deki parallax tablosuna göre 5 `_add_paper_cutout_asset()` çağrısı:
    - `AMASYA_PAPER_SKY_TEXTURE` → `Vector2(800, 380)`, scale 1.05, opacity 0.88, z-index -18, parallax -15.0, slot `amasya.depth.sky`
    - `AMASYA_PAPER_TERRAIN_TEXTURE` → `Vector2(800, 1100)`, scale 1.10, opacity 0.90, z-index -14, parallax -3.5, slot `amasya.depth.terrain`
    - `AMASYA_PAPER_MAIN_PATH_TEXTURE` → `Vector2(800, 1300)`, scale 0.82, opacity 0.86, z-index -10, parallax -1.5, slot `amasya.path.main`
    - `AMASYA_PAPER_CONGRESS_HALL_TEXTURE` → `Vector2(800, 1450)`, scale 0.88, opacity 0.90, z-index -5, parallax 2.0, slot `amasya.landmark.congress_hall`
    - `AMASYA_PAPER_FOREGROUND_FRAME_TEXTURE` → `Vector2(800, 1850)`, scale 1.12, opacity 0.90, z-index 4, parallax 18.0, slot `amasya.foreground.frame`
  - `world_builder.gd` içinde `preload("res://assets/art/world/amasya/` ile başlayan doğrudan `preload()` çağrısı bulunmamalı
  - Dosya: `scripts/world_builder.gd`
  - _Gereksinimler: 9.3, 10.1, 12.1_

- [ ] 9. `_build_amasya_world()` fonksiyonunu güncelle
  - `scripts/world_builder.gd` içindeki `_build_amasya_world()` fonksiyonuna aşağıdaki değişiklikleri uygula:
    - `_add_rect(world_root, Vector2.ZERO, WORLD_SIZE, Color(0.12, 0.15, 0.20))` çağrısından sonra `_add_amasya_paper_asset_layer(world_root)` ekle
    - `_decorate_amasya(world_root)` çağrısından sonra `emit_signal("world_built", "amasya")` ekle
    - Mevcut `_add_rect()` ve `_add_rift_cloud()` çağrıları korunabilir (base background için)
  - `_build_amasya_world()` içinde `func _process(delta)` çağrısı veya `while` döngüsü bulunmamalı
  - `_build_amasya_world()` içinde `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturulmamalı
  - `_build_amasya_world()` içinde `Sprite2D.new()` veya `Node2D.new()` gibi doğrudan node oluşturma çağrısı bulunmamalı
  - Dosya: `scripts/world_builder.gd`
  - _Gereksinimler: 10.1, 10.2, 10.3, 10.4, 10.5, 11.1, 11.2, 14.1, 14.2, 14.3_

---

### Wave 3 — Test

- [ ] 10. SVG geçerlilik test dosyasını oluştur
  - `test/test_amasya_svg_validity.gd` dosyasını oluştur
  - Havza test dosyasıyla (`test/test_havza_svg_validity.gd`) aynı pattern'i izle
  - Her SVG dosyasında `xmlns="http://www.w3.org/2000/svg"` mevcut olduğunu doğrula
  - `style` attribute, `<defs>`, `<text>`, `<image>`, `<use>`, `<symbol>` olmadığını doğrula
  - Yalnızca mutlak koordinat komutları (`M`, `L`, `C`, `Q`, `A`, `Z`) kullanıldığını doğrula
  - `<path>` sayısının her dosyada 2–5 arasında olduğunu doğrula
  - viewBox boyutlarının design.md'deki tabloya uygun olduğunu doğrula:
    - `paper_sky_amasya.svg` → `"0 0 1500 760"`
    - `paper_terrain_amasya.svg` → `"0 0 800 600"`
    - `paper_main_path.svg` → `"0 0 920 900"`
    - `paper_congress_hall.svg` → `"0 0 600 400"`
    - `paper_foreground_frame.svg` → `"0 0 1600 780"`
  - Yasak elementler (`<rect>`, `<circle>`, `<ellipse>`, `<g>`) olmadığını doğrula
  - Test dosyası: `test/test_amasya_svg_validity.gd`
  - _Gereksinimler: 1.3, 1.6, 3.1, 3.2, 3.3, 3.4, 3.5, 13.4_

---

### Wave 4 — Final Checkpoint

- [ ] 11. Final Checkpoint — Tüm testler geçmeli
  - Tüm görevler tamamlandıktan sonra aşağıdakileri doğrula:
  - 5 SVG dosyası `assets/art/world/amasya/` dizininde mevcut ve geçerli
  - `scripts/textures.gd` içinde 5 `AMASYA_PAPER_*` sabiti mevcut
  - `_add_amasya_paper_asset_layer()` fonksiyonu 5 asset yüklüyor (parallax tablosuna uygun)
  - `_build_amasya_world()` içinde `_add_amasya_paper_asset_layer(world_root)` çağrısı mevcut
  - `_build_amasya_world()` içinde `emit_signal("world_built", "amasya")` çağrısı mevcut
  - `test/test_amasya_svg_validity.gd` dosyası mevcut ve testler geçiyor
  - Soru varsa kullanıcıya sor

---

## Notlar

- Görevler 1–5 birbirinden bağımsız olarak tamamlanabilir; paralel çalışmaya uygundur
- Görev 6 (Checkpoint), Görevler 1–5 tamamlandıktan sonra çalıştırılmalıdır
- Görevler 7–9 birbirinden bağımsız olarak tamamlanabilir; ancak Görev 8, Görev 7'nin tamamlanmasına bağlıdır (`AMASYA_PAPER_*` sabitlerinin mevcut olması gerekir)
- Görev 9, Görev 8'in tamamlanmasına bağlıdır (`_add_amasya_paper_asset_layer()` fonksiyonunun mevcut olması gerekir)
- Gölge `<path>` elementleri her zaman diğer `<path>` elementlerinin önünde (SVG belgesinde ilk sırada) yer almalıdır
- `_add_paper_cutout_asset()` çağrı parametreleri (pozisyon, scale, z-index, parallax) design.md'deki parallax tablosundan alınmalıdır
- `paper_foreground_frame.svg` için tüm `<path>` elementlerinde `opacity > 0.85` kuralı geçerlidir
- Mevcut `_add_rect()` ve `_add_rift_cloud()` çağrıları `_build_amasya_world()` içinde korunabilir; paper asset layer bu çağrıların üzerine eklenir

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1", "2", "3", "4", "5"] },
    { "id": 1, "tasks": ["6"] },
    { "id": 2, "tasks": ["7", "8", "9"] },
    { "id": 3, "tasks": ["10"] },
    { "id": 4, "tasks": ["11"] }
  ]
}
```
