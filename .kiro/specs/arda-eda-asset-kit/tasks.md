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

---

## Sonraki Faz: UI Geliştirme Planı

Bu faz, mevcut asset ve flow düzeltmelerinin üstüne oyun içi UI'ı daha tutarlı, daha okunabilir ve mobil hedefe daha uygun hale getirmeyi amaçlar. Öncelik sırası: önce overlay mimarisi ve touch güvenliği, sonra HUD/geri bildirim, en son görsel sistem ve polish.

### Faz 1 — Overlay Mimarisi ve Katman Temizliği

- [x] 10. Overlay katmanlarını tek standartta topla
  - [x] 10.1 `DialogueOverlay`, `DecisionOverlay`, `InfoCardOverlay`, `ChapterTransitionOverlay`, `HudBar` için tek layer hiyerarşisi tanımla
  - [x] 10.2 `CanvasLayer/HUD` ve overlay node yerleşimini tutarlı hale getir
  - [x] 10.3 `scripts/world_ui.gd` içindeki overlay aç/kapat akışını `OverlayManager` merkezli sadeleştir
  - [x] 10.4 `current_overlay_kind` string dispatch yüzeyini azalt veya kaldır

### Faz 2 — Touch ve Mobil Okunabilirlik

- [x] 11. Kritik buton hedeflerini mobil boyuta çek
  - [x] 11.1 `InteractButton` için minimum hit area değerini büyüt
  - [x] 11.2 `DialogueContinue` için tek elle rahat kullanılabilir buton alanı tasarla
  - [x] 11.3 `DecisionOverlay` seçenek yüksekliklerini 9:16 portrait kullanımına göre normalize et
  - [x] 11.4 `InfoCardOverlay` için görünür bir kapat/geri aksiyonu ekle

- [x] 12. Responsive güvenli alan düzenlemesi yap
  - [x] 12.1 Ana menü, HUD ve overlay spacing değerlerini ortak safe-area sabitlerine bağla
  - [x] 12.2 Küçük ekranlarda taşan başlık ve chip alanlarını dengele
  - [x] 12.3 World HUD içinde alt ve üst bölgelerde sabit margin sistemi kur

### Faz 3 — HUD ve Geri Bildirim Sistemi

- [x] 13. HUD'u bağlam duyarlı hale getir
  - [x] 13.1 Hedef/progress değiştiğinde kısa geri bildirim animasyonu ekle
  - [x] 13.2 Kaynak toplama ve doğru karar anlarında HUD micro-feedback göster
  - [x] 13.3 Bölgeye göre HUD vurgu renklerini `colors.gd` ve `world_ui.gd` üzerinden standartlaştır

- [x] 14. Loading ve geçiş yüzeylerini güçlendir
  - [x] 14.1 Bölüm geçişlerinde kısa loading durumu veya progress hissi ekle
  - [x] 14.2 Transition sırasında tıklanabilir alan kilidini merkezi hale getir
  - [x] 14.3 Zincirlenen overlay geçişlerinde skip/fast-forward davranışını belirle

### Faz 4 — Görsel Sistem ve Kod Sağlığı

- [ ] 15. Tekrarlayan UI stillerini ortak tema sistemine taşı
  - [x] 15.1 `main_menu.gd` ve `world.gd/world_ui.gd` içindeki tekrarlı `StyleBoxFlat` kurulumlarını envanterle
  - [x] 15.2 Ortak button/panel/chip stilleri için tema helper veya `Theme.tres` tabanı oluştur
  - [x] 15.3 Font boyutu, radius, padding ve renk sabitlerini ortak isimlendirmeyle topla
    - [x] 15.3.1 `ui_tokens.gd` ile ortak font/radius/spacing/touch token setini oluştur
    - [x] 15.3.2 Tokenları `main_menu.gd`, `hud_bar.gd`, `decision_overlay.gd`, `info_card_overlay.gd` ve `world_ui.gd` içine yay
    - [x] 15.3.3 Kalan overlay/world yüzeylerinde sabit boyut ve spacing sayılarını token sistemine tamamla

- [ ] 16. UI kodunu daha küçük modüllere ayır
  - [x] 16.1 `world.gd` içindeki kalan UI sorumluluklarını `world_ui.gd` içine tamamla
  - [x] 16.2 Overlay scene script'lerinde ortak davranışları helper katmana taşı
  - [x] 16.3 UI için tek giriş noktası ve tek görünürlük sözleşmesi tanımla

### Faz 5 — Doğrulama ve Kabul Kriterleri

- [ ] 17. UI doğrulama checklist'i oluştur ve uygula
  - [x] 17.1 Ana menü, diyalog, karar, bilgi kartı ve chapter transition için ekran görüntüsü checklist'i çıkar
  - [x] 17.2 1080x1920 portrait üzerinde hit area, crop ve overlap kontrolü yap
  - [x] 17.3 Geri tuşu, overlay stack ve save/continue akışını UI regressions açısından tekrar doğrula
  - [x] 17.4 Gerekirse `tools/capture_character_ui.gd` ve ilgili capture script'lerini UI regression yüzeyi olarak genişlet