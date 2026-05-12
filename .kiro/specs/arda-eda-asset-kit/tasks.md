# Uygulama Planı: Arda ve Eda Asset Kit

## Genel Bakış

Bu plan, Arda ve Eda için mevcut 8 karakter SVG dosyasını tek kalite seviyesinde yeniden üretir ve oyundaki mevcut preload sözleşmesini bozmadan doğrular. Hedef, önce asset setini güncellemek, sonra statik SVG doğrulamasını yapmak, ardından menü ve overlay yüzeylerinde görsel kontrolle işi kapatmaktır. Varsayılan yaklaşım asset-only'dir; kod değişikliği yalnız gerçekten gerekirse yapılır.

Uygulama dili: **SVG asset üretimi + GDScript 2.0 doğrulama yüzeyi**

---

## Görevler

- [x] 1. Arda World Sprite'ı yükselt
  - [x] 1.1 `char_arda_world.svg` dosyasını yeniden çiz veya düzenle
    - `viewBox="0 0 260 340"` korunmalı
    - Şeffaf arka plan, tam gövdeye yakın duruş
    - Arda Coral ve Arda Amber ailesi korunmalı
    - Küçük ölçekte okunabilir saç, omuz ve gövde silüeti sağlanmalı
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.1, 2.3, 4.1, 4.2, 4.3, 7.1, 7.5, 8.1, 9.2_

- [x] 2. Eda World Sprite'ı yükselt
  - [x] 2.1 `char_eda_world.svg` dosyasını yeniden çiz veya düzenle
    - `viewBox="0 0 260 340"` korunmalı
    - Şeffaf arka plan, tam gövdeye yakın duruş
    - Eda Teal ve Eda Mist ailesi korunmalı
    - Arda'dan ayrışan daha sakin/dengeli silüet sağlanmalı
    - _Gereksinimler: 1.1, 1.2, 1.3, 2.2, 2.3, 4.1, 4.2, 4.3, 7.1, 7.5, 8.1, 9.2_

- [x] 3. Arda Portrait Setini yükselt
  - [x] 3.1 `portrait_arda_idle.svg` dosyasını güncelle
    - `viewBox="0 0 520 520"` korunmalı
    - Gömülü karakter adı kaldırılmalı
    - Nötr ama dikkatli ifade korunmalı
    - Dialogue ve decision overlay crop alanına uygun kadraj sağlanmalı
    - _Gereksinimler: 1.1, 1.2, 3.1, 3.2, 3.3, 3.4, 3.5, 5.2, 5.3, 5.4, 7.1, 8.3, 9.1_

  - [x] 3.2 `portrait_arda_thinking.svg` dosyasını güncelle
    - `viewBox="0 0 520 520"` korunmalı
    - Kaş/göz/ağız farkı ile düşünme hali netleşmeli
    - Idle portre ile aynı kimlik ve kadraj dili korunmalı
    - _Gereksinimler: 1.1, 1.2, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 5.1, 5.3, 5.4, 8.3, 9.1_

  - [x] 3.3 `portrait_arda_happy.svg` dosyasını güncelle
    - `viewBox="0 0 520 520"` korunmalı
    - Umutlu/rahatlamış ifade net olmalı
    - Gömülü karakter adı kaldırılmalı
    - _Gereksinimler: 1.1, 1.2, 3.1, 3.2, 3.3, 3.5, 3.6, 5.1, 5.3, 5.4, 8.3, 9.1_

- [x] 4. Eda Portrait Setini yükselt
  - [x] 4.1 `portrait_eda_idle.svg` dosyasını güncelle
    - `viewBox="0 0 520 520"` korunmalı
    - Gömülü karakter adı kaldırılmalı
    - Sakin ve güven veren nötr ifade korunmalı
    - Decision overlay crop alanına uygun kadraj sağlanmalı
    - _Gereksinimler: 1.1, 1.2, 3.1, 3.2, 3.3, 3.4, 3.5, 5.2, 5.3, 5.4, 7.1, 8.3, 9.1_

  - [x] 4.2 `portrait_eda_thinking.svg` dosyasını güncelle
    - `viewBox="0 0 520 520"` korunmalı
    - Analitik/düşünen ifade netleşmeli
    - Idle portre ile aynı kimlik ve kadraj dili korunmalı
    - _Gereksinimler: 1.1, 1.2, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 5.1, 5.3, 5.4, 8.3, 9.1_

  - [x] 4.3 `portrait_eda_happy.svg` dosyasını güncelle
    - `viewBox="0 0 520 520"` korunmalı
    - Sıcak ama ölçülü memnuniyet ifadesi net olmalı
    - Gömülü karakter adı kaldırılmalı
    - _Gereksinimler: 1.1, 1.2, 3.1, 3.2, 3.3, 3.5, 3.6, 5.1, 5.3, 5.4, 8.3, 9.1_

- [x] 5. Teknik SVG temizliği ve standardizasyonu
  - [x] 5.1 Tüm 8 SVG dosyasında `xmlns` bildirimi doğrula
  - [x] 5.2 Tüm portrait dosyalarından `<text>` öğelerini kaldır
  - [x] 5.3 `style`, `<defs>`, `<image>`, `<use>`, `<symbol>`, harici referans bulunmadığını doğrula
  - [x] 5.4 World sprite'larda ortak ayak tabanı; portrait'larda ortak güvenli kadraj uygula
  - [x] 5.5 Dosya boyutlarını budget içinde tut
  - _Gereksinimler: 1.4, 4.4, 5.3, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5, 9.1, 9.2, 9.3_

- [x] 6. Statik doğrulama checkpoint'i
  - 8 dosyanın tamamı beklenen klasör ve adlarla mevcut olmalı
  - Portrait dosyalarında `<text>` bulunmamalı
  - World sprite dosyaları `60 KB` altında olmalı
  - Portrait dosyaları `80 KB` altında olmalı
  - Gerekirse kullanıcıya ara onay göster

- [x] 7. Runtime görsel doğrulama
  - [x] 7.1 Ana menüde Arda ve Eda world sprite'larını kontrol et
    - Yan yana ayırt edilebilirlik doğrulanmalı
    - _Gereksinimler: 2.3, 4.3, 6.2_

  - [x] 7.2 Karakter seçimi / kimlik kartı görünümünü kontrol et
    - Baseline kayması veya crop olmamalı
    - _Gereksinimler: 4.4, 6.1, 6.2, 6.3_

  - [x] 7.3 Decision overlay içinde idle portrait'ları kontrol et
    - Çene ve saç üstü kesilmemeli
    - _Gereksinimler: 5.2, 5.3, 5.4_

  - [x] 7.4 Dialogue overlay içinde `idle`, `thinking`, `happy` geçişlerini kontrol et
    - Expression farkları net, karakter kimliği tutarlı olmalı
    - _Gereksinimler: 3.1, 3.2, 3.3, 3.6, 5.1_

- [x]* 8. Gerekirse minimal entegrasyon düzeltmesi yap
  - Yalnız runtime doğrulama kırılırsa yapılır
  - Öncelik sırası:
    - asset kadrajını düzelt
    - asset scale/baseline'ı düzelt
    - en son küçük UI veya stretch ayarı yap
  - Olası dosyalar: `scripts/dialogue_overlay.gd`, `scripts/decision_overlay.gd`, `scripts/main_menu.gd`, `scripts/world_player.gd`
  - _Gereksinimler: 5.4, 6.1, 10.1, 10.2, 10.3, 10.4_

- [x] 9. Final checkpoint
  - 8 asset dosyası güncel olmalı
  - Mevcut preload yolları değişmemiş olmalı
  - Portrait dosyalarında `<text>` kalmamalı
  - Menü, decision overlay ve dialogue overlay doğrulaması tamamlanmış olmalı
  - Kullanıcı onayına hazır çıktı seti sunulmalı

---

## Notlar

- Bu kit, önceki bölge asset kitlerinden farklı olarak büyük ölçüde asset odaklıdır; `textures.gd` ve runtime dosyalarında varsayılan olarak değişiklik beklenmez.
- Şu anki portrait dosyalarında isim yazısı bulunduğu için ilk teknik kazanç, bu etiketlerin kaldırılmasıdır.
- World sprite ve portrait canvas boyutları korunmalıdır; entegrasyon güvenliği bu karara dayanır.
- `*` ile işaretli görev opsiyoneldir; yalnız doğrulama başarısız olursa açılır.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1", "3.1", "3.2", "3.3", "4.1", "4.2", "4.3"] },
    { "id": 1, "tasks": ["5.1", "5.2", "5.3", "5.4", "5.5", "6"] },
    { "id": 2, "tasks": ["7.1", "7.2", "7.3", "7.4"] },
    { "id": 3, "tasks": ["8"] },
    { "id": 4, "tasks": ["9"] }
  ]
}
```