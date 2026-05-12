# Gereksinimler Belgesi — Bandırma Asset Kit

## Introduction

Bu belge, "Bandırma Yolculuğu" oyununun Bandırma Vapuru sahnesi için yüksek kaliteli paper diorama asset kitinin gereksinimlerini tanımlar. Teknik olarak sahne `ship` area key'i ile inşa edilir, ancak görsel tema ve asset klasörü `bandirma` olarak adlandırılmıştır. Hedef, mevcut 5 SVG dosyasını ve prosedürel gemi/kamara plakalarını, artwork referanslarına uygun tam bir paper cutout katman sistemine yükseltmektir.

Oyun; Godot 4.6.2 ile geliştirilmiş, 5-10 yaş hedef kitlesine yönelik eğitici tarih macerası oyunudur. Android portrait (1080×1920, 9:16) platformunda çalışır. Bandırma Vapuru bölgesi, Samsun'a hareket öncesi "deniz, sis, rota planı, bekleyiş" temalı yarı açık gemi güvertesi/kamara sahnesidir.

---

## Requirements

### Requirement 1: SVG Asset Dosya Seti

**User Story:** Bir oyun sanatçısı olarak, Bandırma Vapuru sahnesi için eksiksiz bir paper diorama asset seti istiyorum; böylece `_build_ship()` fonksiyonu prosedürel plakalar yerine tutarlı SVG katmanları yükleyebilsin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `assets/art/world/bandirma/` dizininde aşağıdaki SVG dosyalarını içermelidir: `paper_sky_bandirma.svg`, `paper_fog_bands.svg`, `paper_distant_coast.svg`, `paper_cabin_wall.svg`, `paper_sea_window.svg`, `paper_terrain_harbor.svg`, `paper_main_path.svg`, `paper_bandirma_ship.svg`, `paper_map_table.svg`, `paper_uniform_stand.svg`, `paper_compass.svg`, `paper_telegraph_props.svg`, `paper_foreground_frame.svg`.

2. THE Asset_Kit SHALL her SVG dosyasını `viewBox="0 0 W H"` tanımıyla üretmelidir; burada W ve H değerleri 300 ile 1800 piksel aralığında tam sayı olmalıdır.

3. THE Asset_Kit SHALL her SVG dosyasında en az 2, en fazla 5 `<path>` elementi içermelidir; `paper_bandirma_ship.svg` dosyası için maksimum 5 `<path>` sınırı geçerlidir.

4. WHEN bir SVG dosyası Godot 4.6.2 import pipeline'ı tarafından işlendiğinde, THE Asset_Kit SHALL Godot editörünün Import sekmesinde hata üretmemelidir; editör tema uyarıları bu kriterin kapsamı dışındadır.

5. THE Asset_Kit SHALL her SVG dosyasında `fill` ve `stroke` attribute'ları genelinde benzersiz renk değeri sayısını maksimum 5 ile sınırlandırmalıdır; `paper_compass.svg` ve `paper_telegraph_props.svg` dosyaları bir ek vurgu rengi daha kullanabilir.

6. THE Asset_Kit SHALL her SVG dosyasını iyi biçimlendirilmiş XML olarak üretmelidir: `xmlns="http://www.w3.org/2000/svg"` namespace bildirimi içermeli, harici dosya referansı içermemeli ve tüm açılan etiketler kapatılmış olmalıdır.

---

### Requirement 2: Paper Diorama Görsel Stili

**User Story:** Bir oyun tasarımcısı olarak, Bandırma asset'lerinin mevcut neo-historical paper diorama stiline uymasını istiyorum; böylece Room, Samsun ve diğer bölgelerle görsel tutarlılık sağlansın.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `stroke` kullanan `<path>` elementlerinde `stroke-width` değerini 8 ile 18 piksel arasında kullanmalıdır; böylece çocuk okunabilirliği korunur.

2. THE Asset_Kit SHALL gölge amacıyla kullanılan `<path>` elementlerinde `fill="#1A1510"` veya `fill="#2B2730"` renklerini ve `opacity` değerini 0.18 ile 0.30 arasında kullanmalıdır; gölge katmanı SVG belgesinde önce yer almalıdır.

3. THE Asset_Kit SHALL ana şekil `<path>` renklerinde `#292c39` (ART_WAR_NAVY), `#856536` (ART_WARM_EARTH), `#ecdec8` (ART_CREAM_LIGHT), `#067078` (POP_DEEP_TURQUOISE) ve `#2B2730` (DESIGN_STORY_INK) renk ailelerinden türetilmiş düşük doygunluklu tonları kullanmalıdır.

4. THE Asset_Kit SHALL Bandırma bölümüne özel vurgu olarak `#FFB340` (POP_GOLD) rengini sis ışığı, pusula, rota ve lamba detaylarında kullanabilmelidir.

5. IF bir SVG asset `paper_foreground_frame.svg` dosyasıysa, THEN THE Asset_Kit SHALL ön plan silüetlerini `fill="#2B2730"` veya `fill="#1A1510"` ile üretmeli ve `opacity` değerini 0.85'ten büyük tutmalıdır.

6. IF bir SVG asset `paper_compass.svg` veya `paper_telegraph_props.svg` dosyasıysa, THEN THE Asset_Kit SHALL `#38C7FF` (RIFT_BLUE) rengini düşük opaklıklı yardımcı vurgu olarak kullanabilmelidir; bu kullanım dekoratif glow/rota okuması amacıyla sınırlı olmalıdır.

---

### Requirement 3: Parallax Katman Sistemi

**User Story:** Bir oyun geliştiricisi olarak, Bandırma asset'lerinin doğru z-index ve parallax değerleriyle yerleşmesini istiyorum; böylece yarı açık gemi sahnesinde derinlik hissi oluşsun.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_ship()` içinde her asset'i `_add_paper_cutout_asset()` veya `_add_foreground_paper_cutout_asset()` ile aşağıdaki z-index değerlerinde yerleştirmelidir: `paper_sky_bandirma` → -18, `paper_fog_bands` → -17, `paper_distant_coast` → -16, `paper_cabin_wall` → -14, `paper_sea_window` → -13, `paper_terrain_harbor` → -11, `paper_main_path` → -10, `paper_bandirma_ship` → -8, `paper_uniform_stand` → -6, `paper_map_table` → -5, `paper_compass` → -3, `paper_telegraph_props` → -2, `paper_foreground_frame` → 4.

2. THE World_Builder SHALL aşağıdaki `paper_parallax_strength` değerlerini kullanmalıdır: `paper_sky_bandirma` → -16.0, `paper_fog_bands` → -13.0, `paper_distant_coast` → -9.0, `paper_cabin_wall` → -4.0, `paper_sea_window` → -6.0, `paper_terrain_harbor` → -2.5, `paper_main_path` → -0.5, `paper_bandirma_ship` → 0.5, `paper_uniform_stand` → 1.0, `paper_map_table` → 2.0, `paper_compass` → 3.5, `paper_telegraph_props` → 4.0, `paper_foreground_frame` → 14.0.

3. THE World_Builder SHALL her `_add_paper_cutout_asset()` çağrısında asset'in taban konumunu `set_meta("base_pos", position)` ile kaydetmelidir.

4. IF bir asset'in `paper_parallax_strength` değeri 0.0 ise, THEN THE World_Builder SHALL kamera hareketi sırasında bu asset'in `position` değerini değiştirmemelidir.

---

### Requirement 4: Textures Registry Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, tüm Bandırma SVG asset'lerinin `textures.gd` içinde merkezi sabitler olarak tanımlanmasını istiyorum; böylece asset yolları tek noktadan yönetilsin.

#### Acceptance Criteria

1. THE Textures_Registry SHALL `scripts/textures.gd` içinde Bandırma klasöründeki her SVG dosyası için `const BANDIRMA_PAPER_[ASSET_ADI]_TEXTURE := preload("res://assets/art/world/bandirma/[dosya].svg")` formatında tam olarak bir sabit tanımlamalıdır.

2. THE Textures_Registry SHALL bu sabitleri `# BANDIRMA PAPER CUTOUT (özel asset)` başlığı altında gruplandırmalıdır.

3. WHEN `world_builder.gd` bir Bandırma asset'i yüklemek istediğinde, THE World_Builder SHALL yalnızca `_textures.BANDIRMA_PAPER_[ASSET_ADI]_TEXTURE` sabitlerini kullanmalıdır; `world_builder.gd` içinde `preload("res://assets/art/world/bandirma/` ile başlayan doğrudan preload çağrısı bulunmamalıdır.

4. THE Textures_Registry SHALL mevcut başka bölüm sabitlerini silmemeli veya yeniden adlandırmamalıdır.

---

### Requirement 5: Colors Registry Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, Bandırma sahnesinin renk sisteminin `THEME_BANDIRMA` sözlüğünden türetilmesini istiyorum; böylece bölüm teması merkezi kalır.

#### Acceptance Criteria

1. THE Colors_Registry SHALL `scripts/colors.gd` içinde `THEME_BANDIRMA` sözlüğünü korumalıdır; geçerli anahtarlar `"bg"`, `"accent"`, `"panel"`, `"shadow"`, `"text"` olmalıdır.

2. THE World_Builder SHALL `_build_ship()` ve `_add_bandirma_paper_asset_layer()` içinde ana arka plan ve vurgu renklerini `_colors.THEME_BANDIRMA["bg"]`, `_colors.THEME_BANDIRMA["accent"]`, `_colors.THEME_BANDIRMA["panel"]` ve `_colors.THEME_BANDIRMA["shadow"]` referanslarıyla kullanmalıdır.

3. THE World_Builder SHALL Bandırma katmanları için doğrudan `Color("#` ile başlayan tekrar eden renk literallerini azaltmalı; yalnızca tekil sanatsal istisnalar kabul edilebilir.

4. THE Colors_Registry SHALL `POP_GOLD`, `POP_DEEP_TURQUOISE`, `POP_CRIMSON` ve `RIFT_BLUE` sabitlerinin Bandırma dekorasyonunda ikincil vurgu olarak kullanılmasına izin vermelidir.

---

### Requirement 6: World Builder Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, Bandırma sahnesinin mevcut `_build_ship()` ve `_decorate_ship()` pattern'ini koruyarak paper asset layer ile güncellenmesini istiyorum; böylece kod tabanı tutarlı kalsın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_add_bandirma_paper_asset_layer(world_root)` adlı yeni bir yardımcı fonksiyon tanımlamalı ve `_build_ship()` içinde çağırmalıdır.

2. THE World_Builder SHALL `_build_ship()` içinde büyük yapısal arka planı SVG katmanlarına devretmeli; `_add_ship_room_plates()` içindeki tekrar eden büyük dikdörtgen plakalar kaldırılmalı veya yalnızca en arka fallback katmanına indirgenmelidir.

3. THE World_Builder SHALL `_decorate_ship()` içindeki etkileşimsel prop ve marker akışını korumalıdır: `ship.map_table`, `ship.uniform_stand`, `ship.compass` ve `ship.dock_glow` asset slot'ları yaşamaya devam etmelidir.

4. THE World_Builder SHALL `paper_bandirma_ship.svg` katmanı eklendikten sonra `_decorate_ship()` içindeki büyük gövde/mast/yelken sprite çağrılarını kaldırmalı veya görünmeyecek düzeye indirmelidir; aynı yapıyı iki kez çizen düğümler bırakılmamalıdır.

5. WHEN `build_world("ship", world_root)` çağrıldığında, THE World_Builder SHALL `world_built` sinyalinin ancak `_build_ship()` ve `_decorate_ship()` tamamlandıktan sonra gözlemlenmesini sağlamalıdır.

6. THE World_Builder SHALL `_build_ship()` içinde `Sprite2D.new()` veya `Node2D.new()` gibi doğrudan node oluşturma çağrılarını kullanmamalı; tüm yeni görsel katmanlar yardımcı fonksiyonlar üzerinden eklenmelidir.

---

### Requirement 7: Gökyüzü ve Ufuk Grubu

**User Story:** Bir oyun tasarımcısı olarak, Bandırma sahnesinin sisli gökyüzü ve uzak kıyı katmanlarının limana hareket hissi vermesini istiyorum; böylece bölüm atmosferi kurulabilsin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_sky_bandirma.svg` dosyasını `viewBox="0 0 1800 900"` veya daha geniş bir formatta üretmelidir; gökyüzünde sisli gece/şafak geçişi bulunmalıdır.

2. THE Asset_Kit SHALL `paper_fog_bands.svg` dosyasında en az 2 sis bandı ve 1 hafif altın vurgu katmanı içermelidir; `opacity` değerleri 0.20 ile 0.55 arasında olmalıdır.

3. THE Asset_Kit SHALL `paper_distant_coast.svg` dosyasında kıyı şeridi, iskele gölgeleri ve en az bir uzak yapı silüeti içermelidir; tüm detaylar düşük opaklıkta tutulmalıdır.

4. THE Asset_Kit SHALL bu üç dosyayı birlikte kullanıldığında gemi güvertesinin arkasında okunabilir bir horizon kompozisyonu oluşturacak şekilde tasarlamalıdır.

---

### Requirement 8: Kamara ve Güverte Katmanları

**User Story:** Bir oyun tasarımcısı olarak, Bandırma sahnesinin kamara duvarı, pencere açıklığı ve güverte zemininin paper cutout yapısında okunabilir olmasını istiyorum; böylece yarı açık mekan duygusu güçlensin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_cabin_wall.svg` dosyasında koyu lacivert gemi iç duvarını, kiriş/kesit hissini ve en az 1 pencere boşluğu okumasını içermelidir.

2. THE Asset_Kit SHALL `paper_sea_window.svg` dosyasında denize açılan parlak bir pencere yüzeyi, altın/turkuaz yansıma ve koyu gölge içermelidir.

3. THE Asset_Kit SHALL `paper_terrain_harbor.svg` dosyasında ahşap güverte zemini, sıcak kahve plank hissi ve limana bakan alt kenar kütlesi oluşturmalıdır.

4. THE Asset_Kit SHALL `paper_main_path.svg` dosyasında oyuncuyu rota masasına ve çıkış noktasına yönlendiren kıvrımlı güverte yolu/ışık şeridi üretmelidir.

---

### Requirement 9: Bandırma Gemi Silüeti

**User Story:** Bir oyun tasarımcısı olarak, Bandırma Vapuru'nun ana silüetinin tek bir hero asset ile tanımlanmasını istiyorum; böylece tarihsel landmark sahnenin odağı olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_bandirma_ship.svg` dosyasında gövde, güverte, baca, direk/yelken silüeti ve su gölgesini tek kompozisyonda içermelidir.

2. THE Asset_Kit SHALL `paper_bandirma_ship.svg` dosyasında `<text>` elementi kullanmamalıdır; gemi adı gerekirse yalnızca path ile çözümlenmelidir veya hiç yazılmamalıdır.

3. THE Asset_Kit SHALL `paper_bandirma_ship.svg` dosyasında çocuk okunabilirliğini korumak için kalın outline veya koyu gölge katmanı kullanmalıdır.

4. THE Asset_Kit SHALL `paper_bandirma_ship.svg` dosyasında `<metadata><slot_id>ship.bandirma_hero</slot_id></metadata>` etiketini içermelidir.

---

### Requirement 10: Görev Prop Grubu

**User Story:** Bir oyun tasarımcısı olarak, Bandırma sahnesindeki rota masası, üniforma standı ve pusula gibi etkileşimli öğelerin kendi SVG landmark'larına sahip olmasını istiyorum; böylece görev odağı netleşsin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_map_table.svg` dosyasında masa yüzeyi, açık rota haritası ve en az 1 belge/işaret unsuru içermelidir; `<metadata><slot_id>ship.map_table</slot_id></metadata>` bulunmalıdır.

2. THE Asset_Kit SHALL `paper_uniform_stand.svg` dosyasında çocuk ölçeğinde üniforma/aksesuar standı veya askılık kompozisyonu içermelidir; `<metadata><slot_id>ship.uniform_stand</slot_id></metadata>` bulunmalıdır.

3. THE Asset_Kit SHALL `paper_compass.svg` dosyasında pusula gövdesi, yön oku ve hafif parıltı katmanı içermelidir; `<metadata><slot_id>ship.compass</slot_id></metadata>` bulunmalıdır.

4. THE Asset_Kit SHALL `paper_telegraph_props.svg` dosyasında iskele sinyal lambası, halat veya rota/mesaj prop'larını içermelidir; dosya `ship.dock_glow` işaretinin çevresini tamamlamalıdır.

---

### Requirement 11: Mobil Performans Kısıtları

**User Story:** Bir oyun geliştiricisi olarak, Bandırma asset kitinin Android cihazlarda akıcı çalışmasını istiyorum; böylece sahne geçişlerinde performans kaybı yaşanmasın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_ship()` veya `_add_bandirma_paper_asset_layer()` içinde `while` döngüsü, `func _process(delta)` veya `Timer` node'u kullanmamalıdır.

2. THE World_Builder SHALL Bandırma sahnesinde oluşturulan `Sprite2D` ve `Polygon2D` node toplamını 65'in altında tutmalıdır; bu sayım `Props`, `ForegroundProps` ve `Markers` altındaki node'ları kapsar.

3. THE Asset_Kit SHALL Bandırma klasöründeki her `.svg` kaynak dosyasının boyutunu 50 KB altında tutmalıdır.

4. WHEN `clear_world(world_root)` çağrıldığında, THE World_Builder SHALL `asset_slot` meta değeri `paperworld.bandirma_` önekiyle işaretlenmiş düğümleri serbest bırakabilmelidir.

---

### Requirement 12: Portrait 9:16 Kompozisyon Uyumu

**User Story:** Bir oyun tasarımcısı olarak, tüm Bandırma asset'lerinin 1080×1920 portrait ekranda doğal görünmesini istiyorum; böylece yarı açık gemi sahnesi mobil ekranda da okunur olsun.

#### Acceptance Criteria

1. THE World_Builder SHALL Bandırma asset'lerini `WORLD_SIZE = Vector2(1600, 2200)` koordinat sistemi içinde yerleştirmelidir; hiçbir asset'in `position.x` değeri -100 ile 1700, `position.y` değeri -100 ile 2300 aralığı dışına çıkmamalıdır.

2. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasını `viewBox` genişliği en az 1600 piksel olacak şekilde üretmelidir.

3. THE Asset_Kit SHALL `paper_sky_bandirma.svg` dosyasını geniş overscan ile üretmelidir; kamera hafif salınım yaptığında kenarlar görünmemelidir.

4. THE Asset_Kit SHALL `paper_map_table.svg`, `paper_uniform_stand.svg` ve `paper_compass.svg` odak noktalarının portrait kompozisyonun orta bandı içinde kalmasını desteklemelidir.

---

### Requirement 13: SVG Üretim Standardı

**User Story:** Bir oyun geliştiricisi olarak, Bandırma SVG dosyalarının Godot 4.6.2 tarafından güvenilir biçimde içe aktarılmasını istiyorum; böylece asset pipeline tutarlı olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG dosyasını kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` ile üretmelidir.

2. THE Asset_Kit SHALL `style` attribute'u, `<defs>`, `<text>`, `<tspan>`, `<image>`, `<use>` ve `<symbol>` elementlerini kullanmamalıdır.

3. THE Asset_Kit SHALL her SVG dosyasında `<path>` elementlerinin `d` attribute'unda yalnızca büyük harf komutları kullanmalıdır: `M`, `L`, `C`, `Q`, `A`, `Z`.

4. THE Asset_Kit SHALL harici referans (`xlink:href`, `url()`) kullanmamalıdır.

5. THE Asset_Kit SHALL `paper_bandirma_ship.svg` mevcut düşük kaliteli sürümündeki `<text>` öğesini kaldırmalı ve round-trip uyumlu yalnızca path tabanlı içerik üretmelidir.