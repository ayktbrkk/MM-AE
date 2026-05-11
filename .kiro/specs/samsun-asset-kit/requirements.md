# Gereksinimler Belgesi — Samsun Asset Kit

## Introduction

Bu belge, "Bandırma Yolculuğu" oyununun `samsun_rift` bölgesi için yüksek kaliteli paper diorama asset kitinin gereksinimlerini tanımlar. Hedef, mevcut 3 basit SVG dosyasını (sky, terrain, foreground), artwork çalışma kitinden türetilen tam bir diorama setine yükseltmektir.

Oyun; Godot 4.6.2 ile geliştirilmiş, 5-10 yaş hedef kitlesine yönelik eğitici tarih macerası oyunudur. Android portrait (1080×1920, 9:16) platformunda çalışır. Samsun bölgesi, Mustafa Kemal'in 19 Mayıs 1919'da Samsun'a çıkışını temsil eden "varış, umut, rift enerjisi" temalı dış mekan dioramasıdır.

---

## Requirements

### Requirement 1: SVG Asset Dosya Seti

**User Story:** Bir oyun sanatçısı olarak, Samsun bölgesi için eksiksiz bir paper diorama asset seti istiyorum; böylece `_build_samsun_rift()` fonksiyonu tüm parallax katmanlarını yükleyebilsin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `assets/art/world/samsun/` dizininde aşağıdaki SVG dosyalarını içermelidir: `paper_sky_samsun.svg`, `paper_sky_life.svg`, `paper_distant_town.svg`, `paper_skyline_depth.svg`, `paper_harbor_water.svg`, `paper_coast_details.svg`, `paper_harbor_dock_props.svg`, `paper_coastal_life.svg`, `paper_terrain_island.svg`, `paper_side_paths.svg`, `paper_main_path.svg`, `paper_route_beads.svg`, `paper_safe_clearings.svg`, `paper_civic_cluster.svg`, `paper_discovery_props.svg`, `paper_harbor_boats.svg`, `paper_signal_ridge.svg`, `paper_vista_flags.svg`, `paper_harbor_landmark.svg`, `paper_telegraph_landmark.svg`, `paper_people_plaza.svg`, `paper_rift_core.svg`, `paper_wave_gate.svg`, `paper_map_compass.svg`, `paper_foreground_frame.svg`.

2. THE Asset_Kit SHALL her SVG dosyasını `viewBox="0 0 W H"` tanımıyla üretmelidir; burada W ve H değerleri 400–1600 piksel aralığında tam sayı olmalıdır.

3. THE Asset_Kit SHALL her SVG dosyasında en az 2, en fazla 5 `<path>` elementi içermelidir (gölge `<path>` + ana şekil `<path>` + opsiyonel vurgu `<path>` + opsiyonel outline `<path>`).

4. WHEN bir SVG dosyası Godot 4.6.2 import pipeline'ı tarafından işlendiğinde, THE Asset_Kit SHALL Godot editörünün "Import" sekmesinde hata veya uyarı mesajı üretmemelidir; editör tema uyarıları bu kriterin kapsamı dışındadır.

5. THE Asset_Kit SHALL her SVG dosyasında `fill` ve `stroke` attribute'ları genelinde benzersiz renk değeri sayısını maksimum 5 ile sınırlandırmalıdır (gölge rengi + 2 ana renk + 1 vurgu + 1 outline).

6. THE Asset_Kit SHALL her SVG dosyasını iyi biçimlendirilmiş XML olarak üretmelidir: `xmlns="http://www.w3.org/2000/svg"` namespace bildirimi içermeli, harici dosya referansı (`xlink:href`, `url()`) içermemeli ve tüm açılan etiketler kapatılmış olmalıdır.

---

### Requirement 2: Paper Diorama Görsel Stili

**User Story:** Bir oyun tasarımcısı olarak, Samsun asset'lerinin mevcut paper diorama stiline uymasını istiyorum; böylece diğer bölgelerle görsel tutarlılık sağlansın.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG asset'te `stroke` attribute'u kullanan `<path>` elementlerinde `stroke-width` değerini 8 ile 18 piksel arasında kullanmalıdır; böylece 5-10 yaş hedef kitlesine uygun okunabilirlik sağlanır.

2. THE Asset_Kit SHALL gölge amacıyla kullanılan `<path>` elementlerinde `fill="#10202d"` rengi ile `opacity` attribute değerini 0.20 ile 0.30 arasında kullanmalıdır; gölge `<path>` elementleri diğer `<path>` elementlerinin altında (SVG belgesinde önce) yer almalıdır.

3. THE Asset_Kit SHALL ana şekil `<path>` elementlerinin `fill` renk değerlerinde HSL doygunluğunu %50 ile %70 arasında tutmalıdır; böylece pastel paper diorama tonu korunur.

4. THE Asset_Kit SHALL her SVG dosyasındaki tüm `fill` ve `stroke` renk değerlerini `#067078` (POP_DEEP_TURQUOISE), `#FFB340` (POP_GOLD), `#F5E8D3` (DESIGN_CREAM_PAPER), `#10202d` (PAPER_SHADOW) ve `#2B2730` (DESIGN_STORY_INK) renk ailesinden türetmelidir; rift efekti (`paper_rift_core.svg`) ve bayrak (`paper_vista_flags.svg`) asset'leri bu beş renk ailesini kullanmaya devam etmeli ve ek olarak kendi özel renklerini de içerebilir.

5. IF bir SVG asset `paper_rift_core.svg` dosyasıysa, THEN THE Asset_Kit SHALL rift enerjisini temsil eden `<path>` elementlerinde `fill="#53c6df"` mavi tonunu ve `fill="#f9eec5"` altın tonunu yarı-saydam katmanlarla (`opacity` değeri 0.58 ile 0.82 arasında) kullanmalıdır.

6. IF bir SVG asset `paper_foreground_frame.svg` dosyasıysa, THEN THE Asset_Kit SHALL ön plan silüetlerini oluşturan `<path>` elementlerinde `fill="#2B2730"` (DESIGN_STORY_INK) veya `fill="#10202d"` (PAPER_SHADOW) renk değerini kullanmalıdır; bu elementlerde `opacity` değeri 0.85'ten büyük olmalıdır.

---

### Requirement 3: Parallax Katman Sistemi

**User Story:** Bir oyun geliştiricisi olarak, Samsun asset'lerinin parallax katmanlarında doğru z-index ve parallax_strength değerleriyle yerleşmesini istiyorum; böylece kamera hareketi sırasında derinlik hissi oluşsun.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_samsun_rift()` içinde her asset'i `_add_paper_cutout_asset()` çağrısıyla aşağıdaki z-index değerlerine göre yerleştirmelidir: `paper_sky_samsun` → z=-18, `paper_sky_life` → z=-17, `paper_distant_town` → z=-16, `paper_skyline_depth` → z=-15, `paper_harbor_water` → z=-14, `paper_coast_details` → z=-13, `paper_terrain_island` → z=-15, `paper_main_path` → z=-13, `paper_side_paths` → z=-12, `paper_route_beads` → z=-9, `paper_safe_clearings` → z=-8, `paper_civic_cluster` → z=-6, `paper_discovery_props` → z=-4, `paper_harbor_boats` → z=-5, `paper_signal_ridge` → z=-6, `paper_harbor_dock_props` → z=-7, `paper_coastal_life` → z=-7, `paper_vista_flags` → z=-4, `paper_harbor_landmark` → z=-3, `paper_telegraph_landmark` → z=-3, `paper_people_plaza` → z=-3, `paper_rift_core` → z=-2, `paper_wave_gate` → z=-2, `paper_map_compass` → z=2, `paper_foreground_frame` → z=4.

2. THE World_Builder SHALL `_add_paper_cutout_asset()` çağrısında her asset için aşağıdaki `paper_parallax_strength` değerlerini kullanmalıdır: `paper_sky_samsun` → -20.0, `paper_sky_life` → -18.0, `paper_distant_town` → -13.0, `paper_skyline_depth` → -10.0, `paper_harbor_water` → -8.0, `paper_coast_details` → -6.0, `paper_harbor_dock_props` → 2.5, `paper_coastal_life` → 3.0, `paper_terrain_island` → -3.5, `paper_side_paths` → -2.0, `paper_main_path` → -1.5, `paper_route_beads` → 1.0, `paper_safe_clearings` → 1.5, `paper_civic_cluster` → 2.0, `paper_discovery_props` → 3.0, `paper_harbor_boats` → 3.0, `paper_signal_ridge` → -5.0, `paper_vista_flags` → 4.5, `paper_harbor_landmark` → 4.0, `paper_telegraph_landmark` → 4.0, `paper_people_plaza` → 5.0, `paper_rift_core` → 5.0, `paper_wave_gate` → 5.0, `paper_map_compass` → 12.0, `paper_foreground_frame` → 18.0.

3. THE World_Builder SHALL her `_add_paper_cutout_asset()` çağrısında `set_meta("base_pos", position)` ile asset'in yerleştirme anındaki `position` değerini kaydetmelidir; böylece Tween tabanlı sallanma animasyonu bu değeri referans alabilir.

4. IF bir asset'in `paper_parallax_strength` değeri 0.0 olarak atanırsa, THEN THE World_Builder SHALL kamera hareketi sırasında o asset'in `position` değerini değiştirmemelidir; asset sahnede sabit kalmalıdır.

---

### Requirement 4: Textures Registry Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, tüm Samsun SVG asset'lerinin `textures.gd` içinde merkezi sabitler olarak tanımlanmasını istiyorum; böylece DRY prensibi korunur ve asset yolları tek noktadan yönetilir.

#### Acceptance Criteria

1. THE Textures_Registry SHALL `scripts/textures.gd` içinde `res://assets/art/world/samsun/` dizinindeki her SVG dosyası için, dosya adından uzantı çıkarılarak büyük harfe dönüştürülmüş `[ASSET_ADI]` ile `const SAMSUN_PAPER_[ASSET_ADI]_TEXTURE := preload("res://assets/art/world/samsun/[dosya_adı].svg")` formatında tam olarak bir sabit tanımlamalıdır; sabit sayısı `res://assets/art/world/samsun/` dizinindeki SVG dosyası sayısına eşit olmalıdır.

2. THE Textures_Registry SHALL Samsun sabitlerini `scripts/textures.gd` içinde `# ====================================` açılış satırı, ardından `# SAMSUN PAPER CUTOUT (özel asset)` başlık satırı, ardından `# ====================================` kapanış satırından oluşan bölüm başlığı altında gruplandırmalıdır; bu yapı diğer bölüm başlıklarıyla aynı biçimi korumalıdır.

3. WHEN `world_builder.gd` bir Samsun asset'i yüklemek istediğinde, THE World_Builder SHALL `_textures.SAMSUN_PAPER_[ASSET_ADI]_TEXTURE` sabitini kullanmalıdır; `world_builder.gd` içinde `preload("res://assets/art/world/samsun/` ile başlayan hiçbir doğrudan `preload()` çağrısı bulunmamalıdır.

4. THE Textures_Registry SHALL `scripts/textures.gd` içindeki mevcut `SAMSUN_PAPER_*` sabitlerinin hiçbirini silmemeli veya yeniden adlandırmamalıdır; yeni sabitler mevcut sabitlerden sonra aynı bölüm içine eklenmelidir.

---

### Requirement 5: Colors Registry Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, Samsun bölgesine özgü renk sabitlerinin `colors.gd` içinde tanımlı `THEME_SAMSUN` sözlüğünden türetilmesini istiyorum; böylece renk sistemi tutarlılığı sağlansın.

#### Acceptance Criteria

1. THE Colors_Registry SHALL `scripts/colors.gd` içinde `THEME_SAMSUN` adlı bir `Dictionary` sabiti tanımlamalıdır; bu sözlük `"bg"`, `"accent"`, `"panel"`, `"shadow"` ve `"text"` anahtarlarını içermeli ve her anahtar sırasıyla `POP_DEEP_TURQUOISE`, `POP_GOLD`, `DESIGN_CREAM_PAPER`, `PAPER_SHADOW` ve `DESIGN_STORY_INK` adlı sabitlerden değer almalıdır.

2. THE World_Builder SHALL `_build_samsun_rift()` içinde renk değerlerini doğrudan hex string olarak yazmak yerine `_colors.THEME_SAMSUN["bg"]`, `_colors.THEME_SAMSUN["accent"]` gibi referanslarla kullanmalıdır; `_build_samsun_rift()` fonksiyonu içinde `Color("#` ile başlayan hiçbir doğrudan renk literali bulunmamalıdır.

3. WHEN `THEME_SAMSUN` sözlüğündeki bir renk değeri `scripts/colors.gd` içinde güncellenerek dosya kaydedildiğinde, THE World_Builder SHALL oyun yeniden başlatıldığında bir sonraki `_build_samsun_rift()` çağrısında güncellenmiş rengi kullanmalıdır; renk değerleri oyun başlangıcında yüklenir ve çalışma zamanında yeniden yüklenmez.

4. THE Colors_Registry SHALL `scripts/colors.gd` içinde `RIFT_BLUE` adlı bir `Color` sabiti tanımlamalıdır; bu sabitin R kanalı tam olarak 0.22, G kanalı tam olarak 0.78, B kanalı tam olarak 1.0 değerinde olmalıdır; böylece `paper_rift_core.svg` içindeki `#53c6df` renk değeriyle görsel uyum sağlanır.

---

### Requirement 6: World Builder Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, `_build_samsun_rift()` fonksiyonunun mevcut `_build_*` pattern'ini izlemesini istiyorum; böylece kod tabanı tutarlılığı korunur.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_samsun_rift()` içinde tüm SVG asset'leri `_add_paper_cutout_asset()` veya `_add_foreground_paper_cutout_asset()` yardımcı fonksiyonlarını kullanarak sahnelere eklemeli; `Sprite2D.new()` veya `Node2D.new()` gibi doğrudan node oluşturma çağrıları `_build_samsun_rift()` içinde bulunmamalıdır.

2. THE World_Builder SHALL `_build_samsun_rift()` içinde `_decorate_samsun_rift()` fonksiyonunu çağırmalıdır; `_decorate_samsun_rift()` fonksiyonu atmosferik efektleri (`_add_soft_blob()`, rift cloud, light pool) eklemeli ve `_build_samsun_rift()` içinde doğrudan `_add_soft_blob()` çağrısı yapılmamalıdır.

3. THE World_Builder SHALL `_build_samsun_rift()` içinde marker oluşturma işlemini `world_marker.gd`'deki `_spawn_samsun_rift_markers()` fonksiyonuna devretmelidir; `harbor_landmark`, `telegraph_landmark` ve `people_plaza` marker node'ları `_build_samsun_rift()` içinde doğrudan oluşturulmamalıdır.

4. THE World_Builder SHALL `_build_samsun_rift()` içinde `func _process(delta)` çağrısı veya `while` döngüsü içermemelidir; tüm animasyonlar `create_tween()` ile başlatılan `Tween` nesneleri aracılığıyla uygulanmalıdır.

5. WHEN `build_world("samsun_rift", world_root)` çağrıldığında, THE World_Builder SHALL `world_built` sinyalini `"samsun_rift"` String argümanıyla yaymalıdır; sinyal hem `_build_samsun_rift()` hem de `_decorate_samsun_rift()` tamamlandıktan sonra yayılmalıdır.

6. THE World_Builder SHALL `_build_samsun_rift()` içinde tüm yerel değişkenleri GDScript 2.0 statik tipleme sözdizimi ile tanımlamalıdır; `var pos := Vector2(800, 400)` yerine `var pos: Vector2 = Vector2(800, 400)` veya `var pos: Vector2 := Vector2(800, 400)` formatı kullanılmalıdır.

---

### Requirement 7: Liman (Harbor) Asset Grubu

**User Story:** Bir oyun tasarımcısı olarak, Samsun limanını temsil eden asset grubunun iskele, sandık, vapur ve deniz feneri öğelerini içermesini istiyorum; böylece 1919 Samsun limanı atmosferi oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_harbor_landmark.svg` dosyasında iskele platformu, en az 1 sandık, 1 vapur silüeti ve 1 deniz feneri silüetini tek bir kompozisyonda içermelidir; her öğe ayrı bir `<path>` elementi olarak tanımlanmalıdır.

2. THE Asset_Kit SHALL `paper_harbor_water.svg` dosyasında `#067078` renk ailesinden türetilen turkuaz deniz yüzeyini yatay bantlarla temsil etmelidir; yatay bantlar en az 3 farklı `opacity` değeri (0.40, 0.60, 0.80 ± 0.05) kullanmalıdır.

3. THE Asset_Kit SHALL `paper_harbor_boats.svg` dosyasında en az 1 sandal ve 1 martı silüetini içermelidir; martı silüeti `<path>` elementi olarak, sandal silüeti ayrı bir `<path>` elementi olarak tanımlanmalıdır; `paper_harbor_boats.svg` dosyası `paper_harbor_landmark.svg` ve `paper_harbor_water.svg` dosyalarıyla birlikte kullanıldığında liman sahnesini görsel olarak tamamlamalıdır.

4. THE Asset_Kit SHALL `paper_harbor_landmark.svg` dosyasında `<metadata>` elementi içinde `<slot_id>samsun.harbor_landmark</slot_id>` etiketini içermelidir; böylece marker sistemi bu asset'i tanıyabilir.

---

### Requirement 8: Telgraf Tepesi Asset Grubu

**User Story:** Bir oyun tasarımcısı olarak, Telgraf Tepesi asset grubunun telgraf direği, bina ve Türk bayrağı öğelerini içermesini istiyorum; böylece tarihsel telgraf istasyonu atmosferi oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_telegraph_landmark.svg` dosyasında telgraf direği, küçük bir bina ve bayrak direği silüetini içermelidir; bina yüksekliği telgraf direği yüksekliğinin en fazla %50'si kadar olmalıdır; her öğe ayrı bir `<path>` elementi olarak tanımlanmalıdır.

2. THE Asset_Kit SHALL `paper_vista_flags.svg` dosyasında en az 1 Türk bayrağı ve 1 flama silüetini içermelidir; bayrak `<path>` elementlerinde `fill` değeri `#B82E1F` (POP_CRIMSON) renk ailesinden türetilmelidir.

3. THE Asset_Kit SHALL `paper_telegraph_landmark.svg` dosyasında `<metadata>` elementi içinde `<slot_id>samsun.telegraph_landmark</slot_id>` etiketini içermelidir.

---

### Requirement 9: Halk Meydanı Asset Grubu

**User Story:** Bir oyun tasarımcısı olarak, Halk Meydanı asset grubunun heykel, bank, ağaç ve NPC figürleri içermesini istiyorum; böylece sivil toplantı atmosferi oluşturulsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_people_plaza.svg` dosyasında en az 1 heykel (kaide üzerinde figür), 1 bank ve 1 ağaç silüetini içermelidir; her öğe ayrı bir `<path>` elementi olarak tanımlanmalıdır.

2. THE Asset_Kit SHALL `paper_people_plaza.svg` dosyasında en az 2 NPC figür silüetini içermelidir; her NPC figürü tek renk dolgulu (`fill="#2B2730"`) ve iç detay içermeyen (tek `<path>` elementi) basit siluet olarak çizilmelidir.

3. THE Asset_Kit SHALL `paper_people_plaza.svg` dosyasında `<metadata>` elementi içinde `<slot_id>samsun.people_plaza</slot_id>` etiketini içermelidir.

---

### Requirement 10: Rift Çekirdeği Asset Grubu

**User Story:** Bir oyun tasarımcısı olarak, Rift Çekirdeği asset'inin mavi kristal portal efektini temsil etmesini istiyorum; böylece zaman yolculuğu geçiş noktası görsel olarak belirgin olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_rift_core.svg` dosyasında merkezi bir kristal şekli `<path>` elementi, dışa yayılan tam olarak 2 enerji halkası `<path>` elementi ve mavi ışıltı efekti `<path>` elementi içermelidir; toplam `<path>` sayısı tam olarak 4 olmalıdır.

2. THE Asset_Kit SHALL `paper_rift_core.svg` dosyasında enerji halkası `<path>` elementlerinde `fill="#53c6df"` ve kristal çekirdek `<path>` elementlerinde `fill="#f9eec5"` renk değerlerini kullanmalıdır; bu elementlerin `opacity` değerleri 0.58 ile 0.82 arasında olmalıdır.

3. THE World_Builder SHALL `_decorate_samsun_rift()` içinde `paper_rift_core.svg` asset'inin konumuna `_add_soft_blob()` fonksiyonunu çağırarak mavi ışıltı efekti eklemelidir; `_add_soft_blob()` çağrısında renk parametresi `_colors.RIFT_BLUE` sabiti olmalıdır; `_add_soft_blob()` çağrısının yarıçap parametresi 80 ile 140 piksel arasında olmalıdır.

4. THE Asset_Kit SHALL `paper_rift_core.svg` dosyasında `<metadata>` elementi içinde `<slot_id>samsun.rift_core</slot_id>` etiketini içermelidir.

---

### Requirement 11: Uzak Şehir Silüeti ve Gökyüzü

**User Story:** Bir oyun tasarımcısı olarak, Samsun'un uzak şehir silüetinin ve gökyüzünün derinlik hissi yaratmasını istiyorum; böylece diorama perspektifi güçlensin.

#### Acceptance Criteria

1. THE Asset_Kit SHALL `paper_sky_samsun.svg` dosyasında sabah ışığını temsil eden en az 2 yatay bant `<path>` elementi içermelidir; üst bant `fill` değeri `#067078` renk ailesinden (açık turkuaz), alt bant `fill` değeri `#F5E8D3` renk ailesinden (krem) türetilmelidir.

2. THE Asset_Kit SHALL `paper_distant_town.svg` dosyasında kule, kubbe ve bayrak direği silüetlerini temsil eden `<path>` elementlerini içermelidir; bu elementlerin `opacity` değerleri 0.40 ile 0.60 arasında olmalıdır.

3. THE Asset_Kit SHALL `paper_sky_samsun.svg` dosyasını `viewBox` genişliği 1600 pikselden büyük olacak şekilde üretmelidir; böylece kamera hareketi sırasında gökyüzü asset'inin sağ veya sol kenarı ekranda görünmez.

---

### Requirement 12: Rota İkonları

**User Story:** Bir oyun tasarımcısı olarak, Samsun bölgesindeki rota ikonlarının (başlangıç, durak, görev, bitiş) paper diorama stiliyle tutarlı olmasını istiyorum; böylece oyuncu yönlendirmesi görsel dille uyumlu olsun.

#### Acceptance Criteria

1. THE World_Builder SHALL `_decorate_samsun_rift()` içinde `harbor_landmark` marker'ının konumuna `_add_soft_blob()` fonksiyonunu çağırarak başlangıç noktası ışıltı efekti eklemelidir; `_add_soft_blob()` çağrısında renk parametresi `_colors.POP_GOLD` sabiti olmalıdır.

2. THE World_Builder SHALL `_decorate_samsun_rift()` içinde `telegraph_landmark` marker'ının konumuna `_add_soft_blob()` fonksiyonunu çağırarak durak noktası ışıltı efekti eklemelidir; `_add_soft_blob()` çağrısında renk parametresi `_colors.RIFT_BLUE` sabiti olmalıdır.

3. THE World_Builder SHALL `_decorate_samsun_rift()` içinde `people_plaza` marker'ının konumuna `_add_soft_blob()` fonksiyonunu çağırarak görev noktası ışıltı efekti eklemelidir; `_add_soft_blob()` çağrısında renk parametresi `_colors.POP_CRIMSON` sabiti olmalıdır.

4. THE World_Builder SHALL her marker ışıltı efektini `_add_soft_blob()` fonksiyonuyla oluşturmalıdır; `_decorate_samsun_rift()` içinde `func _process(delta)` çağrısı veya `Timer` node'u kullanılmamalıdır; ışıltı efektleri statik olmalı ve zaman içinde animasyon içermemelidir.

---

### Requirement 13: Mobil Performans Kısıtları

**User Story:** Bir oyun geliştiricisi olarak, Samsun asset kitinin Android cihazlarda 60 FPS performansını korumasını istiyorum; böylece 5-10 yaş hedef kitlesinin cihazlarında akıcı oyun deneyimi sağlansın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_samsun_rift()` içinde `func _process(delta)` fonksiyonunu çağırmamalıdır; `_build_samsun_rift()` içinde `_process` adını içeren hiçbir fonksiyon çağrısı bulunmamalıdır.

2. THE World_Builder SHALL `_build_samsun_rift()` içinde tüm animasyonları `create_tween()` ile başlatılan `Tween` nesneleri aracılığıyla uygulamalıdır; `_build_samsun_rift()` içinde `AnimationPlayer`, `AnimationTree` veya `Timer` node'u oluşturulmamalıdır.

3. THE World_Builder SHALL `_build_samsun_rift()` tamamlandığında sahnede oluşturulan `Sprite2D` ve `Polygon2D` node'larının toplam sayısını 60'ın altında tutmalıdır; bu sayım `Props`, `ForegroundProps` ve `Markers` node'larının doğrudan alt node'larını kapsar.

4. THE Asset_Kit SHALL `assets/art/world/samsun/` dizinindeki her SVG kaynak dosyasının disk boyutunu 50 KB'ın altında tutmalıdır; disk boyutu Godot import işlemi öncesi kaynak `.svg` dosyasının boyutunu ifade eder.

5. WHEN `clear_world(world_root)` çağrıldığında, THE World_Builder SHALL `Props`, `ForegroundProps` ve `Markers` node'larının doğrudan alt node'larından `set_meta("asset_slot", ...)` ile `"paperworld.samsun_"` önekiyle işaretlenmiş tüm node'ları `queue_free()` ile serbest bırakmalıdır.

---

### Requirement 14: Portrait 9:16 Kompozisyon Uyumu

**User Story:** Bir oyun tasarımcısı olarak, tüm Samsun asset'lerinin 1080×1920 portrait ekranda doğal görünmesini istiyorum; böylece Android hedef platformunda görsel bütünlük sağlansın.

#### Acceptance Criteria

1. THE World_Builder SHALL `_build_samsun_rift()` içinde her asset'i `WORLD_SIZE = Vector2(1600, 2200)` koordinat sistemi içinde konumlandırmalıdır; hiçbir asset'in `position.x` değeri -100'den küçük veya 1700'den büyük, `position.y` değeri -100'den küçük veya 2300'den büyük olmamalıdır.

2. THE Asset_Kit SHALL `paper_foreground_frame.svg` dosyasını `viewBox` genişliği en az 1600 piksel olacak şekilde üretmelidir; böylece ekranın sol ve sağ kenarları kapatılır.

3. THE Asset_Kit SHALL `paper_sky_samsun.svg` dosyasını `viewBox` yüksekliği en az 800 piksel olacak şekilde üretmelidir; `_build_samsun_rift()` içinde `paper_sky_samsun` asset'inin `position.y` değeri 380 ± 50 piksel olarak ayarlandığında gökyüzü ile terrain arasında boşluk kalmamalıdır.

4. WHEN kamera `zoom` değeri `Vector2(0.9, 0.9)` olarak ayarlandığında, THE World_Builder SHALL `harbor_landmark` (Vector2(360, 760)), `telegraph_landmark` (Vector2(1190, 770)) ve `people_plaza` (Vector2(530, 1455)) asset'lerinin merkez noktalarının 1080×1920 ekran koordinatları içinde kalmasını sağlamalıdır; merkez noktası ekran sınırlarından en az 50 piksel içeride olmalıdır.

---

### Requirement 15: SVG Üretim Standardı (Round-Trip Uyumu)

**User Story:** Bir oyun geliştiricisi olarak, SVG dosyalarının Godot 4.6.2 tarafından içe aktarılıp tekrar dışa aktarıldığında görsel bütünlüğünü korumasını istiyorum; böylece asset pipeline güvenilir olsun.

#### Acceptance Criteria

1. THE Asset_Kit SHALL her SVG dosyasını kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` attribute'u ile üretmelidir.

2. THE Asset_Kit SHALL SVG dosyalarında `style` attribute'u veya `<defs>` elementi kullanmamalıdır; `style` attribute'u yalnızca `fill` ve `stroke` gibi temel özellikleri içerse dahi kullanılmamalıdır; tüm görsel özellikler `fill`, `stroke`, `stroke-width`, `opacity` attribute'ları olarak doğrudan `<path>` elementlerinde tanımlanmalıdır.

3. THE Asset_Kit SHALL SVG dosyalarında `<text>` veya `<tspan>` elementi kullanmamalıdır.

4. THE Asset_Kit SHALL her SVG dosyasında `<path>` elementlerinin `d` attribute'unda yalnızca büyük harf (mutlak koordinat) komutları kullanmalıdır: `M`, `L`, `C`, `Q`, `A`, `Z`; küçük harf (göreli koordinat) komutları `m`, `l`, `c`, `q`, `a` kullanılmamalıdır.

5. THE Asset_Kit SHALL her SVG dosyasında `<image>`, `<use>`, `<symbol>` veya `xlink:href` referansı içermemelidir; tüm görsel içerik `<path>`, `<rect>`, `<circle>`, `<ellipse>` veya `<polygon>` elementleriyle tanımlanmalıdır.

