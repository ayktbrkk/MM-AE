# Uygulama Planı: Room Asset Kit

## Genel Bakış

Bu plan, `room` bölgesi için mevcut düşük kaliteli SVG asset'lerini paper diorama üretim standardına yükseltir, `_add_room_paper_asset_layer()` fonksiyonunu 10 asset'i yükleyecek şekilde genişletir ve `_build_room()` içinden çağrılmasını sağlar. `textures.gd` içine eksik `ROOM_PAPER_TERRAIN_TEXTURE` sabiti eklenir. `colors.gd` ve `_add_paper_cutout_asset()` çağrı parametreleri değişmez; yalnızca SVG içerikleri ve iki GDScript fonksiyonu güncellenir.

Uygulama dili: **GDScript 2.0** (Godot 4.6.2)

---

## Görevler

- [ ] 1. `paper_wall_window.svg` dosyasını yükselt
  - `viewBox="0 0 1500 780"` — genişlik 1500px, yükseklik 780px
  - 4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.18"` (duvar kenar gölgesi)
    - Katman 2 — Duvar: `fill="#20344F"` (tüm viewBox'ı kaplayan arka plan)
    - Katman 3 — Pencere camı: `fill="#47B2C2"` `opacity="0.72"` (dikdörtgen cam yüzeyi)
    - Katman 4 — Pencere çerçevesi: `fill="none"` `stroke="#7A5A42"` `stroke-width="12"` (ahşap çerçeve outline)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 4.1, 4.2, 4.3, 4.4, 16.1, 16.4_

- [ ] 2. `paper_wall_story.svg` dosyasını yükselt
  - `viewBox="0 0 900 420"` — genişlik 900px, yükseklik 420px
  - 3–4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#2b2730"` `opacity="0.16"` (çerçeve altı gölge)
    - Katman 2 — Çerçeve 1: `fill="#7A5A42"` (sol çerçeve silueti)
    - Katman 3 — Çerçeve 2: `fill="#2B2730"` (orta çerçeve silueti)
    - Katman 4 — Çerçeve 3 (opsiyonel): `fill="#7A5A42"` `opacity="0.80"` (sağ küçük çerçeve)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 5.1, 5.2, 5.3, 16.1, 16.4_

- [ ] 3. `paper_terrain_room.svg` dosyasını yükselt
  - `viewBox="0 0 800 600"` — genişlik 800px, yükseklik 600px
  - 3 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.14"` (zemin kenar gölgesi)
    - Katman 2 — Zemin: `fill="#E89863"` (ana zemin yüzeyi)
    - Katman 3 — Zemin vurgusu: `fill="#F2BE63"` `opacity="0.30"` (lamba ışığı yansıması)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 6.1, 6.2, 16.1, 16.4_

- [ ] 4. `paper_shelf.svg` dosyasını yükselt
  - `viewBox="0 0 520 760"` — genişlik 520px, yükseklik 760px
  - 4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.20"` (kitaplık yan gölgesi)
    - Katman 2 — Gövde: `fill="#7A5A42"` (kitaplık çerçevesi ve raflar)
    - Katman 3 — Kitaplar: `fill="#F5E8D3"` (kitap sırtı siluetleri)
    - Katman 4 — Vurgu kitap: `fill="#F2BE63"` `opacity="0.85"` (öne çıkan kitap)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 7.1, 7.2, 7.3, 16.1, 16.4_

- [ ] 5. `paper_desk_clutter.svg` dosyasını yükselt
  - `viewBox="0 0 520 300"` — genişlik 520px, yükseklik 300px
  - 5 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#2b2730"` `opacity="0.16"` (eşya altı gölge)
    - Katman 2 — Kitaplar: `fill="#F5E8D3"` (istiflenmiş kitap silueti)
    - Katman 3 — Hokka: `fill="#2B2730"` (mürekkep hokkası silueti)
    - Katman 4 — Kalem: `fill="#F2BE63"` `opacity="0.90"` (tüy kalem silueti)
    - Katman 5 — Vurgu: `fill="#7A5A42"` `opacity="0.70"` (ahşap masa yüzeyi detayı)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 8.1, 8.2, 16.1, 16.4_

- [ ] 6. `paper_study_nook.svg` dosyasını yükselt
  - `viewBox="0 0 720 520"` — genişlik 720px, yükseklik 520px
  - 4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.18"` (masa altı gölge)
    - Katman 2 — Masa: `fill="#7A5A42"` (ahşap masa silueti)
    - Katman 3 — Lamba: `fill="#2B2730"` (lamba gövdesi silueti)
    - Katman 4 — Lamba ışıltısı: `fill="#F2BE63"` `opacity="0.55"` (altın ışık halesi)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 8.3, 8.4, 16.1, 16.4_

- [ ] 7. `paper_bed.svg` dosyasını yükselt
  - `viewBox="0 0 720 520"` — genişlik 720px, yükseklik 520px
  - 4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.20"` (yatak altı gölge)
    - Katman 2 — Çerçeve: `fill="#7A5A42"` (ahşap yatak çerçevesi)
    - Katman 3 — Örtü: `fill="#F5E8D3"` (yatak örtüsü yüzeyi)
    - Katman 4 — Yastık: `fill="#E89863"` `opacity="0.80"` (yastık silueti)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 9.1, 9.2, 9.3, 9.4, 16.1, 16.4_

- [ ] 8. `paper_floor_rug.svg` dosyasını yükselt
  - `viewBox="0 0 980 560"` — genişlik 980px, yükseklik 560px
  - 4 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.14"` (halı kenar gölgesi)
    - Katman 2 — Halı gövdesi: `fill="#E89863"` (oval halı ana yüzeyi)
    - Katman 3 — Desen: `fill="#7A5A42"` `opacity="0.65"` (geometrik iç desen)
    - Katman 4 — Kenar şeridi: `fill="#F2BE63"` `opacity="0.70"` (halı kenar bordürü)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 6.3, 6.4, 16.1, 16.4_

- [ ] 9. `paper_book_portal.svg` dosyasını yükselt
  - `viewBox="0 0 420 340"` — genişlik 420px, yükseklik 340px
  - 4–5 `<path>` elementi:
    - Katman 1 — Gölge: `fill="#1a2a3a"` `opacity="0.18"` (kitap altı gölge)
    - Katman 2 — Kitap gövdesi: `fill="#F5E8D3"` (açık kitap silueti)
    - Katman 3 — Altın ışıltı: `fill="#F2BE63"` `opacity="0.42"` (portal altın parıltısı)
    - Katman 4 — Mavi ışıltı: `fill="#47B2C2"` `opacity="0.35"` (portal mavi parıltısı)
    - Katman 5 — Vurgu (opsiyonel): `fill="#F5E8D3"` `opacity="0.80"` (sayfa kenar vurgusu)
  - `paper_book_portal.svg` için 5 benzersiz renk kuralı istisnası geçerlidir
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 10.1, 10.2, 10.3, 10.4, 10.5, 16.1, 16.4_

- [ ] 10. `paper_foreground_frame.svg` dosyasını yükselt
  - `viewBox="0 0 1600 780"` — genişlik 1600px, yükseklik 780px
  - 2–3 `<path>` elementi:
    - Katman 1 — Sol siluet: `fill="#2B2730"` `opacity="0.92"` (sol kenar ön plan)
    - Katman 2 — Sağ siluet: `fill="#20344F"` `opacity="0.90"` (sağ kenar ön plan)
    - Katman 3 — Üst bant (opsiyonel): `fill="#2B2730"` `opacity="0.88"` (üst kenar karartma)
  - Yalnızca mutlak koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - `style` attribute, `<defs>`, `<text>`, `<image>` yok; `xmlns` bildirimi var
  - Disk boyutu < 50 KB
  - _Gereksinimler: 1.3, 1.6, 2.1, 2.2, 3.1, 3.2, 11.1, 11.2, 11.3, 15.3, 16.1, 16.4_

- [ ] 11. Checkpoint — 10 SVG dosyasını doğrula
  - Görevler 1–10 tamamlandıktan sonra tüm SVG dosyalarını doğrula
  - Her dosyada `xmlns="http://www.w3.org/2000/svg"` mevcut
  - Her dosyada `<path>` sayısı 2–5 arasında (`paper_book_portal.svg` en fazla 5)
  - Yasak elementler yok: `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>`
  - Yalnızca büyük harf (mutlak) koordinat komutları: `M`, `L`, `C`, `Q`, `A`, `Z`
  - Her dosyanın disk boyutu < 50 KB
  - viewBox boyutları design.md'deki tabloya uygun
  - Soru varsa kullanıcıya sor

- [ ] 12. `textures.gd` güncelle — `ROOM_PAPER_TERRAIN_TEXTURE` sabitini ekle
  - `scripts/textures.gd` içindeki `# ROOM PAPER CUTOUT (özel asset)` bölümüne eksik sabiti ekle:
    ```gdscript
    const ROOM_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/room/paper_terrain_room.svg")
    ```
  - Mevcut 9 `ROOM_PAPER_*` sabitinin hiçbirini silme veya yeniden adlandırma
  - Yeni sabit mevcut sabitlerden sonra aynı bölüm içine eklenmelidir
  - Dosya: `scripts/textures.gd`
  - _Gereksinimler: 12.1, 12.2, 12.4_

- [ ] 13. `_add_room_paper_asset_layer()` fonksiyonunu genişlet
  - `scripts/world_builder.gd` içindeki `_add_room_paper_asset_layer()` fonksiyonunu 10 asset çağrısını içerecek şekilde güncelle
  - design.md'deki parallax tablosuna göre tüm `_add_paper_cutout_asset()` çağrılarını ekle:
    - `ROOM_PAPER_WALL_TEXTURE` → `Vector2(800, 410)`, scale 1.0, opacity 0.86, z-index -6, parallax -2.0, slot `paperroom.wall_window`
    - `ROOM_PAPER_WALL_STORY_TEXTURE` → `Vector2(460, 320)`, scale 0.90, opacity 0.78, z-index -5, parallax -1.8, slot `paperroom.wall_story`
    - `ROOM_PAPER_TERRAIN_TEXTURE` → `Vector2(800, 1580)`, scale 1.05, opacity 0.88, z-index -9, parallax -3.0, slot `paperroom.terrain`
    - `ROOM_PAPER_SHELF_TEXTURE` → `Vector2(60, 900)`, scale 0.82, opacity 0.84, z-index -7, parallax -1.5, slot `paperroom.shelf`
    - `ROOM_PAPER_DESK_CLUTTER_TEXTURE` → `Vector2(1100, 1260)`, scale 0.78, opacity 0.82, z-index -4, parallax -1.0, slot `paperroom.desk_clutter`
    - `ROOM_PAPER_STUDY_NOOK_TEXTURE` → `Vector2(860, 1280)`, scale 0.80, opacity 0.86, z-index -3, parallax -0.8, slot `paperroom.study_nook`
    - `ROOM_PAPER_BED_TEXTURE` → `Vector2(340, 1380)`, scale 0.84, opacity 0.88, z-index -4, parallax -1.2, slot `paperroom.bed`
    - `ROOM_PAPER_FLOOR_RUG_TEXTURE` → `Vector2(800, 1620)`, scale 0.92, opacity 0.76, z-index -8, parallax -2.5, slot `paperroom.floor_rug`
    - `ROOM_PAPER_BOOK_PORTAL_TEXTURE` → `Vector2(800, 1100)`, scale 0.72, opacity 0.92, z-index -2, parallax 0.5, slot `paperroom.book_portal`
    - `ROOM_PAPER_FOREGROUND_FRAME_TEXTURE` → `Vector2(800, 1850)`, scale 1.10, opacity 0.88, z-index 4, parallax 2.0, slot `paperroom.foreground_frame`
  - `world_builder.gd` içinde `preload("res://assets/art/world/room/` ile başlayan doğrudan `preload()` çağrısı bulunmamalı
  - Dosya: `scripts/world_builder.gd`
  - _Gereksinimler: 12.3, 13.1, 13.3, 14.1, 15.1_

- [ ] 14. `_build_room()` fonksiyonunu güncelle
  - `scripts/world_builder.gd` içindeki `_build_room()` fonksiyonuna aşağıdaki çağrıları ekle:
    - `_add_room_paper_asset_layer(world_root)` — mevcut `_add_open_world_start_asset_layer()` çağrısından sonra
    - `_add_room_depth_pass(world_root)` — `_add_room_paper_asset_layer()` çağrısından sonra
  - Mevcut çağrılar korunmalı: `_add_open_world_start_depth_pass()`, `_add_open_world_start_asset_layer()`, `_snap_room_characters_to_floor()`, `_decorate_room()`
  - `_build_room()` içinde `func _process(delta)` çağrısı veya `while` döngüsü bulunmamalı
  - `_build_room()` içinde `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturulmamalı
  - `_build_room()` içinde `Sprite2D.new()` veya `Node2D.new()` gibi doğrudan node oluşturma çağrısı bulunmamalı
  - Dosya: `scripts/world_builder.gd`
  - _Gereksinimler: 13.1, 13.2, 13.4, 14.1, 14.3_

- [ ] 15. SVG geçerlilik test dosyasını oluştur
  - `test/test_room_svg_validity.gd` dosyasını oluştur
  - Samsun test dosyasıyla (`test/test_samsun_svg_validity.gd`) aynı pattern'i izle
  - Her SVG dosyasında `xmlns="http://www.w3.org/2000/svg"` mevcut olduğunu doğrula
  - `style` attribute, `<defs>`, `<text>`, `<image>`, `<use>`, `<symbol>` olmadığını doğrula
  - Yalnızca mutlak koordinat komutları (`M`, `L`, `C`, `Q`, `A`, `Z`) kullanıldığını doğrula
  - `<path>` sayısının her dosyada 2–5 arasında olduğunu doğrula
  - viewBox boyutlarının design.md'deki tabloya uygun olduğunu doğrula:
    - `paper_wall_window.svg` → `"0 0 1500 780"`
    - `paper_wall_story.svg` → `"0 0 900 420"`
    - `paper_terrain_room.svg` → `"0 0 800 600"`
    - `paper_shelf.svg` → `"0 0 520 760"`
    - `paper_desk_clutter.svg` → `"0 0 520 300"`
    - `paper_study_nook.svg` → `"0 0 720 520"`
    - `paper_bed.svg` → `"0 0 720 520"`
    - `paper_floor_rug.svg` → `"0 0 980 560"`
    - `paper_book_portal.svg` → `"0 0 420 340"`
    - `paper_foreground_frame.svg` → `"0 0 1600 780"`
  - Test dosyası: `test/test_room_svg_validity.gd`
  - _Gereksinimler: 1.3, 1.6, 3.1, 3.2, 3.3, 3.4, 16.1, 16.4, 16.5_

- [ ] 16. Final Checkpoint — Tüm testler geçmeli
  - Tüm görevler tamamlandıktan sonra aşağıdakileri doğrula:
  - 10 SVG dosyası `assets/art/world/room/` dizininde mevcut ve geçerli
  - `scripts/textures.gd` içinde `ROOM_PAPER_TERRAIN_TEXTURE` sabiti mevcut
  - `_add_room_paper_asset_layer()` 10 asset yüklüyor (parallax tablosuna uygun)
  - `_build_room()` içinde `_add_room_paper_asset_layer(world_root)` çağrısı mevcut
  - `_build_room()` içinde `_add_room_depth_pass(world_root)` çağrısı mevcut
  - `test/test_room_svg_validity.gd` dosyası mevcut ve testler geçiyor
  - Soru varsa kullanıcıya sor

---

## Notlar

- Görevler 1–10 birbirinden bağımsız olarak tamamlanabilir; paralel çalışmaya uygundur
- Görev 11 (Checkpoint), Görevler 1–10 tamamlandıktan sonra çalıştırılmalıdır
- Görevler 12–14 birbirinden bağımsız olarak tamamlanabilir; ancak Görev 13, Görev 12'nin tamamlanmasına bağlıdır (`ROOM_PAPER_TERRAIN_TEXTURE` sabitinin mevcut olması gerekir)
- `paper_book_portal.svg` için 5 benzersiz renk kuralı istisnası geçerlidir; ışıltı katmanları için ek renkler kullanılabilir
- Gölge `<path>` elementleri her zaman diğer `<path>` elementlerinin önünde (SVG belgesinde ilk sırada) yer almalıdır
- `_add_paper_cutout_asset()` çağrı parametreleri (pozisyon, scale, z-index, parallax) design.md'deki parallax tablosundan alınmalıdır
- `_add_soft_blob()` çağrıları `_decorate_room()` içinde kalır; `_build_room()` içine taşınmaz

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"] },
    { "id": 1, "tasks": ["11"] },
    { "id": 2, "tasks": ["12", "13", "14"] },
    { "id": 3, "tasks": ["15"] },
    { "id": 4, "tasks": ["16"] }
  ]
}
```
