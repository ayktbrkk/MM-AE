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

### Kisa Kosu Sirasi

- `verify_app_lifecycle_contract -> validate_game_flow -> A12.1 -> A12.2 -> A12.3 -> A16.1 -> A16.2 -> A16.3 -> A15 -> A16.4 -> test sonu ozeti`

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