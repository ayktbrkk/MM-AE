# Gereksinimler Belgesi — Havza Asset Kit

## Introduction

Bu belge, "Bandırma Yolculuğu" oyununun `havza` bölgesi için yüksek kaliteli paper diorama asset kitinin gereksinimlerini tanımlar. Hedef, mevcut 5 basit SVG dosyasını (sky, terrain, path, civic square, foreground) artwork çalışma kitinden türetilen tam bir diorama setine yükseltmektir.

Oyun; Godot 4.6.2 ile geliştirilmiş, 5-10 yaş hedef kitlesine yönelik eğitici tarih macerası oyunudur. Android portrait (1080×1920, 9:16) platformunda çalışır. Havza bölgesi, Mustafa Kemal'in Samsun'dan sonra uğradığı ikinci dış mekan sahnesidir: 1919 Anadolu kasabası, dusty afternoon atmosferi, olive-green tepeler, cream cobblestone yollar, kasaba meydanı.

Mevcut 5 SVG dosyası `<rect>`, `<circle>`, `<ellipse>`, `<g>` gibi yasak elementler içermektedir; bu spec kapsamında tüm dosyalar yalnızca `<path>` elementleri kullanılarak yeniden yazılacaktır.

---

## Glossary

- **Asset_Kit**: `assets/art/world/havza/` dizinindeki 5 SVG dosyasının tamamı.
- **World_Builder**: `scripts/world_builder.gd` içindeki `_build_havza_world()` ve `_decorate_havza()` fonksiyonları.
- **Textures_Registry**: `scripts/textures.gd` içindeki `HAVZA_PAPER_*` sabit grubu.
- **Paper_Diorama_Standard**: Samsun/Room Asset Kit ile belirlenen SVG üretim kuralları — yalnızca `<path>` elementleri, yalnızca mutlak koordinat komutları, maksimum 5 benzersiz renk, 50 KB altı dosya boyutu.
- **HAVZA_SKY_DUST**: `#685934` — dusty afternoon sky, earthy brown.
- **HAVZA_TERRAIN_TAN**: `#D4C5A9` — warm tan terrain.
- **HAVZA_SAGE_GREEN**: `#8DB572` — sage green vegetation.
- **HAVZA_CREAM_PATH**: `#E8DFC8` — cream path surface.
- **DESIGN_STORY_INK**: `#2B2730` — outlines, dark silhouettes.
- **POP_GOLD**: `#F2BE63` — sun glow, accents.
- **PAPER_SHADOW**: `#1A2A3A` — shadow layers.

---

## Requirements

### Requirement 1: SVG Asset Dosya Seti

**User Story:** Bir oyun sanatçısı olarak, Havza bölgesi için eksiksiz bir paper diorama asset seti istiyorum; böylece `_build_havza_world()` fonksiyonu tüm parallax katmanlarını yükleyebilsin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `assets/art/world/havza/` dizininde aşağıdaki SVG dosyalarını içermelidir: `paper_sky_havza.svg`, `paper_terrain_town.svg`, `paper_main_path.svg`, `paper_civic_square.svg`, `paper_foreground_frame.svg`.

2. THE Asset_Kit SHALL her SVG dosyasını `viewBox="0 0 W H"` tanımıyla üretmelidir; burada W ve H değerleri kullanıcı tarafından belirtilen boyutlara eşit olmalıdır: `paper_sky_havza.svg` (1500×760), `paper_terrain_town.svg` (800×600), `paper_main_path.svg` (920×900), `paper_civic_square.svg` (600×400), `paper_foreground_frame.svg` (1600×780).

3. THE Asset_Kit SHALL her SVG dosyasında en az 2, en fazla 5 `<path>` elementi içermelidir (gölge `<path>` + ana şekil `<path>` + opsiyonel vurgu `<path>` + opsiyonel outline `<path>`).

4. WHEN bir SVG dosyası Godot 4.6.2 import pipeline'ı tarafından işlendiğinde, THE Asset_Kit SHALL Godot editörünün "Import" sekmesinde hata veya uyarı mesajı üretmemelidir; editör tema uyarıları bu kriterin kapsamı dışındadır.

5. THE Asset_Kit SHALL her SVG dosyasında `fill` ve `stroke` attribute'ları genelinde benzersiz renk değeri sayısını maksimum 5 ile sınırlandırmalıdır (gölge rengi + 2 ana renk + 1 vurgu + 1 outline).

6. THE Asset_Kit SHALL her SVG dosyasını iyi biçimlendirilmiş XML olarak üretmelidir: `xmlns="http://www.w3.org/2000/svg"` namespace bildirimi içermeli, harici dosya referansı (`xlink:href`, `url()`) içermemeli ve tüm açılan etiketler kapatılmış olmalıdır.

---

### Requirement 2: Paper Diorama Görsel Stili

**User Story:** Bir oyun tasarımcısı olarak, Havza asset'lerinin mevcut paper diorama stiline uymasını istiyorum; böylece diğer bölgelerle görsel tutarlılık sağlansın.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG asset'te `stroke` attribute'u kullanan `<path>` elementlerinde `stroke-width` değerini 8 ile 18 piksel arasında kullanmalıdır; böylece 5-10 yaş hedef kitlesine uygun okunabilirlik sağlanır.

2. THE Asset_Kit SHALL gölge amacıyla kullanılan `<path>` elementlerinde `fill="#1a2a3a"` rengi ile `opacity` attribute değerini 0.14 ile 0.22 arasında kullanmalıdır; gölge `<path>` elementleri diğer `<path>` elementlerinin altında (SVG belgesinde önce) yer almalıdır.

3. THE Asset_Kit SHALL ana şekil `<path>` elementlerinin `fill` renk değerlerinde HSL doygunluğunu %50 ile %70 arasında tutmalıdır; böylece pastel paper diorama tonu korunur.

4. THE Asset_Kit SHALL her SVG dosyasındaki tüm `fill` ve `stroke` renk değerlerini `#685934` (HAVZA_SKY_DUST), `#D4C5A9` (HAVZA_TERRAIN_TAN), `#8DB572` (HAVZA_SAGE_GREEN), `#E8DFC8` (HAVZA_CREAM_PATH), `#2B2730` (DESIGN_STORY_INK), `#F2BE63` (POP_GOLD) ve `#1A2A3A` (PAPER_SHADOW) renk ailesinden türetmelidir.

5. IF bir SVG asset `paper_foreground_frame.svg` dosyasıysa, THEN THE Asset_Kit SHALL ön plan silüetlerini oluşturan `<path>` elementlerinde `fill="#2B2730"` (DESIGN_STORY_INK) veya `fill="#1A2A3A"` (PAPER_SHADOW) renk değerini kullanmalıdır; bu elementlerde `opacity` değeri 0.85'ten büyük olmalıdır.

---

### Requirement 3: SVG Üretim Standardı (Teknik Uyum)

**User Story:** Bir oyun geliştiricisi olarak, SVG dosyalarının Godot 4.6.2 tarafından sorunsuz içe aktarılmasını ve yalnızca `<path>` elementleri kullanmasını istiyorum; böylece asset pipeline güvenilir ve tutarlı olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG dosyasında `<path>` elementlerinin `d` attribute'unda yalnızca büyük harf (mutlak koordinat) komutları kullanmalıdır: `M`, `L`, `C`, `Q`, `A`, `Z`; küçük harf (göreli koordinat) komutları `m`, `l`, `c`, `q`, `a` kullanılmamalıdır.

2. THE Asset_Kit SHALL SVG dosyalarında `style` attribute'u veya `<defs>` elementi kullanmamalıdır; tüm görsel özellikler `fill`, `stroke`, `stroke-width`, `opacity` attribute'ları olarak doğrudan `<path>` elementlerinde tanımlanmalıdır.

3. THE Asset_Kit SHALL SVG dosyalarında `<text>`, `<tspan>`, `<image>`, `<use>`, `<symbol>` elementleri kullanmamalıdır.

4. THE Asset_Kit SHALL her SVG dosyasını kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` attribute'u ile üretmelidir.

5. THE Asset_Kit SHALL her SVG dosyasında yalnızca `<path>` elementleri kullanmalıdır; `<rect>`, `<circle>`, `<ellipse>`, `<g>` elementleri hiçbir dosyada bulunmamalıdır.

---

### Requirement 4: Gökyüzü Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_sky_havza.svg` dosyasının dusty afternoon gökyüzünü paper diorama stilinde temsil etmesini istiyorum; böylece Havza atmosferi oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_sky_havza.svg` dosyasında gökyüzü yüzeyini `fill="#685934"` (HAVZA_SKY_DUST) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_sky_havza.svg` dosyasında güneş ışığı vurgusunu `fill="#F2BE63"` (POP_GOLD) rengiyle temsil eden en az 1 yarı-saydam `<path>` elementi içermelidir; bu elementin `opacity` değeri 0.25 ile 0.35 arasında olmalıdır.

3. THE Asset_Kit SHALL `paper_sky_havza.svg` dosyasını `viewBox="0 0 1500 760"` boyutlarında üretmelidir; viewBox genişliği 1500 piksel olmalıdır.

4. THE Asset_Kit SHALL `paper_sky_havza.svg` dosyasında toplam `<path>` sayısını 3 ile 4 arasında tutmalıdır: 1 gölge `<path>` + 1 gökyüzü `<path>` + 1 atmosfer bandı `<path>` + 1 opsiyonel güneş ışıltısı `<path>`.

---

### Requirement 5: Arazi Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_terrain_town.svg` dosyasının Havza kasaba arazisini paper diorama stilinde temsil etmesini istiyorum; böylece zemin katmanı oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_terrain_town.svg` dosyasında arazi yüzeyini `fill="#D4C5A9"` (HAVZA_TERRAIN_TAN) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_terrain_town.svg` dosyasında bitki örtüsü katmanını `fill="#8DB572"` (HAVZA_SAGE_GREEN) rengiyle temsil eden en az 1 yarı-saydam `<path>` elementi içermelidir; bu elementin `opacity` değeri 0.55 ile 0.65 arasında olmalıdır.

3. THE Asset_Kit SHALL `paper_terrain_town.svg` dosyasını `viewBox="0 0 800 600"` boyutlarında üretmelidir.

4. THE Asset_Kit SHALL `paper_terrain_town.svg` dosyasında toplam `<path>` sayısını 4 ile sınırlandırmalıdır: 1 gölge `<path>` + 1 arazi `<path>` + 1 sage green katman `<path>` + 1 opsiyonel altın vurgu `<path>`.

---

### Requirement 6: Ana Patika Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_main_path.svg` dosyasının Havza kasabasındaki ana patikayı paper diorama stilinde temsil etmesini istiyorum; böylece oyuncu yönlendirmesi görsel olarak belirgin olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_main_path.svg` dosyasında ana patika yüzeyini `fill="#E8DFC8"` (HAVZA_CREAM_PATH) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_main_path.svg` dosyasında patika dallanmalarını temsil eden en az 1 ek `<path>` elementi içermelidir; dallanma renkleri `#E8DFC8` veya `#D4C5A9` renk ailesinden türetilmelidir.

3. THE Asset_Kit SHALL `paper_main_path.svg` dosyasını `viewBox="0 0 920 900"` boyutlarında üretmelidir.

4. THE Asset_Kit SHALL `paper_main_path.svg` dosyasında toplam `<path>` sayısını 4 ile 5 arasında tutmalıdır: 1 gölge `<path>` + 1 ana patika `<path>` + 1-2 dallanma `<path>` + 1 opsiyonel vurgu `<path>`.

---

### Requirement 7: Kasaba Meydanı Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_civic_square.svg` dosyasının Havza kasaba meydanını paper diorama stilinde temsil etmesini istiyorum; böylece sivil toplantı atmosferi oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_civic_square.svg` dosyasında meydan zeminini `fill="#E8DFC8"` (HAVZA_CREAM_PATH) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

2. THE Asset_Kit SHALL `paper_civic_square.svg` dosyasında çeşme veya anıt siluetini `fill="#D4C5A9"` (HAVZA_TERRAIN_TAN) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

3. THE Asset_Kit SHALL `paper_civic_square.svg` dosyasında ağaç siluetlerini `fill="#8DB572"` (HAVZA_SAGE_GREEN) rengiyle temsil eden en az 1 `<path>` elementi içermelidir.

4. THE Asset_Kit SHALL `paper_civic_square.svg` dosyasında NPC figür siluetlerini `fill="#2B2730"` (DESIGN_STORY_INK) rengiyle temsil eden en az 1 `<path>` elementi içermelidir; NPC siluetleri `opacity` değeri 0.25 ile 0.35 arasında olmalıdır.

5. THE Asset_Kit SHALL `paper_civic_square.svg` dosyasını `viewBox="0 0 600 400"` boyutlarında üretmelidir.

6. THE Asset_Kit SHALL `paper_civic_square.svg` dosyasında toplam `<path>` sayısını 4 ile 5 arasında tutmalıdır: 1 gölge `<path>` + 1 zemin `<path>` + 1 çeşme/anıt `<path>` + 1 ağaç `<path>` + 1 opsiyonel NPC `<path>`.

---

### Requirement 8: Ön Plan Çerçeve Asset'i

**User Story:** Bir oyun tasarımcısı olarak, `paper_foreground_frame.svg` dosyasının ekranın kenarlarını kapatan ön plan siluetini temsil etmesini istiyorum; böylece diorama derinlik hissi güçlensin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasında ön plan siluetlerini oluşturan `<path>` elementlerinde `fill="#1A2A3A"` (PAPER_SHADOW) veya `fill="#2B2730"` (DESIGN_STORY_INK) renk değerini kullanmalıdır; bu elementlerde `opacity` değeri 0.85'ten büyük olmalıdır.

2. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasını `viewBox="0 0 1600 780"` boyutlarında üretmelidir; viewBox genişliği 1600 piksel olmalıdır.

3. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasında en az 2 `<path>` elementi içermelidir: sol ağaç/bina silueti ve sağ ağaç/bina silueti.

4. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasında toplam `<path>` sayısını 3 ile sınırlandırmalıdır: 1 sol siluet `<path>` + 1 sağ siluet `<path>` + 1 opsiyonel zemin bandı `<path>`.

---

### Requirement 9: Textures Registry Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, tüm Havza SVG asset'lerinin `textures.gd` içinde merkezi sabitler olarak tanımlanmasını istiyorum; böylece DRY prensibi korunur ve asset yolları tek noktadan yönetilir.

#### Acceptance Criteria

1. THE Textures_Registry SHALL `scripts/textures.gd` içinde `res://assets/art/world/havza/` dizinindeki her SVG dosyası için `const HAVZA_PAPER_[ASSET_ADI]_TEXTURE := preload("res://assets/art/world/havza/[dosya_adı].svg")` formatında tam olarak bir sabit tanımlamalıdır; sabit sayısı `res://assets/art/world/havza/` dizinindeki SVG dosyası sayısına eşit olmalıdır.

2. THE Textures_Registry SHALL Havza sabitlerini `scripts/textures.gd` içinde `# ====================================` açılış satırı, ardından `# HAVZA PAPER CUTOUT (özel asset)` başlık satırı, ardından `# ====================================` kapanış satırından oluşan bölüm başlığı altında gruplandırmalıdır; bu yapı diğer bölüm başlıklarıyla aynı biçimi korumalıdır.

3. WHEN `world_builder.gd` bir Havza asset'i yüklemek istediğinde, THE World_Builder SHALL `_textures.HAVZA_PAPER_[ASSET_ADI]_TEXTURE` sabitini kullanmalıdır; `world_builder.gd` içinde `preload("res://assets/art/world/havza/` ile başlayan hiçbir doğrudan `preload()` çağrısı bulunmamalıdır.

4. THE Textures_Registry SHALL `scripts/textures.gd` içindeki mevcut `HAVZA_PAPER_*` sabitlerinin hiçbirini silmemeli veya yeniden adlandırmamalıdır; yeni sabitler mevcut sabitlerden sonra aynı bölüm içine eklenmelidir.

---

### Requirement 10: World Builder Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, `_build_havza_world()` fonksiyonunun mevcut `_build_*` pattern'ini izlemesini istiyorum; böylece kod tabanı tutarlılığı korunur.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_havza_world()` içinde tüm SVG asset'leri `_add_havza_paper_asset_layer()` yardımcı fonksiyonunu kullanarak sahnelere eklemeli; `Sprite2D.new()` veya `Node2D.new()` gibi doğrudan node oluşturma çağrıları `_build_havza_world()` içinde bulunmamalıdır.

2. THE World_Builder SHALL `_build_havza_world()` içinde `_decorate_havza()` fonksiyonunu çağırmalıdır; `_decorate_havza()` fonksiyonu atmosferik efektleri (`_add_soft_blob()`, rift cloud, light pool) eklemeli ve `_build_havza_world()` içinde doğrudan `_add_soft_blob()` çağrısı yapılmamalıdır.

3. THE World_Builder SHALL `_build_havza_world()` içinde `func _process(delta)` çağrısı veya `while` döngüsü içermemelidir; tüm animasyonlar `create_tween()` ile başlatılan `Tween` nesneleri aracılığıyla uygulanmalıdır.

4. WHEN `build_world("havza", world_root)` çağrıldığında, THE World_Builder SHALL `world_built` sinyalini `"havza"` String argümanıyla yaymalıdır; sinyal hem `_build_havza_world()` hem de `_decorate_havza()` tamamlandıktan sonra yayılmalıdır.

5. THE World_Builder SHALL `_build_havza_world()` içinde tüm yerel değişkenleri GDScript 2.0 statik tipleme sözdizimi ile tanımlamalıdır; `var pos := Vector2(800, 400)` yerine `var pos: Vector2 = Vector2(800, 400)` veya `var pos: Vector2 := Vector2(800, 400)` formatı kullanılmalıdır.

---

### Requirement 11: Mobil Performans Kısıtları

**User Story:** Bir oyun geliştiricisi olarak, Havza asset kitinin Android cihazlarda 60 FPS performansını korumasını istiyorum; böylece 5-10 yaş hedef kitlesinin cihazlarında akıcı oyun deneyimi sağlansın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_havza_world()` içinde `func _process(delta)` fonksiyonunu çağırmamalıdır; `_build_havza_world()` içinde `_process` adını içeren hiçbir fonksiyon çağrısı bulunmamalıdır.

2. THE World_Builder SHALL `_build_havza_world()` içinde tüm animasyonları `create_tween()` ile başlatılan `Tween` nesneleri aracılığıyla uygulamalıdır; `_build_havza_world()` içinde `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturulmamalıdır.

3. THE World_Builder SHALL `_build_havza_world()` tamamlandığında sahnede oluşturulan `Sprite2D` ve `Polygon2D` node'larının toplam sayısını 60'ın altında tutmalıdır; bu sayım `Props`, `ForegroundProps` ve `Markers` node'larının doğrudan alt node'larını kapsar.

4. THE Asset_Kit SHALL `assets/art/world/havza/` dizinindeki her SVG kaynak dosyasının disk boyutunu 50 KB'ın altında tutmalıdır; disk boyutu Godot import işlemi öncesi kaynak `.svg` dosyasının boyutunu ifade eder.

5. WHEN `clear_world(world_root)` çağrıldığında, THE World_Builder SHALL `Props`, `ForegroundProps` ve `Markers` node'larının doğrudan alt node'larından `set_meta("asset_slot", ...)` ile `"paperworld.havza_"` önekiyle işaretlenmiş tüm node'ları `queue_free()` ile serbest bırakmalıdır.

---

### Requirement 12: Portrait 9:16 Kompozisyon Uyumu

**User Story:** Bir oyun tasarımcısı olarak, tüm Havza asset'lerinin 1080×1920 portrait ekranda doğal görünmesini istiyorum; böylece Android hedef platformunda görsel bütünlük sağlansın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_havza_world()` içinde her asset'i `WORLD_SIZE = Vector2(1600, 2200)` koordinat sistemi içinde konumlandırmalıdır; hiçbir asset'in `position.x` değeri -100'den küçük veya 1700'den büyük, `position.y` değeri -100'den küçük veya 2300'den büyük olmamalıdır.

2. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasını `viewBox` genişliği en az 1600 piksel olacak şekilde üretmelidir; böylece ekranın sol ve sağ kenarları kapatılır.

3. THE Asset_Kit SHALL `paper_sky_havza.svg` dosyasını `viewBox` yüksekliği en az 760 piksel olacak şekilde üretmelidir; `_build_havza_world()` içinde `paper_sky_havza` asset'inin `position.y` değeri 380 ± 50 piksel olarak ayarlandığında gökyüzü ile terrain arasında boşluk kalmamalıdır.

4. WHEN kamera `zoom` değeri `Vector2(0.9, 0.9)` olarak ayarlandığında, THE World_Builder SHALL `paper_civic_square.svg` asset'inin merkez noktasının 1080×1920 ekran koordinatları içinde kalmasını sağlamalıdır; merkez noktası ekran sınırlarından en az 50 piksel içeride olmalıdır.

---

### Requirement 13: SVG Round-Trip Uyumu

**User Story:** Bir oyun geliştiricisi olarak, SVG dosyalarının Godot 4.6.2 tarafından içe aktarılıp tekrar dışa aktarıldığında görsel bütünlüğünü korumasını istiyorum; böylece asset pipeline güvenilir olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG dosyasını kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` attribute'u ile üretmelidir.

2. THE Asset_Kit SHALL SVG dosyalarında `style` attribute'u veya `<defs>` elementi kullanmamalıdır; `style` attribute'u yalnızca `fill` ve `stroke` gibi temel özellikleri içerse dahi kullanılmamalıdır; tüm görsel özellikler `fill`, `stroke`, `stroke-width`, `opacity` attribute'ları olarak doğrudan `<path>` elementlerinde tanımlanmalıdır.

3. THE Asset_Kit SHALL SVG dosyalarında `<text>` veya `<tspan>` elementi kullanmamalıdır.

4. THE Asset_Kit SHALL her SVG dosyasında `<path>` elementlerinin `d` attribute'unda yalnızca büyük harf (mutlak koordinat) komutları kullanmalıdır: `M`, `L`, `C`, `Q`, `A`, `Z`; küçük harf (göreli koordinat) komutları `m`, `l`, `c`, `q`, `a` kullanılmamalıdır.

5. THE Asset_Kit SHALL her SVG dosyasında `<image>`, `<use>`, `<symbol>` veya `xlink:href` referansı içermemelidir; tüm görsel içerik `<path>` elementleriyle tanımlanmalıdır.

---

### Requirement 14: World Built Sinyal Zamanlaması

**User Story:** Bir oyun geliştiricisi olarak, `world_built` sinyalinin `_decorate_havza()` tamamlandıktan sonra yayılmasını istiyorum; böylece diğer sistemler dünya inşasının tamamlandığından emin olabilsin.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_havza_world()` içinde `_decorate_havza(world_root)` çağrısından sonra `emit_signal("world_built", "havza")` çağrısı yapmalıdır; sinyal `_decorate_havza()` tamamlanmadan önce yayılmamalıdır.

2. THE World_Builder SHALL `world_built` sinyalini yalnızca bir kez yaymalıdır; `_build_havza_world()` içinde birden fazla `emit_signal("world_built", ...)` çağrısı bulunmamalıdır.

3. WHEN `world_built` sinyali yayıldığında, THE World_Builder SHALL sinyal parametresi olarak `"havza"` String değerini kullanmalıdır; parametre `area_key` değişkenine eşit olmalıdır.
