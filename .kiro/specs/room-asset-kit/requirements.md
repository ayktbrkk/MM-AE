# Gereksinimler Belgesi — Room Asset Kit

## Introduction

Bu belge, "Bandırma Yolculuğu" oyununun `room` bölgesi için paper diorama asset kitinin gereksinimlerini tanımlar. Hedef, `assets/art/world/room/` dizinindeki 10 SVG dosyasını, Samsun Asset Kit ile belirlenen paper diorama üretim standardına yükseltmektir.

Oyun; Godot 4.6.2 ile geliştirilmiş, 5-10 yaş hedef kitlesine yönelik eğitici tarih macerası oyunudur. Android portrait (1080×1920, 9:16) platformunda çalışır. `room` bölgesi (`area_key = "room"`), oyuncunun yolculuğuna başladığı ilk sahnedir: gece vakti, sıcak lamba ışığıyla aydınlatılmış, 1919 dönemine ait kitaplıklı ve masalı bir öğrenci yatak odası. Mevcut 10 SVG dosyası `<rect>`, `<circle>`, `<ellipse>`, `<g>` gibi yasak elementler içermektedir; bu spec kapsamında tüm dosyalar yalnızca `<path>` elementleri kullanılarak yeniden yazılacaktır.

---

## Glossary

- **Asset_Kit**: `assets/art/world/room/` dizinindeki 10 SVG dosyasının tamamı.
- **World_Builder**: `scripts/world_builder.gd` içindeki `_build_room()` ve `_decorate_room()` fonksiyonları.
- **Textures_Registry**: `scripts/textures.gd` içindeki `ROOM_PAPER_*` sabit grubu.
- **Paper_Diorama_Standard**: Samsun Asset Kit ile belirlenen SVG üretim kuralları — yalnızca `<path>` elementleri, yalnızca mutlak koordinat komutları, maksimum 5 benzersiz renk, 50 KB altı dosya boyutu.
- **Book_Portal**: `paper_book_portal.svg` — oyuncunun zaman yolculuğuna geçiş yaptığı sihirli parlayan kitap asset'i; özel ışıltı efekti gerektirir.
- **DESIGN_DEEP_NAVY**: `#20344F` — duvar arka planı, koyu alanlar.
- **DESIGN_WEATHERED_WALNUT**: `#7A5A42` — ahşap mobilya, raflar.
- **DESIGN_CREAM_PAPER**: `#F5E8D3` — kağıt, kitaplar, açık yüzeyler.
- **DESIGN_ROOM_FLOOR**: `#E89863` — zemin, sıcak turuncu tonlar.
- **DESIGN_STORY_INK**: `#2B2730` — outline, koyu siluetler.
- **POP_GOLD**: `#F2BE63` — vurgu, lamba ışıltısı, öne çıkan detaylar.
- **RIFT_BLUE**: `#47B2C2` — pencere camı, serin vurgular, portal efekti.

---

## Requirements

### Requirement 1: SVG Asset Dosya Seti

**User Story:** Bir oyun sanatçısı olarak, oda bölgesi için eksiksiz bir paper diorama asset seti istiyorum; böylece `_build_room()` fonksiyonu tüm katmanları yükleyebilsin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `assets/art/world/room/` dizininde aşağıdaki 10 SVG dosyasını içermelidir: `paper_wall_window.svg`, `paper_wall_story.svg`, `paper_terrain_room.svg`, `paper_shelf.svg`, `paper_desk_clutter.svg`, `paper_study_nook.svg`, `paper_bed.svg`, `paper_floor_rug.svg`, `paper_book_portal.svg`, `paper_foreground_frame.svg`.

2. THE Asset_Kit SHALL her SVG dosyasını `viewBox="0 0 W H"` tanımıyla üretmelidir; W ve H değerleri kullanıcı tarafından belirtilen orijinal boyutlara (örn. `paper_wall_window.svg` için 1500×780) eşit olmalıdır.

3. THE Asset_Kit SHALL her SVG dosyasında yalnızca `<path>` elementleri kullanmalıdır; `<rect>`, `<circle>`, `<ellipse>`, `<g>`, `<use>`, `<symbol>` elementleri hiçbir dosyada bulunmamalıdır.

4. THE Asset_Kit SHALL her SVG dosyasında en az 2, en fazla 5 `<path>` elementi içermelidir; `paper_book_portal.svg` bu kuralın istisnasıdır ve en fazla 5 `<path>` elementi içerebilir.

5. WHEN bir SVG dosyası Godot 4.6.2 import pipeline'ı tarafından işlendiğinde, THE Asset_Kit SHALL Godot editörünün "Import" sekmesinde hata veya uyarı mesajı üretmemelidir; editör tema uyarıları bu kriterin kapsamı dışındadır; import işlemi gerçekleşmeden önce var olan hatalar bu kriterin kapsamı dışındadır.

6. THE Asset_Kit SHALL her SVG dosyasını iyi biçimlendirilmiş XML olarak üretmelidir: kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` namespace bildirimi içermeli, harici dosya referansı (`xlink:href`, `url()`) içermemeli ve tüm açılan etiketler kapatılmış olmalıdır.

---

### Requirement 2: Paper Diorama Görsel Stili

**User Story:** Bir oyun tasarımcısı olarak, oda asset'lerinin Samsun Asset Kit ile belirlenen paper diorama stiline uymasını istiyorum; böylece tüm bölgeler arasında görsel tutarlılık sağlansın.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG dosyasındaki `<path>` elementlerinde `fill` ve `stroke` renk değerlerini yalnızca oda renk paletinden türetmelidir: `#20344F` (DESIGN_DEEP_NAVY), `#7A5A42` (DESIGN_WEATHERED_WALNUT), `#F5E8D3` (DESIGN_CREAM_PAPER), `#E89863` (DESIGN_ROOM_FLOOR), `#2B2730` (DESIGN_STORY_INK), `#F2BE63` (POP_GOLD), `#47B2C2` (RIFT_BLUE); gölge rengi `#1A2A3A` veya `#2B2730` bu paletten bağımsız olarak kullanılabilir.

2. THE Asset_Kit SHALL gölge amacıyla kullanılan `<path>` elementlerinde `fill="#1a2a3a"` veya `fill="#2b2730"` rengi ile `opacity` attribute değerini 0.14 ile 0.22 arasında kullanmalıdır; gölge `<path>` elementleri diğer `<path>` elementlerinin altında (SVG belgesinde önce) yer almalıdır.

3. THE Asset_Kit SHALL her SVG dosyasında `fill` ve `stroke` attribute'ları genelinde benzersiz renk değeri sayısını maksimum 5 ile sınırlandırmalıdır; `paper_book_portal.svg` portal ışıltısı için bu sınırın dışında tutulabilir.

4. THE Asset_Kit SHALL `stroke` attribute'u kullanan `<path>` elementlerinde `stroke-width` değerini 8 ile 18 piksel arasında kullanmalıdır; böylece 5-10 yaş hedef kitlesine uygun okunabilirlik sağlanır.

5. THE Asset_Kit SHALL her SVG dosyasının disk boyutunu 50 KB'ın altında tutmalıdır; disk boyutu Godot import işlemi öncesi kaynak `.svg` dosyasının boyutunu ifade eder.

---

### Requirement 3: SVG Üretim Standardı (Teknik Uyum)

**User Story:** Bir oyun geliştiricisi olarak, SVG dosyalarının Godot 4.6.2 tarafından sorunsuz içe aktarılmasını ve yalnızca `<path>` elementleri kullanmasını istiyorum; böylece asset pipeline güvenilir ve tutarlı olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG dosyasında `<path>` elementlerinin `d` attribute'unda yalnızca büyük harf (mutlak koordinat) komutları kullanmalıdır: `M`, `L`, `C`, `Q`, `A`, `Z`; küçük harf (göreli koordinat) komutları `m`, `l`, `c`, `q`, `a` kullanılmamalıdır.

2. THE Asset_Kit SHALL SVG dosyalarında `style` attribute'u veya `<defs>` elementi kullanmamalıdır; tüm görsel özellikler `fill`, `stroke`, `stroke-width`, `opacity` attribute'ları olarak doğrudan `<path>` elementlerinde tanımlanmalıdır.

3. THE Asset_Kit SHALL SVG dosyalarında `<text>`, `<tspan>`, `<image>`, `<use>`, `<symbol>` elementleri kullanmamalıdır.

4. THE Asset_Kit SHALL her SVG dosyasını kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` attribute'u ile üretmelidir.

5. IF bir SVG dosyasında `stroke` attribute'u kullanan bir `<path>` elementi varsa, THEN THE Asset_Kit SHALL `stroke-linecap` veya `stroke-linejoin` attribute'larını yalnızca `stroke` attribute'u bulunan `<path>` elementlerinde tanımlamalıdır; `stroke` attribute'u bulunmayan `<path>` elementlerine `stroke-linecap` veya `stroke-linejoin` eklenmemelidir; `<g>` elementi üzerinde grup düzeyinde attribute kullanılmamalıdır.

---

### Requirement 4: Duvar ve Pencere Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_wall_window.svg` dosyasının gece vakti oda duvarını ve penceresini paper diorama stilinde temsil etmesini istiyorum; böylece sahnenin arka plan atmosferi oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_wall_window.svg` dosyasında duvar arka planını `fill="#20344F"` (DESIGN_DEEP_NAVY) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_wall_window.svg` dosyasında pencere çerçevesini ve cam yüzeyini ayrı `<path>` elementleri olarak içermelidir; pencere camı `fill="#47B2C2"` (RIFT_BLUE) renk ailesinden türetilmelidir.

3. THE Asset_Kit SHALL `paper_wall_window.svg` dosyasında gece atmosferini destekleyen en az 1 gölge `<path>` elementi içermelidir; gölge `opacity` değeri 0.14 ile 0.22 arasında olmalıdır.

4. THE Asset_Kit SHALL `paper_wall_window.svg` dosyasını `viewBox="0 0 1500 780"` boyutlarında üretmelidir.

---

### Requirement 5: Duvar Hikaye Çerçeveleri Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_wall_story.svg` dosyasının duvardaki hikaye çerçevelerini paper diorama stilinde temsil etmesini istiyorum; böylece 1919 dönemi oda atmosferi güçlensin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_wall_story.svg` dosyasında en az 2 çerçeve siluetini ayrı `<path>` elementleri olarak içermelidir; çerçeveler `fill="#7A5A42"` (DESIGN_WEATHERED_WALNUT) veya `fill="#2B2730"` (DESIGN_STORY_INK) renk ailesinden türetilmelidir.

2. THE Asset_Kit SHALL `paper_wall_story.svg` dosyasını `viewBox="0 0 900 420"` boyutlarında üretmelidir.

3. THE Asset_Kit SHALL `paper_wall_story.svg` dosyasında en az 1 gölge `<path>` elementi içermelidir; gölge `opacity` değeri 0.14 ile 0.22 arasında olmalıdır.

---

### Requirement 6: Zemin ve Halı Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_terrain_room.svg` ve `paper_floor_rug.svg` dosyalarının oda zeminini ve dekoratif halıyı paper diorama stilinde temsil etmesini istiyorum; böylece sahnenin zemin katmanı oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_terrain_room.svg` dosyasında zemin yüzeyini `fill="#E89863"` (DESIGN_ROOM_FLOOR) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_terrain_room.svg` dosyasını `viewBox="0 0 800 600"` boyutlarında üretmelidir.

3. THE Asset_Kit SHALL `paper_floor_rug.svg` dosyasında dekoratif halı desenini en az 2 `<path>` elementi ile temsil etmelidir; halı renkleri oda paletinden türetilmelidir.

4. THE Asset_Kit SHALL `paper_floor_rug.svg` dosyasını `viewBox="0 0 980 560"` boyutlarında üretmelidir.

---

### Requirement 7: Kitaplık Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_shelf.svg` dosyasının ahşap kitaplığı ve üzerindeki kitapları paper diorama stilinde temsil etmesini istiyorum; böylece 1919 dönemi öğrenci odası atmosferi oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_shelf.svg` dosyasında kitaplık gövdesini `fill="#7A5A42"` (DESIGN_WEATHERED_WALNUT) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_shelf.svg` dosyasında kitap siluetlerini temsil eden en az 1 ek `<path>` elementi içermelidir; kitap renkleri `fill="#F5E8D3"` (DESIGN_CREAM_PAPER) veya `fill="#F2BE63"` (POP_GOLD) renk ailesinden türetilmelidir.

3. THE Asset_Kit SHALL `paper_shelf.svg` dosyasını `viewBox="0 0 520 760"` boyutlarında üretmelidir.

---

### Requirement 8: Masa Eşyaları ve Çalışma Köşesi Asset'leri

**User Story:** Bir oyun tasarımcısı olarak, `paper_desk_clutter.svg` ve `paper_study_nook.svg` dosyalarının masa üstü eşyaları ile çalışma köşesini paper diorama stilinde temsil etmesini istiyorum; böylece öğrenci odası detayları güçlensin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_desk_clutter.svg` dosyasında masa üstü eşyalarını (kitap, kalem, mürekkep hokkası vb.) temsil eden en az 3 `<path>` elementi içermelidir; önerilen aralık 3–5 `<path>` elementidir; eşya renkleri oda paletinden türetilmelidir.

2. THE Asset_Kit SHALL `paper_desk_clutter.svg` dosyasını `viewBox="0 0 520 300"` boyutlarında üretmelidir.

3. THE Asset_Kit SHALL `paper_study_nook.svg` dosyasında masa ve lamba siluetlerini ayrı `<path>` elementleri olarak içermelidir; lamba ışıltısı `fill="#F2BE63"` (POP_GOLD) renk ailesinden türetilmelidir.

4. THE Asset_Kit SHALL `paper_study_nook.svg` dosyasını `viewBox="0 0 720 520"` boyutlarında üretmelidir.

---

### Requirement 9: Yatak Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_bed.svg` dosyasının ahşap çerçeveli yatağı paper diorama stilinde temsil etmesini istiyorum; böylece oda mobilyası tamamlansın.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_bed.svg` dosyasında yatak çerçevesini `fill="#7A5A42"` (DESIGN_WEATHERED_WALNUT) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_bed.svg` dosyasında yatak örtüsünü ve yastığı temsil eden en az 1 ek `<path>` elementi içermelidir; örtü rengi `fill="#F5E8D3"` (DESIGN_CREAM_PAPER) veya `fill="#E89863"` (DESIGN_ROOM_FLOOR) renk ailesinden türetilmelidir.

3. THE Asset_Kit SHALL `paper_bed.svg` dosyasını `viewBox="0 0 720 520"` boyutlarında üretmelidir.

4. THE Asset_Kit SHALL `paper_bed.svg` dosyasında en az 1 gölge `<path>` elementi içermelidir; gölge `opacity` değeri 0.14 ile 0.22 arasında olmalıdır.

---

### Requirement 10: Kitap Portalı Asset'i (Özel Efekt)

**User Story:** Bir oyun tasarımcısı olarak, `paper_book_portal.svg` dosyasının zaman yolculuğu geçiş noktası olan sihirli parlayan kitabı temsil etmesini istiyorum; böylece portal görsel olarak belirgin ve büyülü bir atmosfer taşısın.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_book_portal.svg` dosyasında açık kitap siluetini temsil eden en az 1 `<path>` elementi içermelidir; kitap `fill="#F5E8D3"` (DESIGN_CREAM_PAPER) renk ailesinden türetilmelidir.

2. THE Asset_Kit SHALL `paper_book_portal.svg` dosyasında portal ışıltısını temsil eden en az 2 yarı-saydam `<path>` elementi içermelidir; ışıltı elementleri `fill="#F2BE63"` (POP_GOLD) veya `fill="#47B2C2"` (RIFT_BLUE) renk ailesinden türetilmeli ve `opacity` değerleri 0.18 ile 0.45 arasında olmalıdır.

3. THE Asset_Kit SHALL `paper_book_portal.svg` dosyasını `viewBox="0 0 420 340"` boyutlarında üretmelidir.

4. THE Asset_Kit SHALL `paper_book_portal.svg` dosyasında toplam `<path>` sayısını en fazla 5 ile sınırlandırmalıdır: 1 gölge `<path>` + 1 kitap gövdesi `<path>` + 2 ışıltı `<path>` + 1 opsiyonel vurgu `<path>`.

5. IF `paper_book_portal.svg` dosyasında ışıltı efekti için 5'ten fazla benzersiz renk gerekiyorsa, THEN THE Asset_Kit SHALL bu dosyayı maksimum 5 benzersiz renk kuralının istisnası olarak değerlendirmelidir; ek renkler yalnızca ışıltı katmanları için kullanılabilir.

---

### Requirement 11: Ön Plan Çerçeve Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_foreground_frame.svg` dosyasının ekranın sol ve sağ kenarlarını kapatan ön plan siluetini temsil etmesini istiyorum; böylece diorama derinlik hissi güçlensin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasında ön plan siluetlerini oluşturan `<path>` elementlerinde `fill="#2B2730"` (DESIGN_STORY_INK) veya `fill="#20344F"` (DESIGN_DEEP_NAVY) renk değerini kullanmalıdır; bu elementlerde `opacity` değeri 0.85'ten büyük olmalıdır.

2. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasını `viewBox="0 0 1600 780"` boyutlarında üretmelidir; viewBox genişliği 1600 piksel olmalıdır.

3. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasında en az 2 `<path>` elementi içermelidir: sol kenar silueti ve sağ kenar silueti.

---

### Requirement 12: Textures Registry Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, tüm oda SVG asset'lerinin `textures.gd` içinde merkezi sabitler olarak tanımlanmasını istiyorum; böylece DRY prensibi korunur ve asset yolları tek noktadan yönetilir.

#### Acceptance Criteria

1. THE Textures_Registry SHALL `scripts/textures.gd` içinde `res://assets/art/world/room/` dizinindeki her SVG dosyası için `const ROOM_PAPER_[ASSET_ADI]_TEXTURE := preload("res://assets/art/world/room/[dosya_adı].svg")` formatında tam olarak bir sabit tanımlamalıdır; sabit sayısı `res://assets/art/world/room/` dizinindeki SVG dosyası sayısına eşit olmalıdır.

2. THE Textures_Registry SHALL oda sabitlerini `scripts/textures.gd` içinde `# ====================================` açılış satırı, ardından `# ROOM PAPER CUTOUT (özel asset)` başlık satırı, ardından `# ====================================` kapanış satırından oluşan bölüm başlığı altında gruplandırmalıdır.

3. WHEN `world_builder.gd` bir oda asset'i yüklemek istediğinde, THE World_Builder SHALL `_textures.ROOM_PAPER_[ASSET_ADI]_TEXTURE` sabitini kullanmalıdır; `world_builder.gd` içinde `preload("res://assets/art/world/room/` ile başlayan hiçbir doğrudan `preload()` çağrısı bulunmamalıdır.

4. THE Textures_Registry SHALL `scripts/textures.gd` içindeki mevcut `ROOM_PAPER_*` sabitlerinin hiçbirini silmemeli veya yeniden adlandırmamalıdır; yeni sabitler mevcut sabitlerden sonra aynı bölüm içine eklenmelidir.

---

### Requirement 13: World Builder Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, `_build_room()` fonksiyonunun mevcut `_build_*` pattern'ini izlemesini istiyorum; böylece kod tabanı tutarlılığı korunur.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_room()` içinde SVG asset'leri `_add_paper_cutout_asset()` yardımcı fonksiyonunu kullanarak sahnelere eklemeli; `Sprite2D.new()` veya `Node2D.new()` gibi doğrudan node oluşturma çağrıları `_build_room()` içinde bulunmamalıdır.

2. THE World_Builder SHALL `_build_room()` içinde `_decorate_room()` fonksiyonunu çağırmalıdır; `_decorate_room()` fonksiyonu atmosferik efektleri (`_add_soft_blob()`, ışık havuzu) eklemeli ve `_build_room()` içinde doğrudan `_add_soft_blob()` çağrısı yapılmamalıdır.

3. WHEN `_add_paper_cutout_asset()` çağrısıyla bir asset sahnelere eklendiğinde, THE World_Builder SHALL `set_meta("base_pos", position)` ile asset'in yerleştirme anındaki `position` değerini kaydetmelidir; böylece Tween tabanlı sallanma animasyonu bu değeri referans alabilir; asset eklenmiyorsa metadata kaydı yapılmamalıdır; metadata kaydı başarısız olsa dahi asset yerleştirme işlemi devam etmelidir.

4. THE World_Builder SHALL `_build_room()` içinde `func _process(delta)` çağrısı veya `while` döngüsü içermemelidir; tüm animasyonlar `create_tween()` ile başlatılan `Tween` nesneleri aracılığıyla uygulanmalıdır.

---

### Requirement 14: Mobil Performans Kısıtları

**User Story:** Bir oyun geliştiricisi olarak, oda asset kitinin Android cihazlarda 60 FPS performansını korumasını istiyorum; böylece 5-10 yaş hedef kitlesinin cihazlarında akıcı oyun deneyimi sağlansın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_room()` tamamlandığında sahnede oluşturulan `Sprite2D` ve `Polygon2D` node'larının toplam sayısını 60'ın altında tutmalıdır; bu sayım `Props`, `ForegroundProps` ve `Markers` node'larının doğrudan alt node'larını kapsar.

2. THE Asset_Kit SHALL `assets/art/world/room/` dizinindeki her SVG kaynak dosyasının disk boyutunu 50 KB'ın altında tutmalıdır.

3. THE World_Builder SHALL `_build_room()` içinde `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturmamalıdır.

---

### Requirement 15: Portrait 9:16 Kompozisyon Uyumu

**User Story:** Bir oyun tasarımcısı olarak, tüm oda asset'lerinin 1080×1920 portrait ekranda doğal görünmesini istiyorum; böylece Android hedef platformunda görsel bütünlük sağlansın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_room()` içinde her asset'i `WORLD_SIZE = Vector2(1600, 2200)` koordinat sistemi içinde konumlandırmalıdır; hiçbir asset'in `position.x` değeri -100'den küçük veya 1700'den büyük, `position.y` değeri -100'den küçük veya 2300'den büyük olmamalıdır.

2. THE Asset_Kit SHALL `paper_wall_window.svg` dosyasını `viewBox` genişliği 1500 piksel olacak şekilde üretmelidir; böylece duvar arka planı ekranın tamamını kapatır.

3. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasını `viewBox` genişliği en az 1600 piksel olacak şekilde üretmelidir; böylece ekranın sol ve sağ kenarları kapatılır.

4. WHEN kamera `zoom` değeri `Vector2(0.9, 0.9)` olarak ayarlandığında, THE World_Builder SHALL `paper_book_portal.svg` asset'inin merkez noktasının 1080×1920 ekran koordinatları içinde kalmasını sağlamalıdır; merkez noktası ekran sınırlarından en az 50 piksel içeride olmalıdır.

---

### Requirement 16: SVG Round-Trip Uyumu

**User Story:** Bir oyun geliştiricisi olarak, SVG dosyalarının Godot 4.6.2 tarafından içe aktarılıp tekrar dışa aktarıldığında görsel bütünlüğünü korumasını istiyorum; böylece asset pipeline güvenilir olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG dosyasında `<path>` elementlerinin `d` attribute'unda yalnızca büyük harf mutlak koordinat komutları kullanmalıdır: `M`, `L`, `C`, `Q`, `A`, `Z`.

2. THE Asset_Kit SHALL SVG dosyalarında `style` attribute'u veya `<defs>` elementi kullanmamalıdır.

3. THE Asset_Kit SHALL SVG dosyalarında `<text>`, `<tspan>`, `<image>`, `<use>`, `<symbol>` veya `xlink:href` referansı içermemelidir.

4. THE Asset_Kit SHALL her SVG dosyasını kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` attribute'u ile üretmelidir.

5. THE Asset_Kit SHALL her SVG dosyasında `<path>` sayısını 2 ile 5 arasında tutmalıdır; `paper_book_portal.svg` için bu sınır en fazla 5'tir.
