# Bandırma Yolculuğu — Hikaye İncili (Story Bible)

> **Son Güncelleme:** 2026-05-09
> **Kapsam:** Tüm hikaye akışı, karakter rehberi, tarihsel doğruluk notları
> **Veri Kaynağı:** [`assets/data/questions.gd`](assets/data/questions.gd)

---

## 1. Hikaye Çerçevesi

### 1.1 Temel Kurgu

Oyuncu (Arda veya Eda), tarih sınavına çalışması gereken bir öğrencidir. Sınav gecesi uykuya dalar ve kendini Türk Milli Mücadele döneminin rüya dioramalarında bulur. Oyuncu, tarihsel kişiliklerin **yerine geçmez**; onların kararlarını anlamaya çalışan, tarihin sorumluluğunu taşıyan bir gözlemci/katılımcıdır.

### 1.2 Tasarım İlkeleri

| İlke | Açıklama |
|------|----------|
| **Tarihsel Doğruluk** | Tüm olaylar gerçek kronolojiye dayanır, ancak 7-8 yaş seviyesine uygun şekilde sadeleştirilir |
| **Empati, Ezber Değil** | Oyuncu tarihsel kararları hissederek öğrenir, ezberlemez |
| **A/B Kararları** | Her karar, 7-8 yaş için net bir doğru/yanlış ayrımına sahiptir; `retry` mesajı öğreticidir, cezalandırıcı değildir |
| **Bilgi Kartı** | Doğru karar sonrası `info` alanı, tarihsel bağlamı kısaca açıklar |
| **{hero} Kullanımı** | Oyuncu adı runtime'da Arda/Eda'ya göre değişir |

### 1.3 Karakterler

| Karakter | Rol | Açıklama |
|----------|-----|----------|
| **Arda** | Erkek oyuncu karakteri | Meraklı, cesur, bazen sabırsız. Tarihi anlamaya çalışan öğrenci. |
| **Eda** | Kız oyuncu karakteri | Düşünceli, dikkatli, analitik. Tarihsel bağlantıları fark eden öğrenci. |
| **Anlatıcı** | Üçüncü şahıs anlatıcı | Tarihsel bağlamı sağlar, oyuncuyu yönlendirir, duygusal tonu belirler. |
| **Yardımcı Karakterler** | Dönemsel figürler | Subay, telgrafçı, temsilci, vekil gibi dönem karakterleri diyaloglarda yer alır. |

---

## 2. Bölüm Yapısı

### 2.1 Genel Bölüm Şablonu

Her bölüm aşağıdaki yapıyı takip eder:

```
1. Giriş Story Event'i → Mekan ve durum tanıtımı
2. Keşif/Story Event'i → Tarihsel bağlam derinleşir
3. Karar (Decision) → A/B seçeneği ile kritik dönüm noktası
4. [Opsiyonel] İkinci Karar → Bölümün ikincil kararı
5. [Opsiyonel] Kapanış Story Event'i → Bölüm sonu değerlendirmesi
```

### 2.2 Bölüm Kronolojisi

```
Bölüm 0: Giriş — Sınav Gecesi          → Günümüz, Hazırlık
Bölüm 1: Samsun — Milli Mücadele Başlıyor → 19 Mayıs 1919
Bölüm 2: Havza — Milli Bilinç Uyanıyor    → 28 Mayıs 1919
Bölüm 3: Amasya — Bağımsızlık Kararı     → 22 Haziran 1919
Bölüm 4: Erzurum Kongresi                → 23 Temmuz - 7 Ağustos 1919
Bölüm 5: Sivas Kongresi                  → 4-11 Eylül 1919
Bölüm 6: Ankara — Meclis ve İrade        → 27 Aralık 1919 / 23 Nisan 1920
Bölüm 7: Sakarya & Büyük Taarruz         → 1921-1922
Final: Cumhuriyet                        → 29 Ekim 1923
```

---

## 3. Olay Dizini (Event Index)

Her olay, [`questions.gd`](assets/data/questions.gd:5) içindeki `EVENTS` dizisinde 0-indeksli sırayla yer alır.

### BÖLÜM 0: Giriş — Sınav Gecesi (İndeks 0-2)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 0 | `story` | Anlatıcı | {hero} sınav gecesi oyun oynar, kitabı görür |
| 1 | `story` | {hero} | {hero} yatağına uzanır, kitabı okumaya başlar, uykuya dalar |
| 2 | `story` | Anlatıcı | Bandırma Vapuru'nda uyanış, üniforma, ayna sahnesi |

**Tarihsel Arkaplan:** Yok (kurgusal giriş)
**Mood:** `room` → `ship`
**Eğitim Hedefi:** Oyuncunun hikayeye duygusal bağ kurması

---

### BÖLÜM 1: Samsun — Milli Mücadele Başlıyor (İndeks 3-6)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 3 | `story` | Anlatıcı | Samsun limanına varış, işgal altındaki şehir |
| 4 | `story` | Subay | Karşılama, görevin önemi |
| 5 | `decision` | Öğrenci Asker | Plansız çıkış vs gözlem + güvenilir bağlantı |
| 6 | `decision` | {hero} | Kahvehanede güvenilir kişilerle özel konuşma vs herkese açık seslenme |

**Tarihsel Arkaplan:** 19 Mayıs 1919 — Mustafa Kemal Paşa, 9. Ordu Müfettişi olarak Samsun'a çıktı.
**Mood:** `arrival` → `ship` → `city`
**Eğitim Hedefi:** Örgütlü hareketin önemi, güvenilir bağlantılar kurma

---

### BÖLÜM 2: Havza — Milli Bilinç Uyanıyor (İndeks 7-9)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 7 | `story` | Anlatıcı | Havza yolculuğu, halkın endişesi |
| 8 | `decision` | {hero} | Örgütlü protesto vs tek başına hareket |
| 9 | `decision` | Telgrafçı | Açık telgraf vs güvenilir ulak/şifreli mesaj |

**Tarihsel Arkaplan:** 28 Mayıs 1919 — Havza Genelgesi yayınlandı. İşgallere karşı milli bilinç uyandırma çağrısı.
**Mood:** `road` → `city`
**Eğitim Hedefi:** Toplumsal örgütlenme, haberleşme güvenliği

---

### BÖLÜM 3: Amasya — Bağımsızlık Kararı (İndeks 10-13)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 10 | `story` | Anlatıcı | Amasya'ya varış, Yeşilırmak, tarihi atmosfer |
| 11 | `decision` | Anlatıcı | Milletin azmi vs dışarıdan bekleme |
| 12 | `story` | {hero} | Amasya kararları: vatan bütünlüğü, İstanbul Hükümeti, milli irade |
| 13 | `decision` | Temsilci Adayı | Seçilmiş temsilciler vs sadece askerler |

**Tarihsel Arkaplan:** 22 Haziran 1919 — Amasya Genelgesi yayınlandı. "Milletin bağımsızlığını yine milletin azim ve kararı kurtaracaktır."
**Mood:** `city`
**Eğitim Hedefi:** Milli irade kavramı, temsili demokrasi

---

### BÖLÜM 4: Erzurum Kongresi (İndeks 14-16)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 14 | `story` | Anlatıcı | Erzurum Kongresi toplanıyor, delegeler |
| 15 | `decision` | Temsilci | Manda ve himaye vs tam bağımsızlık |
| 16 | `story` | Anlatıcı | Temsil Heyeti kuruluyor, Mustafa Kemal başkan |

**Tarihsel Arkaplan:** 23 Temmuz - 7 Ağustos 1919 — Erzurum Kongresi. Manda ve himaye reddedildi. Temsil Heyeti kuruldu.
**Mood:** `hall`
**Eğitim Hedefi:** Tam bağımsızlık ilkesi, milli egemenlik

---

### BÖLÜM 5: Sivas Kongresi (İndeks 17-19)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 17 | `story` | Anlatıcı | Sivas'ta tüm vatanın temsil edildiği kongre |
| 18 | `decision` | Temsilci | Ayrı cemiyetler vs Anadolu ve Rumeli Müdafaa-i Hukuk çatısı |
| 19 | `story` | {hero} | Kongre sonu, bayrak, yeni umut |

**Tarihsel Arkaplan:** 4-11 Eylül 1919 — Sivas Kongresi. Tüm milli cemiyetler tek çatı altında birleşti.
**Mood:** `hall`
**Eğitim Hedefi:** Birlikten kuvvet doğar, ulusal birlik

---

### BÖLÜM 6: Ankara — Meclis ve İrade (İndeks 20-23)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 20 | `story` | Anlatıcı | Ankara yolculuğu, Anadolu bozkırı |
| 21 | `decision` | {hero} | Ankara merkez seçimi vs rastgele şehir |
| 22 | `story` | Anlatıcı | 23 Nisan 1920 — Büyük Millet Meclisi açılışı |
| 23 | `decision` | Meclis Vekili | Meclis'te ortak karar vs herkes başına buyruk |

**Tarihsel Arkaplan:** 27 Aralık 1919 — Temsil Heyeti Ankara'ya geldi. 23 Nisan 1920 — Büyük Millet Meclisi açıldı.
**Mood:** `road` → `hall`
**Eğitim Hedefi:** Egemenlik kayıtsız şartsız milletindir, meclis kültürü

---

### BÖLÜM 7: Sakarya & Büyük Taarruz (İndeks 24-27)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 24 | `story` | Anlatıcı | Sakarya öncesi, "Hatt-ı müdafaa yoktur" |
| 25 | `decision` | Subay | Topyekün savunma vs teslimiyet |
| 26 | `story` | Anlatıcı | Büyük Taarruz, Dumlupınar, İzmir |
| 27 | `decision` | {hero} | Barış ve cumhuriyet vs eski düzen |

**Tarihsel Arkaplan:** 23 Ağustos - 13 Eylül 1921 — Sakarya Meydan Muharebesi. 26 Ağustos - 9 Eylül 1922 — Büyük Taarruz.
**Mood:** `war` → `arrival`
**Eğitim Hedefi:** Vatan savunması, kararlılık, zafer sonrası barış

---

### FİNAL: Cumhuriyet & Uyanış (İndeks 28-30)

| # | Tür | Konuşmacı | Konu |
|---|-----|-----------|------|
| 28 | `story` | Anlatıcı | 29 Ekim 1923 — Cumhuriyet ilanı |
| 29 | `decision` | {hero} | Gelecek vizyonu: öğrendiklerini uygulama |
| 30 | `story` | Anlatıcı | Uyanış, sınav sabahı, kitap ve gülümseme |

**Tarihsel Arkaplan:** 29 Ekim 1923 — Cumhuriyet ilan edildi. Mustafa Kemal Atatürk ilk Cumhurbaşkanı.
**Mood:** `hall` → `room`
**Eğitim Hedefi:** Cumhuriyet bilinci, tarihsel empati, gelecek sorumluluğu

---

## 4. Event Data Model Referansı

### 4.1 `kind: "story"` Alanları

| Alan | Tip | Zorunlu | Açıklama |
|------|-----|---------|----------|
| `kind` | `String` | Evet | `"story"` |
| `chapter` | `String` | Evet | Bölüm adı (header'da gösterilir) |
| `unit` | `String` | Evet | Ünite/alt başlık |
| `location` | `String` | Evet | Mekan adı |
| `mood` | `String` | Evet | Atmosfer anahtarı (`room`, `ship`, `arrival`, `city`, `road`, `hall`, `war`) |
| `speaker` | `String` | Evet | Konuşmacı adı (`{hero}` placeholder kullanılabilir) |
| `story` | `String` | Evet | Diyalog metni (1-3 cümle, 7-8 yaş seviyesi) |
| `info` | `String` | Evet | Bilgi kartı metni (tarihsel bağlam) |

### 4.2 `kind: "decision"` Alanları

| Alan | Tip | Zorunlu | Açıklama |
|------|-----|---------|----------|
| `kind` | `String` | Evet | `"decision"` |
| `chapter` | `String` | Evet | Bölüm adı |
| `unit` | `String` | Evet | Ünite |
| `location` | `String` | Evet | Mekan |
| `mood` | `String` | Evet | Atmosfer |
| `speaker` | `String` | Evet | Konuşmacı (`{hero}` kullanılabilir) |
| `story` | `String` | Evet | Karar öncesi durum açıklaması |
| `option_a` | `String` | Evet | A seçeneği (7-8 yaş için net) |
| `option_b` | `String` | Evet | B seçeneği |
| `correct` | `String` | Evet | `"a"` veya `"b"` |
| `retry` | `String` | Evet | Yanlış seçim sonrası öğretici geribildirim |
| `info` | `String` | Evet | Doğru cevap sonrası bilgi kartı |

---

## 5. Tarihsel Doğruluk Notları

### 5.1 Doğruluk Seviyesi

Tüm olaylar, aşağıdaki kaynaklara dayanarak 7-8 yaş seviyesine uygun şekilde sadeleştirilmiştir:

- Türkiye Cumhuriyeti Milli Eğitim Bakanlığı — İlkokul Sosyal Bilgiler müfredatı
- Türk Tarih Kurumu kaynakları
- Atatürk Araştırma Merkezi yayınları

### 5.2 Sadeleştirme Kuralları

| Kural | Açıklama |
|-------|----------|
| **Karmaşık siyaset yok** | İstanbul Hükümeti ile ilişkiler, saltanat tartışmaları gibi konular doğrudan girilmez; sadece "hükümet görevini yapamıyor" seviyesinde kalır |
| **Yaş uygun dil** | "Manda", "himaye", "tam bağımsızlık" gibi kavramlar basitçe açıklanır |
| **Şiddet içermez** | Savaş sahneleri fiziksel şiddet içermez; strateji, kararlılık ve millet olma bilinci vurgulanır |
| **Atatürk doğrudan görünmez** | Oyuncu Atatürk'ün yerine geçmez. Kararlar, oyuncunun kendi tarihsel anlayışıyla verilir. Atatürk ileride rehber karakter olarak eklenebilir. |
| **Kronoloji korunur** | Tarihler ve sıralama gerçek tarihle birebir uyumludur |
| **Sebep-sonuç net** | Her kararın tarihsel sonucu, bilgi kartında açıkça belirtilir |

### 5.3 Kritik Tarihsel Kavramlar

| Kavram | Oyun İçi Kullanım |
|--------|-------------------|
| **Milli Mücadele** | Vatanı kurtarma yolculuğu |
| **Tam Bağımsızlık** | Kendi kendine karar verebilme, kimseye bağımlı olmama |
| **Manda/Himaye** | Bir devletin koruması altına girme (kabul edilemez) |
| **Milli İrade** | Milletin kendi kararlarını kendisinin vermesi |
| **Temsil Heyeti** | Millet adına karar veren kurul |
| **Egemenlik** | Yönetme yetkisi |

---

## 6. Eğitim Hedefleri (Müfredat Eşlemesi)

### 6.1 İlkokul Sosyal Bilgiler Kazanımları

| Bölüm | Kazanım |
|-------|---------|
| Giriş | Tarihsel olaylara ilgi duyma |
| Samsun | Milli Mücadele'nin başlangıcını kavrama |
| Havza | Örgütlü toplumsal hareketin önemini anlama |
| Amasya | Bağımsızlık kavramını anlama |
| Erzurum | Tam bağımsızlık ilkesini kavrama |
| Sivas | Birlik ve beraberliğin önemini anlama |
| Ankara | Egemenlik kavramını, Meclis'in önemini kavrama |
| Sakarya/Zafer | Vatan savunmasının önemini anlama |
| Cumhuriyet | Cumhuriyet yönetiminin anlamını kavrama |

### 6.2 Değerler Eğitimi

| Değer | Bölüm |
|-------|-------|
| Cesaret | Samsun, Sakarya |
| Bilgelik/Öngörü | Havza, Amasya |
| Adalet | Erzurum |
| Birlik | Sivas |
| Sorumluluk | Ankara |
| Azim | Sakarya |
| Özgürlük | Final |

---

## 7. Yazım Kılavuzu

### 7.1 Dil ve Üslup

- **Dil:** Türkiye Türkçesi, sade ve anlaşılır
- **Cümle Uzunluğu:** Maksimum 15-20 kelime
- **Hedef Yaş:** 7-8 (5-6 desteği: simge/ses sonra gelecek)
- **Ton:** Sıcak, cesaretlendirici, asla korkutucu değil
- **{hero} Kullanımı:** Tüm metinlerde oyuncu adı dinamik yerleşir

### 7.2 Kaçınılması Gerekenler

- Fiziksel şiddet tasviri
- Karmaşık siyasi analiz
- Korkutucu veya travmatik imgeler
- Pasif/umutsuz dil
- 15 kelimeyi aşan cümleler
- Soyut kavramlar (açıklanmadan kullanıldığında)

### 7.3 Kullanılması Gerekenler

- Aktif fiiller: "karar verir", "görür", "düşünür"
- Duygusal bağ kuran ifadeler: "hisseder", "merak eder", "gülümser"
- Somut göndermeler: "Samsun", "Bandırma Vapuru", "Meclis"
- Cesaretlendirici geribildirim: "Doğru! Peki neden?"

---

## 8. Gelecek Genişletmeler

| Potansiyel İçerik | Açıklama |
|-------------------|----------|
| **Atatürk Rehber Karakter** | Yanlış karar sonrası yol gösteren bilge figür |
| **Seslendirme** | Tüm diyaloglar profesyonel seslendirme |
| **İkincil Kararlar** | Her bölüme ek karar mekanikleri |
| **Müfredat Modülleri** | Öğretmenler için ders planı entegrasyonu |
| **Çoklu Dil** | İngilizce, Almanya Türkçesi desteği |

---

## 9. Referanslar

- [`assets/data/questions.gd`](assets/data/questions.gd) — Event veritabanı
- [`docs/DESIGN_DECISIONS.md`](docs/DESIGN_DECISIONS.md) — Tasarım kararları
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — Ürün yol haritası
- [`docs/VISUAL_DESIGN_SYSTEM.md`](docs/VISUAL_DESIGN_SYSTEM.md) — Görsel tasarım sistemi
- [`scripts/colors.gd`](scripts/colors.gd) — Renk sistemi
