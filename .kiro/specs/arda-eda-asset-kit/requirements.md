# Gereksinimler Belgesi — Arda ve Eda Asset Kit

## Introduction

Bu belge, "Zaman Yolcuları" oyununun iki ana öğrenci karakteri olan Arda ve Eda için üretilecek yenilenmiş karakter asset kitinin gereksinimlerini tanımlar. Kapsam, mevcut dosya yollarını koruyarak Arda ve Eda'nın world sprite'larını ve portre ekspresyon setlerini daha tutarlı, daha okunabilir ve mevcut neo-historical paper diorama görsel diliyle uyumlu hale getirmektir.

Oyun; Godot 4.6.2 ile geliştirilmiş, Android portrait (1080×1920, 9:16) hedefli, 5-10 yaş grubu için tarih temalı eğitici anlatı/macera oyunudur. Arda ve Eda asset'leri; dünya içinde karakter seçimi, ana menü sunumu, dialogue overlay, decision overlay ve karakter kimlik kartlarında birlikte çalışır. Bu nedenle asset seti yalnızca estetik olarak değil, UI okunabilirliği ve mevcut preload sözleşmeleri açısından da güvenilir olmak zorundadır.

---

## Requirements

### Requirement 1: Karakter Asset Dosya Seti

**User Story:** Bir oyun sanatçısı olarak, Arda ve Eda için eksiksiz ve tutarlı bir karakter asset seti istiyorum; böylece dünya içi karakter gösterimi ve diyalog portreleri tek bir görsel kalite seviyesinde çalışsın.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL aşağıdaki 8 SVG dosyasını korumalı ve üretmelidir: `assets/art/characters/arda/char_arda_world.svg`, `assets/art/characters/arda/portrait_arda_idle.svg`, `assets/art/characters/arda/portrait_arda_happy.svg`, `assets/art/characters/arda/portrait_arda_thinking.svg`, `assets/art/characters/eda/char_eda_world.svg`, `assets/art/characters/eda/portrait_eda_idle.svg`, `assets/art/characters/eda/portrait_eda_happy.svg`, `assets/art/characters/eda/portrait_eda_thinking.svg`.

2. THE Character_Asset_Kit SHALL mevcut dosya adlarını ve klasör yapısını değiştirmemelidir; entegrasyon mevcut preload yolları üzerinden çalışmaya devam etmelidir.

3. THE Character_Asset_Kit SHALL her karakter için tam olarak 1 world sprite ve 3 portrait expression dosyası içermelidir.

4. WHEN oyun `textures.gd`, `dialogue_overlay.gd` ve `decision_overlay.gd` üzerinden bu dosyaları preload ettiğinde, THE Character_Asset_Kit SHALL eksik dosya veya import hatası üretmemelidir.

---

### Requirement 2: Arda ve Eda Kimlik Ayrışması

**User Story:** Bir oyun tasarımcısı olarak, Arda ve Eda'nın ilk bakışta ayırt edilebilir görsel kimliklere sahip olmasını istiyorum; böylece oyuncu karakter seçiminde ve diyaloglarda iki öğrenciyi karıştırmasın.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL Arda için birincil vurgu paletini `Arda Coral` `#D6674B` ve `Arda Amber` `#F0A24A` ailesinden üretmelidir.

2. THE Character_Asset_Kit SHALL Eda için birincil vurgu paletini `Eda Teal` `#438A87` ve `Eda Mist` `#9DD3C8` ailesinden üretmelidir.

3. THE Character_Asset_Kit SHALL iki karakterin saç silüeti, üst beden formu ve en az bir karaktere özgü aksesuar/giysi ritmini birbirinden belirgin biçimde ayırmalıdır.

4. THE Character_Asset_Kit SHALL iki karakterde ortak yüz oranları ve outline sistemi kullanarak aynı oyun evrenine ait olduklarını korumalıdır.

5. THE Character_Asset_Kit SHALL Arda'yı "cesur, meraklı"; Eda'yı "akıllı, sakin" tonalitesini destekleyen duruş ve yüz ritmiyle sunmalıdır.

---

### Requirement 3: Portrait Expression Seti

**User Story:** Bir oyun yazarı ve UI tasarımcısı olarak, Arda ve Eda'nın diyalog ve karar anlarında farklı duyguları taşıyan portre ekspresyonlarına sahip olmasını istiyorum; böylece tarihsel anlatı yalnız metne değil karakter ifadesine de yaslansın.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL her karakter için `idle`, `thinking` ve `happy` olmak üzere tam 3 portre ekspresyonu üretmelidir.

2. THE Character_Asset_Kit SHALL `idle` portresinde sakin/nötr dikkat hali, `thinking` portresinde kaş-göz-ağız ritminde belirgin düşünme hali, `happy` portresinde rahatlama veya umut duygusu içeren açık bir ifade farkı sunmalıdır.

3. THE Character_Asset_Kit SHALL aynı karakterin üç portresinde kafa açısı, omuz kadrajı ve genel kompozisyonu tutarlı tutmalıdır; expression farkı silüet bütünlüğünü bozmamalıdır.

4. THE Character_Asset_Kit SHALL portreleri `dialogue_overlay.gd` içindeki sol/sağ yerleşimde okunabilir kılmak için yüzü merkeze yakın ve göz hattını üst-orta bantta tutmalıdır.

5. THE Character_Asset_Kit SHALL speaker name zaten UI içinde yazıldığı için portrait SVG içinde karakter adı yazısı kullanmamalıdır.

6. IF bir portrait expression dosyası güncellenirse, THEN THE Character_Asset_Kit SHALL diğer iki expression dosyasında da aynı karakter kimliğini koruyan çizgi dili ve renk ailesini sürdürmelidir.

---

### Requirement 4: World Sprite Okunabilirliği

**User Story:** Bir oyun geliştiricisi olarak, Arda ve Eda'nın world sprite'larının hem açık sahnelerde hem de menü katmanında küçük ölçekte okunabilir olmasını istiyorum; böylece oyuncu hangi karakterin aktif olduğunu her zaman anlayabilsin.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL `char_arda_world.svg` ve `char_eda_world.svg` dosyalarını tam gövdeye yakın, ayakta duran, şeffaf arka planlı world sprite olarak üretmelidir.

2. THE Character_Asset_Kit SHALL world sprite'larda baş-gövde oranını çocuk okunabilirliğini destekleyecek şekilde büyük ve sade tutmalıdır; ince detay yerine silüet öncelikli yaklaşım kullanılmalıdır.

3. THE Character_Asset_Kit SHALL `main_menu.gd` içindeki yaklaşık `180x220` minimum sprite sunumunda okunabilir kalmalıdır.

4. THE Character_Asset_Kit SHALL `world_player.gd` içindeki `PlayerSprite` ve `CompanionSprite` kullanımı için ayak tabanını görsel alt banda sabitlemeli; karakterler farklı dosyalarda zıplıyormuş gibi görünmemelidir.

5. THE Character_Asset_Kit SHALL world sprite içinde zemin gölgesi veya yer referansı üretebilir; ancak bu öğe karakterin gerçek gövde konturunu kirletmemelidir.

---

### Requirement 5: Dialogue ve Decision Overlay Entegrasyonu

**User Story:** Bir oyun geliştiricisi olarak, Arda ve Eda asset'lerinin mevcut dialogue ve decision overlay sözleşmeleriyle doğrudan çalışmasını istiyorum; böylece kod tarafında yeniden adlandırma veya geçici workaround gerekmeyecek.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL `scripts/dialogue_overlay.gd` içindeki `ARDA_IDLE_TEXTURE`, `ARDA_HAPPY_TEXTURE`, `ARDA_THINKING_TEXTURE`, `EDA_IDLE_TEXTURE`, `EDA_HAPPY_TEXTURE`, `EDA_THINKING_TEXTURE` preload çağrılarıyla uyumlu kalmalıdır.

2. THE Character_Asset_Kit SHALL `scripts/decision_overlay.gd` içindeki `portrait_arda_idle.svg` ve `portrait_eda_idle.svg` kullanımını bozmayacak şekilde idle portreleri net, ön-yüz ve karar kartı içinde okunabilir üretmelidir.

3. THE Character_Asset_Kit SHALL her portrait dosyasını kare formatta tutmalı ve mevcut decision/dialogue frame'lerinde ek crop gerektirmemelidir.

4. THE Character_Asset_Kit SHALL portrait dosyalarının odak noktasını çene kesilmeyecek ve saç tepesi taşmayacak şekilde merkezi kadraj içinde üretmelidir.

---

### Requirement 6: Karakter Seçimi ve Kimlik Kartı Uyumu

**User Story:** Bir UX tasarımcısı olarak, Arda ve Eda asset'lerinin karakter seçim panelinde ve kimlik kartlarında güçlü ilk izlenim oluşturmasını istiyorum; böylece oyuncu daha oyun başlamadan iki kahraman arasında bilinçli seçim yapabilsin.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL `world_player.gd` içindeki kimlik kartı satırında world sprite kullanıldığında Arda ve Eda'yı küçük kart ölçüsünde ayırt edilir kılmalıdır.

2. THE Character_Asset_Kit SHALL ana karakter seçimi akışında Arda ve Eda arasında yalnız renk değil, silüet ve ifade düzeyinde de farklılık sunmalıdır.

3. THE Character_Asset_Kit SHALL karakter seçim ekranında iki karakter aynı anda göründüğünde kompozisyon dengesini bozmayacak yoğunlukta detay kullanmalıdır.

4. THE Character_Asset_Kit SHALL görsel tonu korkutucu, yetişkinimsi veya aşırı dramatik yapmamalıdır; 5-10 yaş kitlesi için sıcak ve güven verici kalmalıdır.

---

### Requirement 7: Neo-Historical Karakter Stili

**User Story:** Bir sanat yönetmeni olarak, Arda ve Eda'nın karakter asset'lerinin oyunun paper diorama + neo-historical görsel yönüyle uyumlu olmasını istiyorum; böylece çevreler ve karakterler ayrı projelerden gelmiş gibi görünmesin.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL ana dış konturlarda `Story Ink` `#2B2730` veya yakın koyu tonlar kullanmalıdır.

2. THE Character_Asset_Kit SHALL cilt tonlarını sıcak ve sade tutmalı; aşırı gerçekçi modelleme veya yoğun gradient etkisi kullanmamalıdır.

3. THE Character_Asset_Kit SHALL yüz, saç ve kıyafet bölgelerinde düşük karmaşıklıklı, okunabilir shape language kullanmalıdır.

4. THE Character_Asset_Kit SHALL Bandırma, Samsun, Havza ve Amasya gibi sahnelerin krem, turkuaz, altın ve crimson vurgu sistemleriyle çatışmayacak doygunluk seviyesinde çalışmalıdır.

5. THE Character_Asset_Kit SHALL outline + flat fill + sınırlı highlight yaklaşımını kullanmalı; gürültülü texture veya boyalı fırça dokusu üretmemelidir.

---

### Requirement 8: SVG Üretim Standardı

**User Story:** Bir oyun geliştiricisi olarak, Arda ve Eda asset'lerinin Godot 4.6.2 import hattında güvenilir çalışmasını istiyorum; böylece karakter dosyaları diğer SVG asset setleriyle aynı teknik standartta kalabilsin.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL her SVG dosyasını kök `<svg>` elementinde `xmlns="http://www.w3.org/2000/svg"` ile üretmelidir.

2. THE Character_Asset_Kit SHALL `style` attribute'u, `<defs>`, `<image>`, `<use>`, `<symbol>` ve harici referans (`xlink:href`, `url()`) kullanmamalıdır.

3. THE Character_Asset_Kit SHALL yeni veya güncellenmiş portrait SVG dosyalarında `<text>` elementi bulundurmamalıdır.

4. THE Character_Asset_Kit SHALL her SVG dosyasını iyi biçimlendirilmiş XML olarak üretmelidir; açılan tüm etiketler kapanmalıdır.

5. THE Character_Asset_Kit SHALL her SVG dosyasını Godot import pipeline'ında parse edilebilir tutmalıdır; editör tema uyarıları bu kriterin dışında kalır.

---

### Requirement 9: Mobil Performans ve Dosya Bütçesi

**User Story:** Bir oyun geliştiricisi olarak, Arda ve Eda asset'lerinin mobil cihazlarda hızlı yüklenmesini istiyorum; böylece menü ve diyalog açılışlarında gecikme yaşanmasın.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL her portrait SVG dosyasını 80 KB altında tutmalıdır.

2. THE Character_Asset_Kit SHALL her world sprite SVG dosyasını 60 KB altında tutmalıdır.

3. THE Character_Asset_Kit SHALL gereksiz path çoğalmasına gitmemeli; aynı okunabilirliği daha az shape ile çözmeyi hedeflemelidir.

4. WHEN oyun `dialogue_overlay`, `decision_overlay`, `main_menu` veya `world_player` içinde bu dosyaları yüklediğinde, THE Character_Asset_Kit SHALL fark edilir yükleme gecikmesine yol açmamalıdır.

---

### Requirement 10: Değişmeyecek Entegrasyon Sözleşmesi

**User Story:** Bir oyun geliştiricisi olarak, karakter asset yenilemesinin kod yüzeyini büyütmeden uygulanmasını istiyorum; böylece iş yalnız asset odaklı kalabilsin.

#### Acceptance Criteria

1. THE Character_Asset_Kit SHALL `scripts/textures.gd` içindeki `ARDA_TEXTURE` ve `EDA_TEXTURE` sabit adlarını korumalıdır.

2. THE Character_Asset_Kit SHALL `scripts/dialogue_overlay.gd` ve `scripts/decision_overlay.gd` içinde yeni dosya adı zorunluluğu yaratmamalıdır.

3. THE Character_Asset_Kit SHALL mevcut ekspresyon kümesini aşan yeni zorunlu expression türleri tanımlamamalıdır; `idle`, `thinking`, `happy` MVP kapsamı olarak kalmalıdır.

4. IF ileride ek expression türleri gerekirse, THEN THE Character_Asset_Kit SHALL mevcut 8 dosyalık temel setin üzerine genişleyebilir; ancak ilk teslim bu gereksinime bağlı olmamalıdır.