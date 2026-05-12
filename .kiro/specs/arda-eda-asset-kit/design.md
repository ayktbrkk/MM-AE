# Teknik Tasarım — Arda ve Eda Asset Kit

## Genel Bakış

Bu belge, Arda ve Eda için yenilenecek karakter asset kitinin teknik tasarımını tanımlar. Kapsam, mevcut dosya yollarını koruyarak 2 world sprite ve 6 portrait expression SVG dosyasını neo-historical paper diorama görsel diline daha sıkı bağlamak, küçük mobil ölçekte okunabilirliği artırmak ve mevcut preload sözleşmelerini bozmadan üretimi tamamlamaktır.

Bu spec'in temel ilkesi şudur: **öncelikli çözüm asset seviyesinde yapılır, kod yüzeyi yalnız doğrulama sırasında gerçek bir kırılma görünürse değiştirilir.** Mevcut runtime entegrasyonu zaten `textures.gd`, `dialogue_overlay.gd`, `decision_overlay.gd`, `main_menu.gd` ve `world_player.gd` üzerinden kuruludur; bu nedenle yeniden adlandırma veya yeni expression tipi ekleme hedeflenmez.

---

## Mevcut Durum

### Dosya Seti

```text
assets/art/characters/arda/
  char_arda_world.svg
  portrait_arda_idle.svg
  portrait_arda_happy.svg
  portrait_arda_thinking.svg

assets/art/characters/eda/
  char_eda_world.svg
  portrait_eda_idle.svg
  portrait_eda_happy.svg
  portrait_eda_thinking.svg
```

### Kullanım Yüzeyi

- `scripts/textures.gd`
  - `ARDA_TEXTURE`
  - `EDA_TEXTURE`
- `scripts/main_menu.gd`
  - ana menü karakter sunumu için world sprite kullanır
- `scripts/world_player.gd`
  - oyuncu ve yoldaş sprite'ları ile karakter kimlik kartlarında world sprite kullanır
- `scripts/decision_overlay.gd`
  - iki karakter için `idle` portrait kullanır
- `scripts/dialogue_overlay.gd`
  - `idle`, `thinking`, `happy` portrait setini expression routing ile kullanır

### Teknik Gözlemler

- World sprite dosyaları şu anda yaklaşık 2 KB düzeyindedir ve `260x340` viewBox boyutunda üretilmiştir.
- Portrait dosyaları şu anda yaklaşık `1.2-1.35 KB` aralığındadır ve `520x520` kare canvas kullanır.
- Tüm portrait SVG dosyalarında gömülü `<text>` öğesi vardır; bu hem UI içi isim etiketleriyle gereksiz tekrar yaratır hem de SVG standardı gereksinimiyle çelişir.
- Mevcut expression seti sayıca yeterlidir, ancak üretim standardı ve kadraj sözleşmesi dokümante edilmemiştir.

---

## Sorunlar

- Portrait dosyalarında karakter adının SVG içine yazılmış olması, dialogue ve decision overlay içindeki mevcut isim kapsülleriyle çakışır.
- Arda ve Eda şu anda renk bazında ayrışıyor; ancak üretim spec'i seviyesinde silüet, aksesuar ve duruş ayrımı tanımlı değildir.
- World sprite ile portrait seti arasında ortak baseline, outline kalınlığı ve yüz yerleşimi için açık üretim standardı yoktur.
- Mobil kullanımdaki küçük gösterim yüzeyleri için menü, kimlik kartı ve overlay bazlı doğrulama adımları tanımlanmamıştır.

---

## Mimari

### Değişmeyecek Yapı

- `assets/art/characters/arda/` ve `assets/art/characters/eda/` klasör yolları
- Mevcut 8 dosyanın adları
- `scripts/textures.gd` içindeki `ARDA_TEXTURE` ve `EDA_TEXTURE` sabit adları
- `scripts/dialogue_overlay.gd` içindeki `idle`, `thinking`, `happy` expression sözlüğü
- `scripts/decision_overlay.gd` içindeki idle portrait bağımlılığı
- `scripts/main_menu.gd` ve `scripts/world_player.gd` içindeki world sprite kullanımı

### Değişecek Yapı

- 8 SVG dosyasının tamamı yeniden çizilecek veya yükseltilecek
- Portrait dosyalarındaki gömülü `<text>` öğeleri kaldırılacak
- Portrait kompozisyonları ortak kare kadraj, ortak omuz bandı ve ortak göz hattı kuralına göre normalize edilecek
- World sprite'lar ortak ayak tabanı ve küçük ölçekte daha net silüet verecek şekilde hizalanacak
- Her iki karakter için renk, saç, üst gövde formu ve ifade ritmi daha belirgin ayrıştırılacak

### Varsayılan Entegrasyon İlkesi

Bu spec, kodda isim/anahtar değişikliği istemez. Uygulama sırasında yalnızca aşağıdaki durumlarda kod dokunuşu opsiyonel hale gelir:

- portrait kadrajı mevcut UI çerçevesinde taşarsa
- world sprite baseline farkı nedeniyle karakter kartı veya oyuncu/yoldaş hizası bozulursa
- SVG import pipeline beklenmedik parse hatası verirse

Bu üç durumun dışında çözüm asset içinde tamamlanmalıdır.

---

## Görsel Sistem Tasarımı

### Ortak Karakter Kuralları

- Dış kontur: `Story Ink` `#2B2730` veya yakın koyu ton
- Dolgu yaklaşımı: flat fill + sınırlı highlight + düşük sayıda shape
- Cilt tonu: sıcak ve sade, gerçekçi gölgelendirme yok
- Silüet önceliği: ince detay yerine saç, baş, omuz ve gövde kütlesiyle tanınabilirlik
- Çocuk okunabilirliği: baş oranı büyük, mimik farkları abartısız ama net

### Arda Kimlik Yönergesi

- Ana vurgu: `#D6674B`, ikincil sıcak vurgu `#F0A24A`
- Duruş: ileri atılmaya hazır, meraklı, enerjik ama güvenli
- Saç/üst gövde: daha hareketli kontur, sıcak tonlu üst kıyafet
- Expression dili:
  - `idle`: dikkatli ve açık bakış
  - `thinking`: hafif kaş toplanması, odaklı bakış
  - `happy`: rahatlama ve umut duygusu

### Eda Kimlik Yönergesi

- Ana vurgu: `#438A87`, ikincil açık vurgu `#9DD3C8`
- Duruş: dengeli, sakin, planlı, güven verici
- Saç/üst gövde: daha kontrollü kontur, serin tonlu üst kıyafet
- Expression dili:
  - `idle`: dingin ve dikkatli ifade
  - `thinking`: analiz eden, içe odaklı bakış
  - `happy`: sıcak ama sakin sevinç

---

## Asset Üretim Planı

### Canvas ve Kadraj Tablosu

| Dosya | Hedef Canvas | Rol | Kullanım Yüzeyi |
|------|--------------|-----|-----------------|
| `char_arda_world.svg` | `260x340` | tam gövdeye yakın world sprite | menu, world, identity card |
| `char_eda_world.svg` | `260x340` | tam gövdeye yakın world sprite | menu, world, identity card |
| `portrait_arda_idle.svg` | `520x520` | nötr portrait | dialogue, decision |
| `portrait_arda_thinking.svg` | `520x520` | düşünme portrait | dialogue |
| `portrait_arda_happy.svg` | `520x520` | olumlu portrait | dialogue |
| `portrait_eda_idle.svg` | `520x520` | nötr portrait | dialogue, decision |
| `portrait_eda_thinking.svg` | `520x520` | düşünme portrait | dialogue |
| `portrait_eda_happy.svg` | `520x520` | olumlu portrait | dialogue |

### Portrait Kadraj Kuralları

- Kare canvas korunur: `viewBox="0 0 520 520"`
- Baş merkezi üst-orta bantta yer alır
- Omuz çizgisi alt üçte birlik bölgeye oturur
- Saç tepesi ile üst kenar arasında güvenli boşluk bırakılır
- Çene, alt güvenli alan içinde kalır
- SVG içine isim yazısı, rozet veya UI benzeri etiket eklenmez

### World Sprite Kuralları

- World sprite `viewBox="0 0 260 340"` korunur
- Ayak tabanı alt banda hizalanır
- Gölge varsa düşük opaklıkta, gövde konturundan ayrı okunur
- Küçük ölçekte tanınabilirlik için kol, saç ve kıyafet büyük şekiller halinde çözülür

---

## Dosya Bazlı Tasarım

### 1. Arda World Sprite

**`char_arda_world.svg`**
- Turuncu/sıcak ana gövde kütlesi
- Meraklı ve hafif öne dönük duruş
- Eda'dan daha hareketli saç ve omuz ritmi
- Menüde `180x220` sunumda okunabilir silüet

### 2. Eda World Sprite

**`char_eda_world.svg`**
- Teal/serin ana gövde kütlesi
- Daha dengeli ve sakin duruş
- Arda'dan daha kontrollü saç/omuz akışı
- Aynı baseline ile kimlik kartı ve companion sprite uyumu

### 3. Arda Portrait Seti

**`portrait_arda_idle.svg`**
- Kararlı ama nötr odak

**`portrait_arda_thinking.svg`**
- Kaş, göz ve ağız çizgisinde belirgin düşünme farkı

**`portrait_arda_happy.svg`**
- Daha açık ağız ve göz ritmiyle umut/rahatlama hissi

### 4. Eda Portrait Seti

**`portrait_eda_idle.svg`**
- Sakin ve ölçülü nötr ifade

**`portrait_eda_thinking.svg`**
- Analitik, içe odaklı bakış

**`portrait_eda_happy.svg`**
- Kontrollü ama sıcak memnuniyet hissi

---

## SVG Üretim Standardı

Her dosya aşağıdaki teknik sınıra uyar:

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="W" height="H" viewBox="0 0 W H">
  <path d="M..." fill="#F5E8D3"/>
  <path d="M..." fill="#D6674B"/>
  <path d="M..." fill="#D99B72"/>
  <path d="M..." fill="none" stroke="#2B2730" stroke-width="10"/>
</svg>
```

### Kurallar

- `xmlns="http://www.w3.org/2000/svg"` zorunlu
- `style` attribute kullanılmaz
- `<defs>`, `<image>`, `<use>`, `<symbol>`, harici referans yok
- Portrait dosyalarında `<text>` kullanılmaz
- Dosyalar iyi biçimlendirilmiş XML olur
- Gereksiz path çoğalması yapılmaz

---

## Entegrasyon Tasarımı

### Mevcut Kod Yüzeyiyle Uyum

Bu spec aşağıdaki preload ve kullanım noktalarını korur:

```gdscript
const ARDA_TEXTURE := preload("res://assets/art/characters/arda/char_arda_world.svg")
const EDA_TEXTURE := preload("res://assets/art/characters/eda/char_eda_world.svg")

const ARDA_IDLE_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_idle.svg")
const ARDA_HAPPY_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_happy.svg")
const ARDA_THINKING_TEXTURE := preload("res://assets/art/characters/arda/portrait_arda_thinking.svg")
const EDA_IDLE_TEXTURE := preload("res://assets/art/characters/eda/portrait_eda_idle.svg")
const EDA_HAPPY_TEXTURE := preload("res://assets/art/characters/eda/portrait_eda_happy.svg")
const EDA_THINKING_TEXTURE := preload("res://assets/art/characters/eda/portrait_eda_thinking.svg")
```

Hedef, bu preload satırlarına hiç dokunmadan asset yenilemesini tamamlamaktır.

### Doğrulama Yüzeyleri

- `main_menu.gd`: iki world sprite aynı anda okunabilir mi
- `world_player.gd`: player/companion baseline uyumu korunuyor mu
- `world_player.gd`: identity card içinde ayırt edilebilirlik yeterli mi
- `decision_overlay.gd`: idle portrait crop ve odak doğru mu
- `dialogue_overlay.gd`: `idle`, `thinking`, `happy` geçişlerinde karakter kimliği korunuyor mu

---

## Performans Tasarımı

- Portrait SVG hedefi: dosya başına `80 KB` altında
- World sprite SVG hedefi: dosya başına `60 KB` altında
- Mevcut dosyalar bu sınırların çok altında olduğundan asıl risk boyut değil, gereksiz karmaşıklık ve import kararsızlığıdır
- Hedef, kaliteyi artırırken dosya basitliğini korumaktır

---

## Test ve Doğrulama Tasarımı

### Statik Doğrulama

- 8 dosyanın tamamı beklenen yol ve adla bulunur
- Tüm dosyalarda `xmlns` bildirimi vardır
- Portrait dosyalarında `<text>` yoktur
- Yasak elementler kullanılmaz
- World sprite ve portrait dosya boyutları bütçe içinde kalır

### Runtime Doğrulama

- Ana menüde Arda ve Eda yan yana okunabilir görünür
- Karakter seçim panelinde world sprite'lar baseline kayması yapmaz
- Decision overlay içinde idle portrait'lar crop olmadan görünür
- Dialogue overlay içinde expression değişimleri net ayrışır

### Fallback Kuralı

Eğer runtime doğrulama sırasında crop, ölçek veya hizalama sorunu görülürse önce asset kadrajı düzeltilir. Yalnız bu yol yetersiz kalırsa ilgili UI node boyutu veya stretch ayarı için küçük kod düzeltmesi değerlendirilir.