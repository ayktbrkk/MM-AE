# Execution Packages Plan

Bu belge, world art upgrade ve Android release polish backlog'unu önerilen sıraya göre tek bir yürütme planına çevirir.

Amaç:
- Tüm paketleri uygulanabilir sıraya koymak
- Her paket için giriş koşulu, çıktı, doğrulama ve teslim tanımı vermek
- Uygulamaya başlamadan önce net bir onay kapısı bırakmak

Kapsam:
- World Art Upgrade kartları
- Android Release Polish kartları
- Dokümantasyon, audit, teknik uygulama ve kabul paketleri

Kural:
- Paketler aşağıdaki sırayla yürütülür.
- Bir paket tamamlanmadan bağımlı sonraki pakete geçilmez.
- Kod veya asset değiştiren her paket sonunda ilgili dar doğrulama yapılır.
- Bu plan onaysız otomatik icra edilmez.

## Yürütme Özeti

| Paket | Alan | Kaynak kart | Tip | Öncelik | Efor | Bağımlılık |
|------|------|-------------|-----|---------|------|------------|
| P1 | World Art | Issue 10A / Kart A | Audit + plan | P0 | S | Yok |
| P2 | World Art | Issue 10B / Kart B | Standardizasyon | P0 | S-M | P1 |
| P3 | World Art | Kart C | Pilot uygulama | P1 | M-L | P1, P2 |
| P4 | World Art | Kart E | Kalibrasyon | P1 | S-M | P3 |
| P5 | World Art | Kart D | Yaygınlaştırma | P1 | M | P3, P4 |
| P6 | World Art | Kart F | Kabul + regression | P2 | S | P3, P4, P5 |
| P7 | Android | Issue 11A / Kart A | Audit + config plan | P0 | S | Yok |
| P8 | Android | Issue 11B / Kart B | Smoke checklist | P0 | S | P7 |
| P9 | Android | Kart C | UI/system bar polish | P1 | M | P7, P8 |
| P10 | Android | Kart D | Lifecycle sertleştirme | P1 | M | P8 |
| P11 | Android | Kart E | Performans gözlemi | P1 | S-M | P8, P10 |
| P12 | Android | Kart F | Release candidate | P2 | S | P7, P8, P9, P10, P11 |

## Takip Panosu

| Paket | Durum | Son durum | Sonraki adım |
|------|-------|-----------|--------------|
| P1 | tamamlandi | World art audit ilk turu dolduruldu, pilot zone secildi | P2 onayi bekleniyor |
| P2 | tamamlandi | Teknik art sozlesmesi, token sahipligi ve pipeline akisi yazildi | P3 onayi bekleniyor |
| P3 | tamamlandi | Bandirma destek-prop temizlik ve kompozisyon sakinlestirme turu kapatildi, temiz capture sabitlendi | P4 kontrast kalibrasyonu |
| P4 | tamamlandi | Bandirma HUD, guidance/marker, kisa kopya, capture contract ve location sign de-stack kalibrasyonu `bandirma_world_p4_hud.png` ile tekrar uretilebilir sekilde dogrulandi | P5 rollout onayi |
| P5 | tamamlandi | Samsun benchmark kontrati eklendi; Ankara'da yan HUD footprint'i bastirildi, Sakarya'da support kartlari iceri cekildi ve Final'de hem support hem clue anchor'lari iceri alinip rollout capture'lari okunur ara ritme tasindi | P6 kabul kapisi |
| P6 | tamamlandi | `verify_samsun_benchmark_contract`, `verify_p5_late_zone_benchmark_contract`, `verify_capture_world_render_contract` ve parse check ayni acceptance turunda yesile dondu | Sonraki world-art dalgasi veya commit/push |
| P7 | tamamlandi | Android export audit tablosu ve eksik config listesi yazildi | P8 checklist uygulamasina giris |
| P8 | tamamlandi | Android smoke checklist dosyasi ve akış matrisi yazildi | P9 safe-area/system bar uygulamasina giris |
| P9 | tamamlandi | 1080x1920 accepted baseline'lar yenilendi ve UI regression suite tekrar yesile dondu | P10 lifecycle veya P11 cihaz gozlemi |
| P10 | devam ediyor | World autosave + transient overlay cleanup + audio pause/resume kontratina ek olarak dream-intro pause iptali, loading overlay request cancellation/drain ve menu `ui_cancel` ile in-flight transition iptali verifier ile kapsandi; checklist'te A12/A16 cihaz kesitleri Android 12/16 matrisiyle ve kisa kosu sirasi ile somutlasti | Cihaz/emulator ustunde kisa kosu sirasini aynen kosup notlamak |
| P11 | bekliyor | Cihaz gozlemi paketi | P8 ve P10 sonrasi |
| P12 | bekliyor | Release candidate paketi | P7-P11 sonrasi |

## Guncel Onay Kapisi

- Tamamlanan ilk paket: `P1`
- Tamamlanan ikinci paket: `P2`
- Aktif world art paketi: acceptance turu kapandi
- Tamamlanan Android audit paketi: `P7`
- Tamamlanan Android checklist paketi: `P8`
- Aktif Android lifecycle paketi: `P10`
- Tamamlanan Android polish paketi: `P9`
- Beklenen kullanici komutu: `P5 devam et`, `P10 devam et`, `P11 devam et` veya `commit hazirla`

## Paket Ayrıntıları

### P1 - World Art Audit ve Hedef Kalite Panosu

Amaç:
- Kritik 5 zone için mevcut kaliteyi ve hedef görünümü netleştirmek.

Giriş koşulu:
- Mevcut capture ve referans görseller erişilebilir olmalı.
- [docs/WORLD_ART_UPGRADE_PLAN.md](c:/Users/Aykut/Documents/Godot/mmae/docs/WORLD_ART_UPGRADE_PLAN.md) boş şablon olarak hazır olmalı.

Uygulama adımları:
1. Bandirma, Samsun, Ankara, Sakarya ve Final için mevcut capture kaynaklarını topla.
2. Zone audit tablosunu ilk tur doldur.
3. Her zone için `kalacak`, `değişecek`, `yeniden kompoze edilecek` katmanları ayır.
4. Pilot zone önerisini gerekçeyle yaz.
5. `Issue 10B` için aktarım notlarını tamamla.

Çıktılar:
- Dolu world art audit dosyası
- Pilot zone kararı
- Öncelikli replacement listesi

Dosyalar:
- [docs/WORLD_ART_UPGRADE_PLAN.md](c:/Users/Aykut/Documents/Godot/mmae/docs/WORLD_ART_UPGRADE_PLAN.md)
- [docs/ART_WORLD_ROADMAP.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ART_WORLD_ROADMAP.md)
- [docs/ART_ANALYSIS.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ART_ANALYSIS.md)

Doğrulama:
- Audit tablosunda kritik 5 zone boş kalmamalı.
- Pilot zone gerekçesi yazılmış olmalı.

Tamamlanma ölçütü:
- P2 ve P3'ün hangi kararlarla başlayacağı belgeden okunabiliyor olmalı.

### P2 - Asset Pipeline Standardizasyonu

Amaç:
- Yeni art üretimi ve entegrasyonu için tekrar kullanılabilir teknik kuralları sabitlemek.

Giriş koşulu:
- P1 tamamlanmış olmalı.
- Pilot zone ve ana görsel riskler netleşmiş olmalı.

Uygulama adımları:
1. SVG import, ölçek, outline ve opaklık kararlarını dokümante et.
2. Renk ve kontrast kararlarını token seviyesinde eşleştir.
3. UI/karakter/world kontrast çakışmalarını not et.
4. Gerekirse yeni bir kısa teknik art standardı bölümü ekle.

Çıktılar:
- Asset entegrasyon standardı
- Renk/kontrast karar listesi
- Yeni asset pipeline akışı

Dosyalar:
- [docs/GODOT_OFFICIAL_DEMO_ADAPTATION.md](c:/Users/Aykut/Documents/Godot/mmae/docs/GODOT_OFFICIAL_DEMO_ADAPTATION.md)
- [docs/WORLD_ART_UPGRADE_PLAN.md](c:/Users/Aykut/Documents/Godot/mmae/docs/WORLD_ART_UPGRADE_PLAN.md)
- [docs/VISUAL_DESIGN_SYSTEM.md](c:/Users/Aykut/Documents/Godot/mmae/docs/VISUAL_DESIGN_SYSTEM.md)
- [scripts/colors.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/colors.gd)
- [scripts/ui_tokens.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/ui_tokens.gd)

Doğrulama:
- Teknik kurallar tek bir akışta okunabilir olmalı.
- Outline, renk ve oran kararlarının sahip dosyaları belirtilmiş olmalı.

Tamamlanma ölçütü:
- P3 pilot uygulaması yeni belirsizlik üretmeden başlayabilmeli.

### P3 - Pilot Zone Replacement

Amaç:
- Tek bir zone üzerinde gerçek production-pass art değişimini uygulamak.

Giriş koşulu:
- P1 ve P2 tamamlanmış olmalı.
- Pilot zone seçilmiş olmalı.

Uygulama adımları:
1. Pilot zone asset replacement listesini kesinleştir.
2. Gerekli assetleri üret veya entegre et.
3. Builder kompozisyonunu yeni oranlara göre güncelle.
4. Capture al ve önce/sonra karşılaştır.

Çıktılar:
- Güncellenmiş pilot zone
- Önce/sonra capture seti
- İlk uygulama notları

Dosyalar:
- [scripts/world_builder.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/world_builder.gd)
- [assets/art/](c:/Users/Aykut/Documents/Godot/mmae/assets/art/)
- [artifacts/renders/](c:/Users/Aykut/Documents/Godot/mmae/artifacts/renders/)

Doğrulama:
- Godot `--headless --check-only --path . --quit`
- Gerekli UI visual regression veya hedef capture

Tamamlanma ölçütü:
- Pilot zone oyunda ve capture'larda kabul edilebilir yeni kalite seviyesinde görünmeli.

### P4 - Kontrast ve Okunurluk Kalibrasyonu

Amaç:
- Yeni art pass sonrası karakter, companion ve UI okunurluğunu korumak.

Giriş koşulu:
- P3 tamamlanmış olmalı.

Uygulama adımları:
1. Yeni arka planlar üzerinde karakter kontrastını kontrol et.
2. Gerekirse `colors.gd` ve `ui_tokens.gd` değerlerini ayarla.
3. Overlay ve world HUD okunurluğunu capture ile tekrar gözden geçir.

Çıktılar:
- Güncellenmiş kontrast kararları
- Okunurluk notları

Dosyalar:
- [scripts/colors.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/colors.gd)
- [scripts/ui_tokens.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/ui_tokens.gd)

Doğrulama:
- İlgili UI capture yüzeyleri
- Dar parse kontrolü

Tamamlanma ölçütü:
- Karakter ve UI, yeni world art önünde kaybolmamalı.

### P5 - Builder Kompozisyon Uyarlama Dalgası

Amaç:
- Pilot zone derslerini diğer hedef zone'lara yaymak.

Giriş koşulu:
- P3 ve P4 tamamlanmış olmalı.

Uygulama adımları:
1. Kalan hedef zone'lar için kompozisyon güncellemelerini sırala.
2. Marker, prop cluster, path ve landmark yerleşimlerini güncelle.
3. Her zone sonrası dar capture al.

Çıktılar:
- Güncellenmiş çoklu zone kompozisyonu
- Zone bazlı rollout notları

Dosyalar:
- [scripts/world_builder.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/world_builder.gd)
- [scripts/world.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/world.gd)
- [scripts/world_ui.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/world_ui.gd)

Doğrulama:
- `--headless --check-only --path . --quit`
- Gerekli zone capture karşılaştırmaları

Tamamlanma ölçütü:
- Hedef zone'larda marker, player ve overlay akışı bozulmadan yeni kompozisyon çalışmalı.

### P6 - World Art Kabul ve Regression Paketi

Amaç:
- World art dalgasını kabul edilebilir ve tekrar doğrulanabilir hale getirmek.

Giriş koşulu:
- P3, P4 ve P5 tamamlanmış olmalı.

Uygulama adımları:
1. Önce/sonra capture setlerini finalize et.
2. UI visual regression'i yeniden çalıştır.
3. Kabul notlarını plan belgelerine işle.

Çıktılar:
- Kabul paketi
- Regression sonucu
- Final notlar

Dosyalar:
- [artifacts/renders/](c:/Users/Aykut/Documents/Godot/mmae/artifacts/renders/)
- [docs/UI_SCREENSHOT_CHECKLIST.md](c:/Users/Aykut/Documents/Godot/mmae/docs/UI_SCREENSHOT_CHECKLIST.md)

Doğrulama:
- Görsel regression sonucu
- Son parse kapısı

Tamamlanma ölçütü:
- World art upgrade dalgası için tekrar edilebilir kabul paketi oluşmuş olmalı.

### P7 - Export Config Audit

Amaç:
- Android release için teknik export çerçevesini netleştirmek.

Giriş koşulu:
- Yok.

Uygulama adımları:
1. `project.godot` ve `export_presets.cfg` içindeki Android ayarlarını audit et.
2. Debug/release farklarını yaz.
3. Eksik alanları backlog maddesine dönüştür.

Çıktılar:
- Export audit tablosu
- Eksik config listesi

Dosyalar:
- [project.godot](c:/Users/Aykut/Documents/Godot/mmae/project.godot)
- [export_presets.cfg](c:/Users/Aykut/Documents/Godot/mmae/export_presets.cfg)

Doğrulama:
- Audit çıktısı debug/release ayrımını açıkça göstermeli.

Tamamlanma ölçütü:
- P8 ve P9 için teknik belirsizlik kalmamalı.

### P8 - Mobil UX Smoke Checklist

Amaç:
- Android için tekrar edilebilir temel smoke testi oluşturmak.

Giriş koşulu:
- P7 tamamlanmış olmalı.

Uygulama adımları:
1. Start, continue, loading, exit confirm, save/load ve settings akışlarını listele.
2. Beklenen sonuç ve hata semptomu alanlarını tanımla.
3. Back button ve app lifecycle senaryolarını ekle.
4. Checklist'i kuru koşu mantığında gözden geçir.

Çıktılar:
- Android smoke checklist dosyası
- Temel mobil akış matrisi

Dosyalar:
- yeni [docs/ANDROID_RELEASE_CHECKLIST.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ANDROID_RELEASE_CHECKLIST.md)
- [docs/UI_SCREENSHOT_CHECKLIST.md](c:/Users/Aykut/Documents/Godot/mmae/docs/UI_SCREENSHOT_CHECKLIST.md)

Doğrulama:
- Checklist başka biri tarafından uygulanabilir okunmalı.

Tamamlanma ölçütü:
- Cihaz-üstü smoke testi tek belge üzerinden yürütülebilmeli.

### P9 - Safe-area ve System Bar Polish

Amaç:
- Android portrait cihazlarda üst/alt alan ve sistem çubuğu davranışını tutarlı hale getirmek.

Giriş koşulu:
- P7 ve P8 tamamlanmış olmalı.

Uygulama adımları:
1. Safe-area davranışını menu ve world tarafında test et.
2. Gerekirse system bar veya immersive davranışı düzelt.
3. Capture ile sonucu gözden geçir.

Çıktılar:
- Mobil UI polish değişiklikleri
- Safe-area/system bar notları

Dosyalar:
- [scripts/main_menu.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/main_menu.gd)
- [scripts/world_ui.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/world_ui.gd)

Doğrulama:
- `--headless --check-only --path . --quit`
- Gerekli mobil capture veya smoke gözlemi

Tamamlanma ölçütü:
- Portrait cihazlarda kritik safe-area sorunu kalmamalı.

### P10 - Navigation ve App Lifecycle Sertleştirme

Amaç:
- Back button, background/foreground dönüşü ve ilk ayar akışlarını sağlamlaştırmak.

Giriş koşulu:
- P8 tamamlanmış olmalı.

Uygulama adımları:
1. Back button akışını baştan sona smoke checklist ile eşleştir.
2. App background/foreground dönüşünde overlay ve ses davranışını kontrol et.
3. First-run settings ve continue akışlarını gözden geçir.

Çıktılar:
- Sertleştirilmiş navigation/lifecycle akışları
- Hata ve davranış notları

Dosyalar:
- [scripts/loading_overlay.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/loading_overlay.gd)
- [scripts/exit_confirm_overlay.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/exit_confirm_overlay.gd)
- [scripts/audio_manager.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/audio_manager.gd)
- [scripts/world_ui.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/world_ui.gd)

Doğrulama:
- `--headless --check-only --path . --quit`
- Cihaz/emulator smoke testi

Tamamlanma ölçütü:
- Lifecycle kaynaklı bloklayıcı navigation sorunu kalmamalı.

### P11 - Performans ve Cihaz Gözlemi

Amaç:
- Release öncesi düşük/orta seviye cihaz davranışını belgelemek.

Giriş koşulu:
- P8 ve P10 tamamlanmış olmalı.

Uygulama adımları:
1. Yükleme süresi ve input gecikmesi gözlemleri al.
2. Kritik overlay açılışlarında frame drop notlarını yaz.
3. Gerekirse küçük performans backlog'u çıkar.

Çıktılar:
- Cihaz gözlem raporu
- Performans risk listesi

Dosyalar:
- cihaz smoke notları
- gerekirse [scripts/loading_overlay.gd](c:/Users/Aykut/Documents/Godot/mmae/scripts/loading_overlay.gd)

Doğrulama:
- En az bir cihaz veya emulator gözlem kaydı

Tamamlanma ölçütü:
- Release öncesi cihaz riskleri yazılı hale gelmiş olmalı.

### P12 - Release Candidate Checklist ve APK Doğrulaması

Amaç:
- Android release polish dalgasını tekrar edilebilir teslim paketi haline getirmek.

Giriş koşulu:
- P7, P8, P9, P10 ve P11 tamamlanmış olmalı.

Uygulama adımları:
1. Release checklist'i finalize et.
2. Yeni APK üret.
3. Kur, aç, smoke testi uygula.
4. Son kabul notunu yaz.

Çıktılar:
- Release checklist
- Doğrulanmış APK sonucu
- Final kabul notu

Dosyalar:
- [export_presets.cfg](c:/Users/Aykut/Documents/Godot/mmae/export_presets.cfg)
- yeni [docs/ANDROID_RELEASE_CHECKLIST.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ANDROID_RELEASE_CHECKLIST.md)

Doğrulama:
- APK yeniden üretilebilmeli
- Smoke checklist tamamlanmış olmalı

Tamamlanma ölçütü:
- Android release polish için tekrar edilebilir teslim paketi oluşmalı.

## Uygulama Kapısı

Bu plan uygulanmaya hazırdır, ancak otomatik yürütmeye açık değildir.

Uygulamaya başlamak için onay formatı:
- `P1 ile başla`
- `P7 ile başla`
- veya `P1-P2 uygula`

Önerilen başlangıç:
- Önce P1 ve P2
- Ardından P7 ve P8
- Sonra ilk teknik uygulama dalgası olarak P3 veya P9
