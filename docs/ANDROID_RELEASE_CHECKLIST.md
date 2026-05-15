# Android Release Checklist

Bu belge `P8 - Mobil UX Smoke Checklist` cikisidir. Amac, Android debug APK veya emulator uzerinde tekrar edilebilir temel smoke test akisini tek yerde toplamaktir.

## Kullanim

- Hedef build: `builds/BandirmaYolculugu_debug.apk`
- Hedef cihaz: Android telefon veya portrait emulator
- Bagli audit: `docs/ANDROID_EXPORT_AUDIT.md`
- Bagli UI capture checklist'i: `docs/UI_SCREENSHOT_CHECKLIST.md`

## Test Oturumu Baslangic Bilgisi

| Alan | Doldur |
|------|--------|
| Tarih | |
| Cihaz / Emulator | |
| Android surumu | |
| Build tipi | Debug APK |
| APK yolu | `builds/BandirmaYolculugu_debug.apk` |
| Test eden | |

## Gecis Kurali

- `Gecti`: Beklenen sonuc tam elde edildi.
- `Kismi`: Akis tamamlandi ama gozlenebilir pürüz var.
- `Kaldi`: Akis bloklandi veya sonuc yanlis.

## Hata Semptomu Kisaltmalari

- `layout`: Tasma, kirpilma, safe-area hatasi
- `flow`: Yanlis ekran, donen akis, kilitlenme
- `input`: Tus, dokunma veya focus problemi
- `audio`: Ses calmiyor, slider etkisiz, ses geri gelmiyor
- `save`: Continue/save/load davranisi beklenen gibi degil
- `perf`: Belirgin frame drop, gecikmeli loading, takilma

## Cekirdek Smoke Matrisi

| ID | Akis | Adim | Beklenen sonuc | Hata semptomu | Durum | Not |
|----|------|------|----------------|---------------|-------|-----|
| A1 | Kurulum ve acilis | APK'yi kur, uygulamayi ilk kez ac | Uygulama portrait acilir, ana menu gelir, cokus olmaz | flow | | |
| A2 | Ana menu layout | Ana menude baslik, butonlar ve karakterler gorunur | Butonlar safe-area icinde kalir, alt kenar kirpilmaz | layout | | |
| A3 | Settings overlay acilis | Ana menuden `Ayarlar` ac | Overlay ustune gelir, butonlar ve slider'lar secilebilir olur | flow,input | | |
| A4 | BGM slider | BGM slider'ini dusur, yukselt | Ses seviyesi degisir, uygulama donmaz | audio,input | | |
| A5 | SFX slider | SFX slider'ini dusur, yukselt, UI tiklamasi dene | SFX seviyesi hissedilir sekilde degisir | audio,input | | |
| A6 | Settings kapatma | Ayarlar acikken kapat dugmesi veya geri tusu kullan | Overlay kapanir, menu focus'u toparlanir | flow,input | | |
| A7 | Exit confirm | Ana menude geri tusuna bas | Cikis onay overlay'i acilir | flow,input | | |
| A8 | Exit confirm iptal | Exit confirm acikken `Vazgec`/iptal akisini dene | Menuye saglikli donulur | flow,input | | |
| A9 | Start new game | `Oyuna Basla` ile yeni oyun akisini baslat | Loading overlay gorunur, dunya acilir | flow,perf | | |
| A10 | Loading davranisi | Start veya continue sirasinda loading ekranini izle | Baslik/spinner gorunur, donup kalma olmaz | flow,perf | | |
| A11 | World basic input | Dunyada karakter hareketi ve temel interact dugmesini dene | Dokunma/yonlendirme calisir, UI bloklanmaz | input,flow | | |
| A12 | App background/foreground | Dunyadayken uygulamayi arka plana al, sonra geri don | Oyun doner, siyah ekran/cokus olmaz | flow,audio | | |
| A13 | Save olusturma | Yeni oyunda bir ilerleme noktasi olustur, uygulamayi kapat | Sonraki acilista `Devam Et` akisi icin save kalir | save | | |
| A14 | Continue button | Save varken uygulamayi yeniden ac | `Devam Et` aktif gorunur | save,flow | | |
| A15 | Continue flow | `Devam Et` ile oyuna gir | Loading sonrasi uygun noktaya donulur, akış bozulmaz | save,flow | | |
| A16 | Menu geri tusu davranisi | Farkli menu durumlarinda geri tusunu tekrarla | Ayarlar ve exit confirm oncelik sirasi dogru calisir | input,flow | | |

## Genisletilmis Kontrol Notlari

### Ana Menu ve Safe-Area

- Baslik, alt baslik ve buton grubu portrait yuzeyde merkezli kalmali.
- Alt bolgedeki butonlar gesture/navigation alanina saplanmamali.
- Sol/sag safe-area marjlari gozle simetrik gorunmeli.

### Ayarlar ve Ses

- `BGM` ve `SFX` slider'lari dokunmayla rahat hareket etmeli.
- Ayar degisikligi uygulama acik kaldigi surece hissedilir olmali.
- Mümkunse uygulamayi kapatip acinca ses ayarinin korunup korunmadigi ayri not olarak yazilmali.

### Loading ve Dunya Gecisi

- Loading overlay gorundugunde siyah ekran veya yarim yuklenmis UI gorunmemeli.
- Dunya acildiginda interact butonu ve HUD safe-area icinde kalmali.
- Gecis sonrasi overlay stack takili kalmamalı.

### Continue ve Save/Load

- Save yokken `Devam Et` pasif kalmali.
- Save varken `Devam Et` akisi yeni oyun baslatmamalı.
- Continue sonrasi karakter/zone yuklemesi tutarli olmali.

### Geri Tusu ve Lifecycle

- Ana menude geri tusu cikis onayina gitmeli.
- Ayarlar acikken geri tusu once ayarlari kapatmali.
- Uygulama arka plandan donunce ses, input ve loading davranisi bozulmamali.

## P10 Odakli Smoke Paketi

Bu bolum, `P10 - Lifecycle sertlestirme` kapanisina kalan cihaz/emulator teyidini tek oturumda kosmak icin daraltildi.

### Once Otomatik Kapilar

- `tools/verify_app_lifecycle_contract.gd` calistirilmis ve `APP_LIFECYCLE_CONTRACT_OK` vermis olmali.
- `tools/validate_game_flow.gd` son akista yesil olmali; bu script yeni oyun, continue, Bandirma loop ve gec oyun gecis zincirini ayri ayri tarar.
- Windows ortaminda bu iki kapı ve parse check tek komutta `tools/run_p10_smoke_gate.ps1` ile zincirlenebilir.
- Cihaz bagliyken tam oturum `tools/run_p10_device_smoke.ps1` ile baslatilabilir; script once otomatik kapilari kosar, sonra APK'yi yukleyip uygulamayi acar.
- Cihaz smoke oturumunda otomatik gate kirmiziysa once kod regresyonu temizlenmeli; cihaz notu bunun yerine gecmemeli.

### A12 Cihaz Kesitleri

| ID | Yuzey | Adim | Beklenen sonuc | Not |
|----|-------|------|----------------|-----|
| A12.1 | World aktif | Dunyada serbest hareketten sonra uygulamayi arka plana al, 3-5 sn sonra geri don | Oyun ayni zone'da geri gelir, siyah ekran veya takili overlay olmaz, ses toparlanir | `verify_app_lifecycle_contract.gd::_verify_world_pause_resume()` kod karsiligi |
| A12.2 | Dream intro aktif | Ana menude `Oyuna Basla` dedikten sonra dream-intro gorunurken home/app-switch yap ve geri don | Dream intro yarim kalmaz; menuye saglikli donulur veya gecis temizce iptal olmustur | `verify_app_lifecycle_contract.gd::_verify_main_menu_dream_intro_pause_resume()` kod karsiligi |
| A12.3 | Loading overlay aktif | `Oyuna Basla` veya `Devam Et` ile loading gorunurken arka plana al, geri don | Takili loading, leak semptomu, siyah ekran veya yarim yuklenmis dunya gorunmez | `verify_app_lifecycle_contract.gd::_verify_loading_overlay_cancellation()` kod karsiligi |

### A16 Cihaz Kesitleri

| ID | Yuzey | Adim | Beklenen sonuc | Not |
|----|-------|------|----------------|-----|
| A16.1 | Menu idle | Ana menude geri tusuna bas | Exit confirm acilir; `Vazgec` ile menu stabil kalir | Temel geri tusu onceligi |
| A16.2 | Settings aktif | Ayarlar acikken geri tusuna bas | Exit confirm yerine once settings kapanir | Overlay oncelik sirasi |
| A16.3 | Dream intro / loading aktif | Gecis aktifken geri tusuna bas | Exit dialog acilmaz; pending transition iptal olur ve menu input'u geri gelir | `verify_app_lifecycle_contract.gd::_verify_main_menu_cancel_during_transition()` kod karsiligi |
| A16.4 | Continue sonrasi menuye donus | Bir save ile `Devam Et` akisini test ettikten sonra menuye don ve geri tusunu tekrar dene | Save varligi bozulmadan normal menu geri davranisi surer | `validate_game_flow.gd::_validate_continue_flow()` ile birlikte dusunulmeli |

### Onerilen Cihaz Matrisi

- `A12.1` + `A16.1` + `A16.2`: Android 12 fiziksel cihaz veya esit gesture-nav profilinde emulator
- `A12.2` + `A12.3` + `A16.3`: Android 16 emulator veya yeni lifecycle/suspend davranisini agresif uygulayan cihaz
- `A15` + `A16.4`: Save/continue bulunan ayni test oturumu; mumkunse ikinci cihazda tekrar

### Otomatik Kapilar (Automated Gates Execution)

P10 smoke gate, 6 adimli otomatik dogrulama zincirini tek komutta calistirir:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1
```

| # | Gate | Script | Cikti |
|---|------|--------|-------|
| 1/6 | Parse Check | `--headless --check-only` | Exit code 0 |
| 2/6 | Game Flow Validation | `tools/validate_game_flow.gd` | `FLOW_VALIDATION_OK` |
| 3/6 | App Lifecycle Contract | `tools/verify_app_lifecycle_contract.gd` | `APP_LIFECYCLE_CONTRACT_OK` |
| 4/6 | Overlay Input Contract | `tools/verify_overlay_input_contract.gd` | Exit code 0 |
| 5/6 | UI Focus Accessibility | `tools/verify_ui_focus_accessibility.gd` | Exit code 0 |
| 6/6 | ADB Device Smoke | ADB detection | `DEVICE_AVAILABLE` / `DEVICE_SMOKE_SKIPPED_NO_ADB_OR_DEVICE` |

### Kisa Kosu Sirasi

- Otomatik on-kapi: `powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1`
- Cihaz-ustu oturum: `powershell -ExecutionPolicy Bypass -File tools/run_p10_device_smoke.ps1`
- Kosu sirasi: `run_p10_smoke_gate -> A12.1 -> A12.2 -> A12.3 -> A16.1 -> A16.2 -> A16.3 -> A15 -> A16.4 -> test sonu ozeti`

## P11 Performans ve Cihaz Gozlemi

Bu bolum, `P11 - Performans gozlemi` icin en az bir cihaz/emulator oturumunu tekrar edilebilir hale getirir.

### Gozlem Baslangici

- Cihaz bagliyken `powershell -ExecutionPolicy Bypass -File tools/run_p11_device_observation.ps1` komutu cihaz bilgisi ve rapor iskeleti olusturur.
- Rapor varsayilan olarak `artifacts/logs/p11_device_observation_<timestamp>.md` altina yazilir.
- Bu oturumda en az su yuzeyler notlanmali: acilis, settings, start/loading, world basic movement, continue/load ve gec zone overlay yogunlugu.

### Minimum P11 Ciktilari

- En az bir cihaz veya emulator icin doldurulmus performans gozlem raporu.
- Yukleme suresi, input gecikmesi veya overlay frame-drop gorulen en kotu anin kisa notu.
- Gerekirse bir mini backlog maddesi.

## P12 Release Candidate Kapisi

Bu bolum, `P12 - Release candidate` oncesi teknik blokajlari tek oturumda gormek icindir.

### Hazir Preflight Komutu

- `powershell -ExecutionPolicy Bypass -File tools/run_p12_release_preflight.ps1`
- Bu komut debug APK varligini, export metadata'yi, release signing alanlarini, checklist/audit varligini ve P11 cihaz gozlem raporunu denetler.
- Varsayilan davranisla P10 otomatik gate'i de yeniden kosar.

### P12 Kapanisindan Once

- Release signing akisi `export_presets.cfg` veya operasyonel release sureciyle netlesmis olmali.
- En az bir P11 cihaz gozlem raporu mevcut olmali.
- Final APK kurulum/acilis/smoke sonucu bu checklist'e islenmis olmali.

## Opsiyonel Capture Destegi

UI yuzeylerini cihaz smoke testinden bagimsiz gorsel olarak teyit etmek icin:

- `docs/UI_SCREENSHOT_CHECKLIST.md` icindeki capture komutlari kullanilabilir.
- Gerekirse world tarafi icin `tools/capture_world_render.gd` ile temiz portrait capture alinabilir.

## Test Sonu Ozeti

| Alan | Sonuc |
|------|-------|
| Ana menu | |
| Settings / audio | |
| Start + loading | |
| World basic input | |
| Save / continue | |
| Geri tusu | |
| Background / foreground | |
| Genel karar | |

## P9 ve P10'a Aktarim

- P9 icin tutulacak notlar: safe-area bozuldugu ekranlar, system bar cakismalari, portrait layout kusurlari.
- P10 icin tutulacak notlar: geri tusu, lifecycle, loading sonrasi input bloklari, ses geri donus hatalari.
- Ilk P10 sertlestirme slice'inda world background/foreground gecisinde autosave, transient exit-confirm temizligi ve audio pause/resume kontrati kod seviyesinde eklendi; cihaz-ustu A12/A16 teyidi bir sonraki kontrol kapisi olarak kaldi.
- Ikinci P10 slice'inda app background sirasinda menu dream-intro transition'inin yarim kalmasi engellendi; cihaz-ustu kontrolde A12/A16 yanina bu kesinti senaryosu da not edilmeli.
- Ucuncu P10 slice'inda aktif loading overlay request'leri app background sirasinda yalnizca gizlenmek yerine iptal edilip arka planda drain edilerek tuketilmeye baslandi; `verify_app_lifecycle_contract.gd` bu davranisi leak warning'i uretmeden dogrular hale getirildi.
- Cihaz-ustu kontrolde A12 yanina su kesit ayrica eklenmeli: menu dream-intro veya loading overlay aktifken uygulamayi arka plana alip geri dondugunde yarim gecis, siyah ekran veya takili loading kalmamali.
- Dorduncu P10 slice'inda ana menude dream-intro veya loading aktifken `ui_cancel` artik exit dialog acmak yerine pending world transition'i iptal ediyor; `verify_app_lifecycle_contract.gd` bu davranisi `Menu cancel lifecycle` kontroluyle kapsiyor.
- Cihaz-ustu A16 kontrolunde su not da tutulmali: ana menude geri tusu, normal durumda exit confirm acarken aktif gecis sirasinda ayni akisi kesip menuye saglikli donmeli.
- P10 kapanisinda raporlanacak minimum cihaz notu artik `A12.1/A12.2/A12.3` ve `A16.1/A16.2/A16.3` kesitlerinden olusmali; bunlar ayrica `A16.4` continue geri-donus notuyla tamamlanmali.

---

## Release Candidate Pipeline (Package 11)

Bu bölüm, `Package 11 - Release Candidate Pipeline` çıktısıdır. Amaç, debug ve release build süreçlerini birbirinden ayırmak, imzalama adımlarını güvenli şekilde belgelemek ve tekrarlanabilir RC üretimini sağlamaktır.

### Debug vs Release Preset Durumu

**Mevcut durum:** [`export_presets.cfg`](export_presets.cfg) içinde yalnızca **tek bir preset** (`preset.0` — "Android") bulunmaktadır. Debug ve release ayrımı **yoktur**.

| Alan | Debug | Release |
|------|-------|---------|
| Preset sayısı | 1 (ortak) | 1 (ortak) — ayrı preset yok |
| Keystore/debug | Boş (`keystore/debug=""`) | N/A |
| Keystore/release | N/A | **Tanımlı değil** — tüm `keystore/release/*` alanları eksik |
| custom_package/debug | Boş | N/A |
| custom_package/release | N/A | Boş |

**Öneri:** Release imzalama için `export_presets.cfg`'ye ayrı bir `preset.1` eklenmeli (şifre ve yol bilgisi olmadan, sadece yapılandırma). P12 öncesi yapılması önerilir.

### Version Bump Kuralları

**Kaynaklar:**
- [`project.godot`](project.godot:14) — `config/version="1.0.0"`
- [`export_presets.cfg`](export_presets.cfg:17-18) — `version/code=1`, `version/name="1.0"`

**⚠️ Tespit edilen uyumsuzluk:** `project.godot` `1.0.0` (3 segment) kullanırken, `export_presets.cfg` `1.0` (2 segment) kullanıyor. Build öncesi senkronize edilmelidir.

| Sürüm | Alan | Yer | Örnek |
|-------|------|-----|-------|
| **Major** | `config/version` ilk segment | `project.godot` | Büyük içerik güncellemesi (örn: yeni bölüm) → `2.0.0` |
| **Minor** | `config/version` ikinci segment | `project.godot` | Yeni özellik (örn: journal MVP) → `1.1.0` |
| **Patch** | `config/version` üçüncü segment | `project.godot` | Bug fix / polish → `1.0.1` |
| **Build code** | `version/code` | `export_presets.cfg` | Her release'de +1 artırılır (Android manifest `versionCode`) |

**Kural:**
1. Önce `project.godot`'da `config/version` güncellenir (örn: `1.0.0` → `1.0.1`)
2. Ardından `export_presets.cfg`'de `version/name` aynı değere ayarlanır
3. `version/code` (build numarası) her release'de **elle +1** artırılır
4. Build code asla sıfırlanmaz, monotonic olarak artar

### İmzalama (Signing) Adımları

**🚫 ASLA keystore şifrelerini commit etme.** Aşağıdaki adımlar yerel ortamda yapılır.

#### Keystore Oluşturma (ilk seferde)

```powershell
# Keystore oluştur
keytool -genkey -v -keystore mmae_release.keystore `
  -alias mmae_release_key `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -storepass [GİZLİ_STORE_PASS] `
  -keypass [GİZLİ_KEY_PASS] `
  -dname "CN=MMAE, OU=Development, O=MMAE, L=Ankara, ST=Turkey, C=TR"
```

**Not:** Keystore dosyası (`mmae_release.keystore`) proje dışında güvenli bir konumda saklanır (örn: `C:\Users\Aykut\keys\`).

#### Release Build İmzalama

1. Keystore dosyasını yerel ortamda hazır bulundur (proje dışında)
2. Godot Editor'de: `Project > Export > Android > Release` sekmesinde `Keystore` alanlarını doldur
3. Keystore yolu, alias, store pass ve key pass'i editor'den gir (şifreler `/commit edilmez`)
4. `Export > Export Release` ile imzalı APK/AAB üret
5. Alternatif: CLI ile (keystore editor'den konfigüre edilmiş olmalı):
   ```powershell
   & "Godot_v4.6.2-stable_win64_console.exe" --path "." --export-release "Android" "builds/BandirmaYolculugu_release.apk"
   ```

### Release Candidate Checklist

#### Build

- [ ] Debug build başarılı
- [ ] Release build başarılı (export_presets.cfg üzerinden)
- [ ] APK ve AAB formatları üretildi
- [ ] Version numarası `project.godot` ve `export_presets.cfg` arasında tutarlı
- [ ] Build code (`version/code`) bir önceki release'den büyük

#### Install & Smoke

- [ ] Emülatörde kurulum başarılı
- [ ] Cihazda kurulum başarılı
- [ ] Uygulama başlatılabiliyor
- [ ] Ana menü görüntüleniyor
- [ ] Yeni oyun başlatılabiliyor
- [ ] Kayıtlı oyun yüklenebiliyor

#### Lifecycle

- [ ] P10 Smoke Gate geçti (`P10_SMOKE_GATE_OK`)
- [ ] P11 Performance Gate geçti (`P11_PERFORMANCE_GATE_PASSED` veya `PASSED_WITH_WARNINGS`)
- [ ] Uygulama askıya alma/devam ettirme (pause/resume) çalışıyor
- [ ] Ses askıya almada duruyor, devam ettirmede kaldığı yerden devam ediyor

#### Performance

- [ ] 60 FPS hedefi tutturuluyor (düşük-orta seviye cihazda)
- [ ] Bellek kullanımı kabul edilebilir seviyede
- [ ] Zone geçişlerinde belirgin donma yok

#### Final

- [ ] Son capture/log arşivi alındı
- [ ] Version numarası güncellendi
- [ ] Build imzalandı
- [ ] `export_presets.cfg`'de debug/release ayrımı netleştirildi (gerekirse ayrı preset)
- [ ] Mimariler: `arm64` dahil, `x86_64` sadece emulator için (opsiyonel)

### P12 Final APK Smoke Kaydi

Bu blok, final release APK smoke sonucunu ayni checklist icinde sabitlemek icindir. `tools/run_p12_release_preflight.ps1` bu alanlar dolmadan P12 kapisini kapatmaz.

- `P12_RELEASE_BUILD_STATUS=BUILD_RELEASE_OK`
- `P12_FINAL_APK_PATH=C:\Users\Aykut\Documents\Godot\mmae\builds\BandirmaYolculugu_release_20260514_203155.apk`
- `P12_FINAL_SMOKE_STATUS=SKIPPED_NO_DEVICE`
- `P12_RELEASE_DEVICE=TODO`
- `P12_RELEASE_NOTES=TODO`

| Alan | Deger |
|------|-------|
| Release build tarihi | |
| Release APK yolu | |
| Test edilen cihaz/emulator | |
| Android surumu | |
| Kurulum sonucu | |
| Acilis sonucu | |
| Lifecycle sonucu | |
| Continue/load sonucu | |
| Genel karar | |

### Hazir Release Smoke Komutu

- `powershell -ExecutionPolicy Bypass -File tools/run_p12_release_device_smoke.ps1`
- Bu komut en son uretilen `BandirmaYolculugu_release_*.apk` dosyasini cihaza kurar, uygulamayi acar ve checklist marker'larini cihaz bilgisiyle gunceller.
P12_FINAL_SMOKE_STATUS=SKIPPED_NO_DEVICE

