# Godot Official Demo Adaptation

Bu not, indirilen resmi Godot demo projelerinin mevcut MMAE kod tabanina nasil uyarlanacagini dosya bazli olarak ozetler.

Kaynak klasor: `references/godotengine_official_demos/`

## Kisa Sonuc

Bu proje icin en yararli resmi demo seti sunlardir:

- `gui_multiple_resolutions`
- `gui_theming_override`
- `gui_rich_text_bbcode`
- `gui_translation`
- `gui_pseudolocalization`
- `2d_tween`

Bu demolarin hicbiri bu projeye addon gibi kurulmamali. Referans olarak okunup mevcut UI/overlay yapisina parcali uyarlanmalidir.

## 1. Multiple Resolutions

Demo: `references/godotengine_official_demos/gui_multiple_resolutions`

Bu projede zaten iyi bir temel var:

- `project.godot` `canvas_items` + `expand` kullaniyor.
- `scripts/main_menu.gd` icinde `SafeArea` yaklasimi var.
- `scripts/world_ui.gd` icinde `sync_hud_layout()` ile viewport tabanli margin hesabi yapiliyor.
- `scripts/ui_tokens.gd` icinde safe area tokenlari tanimli.

Uyarlanacak kisim:

- Demo'daki `AspectRatioContainer` ve `gui_margin` mantigi, mevcut sabit safe area mantigini tamamlayabilir.
- Ozellikle `main_menu`, `dialogue`, `decision`, `info_card` ve `chapter_transition` overlay'lerinde ust/alt bosluklar tek bir helper uzerinden normalize edilebilir.

Hedef dosyalar:

- `scripts/main_menu.gd`
- `scripts/world_ui.gd`
- `scripts/ui_tokens.gd`
- gerekirse yeni `scripts/gui_frame.gd`

Onerilen uygulama:

1. `main_menu.gd` ve `world_ui.gd` icindeki margin hesaplarini tek helper'a topla.
2. `gui_multiple_resolutions` demosundaki gibi istege bagli bir `content frame` tanimla.
3. Overlay'leri direkt viewport yerine bu frame'e gore hizala.
4. Sonrasinda `tools/capture_character_ui.gd` ile 1080x1920 ve daha dar boylarda tekrar capture al.

Beklenen fayda:

- Daha tutarli portrait mobil layout
- Overlay panel yuksekliklerinin daha kontrollu daralmasi
- Safe area davranisinin menu ve world HUD arasinda ayni hale gelmesi

## 2. Theming Override

Demo: `references/godotengine_official_demos/gui_theming_override`

Bu projede su an tema sistemi `Theme` kaynagi uzerinden degil, runtime `StyleBoxFlat` uretimi ile yurutuluyor.

Mevcut durum:

- `scripts/colors.gd` renklerin merkezi kaynagi
- `scripts/ui_tokens.gd` radius/font/spacing tokenlari
- `scripts/ui_style_factory.gd` her cagride yeni `StyleBoxFlat` instance'lari uretiyor
- `dialogue_overlay.gd`, `decision_overlay.gd`, `info_card_overlay.gd`, `chapter_transition_overlay.gd` kendi stillerini ayri ayri kuruyor

Uyarlanacak kisim:

- Demo'daki runtime override pattern'i, mevcut sistemi bozmadan `Theme` tabanli ikinci bir katman eklemek icin uygun.
- Hedef, tamamen yeni bir tema sistemi kurmak degil; en sik kullanilan panel/button stillerini cache'lemek.

Hedef dosyalar:

- `scripts/ui_style_factory.gd`
- `scripts/colors.gd`
- `scripts/ui_tokens.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/decision_overlay.gd`
- `scripts/info_card_overlay.gd`
- `scripts/chapter_transition_overlay.gd`

Onerilen uygulama:

1. `UIStyleFactory` icine anahtar bazli style cache ekle.
2. En cok tekrar eden panel ve button varyantlarini adlandir.
3. Overlay scriptlerinde dogrudan `StyleBoxFlat.new()` zinciri kurmak yerine cache'li style iste.
4. Ileride istenirse `Theme` resource gecisi icin ayni API korunabilir.

Beklenen fayda:

- UI stillerinde tek kaynak
- Overlay bazli stil farklarinin daha kontrollu hale gelmesi
- Zone veya tema degisimlerinde daha az tekrar

## 3. Rich Text BBCode

Demo: `references/godotengine_official_demos/gui_rich_text_bbcode`

Bu proje icinde en dogrudan uyumlu yuzey `dialogue_overlay.gd`.

Mevcut durum:

- `scripts/dialogue_overlay.gd` zaten `RichTextLabel` kullaniyor.
- `scripts/info_card_overlay.gd` hala duz `Label` kullaniyor.
- Hikaye dili kisa ve cocuk okunabilirligi odakli, bu nedenle abartili formatlama degil secici vurgu gerekli.

Uyarlanacak kisim:

- Diyalogta kelime vurgusu, yer adlari, karar oncesi kritik ifadeler icin sinirli BBCode seti.
- Bilgi kartlarinda baslik/alinti/odul satiri icin daha zengin metin hiyerarsisi.

Hedef dosyalar:

- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`
- `assets/data/questions.gd`

Onerilen uygulama:

1. `dialogue_overlay.gd` icin guvenli BBCode whitelist belirle: `b`, `i`, `color`, `wave`, `shake` degil; once sade set.
2. `info_card_overlay.gd` icindeki `body_label`i `RichTextLabel`e gecirmeyi degerlendir.
3. `questions.gd` veya info-card metinlerinde sadece egitsel vurgu gereken satirlarda BBCode kullan.
4. Uzun metinlerde tasma kontrolunu `pseudolocalization` ile birlikte yap.

Beklenen fayda:

- Cocuklar icin anahtar kelimelerin daha rahat ayristirilmasi
- Diyalog ve bilgi karti tonunun daha canli olmasi
- Metin yogunlugunu arttirmadan hiyerarsi kurulmasi

## 4. Translation

Demo: `references/godotengine_official_demos/gui_translation`

Bu proje icin localization dogrudan sonraki buyume ekseni. Story Bible ve roadmap'te coklu dil zaten hedeflenmis.

Mevcut durum:

- Projede aktif localization pipeline yok.
- Daha once kurulan bazi localization addon'lari uygun bulunmadi; bu yuzden resmi Godot akisi daha guvenli.
- Diyalog ve karar verileri `assets/data/questions.gd` icinde kod olarak tutuluyor.

Uyarlanacak kisim:

- Addon tabanli editor araci yerine resmi Godot CSV/PO import zinciri.
- Ilk adimda tum oyunu tasimak yerine overlay ve menu yuzeylerini anahtar tabanli metne gecirmek.

Hedef dosyalar:

- `scripts/main_menu.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`
- `scripts/decision_overlay.gd`
- `assets/data/questions.gd`
- yeni `translations/`

Onerilen uygulama:

1. Once menu ve sabit UI metinlerini `tr()` uyumlu anahtarlara tas.
2. Sonra `questions.gd` icindeki metinleri kademeli olarak localization key bazina cek.
3. Font fallback ihtiyacini `gui_translation` demosundaki font klasoru mantigi ile planla.
4. Addon yerine Godot'un kendi import/remap zincirini kullan.

Beklenen fayda:

- Localization yuzeyi resmi Godot yoluna oturur
- Eklenti bagimliligi azalir
- Turkish-first metinler ileride Ingilizceye daha guvenli tasinir

## 5. Pseudolocalization

Demo: `references/godotengine_official_demos/gui_pseudolocalization`

Bu demo dogrudan UI regression araci gibi kullanilabilir.

Mevcut durum:

- Bu projede overlay capture akisi zaten var.
- `docs/UI_SCREENSHOT_CHECKLIST.md` ve `tools/capture_character_ui.gd` kullanimda.
- En buyuk risk uzun ceviri veya daha genis metin geldikce `decision`, `dialogue`, `info_card` tasmasi.

Uyarlanacak kisim:

- Pseudolocalization acik bir kontrol modu olarak validation akisina eklenebilir.

Hedef dosyalar:

- `tools/capture_character_ui.gd`
- `docs/UI_SCREENSHOT_CHECKLIST.md`
- `scripts/decision_overlay.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`

Onerilen uygulama:

1. Pseudolocale ile UI capture alan ikinci bir regression modu ekle.
2. Ozel olarak `prompt_label`, `body_label`, `continue_button`, `back_button`, `chapter_label` tasmalarini kontrol et.
3. Bu mod, gercek ceviri gelmeden once layout stres testi olsun.

Beklenen fayda:

- Gercek localization gelmeden tasma sorunlari erken bulunur
- 7-8 yas hedefi icin okunurluk daha guvenli hale gelir

## 6. Tween

Demo: `references/godotengine_official_demos/2d_tween`

Bu proje zaten tween agirlikli. Bu nedenle ana kazanc yeni tween eklemek degil, tween dilini tutarlilastirmak.

Mevcut durum:

- `dialogue_overlay.gd`, `decision_overlay.gd`, `info_card_overlay.gd`, `chapter_transition_overlay.gd`, `dream_intro_overlay.gd`, `loading_overlay.gd` hep kendi tween zincirlerini kuruyor.
- `scripts/overlay_tween_helper.gd` yalnizca cancel/replace yardimcisi sagliyor.
- `addons/godot_ui_animations/UiAnimationHandler.gd` mevcut ama overlay'lerin cogu bunu kullanmiyor.

Uyarlanacak kisim:

- Demo'daki tween organizasyonu kullanilarak overlay giris/cikis pattern'leri standartlasabilir.
- Tek hedef: tum overlay'lerde ayni easing, benzer sure araligi ve iptal edilebilir gecis dili.

Hedef dosyalar:

- `scripts/overlay_tween_helper.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/decision_overlay.gd`
- `scripts/info_card_overlay.gd`
- `scripts/chapter_transition_overlay.gd`
- `scripts/loading_overlay.gd`

Onerilen uygulama:

1. `overlay_tween_helper.gd` icine ortak easing/sure preset'leri ekle.
2. Overlay giris animasyonlarini `fade_up`, `panel_pop`, `soft_backdrop`, `stagger_children` gibi isimli pattern'lere ayir.
3. `godot_ui_animations` yalnizca basit Control kaydirma/pop ihtiyaci olan yuzeylerde kullanilsin; overlay cekirdegi kendi helper'inda kalsin.

Beklenen fayda:

- Gecisler ayni dili konusur
- Gelecekteki UI polish daha hizli olur
- Cancel/skip davranislari daha tutarli hale gelir

## 7. Awesome Godot Curated Shortlist

Kaynak: `https://github.com/godotengine/awesome-godot`

`awesome-godot`, resmi Godot demo reposundan farkli olarak ucuncu taraf repo listesi tutar. Bu nedenle burada gecen her aday ayri uyumluluk ve bakim kontrolu ister. Asagidaki secim, mevcut MMAE mimarisine gore filtrelenmistir.

### 7.1 Simdi Degerlendirilebilir Adaylar

#### GodSVG

Repo: `MewPurPur/GodSVG`

Bu proje SVG agirlikli oldugu icin en dogrudan fayda burada. Karakter asset kit'i ve paper-diorama world asset'leri icin SVG optimizasyon araci olarak degerli.

En uygun kullanim:

- `assets/art/characters/`
- `assets/art/world/`
- `.svg` import boyutlarini dusurme

Not:

- Runtime addon olarak degil, asset uretim araci olarak dusunulmeli.

#### Godot Doctor

Repo: `codevogel/godot_doctor`

Bu repo, mevcut headless validation akisini tamamlayabilecek en guclu adaylardan biri. Bu projede parse/import dogrulamasi zaten var; `Godot Doctor` scene/resource dogrulamasini daha erken yakalayabilir.

En uygun kullanim:

- scene ve resource validation
- CI veya pre-release kontrolu
- `PackedScene` yuzeylerinde tutarlilik taramasi

Not:

- Mevcut `--headless --check-only` akisinin yerine degil, yanina eklenmeli.

#### License Manager

Repo: `kenyoni-software/licenses`

Bu projede Kenney asset'leri ve cesitli ucuncu taraf kaynaklar yogun. Lisans takibi zaten manuel klasorlerle yuruyor; bu addon lisans envanterini editor icinde toplamak icin uygun.

En uygun kullanim:

- `assets/licenses/`
- `kenney/`
- gelecekte export oncesi attribution kontrolu

Not:

- Oyun mekani gi veya runtime degil, proje hijyeni araci.

#### System Bar Color Changer

Repo: `syntaxerror247/godot-android-system-bar-color-changer`

Bu proje Android portrait odakli. Mobil polish tarafinda durum cubugu ve navigation bar renklerinin sahneye gore ayarlanmasi faydali olabilir.

En uygun kullanim:

- ana menu
- chapter transition
- immersive overlay ekranlari

Not:

- Android export asamasina yakin eklenmeli; erken asamada zorunlu degil.

#### Input Helper

Repo: `nathanhoad/godot_input_helper`

Su an proje dokunmatik/on-screen buton agirlikli. Yine de ileride gamepad, klavye ve farkli cihaz tipi algilama istendiyse bu repo mantikli bir yardimci katman olabilir.

En uygun kullanim:

- kontrol cihazi algilama
- input remap
- mobil/disaridan bagli gamepad senaryolari

Not:

- Mevcut MVP icin sart degil; platform kapsamı buyurse degerlenir.

### 7.2 Referans Olarak Degerli, Dogrudan Kurulum Icin Erken

#### Takin Godot Template

Repo: `TinyTakinTeller/TakinGodotTemplate`

Save system, localization, UI, options ve scene loader orneklerini bir arada sunuyor. Bu projeye dogrudan merge etmek buyuk olur; ama `translation`, `save slots`, `options` ve `scene loading` organizasyonu icin referans degeri yuksek.

#### Maaack's Scene Loader

Repo: `Maaack/Godot-Scene-Loader`

Bu projede zaten `loading_overlay.gd` ve kendi scene gecis yapisi var. Bu nedenle dogrudan degistirmek yerine, ileride error handling ve gercek progress takibi icin referans alinabilir.

#### ThemeGen

Repo: `Inspiaaa/ThemeGen`

Bu proje halen `colors.gd` + `ui_tokens.gd` + `ui_style_factory.gd` uzerinden ilerliyor. `ThemeGen`, tam tema sistemine gecis istenirse daha sonra anlamli. Su an once mevcut style factory cache'lenmeli.

#### Quest Manager / Questify / QuestSystem

Repolar:

- `Rubonnek/quest-manager`
- `TheWalruzz/godot-questify`
- `shomykohai/quest-system`

MMAE'de event/zone akisi zaten `questions.gd`, `world_zone.gd` ve chapter chain'leri uzerinden kurulu. Bu nedenle simdi quest sistemine gecmek gereksiz kapsam buyutmesi olur. Yine de ileride yan gorevler, koleksiyon hedefleri veya ogretmen modu gelirse tekrar bakilabilir.

### 7.3 Mevcut Kararlari Destekleyen veya Tekrar Kurulmamalı Olanlar

#### Dialogue Manager

Repo: `nathanhoad/godot_dialogue_manager`

Bu repo zaten projede kurulu ve uygun bulundu. `awesome-godot` icinde yer almasi mevcut secimin dogru oldugunu destekliyor.

#### GUT

Repo: `bitwes/Gut`

Bu repo da projede mevcut. Test framework olarak kalmali; ancak editor plugin tarafi headless validation gürültüsü olusturmamasi icin varsayilan enabled set disinda tutulmali.

#### Beehave

Repo: `bitbrain/beehave`

Bu projede daha once denenip kaldirildi. Gerekce: scope uyumsuzlugu ve gereksiz editor/autoload agirligi. Bu oyunun hikaye ve UI odakli yapisi icin fazla agir.

#### Phantom Camera

Repo: `ramokz/phantom-camera`

Bu projede daha once kaldirildi. Mevcut oyun portrait 2D, overlay ve world-routing agirlikli; camera davranislari icin ek sistem maliyeti faydayi asmiyor.

#### ProtonScatter

Repo: `HungryProton/scatter`

Bu repo 3D/environment placement odakli. Mevcut 2D paper-diorama duzende uygun degil ve zaten kaldirildi.

### 7.4 Su An Icin Bilincli Olarak Girmemesi Gereken Buyuk Alternatifler

#### Dialogic / Konado / Diger Diyalog Toolkit'leri

Repolar:

- `dialogic-godot/dialogic`
- `godothub/konado`

Bu proje zaten `Dialogue Manager` + ozel overlay sunum sozlesmesi ile ilerliyor. Diyalog motorunu orta safhada degistirmek, `world_ui.gd`, overlay sozlesmeleri ve veri akisinda gereksiz kirilim yaratir.

Karar:

- su an kurma
- ancak gelecekte visual narrative editor ihtiyaci buyurse yeniden incele

#### Virtual Joystick

Repo: `MarcoFazioRandom/Virtual-Joystick-Godot`

Bu oyun joystick tabanli hareket oyunu degil. Etkilesim butonlari, overlay'ler ve secim akislari baskin. Bu nedenle simdi gereksiz.

### 7.5 Awesome-Godot Sonrasi Onerilen Kisa Liste

Bu projede `awesome-godot` kaynakli en mantikli sonraki adaylar:

1. `GodSVG` - asset pipeline yardimi
2. `Godot Doctor` - validation katmani
3. `License Manager` - asset attribution hijyeni
4. `System Bar Color Changer` - Android polish

Bu dordunun disindaki adaylar su an ya referans degerinde ya da mevcut mimaride gereksiz kapsam buyutuyor.

## 8. Resmi Demo Reposundan Ek Uygulanabilir Secimler

Kaynak: `https://github.com/godotengine/godot-demo-projects`

Ilk indirilen alti demo dogru cekirdek secimdi. Ancak repo geneline bakinca, MMAE icin ikinci dalga referans olarak alinabilecek birkac demo daha var. Bunlar da addon gibi kurulmamali; sadece mevcut sistemlere parcali fikir tasimak icin okunmali.

### 8.1 Hemen Referans Alinabilecekler

#### gui/accessibility

Bu demo, 7-8 yas hedef kitlesi olan bu proje icin sadece erisilebilirlik uyumu degil, okunurluk ve odak sirasi disiplini acisindan da degerli.

En uygun kullanim:

- `scripts/main_menu.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/decision_overlay.gd`
- `scripts/info_card_overlay.gd`

Onerilen uyarlama:

1. Buton ve continue aksiyonlarinda focus order ve varsayilan secim mantigini standartlastir.
2. Yalniz renk ile iletilen durumlari azalt; secili ve pasif halleri spacing, border veya icon ile de ayirt et.
3. Uzun metin ekranlarinda minimum font-size ve satir araligi alt sinirlarini token seviyesinde sabitle.

#### gui/control_gallery

Bu demo dogrudan runtime ihtiyaci degil, ama `ui_style_factory.gd` icin eksik olan sey tam da bu: eldeki panel, button ve badge varyantlarini tek yerde gormek.

En uygun kullanim:

- `scripts/ui_style_factory.gd`
- `scripts/ui_tokens.gd`
- `scripts/colors.gd`
- gerekirse yeni `scenes/ui_style_gallery.tscn`

Onerilen uyarlama:

1. Uretimde kullandiginiz button, panel, chip ve label kombinasyonlari icin editor icinde acilan basit bir style gallery scene'i ekle.
2. Bu gallery, `theming_override` ve `pseudolocalization` isleri yapilirken hizli gorusel regression araci gibi kullanilsin.
3. Yeni overlay eklenirken stil karari once bu gallery uzerinde dogrulansin.

#### misc/pause

Bu demodaki asıl deger pause tusu degil; zaman akisi durdugunda UI'nin nasil ayri bir sozlesmeyle davranacagi.

En uygun kullanim:

- `scripts/world.gd`
- `scripts/world_ui.gd`
- `scripts/overlay_manager.gd`
- `scripts/loading_overlay.gd`

Onerilen uyarlama:

1. Oyun donduruldugunda hangi overlay'in input kabul edecegini merkezi bir kural haline getir.
2. `loading`, `chapter transition`, `decision` ve `dialogue` ekranlari icin `process_mode` ve input kilidi beklentisini tek yerde tanimla.
3. Ileride gercek bir pause/options overlay'i gelirse ayni sozlesme uzerinden acilsin.

#### loading/scene_changer ve loading/load_threaded

Bu projede zaten `loading_overlay.gd` var. Bu nedenle sifirdan sistem degistirmek yerine, resmi demolardaki sahne gecisi ve yukleme siralama mantigi referans alinmali.

En uygun kullanim:

- `scripts/loading_overlay.gd`
- `scripts/main_menu.gd`
- `scripts/save_manager.gd`
- `scripts/world.gd`

Onerilen uyarlama:

1. `loading_overlay.gd` icinde gorunen progress ile gercek yukleme adimlarini ayirmayi degerlendir.
2. `main_menu -> world`, `continue -> load`, `chapter transition -> next state` gecislerini ayni yukleme API'sine yaklastir.
3. Uzun surecek asset veya chapter degisimlerinde thread tabanli preload ihtiyacini yalniz gerekiyorsa ekle.

### 8.2 Simdilik Referans Olarak Tutulacaklar

#### gui/input_mapping

Simdi icin erken. Ama `ayarlar`, `dokunmatik`, `gamepad` ve `klavye` ayrimi buyurse bu demo dogrudan faydali olur.

En uygun kullanim:

- `scripts/main_menu.gd`
- ileride bir `settings` veya `controls` paneli

Karar:

- simdi kurma veya kopyalama
- sadece ileride kontrol yeniden esleme ihtiyaci buyurse don

#### gui/ui_mirroring ve gui/bidi_and_font_features

Su an proje Turkish-first. Ancak Arapca gibi RTL diller gelecekte hedeflenirse bu iki demo birden onem kazanir.

En uygun kullanim:

- `translations/`
- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`

Karar:

- bugunluk roadmap notu olarak tut
- `translation` isi gercekten ikinci dile acildiginda yeniden incele

#### loading/runtime_save_load ve loading/serialization

Bu demolar, mevcut `scripts/save_manager.gd` icin tam bir drop-in cozum degil; ama save formatini buyutmek, versiyonlamak veya veri migrasyonu yapmak gerekirse faydali olacak.

En uygun kullanim:

- `scripts/save_manager.gd`
- `scripts/world_state.gd`
- `assets/data/`

Karar:

- mevcut JSON/save yapisini hemen degistirme
- once mevcut continue/load akisinin oyun tarafindaki ihtiyaclari tam netlessin

## 9. DOGWALK'ten Alinabilecek Yapilar

Kaynak: `https://github.com/nikitalita/DOGWALK`

DOGWALK bu projeye genre veya asset olarak uymaz. 3D agirlikli, farkli kamera ve karakter davranislarina dayali. Ancak kod organizasyonu tarafinda alinabilecek temiz paternler var. Burada alinacak sey sahne veya asset degil; manager sinirlari, event akisi ve gecis organizasyonu.

### 9.1 En Kullanisli Paternler

#### Kucuk ve Acik Bir Signal Bus

DOGWALK'teki `source/globals/signal_bus.gd`, az sayida ama yuksek degerli global olayi topluyor. Bu iyi bir referans cunku event bus'i buyutmuyor.

MMAE karsiligi:

- `scripts/overlay_manager.gd`
- `scripts/world.gd`
- `scripts/world_ui.gd`

Onerilen uyarlama:

1. Sadece sahneler arasi kopuk baglanti ureten olaylar icin kucuk bir global event katmani dusun.
2. Overlay ic olaylarini oraya tasima; onlar overlay node sinirlari icinde kalsin.
3. Save tetigi, chapter tamamlandi, global input kilidi degisti gibi olaylar aday olabilir.

#### Audio'yu UI, Music ve SFX Olarak Daha Net Ayirmak

DOGWALK `audio_manager`, `music_manager`, `sfx_manager`, `ui_sound_manager` olarak ayrilmis. MMAE'de `scripts/audio_manager.gd` zaten guclu bir autoload ama UI sesleri ile world seslerinin daha acik ayrismasi faydali olabilir.

MMAE karsiligi:

- `scripts/audio_manager.gd`
- `scripts/main_menu.gd`
- `scripts/world_ui.gd`

Onerilen uyarlama:

1. `AudioManager` API'sinde UI click/confirm/back seslerini world SFX'ten kavramsal olarak ayir.
2. Overlay'lerin cogu ayni ses ailesini kullaniyorsa, bunu tek yardimci uzerinden cagir.
3. Menu ve world gecislerinde BGM state degisimlerini daha deklaratif hale getir.

#### Save/Load Icinde Gating ve Fade Akisi

DOGWALK `save_manager.gd` icinde `can_save`, `Persist` grubu ve `transition_screen` ile save/load akisina net kapilar koyuyor. Mevcut MMAE'de de save/load var; ama ayni fikrin daha net ifade edilmesi faydali.

MMAE karsiligi:

- `scripts/save_manager.gd`
- `scripts/loading_overlay.gd`
- `scripts/main_menu.gd`
- `scripts/world_state.gd`

Onerilen uyarlama:

1. Kayit alinabilecek ve alinmayacak anlari tek yerde acik kurala bagla.
2. Continue/load sirasinda UI fade, state restore ve input unlock adimlarini tek akis halinde topla.
3. `Persist` benzeri grup veya acik save contract kullanimi, save kapsamini buyuturken isi kolaylastirir.

#### Gecis Ekranini Ayri Bir Sorumluluk Olarak Tutmak

DOGWALK'teki `transition_screen.gd`, fade ve gorunur yukleme geri bildirimi isini tek Control sahnesine topluyor. MMAE'deki `scripts/loading_overlay.gd` ile ayni yone gidiyor; bu dogru yon.

MMAE karsiligi:

- `scripts/loading_overlay.gd`
- `scripts/chapter_transition_overlay.gd`
- `scripts/overlay_tween_helper.gd`

Onerilen uyarlama:

1. Tum tam ekran gecisleri icin ortak bir transition vocabulary belirle.
2. Loading, chapter gecisi ve dream intro ekranlari ayni temel API ile acilip kapanabilsin.
3. Gercek progress yoksa bile hangi gecisin blocklayici oldugu tek tip gorunsun.

#### Input Mode ve Input Lock Mantigini Tek Yerde Toplamak

DOGWALK `input_controller.gd` icinde input source tespiti, bypass kontrolu ve gameplay input donusumunu tek yerde tutuyor. MMAE mobil odakli olsa da bu fikir menu ve overlay tarafinda ise yarar.

MMAE karsiligi:

- `scripts/main_menu.gd`
- `scripts/world_player.gd`
- `scripts/world_ui.gd`

Onerilen uyarlama:

1. Overlay acikken hangi input katmaninin kilitlenecegi tek yerde tanimlansin.
2. Ileride gamepad veya klavye geri gelirse, aktif input tipi UI focus davranisini degistirebilsin.
3. Ozellikle `continue`, `back`, `choice` gibi aksiyonlar icin dokunmatik ve gamepad semantigi ayrilsin.

#### Kucuk Utility ve Test Dosyalarini Cekirdekten Ayirmak

DOGWALK'te `value_slicer.gd`, `procedural_animator.gd`, `unit_tests_value_slicer.gd`, `batch_reimport.gd` gibi tek sorumlu yardimci dosyalar ayri tutulmus.

MMAE karsiligi:

- `tools/`
- `test/`
- `scripts/overlay_tween_helper.gd`
- olasi yeni kucuk utility script'ler

Onerilen uyarlama:

1. UI yardimcilari buyudukce bunlari overlay scriptlerinin icine gommek yerine ayri scriptlerde tut.
2. Save/load, layout hesaplama veya tween preset gibi saf mantiklar icin kucuk test edilebilir birimler cikar.
3. Editor yardimci scriptleri `tools/` altinda toplamaya devam et.

### 9.2 Bilincli Olarak Alinmamasi Gerekenler

Alinmamasi gereken kisimlar:

- DOGWALK'in 3D asset kutuphanesi ve environment sahneleri
- karakter hareket, leash, camera magnet, terrain detector gibi fizik ve kamera odakli sistemler
- project-level scene yapisini oldugu gibi tasimak

Neden:

- MMAE'nin problemi content flow, overlay UX ve 2D/mobile okunurluk
- DOGWALK'in problemi character locomotion, 3D environmental feedback ve camera takip
- ayni cozum uzeyi degiller

## Oncelik Sirasi

Bu proje icin en mantikli uyarlama sirasi:

1. `gui_multiple_resolutions`
2. `gui_pseudolocalization`
3. `gui_translation`
4. `gui_theming_override`
5. `2d_tween`
6. `gui_rich_text_bbcode`

## Uygulanmamasi Gerekenler

- Demolari doğrudan `addons/` altina tasima
- Demo `project.godot` ayarlarini bu projeye oldugu gibi kopyalama
- Demo scene'lerini runtime'a dogrudan baglama

## Sonraki En Dogal Isler

Bu nottan sonra en dogrudan uygulanabilir iki is:

1. World art upgrade'i mevcut builder ve SVG pipeline'ini bozmadan ikinci kalite dalgasina tasimak
2. Android release polish icin export, cihaz davranisi ve mobil UX kontrol listesini urunlesmek

## 10. Uygulama Gorev Listesi

Bu bolum, yukaridaki referans notunu dogrudan uygulanabilir backlog'a cevirir. Her gorev tek bir cikti, hedef dosya grubu ve dogrulama adimi ile takip edilmelidir.

Ana yurutme plani:

- `docs/EXECUTION_PACKAGES_PLAN.md`

### Gorev 1 - Ortak Safe-Area ve Content Frame Temeli

Durum: tamamlandi

Ilerleme notu:

- `scripts/gui_frame.gd` eklendi.
- `main_menu.gd`, `world_ui.gd` ve `hud_bar.gd` ayni safe-area helper'ina baglandi.

Amac:

- `main_menu`, `world HUD` ve sonraki overlay islerinde ayni inset hesabini kullanmak
- `gui_multiple_resolutions` notundaki ortak helper ihtiyacini gercek koda baglamak

Hedef dosyalar:

- `scripts/gui_frame.gd`
- `scripts/main_menu.gd`
- `scripts/world_ui.gd`
- `scripts/hud_bar.gd`

Uygulama adimlari:

1. Safe-area hesaplarini tek helper script'e tası.
2. `main_menu.gd` icindeki `SafeArea` offsetlerini bu helper'dan besle.
3. `world_ui.gd` ve `hud_bar.gd` icindeki ayni hesabı bu helper'a bagla.
4. Ayarlar paneli genisligini viewport yerine safe-area/content rect uzerinden sinirla.

Dogrulama:

1. Degisen scriptlerde parse hatasi olmamali.
2. Headless `--check-only` calismasi temiz donmeli.

Tamamlanma olcutu:

- Safe-area hesaplari tek yerden geliyor olmali.
- Menu ile world HUD ayni inset kurallarini kullaniyor olmali.

### Gorev 2 - Pseudo-Locale Capture Regression Modu

Durum: tamamlandi

Ilerleme notu:

- `tools/capture_character_ui.gd` icine `--pseudo` varyanti eklendi.
- `docs/UI_SCREENSHOT_CHECKLIST.md` normal ve pseudo capture komutlariyla guncellendi.
- `dialogue` yuzeyi icin pseudo smoke capture alindi.

Amac:

- Localization gelmeden once tasma ve okunurluk risklerini otomatik tekrar eden bir kontrole cevirmek

Hedef dosyalar:

- `tools/capture_character_ui.gd`
- `docs/UI_SCREENSHOT_CHECKLIST.md`
- gerekirse ilgili overlay scriptleri

Uygulama adimlari:

1. Normal capture yanina pseudo-locale varyanti ekle.
2. `prompt_label`, `body_label`, `continue_button`, `back_button`, `chapter_label` icin tasma kontrolu notu ekle.
3. Capture ciktilarini ayri klasor veya adlandirma ile ayir.

Dogrulama:

1. Capture script'i normal ve pseudo modda calisabilmeli.
2. Checklist yeni modu acikca anlatmali.

### Gorev 3 - UI Metinlerini Lokalizasyon Anahtarlarina Hazirlama

Durum: tamamlandi

Ilerleme notu:

- `scripts/ui_text.gd` ile anahtar + Turkce fallback katmani eklendi.
- `translations/ui_texts.csv` ve `project.godot` uzerinden ilk resmi Godot translation zinciri acildi.
- `main_menu`, `dialogue_overlay`, `decision_overlay` ve `info_card_overlay` icindeki sabit UI metinleri anahtar tabanli hale getirildi.
- `assets/data/questions.gd` icine key-or-raw event resolver eklendi; giris ve ilk Samsun event metinleri translation key'lerine tasindi, kalan event'ler ise ham fallback ile calismaya devam ediyor.
- `assets/data/questions.gd` artik key alanı yazilmamis event'ler icin de `story.event.%03d.<field>` adlandirmasini runtime'da uretiyor; boylece tum hikaye verisi tek-locale Turkce akis korunurken ayni key semasina baglandi.
- `world_zone.gd` icindeki karar geri bildirim basliklari, odul etiketleri ve ilgili goal kopyalari `ui_texts.csv` uzerinden tek kaynaga toplandi; bu degisiklik gercek coklu dil acmadan yalnizca metin kaynagini merkezilestiriyor.
- `tools/verify_questions_localization.gd` ile key'li eventler ve ham fallback eventler icin headless localization dogrulamasi eklendi.

Amac:

- `gui_translation` adimina gecmeden once sabit UI metinlerini anahtar tabanli yapıya hazirlamak

Hedef dosyalar:

- `scripts/main_menu.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`
- `scripts/decision_overlay.gd`
- yeni `translations/`

Uygulama adimlari:

1. Sabit menu ve overlay metinlerini `tr()` uyumlu anahtarlara tası.
2. Ilk locale dosyasini sadece UI yuzeyi icin ac.
3. Font fallback ihtiyaclarini not et.

Dogrulama:

1. Varsayilan Turkce akisi bozulmamali.
2. Pseudo-locale capture ile birlikte test edilebilmeli.

### Gorev 4 - Style Cache ve Gallery Temeli

Durum: tamamlandi

Ilerleme notu:

- `ui_style_factory.gd` icine panel ve button state cache'i eklendi.
- `dialogue`, `decision`, `info_card` ve `chapter_transition` overlay'leri adlandirilmis style varyantlarina gecirildi.
- Editor icinde acilabilen `scenes/ui_style_gallery.tscn` ve `scripts/ui_style_gallery.gd` eklendi.

Amac:

- `ui_style_factory.gd` tekrarini azaltmak ve overlay stillerini gorunur hale getirmek

Hedef dosyalar:

- `scripts/ui_style_factory.gd`
- `scripts/ui_tokens.gd`
- `scripts/colors.gd`
- gerekirse yeni `scenes/ui_style_gallery.tscn`

Uygulama adimlari:

1. Sik kullanilan panel ve button stilleri icin cache anahtarlari tanimla.
2. Overlay scriptlerini bu cache API'sine gecir.
3. Stil varyantlarini tek yerde gormek icin basit gallery scene ekle.

Dogrulama:

1. Stil degisiklikleri overlay davranisini bozmamali.
2. Gallery scene editor icinde acilabilmeli.

### Gorev 5 - Ortak Overlay Transition Sozlugu

Durum: tamamlandi

Ilerleme notu:

- `overlay_tween_helper.gd` icine ortak easing/sure presetleri ile `fade_color_alpha`, `fade_modulate_alpha`, `panel_pop_in`, `panel_pop_out` eklendi.
- `dialogue`, `decision`, `info_card`, `chapter_transition` ve `loading` overlay'lerinin giris/cikis animasyonlari ayni vocabulary uzerinden hizalandi.

Amac:

- `2d_tween` ve DOGWALK gecis referanslarini tek overlay API'sine cevirmek

Hedef dosyalar:

- `scripts/overlay_tween_helper.gd`
- `scripts/loading_overlay.gd`
- `scripts/chapter_transition_overlay.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/decision_overlay.gd`
- `scripts/info_card_overlay.gd`

Uygulama adimlari:

1. Ortak easing ve sure preset'leri ekle.
2. `fade_up`, `panel_pop`, `soft_backdrop` gibi pattern isimleri belirle.
3. Tam ekran gecisleri ayni temel vocabulary ile ac/kapat.

Dogrulama:

1. Overlay ac/kapat akislari iptal edilebilir kalmali.
2. Headless parse temiz kalmali.

### Gorev 6 - Metin Hiyerarsisi ve BBCode Sinirlari

Durum: tamamlandi

Ilerleme notu:

- `scripts/rich_text_utils.gd` ile diyalog ve bilgi karti metinleri icin dar whitelist tanimlandi: `b`, `i`, `u`, `color`, `br`.
- `dialogue_overlay.gd` artik BBCode girdisini sanitize edip reveal hizini parse edilmis metin uzunluguna gore hesapliyor.
- `info_card_overlay.tscn` ve `info_card_overlay.gd` `RichTextLabel` tabanina gecirildi; bilgi govdesi icin merkezli, guvenli rich text akisi olusturuldu.
- `tools/verify_rich_text_whitelist.gd` ile whitelist davranisi icin headless dogrulama eklendi.

Amac:

- `dialogue` ve `info_card` metinlerinde kontrollu zenginlestirme yapmak

Hedef dosyalar:

- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`
- `assets/data/questions.gd`

Uygulama adimlari:

1. Guvenli BBCode whitelist belirle.
2. Gerekirse `info_card` govdesini `RichTextLabel`e gecir.
3. Sadece egitsel vurgu gereken satirlarda yeni formatlari kullan.

Dogrulama:

1. Pseudo-locale ve normal akista tasma kontrolu yap.
2. Okunurluk 7-8 yas hedefiyle uyumlu kalmali.

### Gorev 7 - Focus Order ve Okunurluk Temeli

Durum: tamamlandi

Ilerleme notu:

- `scripts/ui_focus_helper.gd` ile menu ve overlay'ler icin tekrar kullanilabilir lineer focus helper eklendi.
- `main_menu.gd` varsayilan odagi baslat butonuna veriyor; ayarlar overlay'i BGM slider'ina odak aciyor ve kapaninca odagi `settings_button`a geri veriyor.
- `decision_overlay.gd` ve `info_card_overlay.gd` butonlari artik acik focus sirasi ve varsayilan secimle geliyor.
- `dialogue_overlay.gd` ve `info_card_overlay.gd` `ui_accept` ve `ui_cancel` akislarini klavye/gamepad dostu sekilde yorumluyor.
- `ui_tokens.gd` icine satir araligi tokenlari eklendi ve menu/overlay metinlerinde uygulandi.
- `tools/verify_ui_focus_accessibility.gd` ile headless focus ve input davranisi dogrulamasi eklendi.

Amac:

- `gui/accessibility` referansini dar ama uygulanabilir bir odak ve okunurluk tabanina cevirmek

Hedef dosyalar:

- `scripts/ui_focus_helper.gd`
- `scripts/ui_tokens.gd`
- `scripts/main_menu.gd`
- `scripts/decision_overlay.gd`
- `scripts/dialogue_overlay.gd`
- `scripts/info_card_overlay.gd`
- `tools/verify_ui_focus_accessibility.gd`

Uygulama adimlari:

1. Menu ve secim ekranlari icin varsayilan focus hedeflerini tanimla.
2. Overlay icindeki button/silder akislari icin lineer focus komsuluklarini standartlastir.
3. `ui_accept` ve `ui_cancel` davranisini dokunmatik disi girisler icin acikca tanimla.
4. Uzun metin yuzeylerinde minimum satir araligi tabanini token seviyesinde sabitle.

Dogrulama:

1. Headless focus verifier temiz donmeli.
2. En az bir UI smoke capture mevcut layout'u bozmadan alinabilmeli.

### Gorev 8 - Overlay Input ve Pause Sozlesmesi

Durum: tamamlandi

Ilerleme notu:

- `scripts/overlay_manager.gd` icine overlay bazli input contract tablosu eklendi: `blocks_world_input`, `closeable_on_cancel`, `process_mode`.
- `dialogue`, `info_card`, `decision`, `chapter_transition`, `exit_confirm` ve `loading` icin bloklayici/closeable beklentileri tek yerde tanimlandi.
- `register_overlay()` artik overlay node'larina bu merkezi `process_mode` beklentisini uyguluyor.
- `world_ui.gd` dunya input kilidini ve `ui_cancel` akisini `OverlayManager` contract'i uzerinden yorumluyor.
- `world.gd` geri tusu davranisini `WorldUI.handle_global_cancel()` uzerinden tek bir routing noktasina indirdi.
- `tools/verify_overlay_input_contract.gd` ile headless contract dogrulamasi eklendi.

Amac:

- `misc/pause` referansindaki overlay bloklama ve input kabul kurallarini tek merkezde tanimlamak

Hedef dosyalar:

- `scripts/overlay_manager.gd`
- `scripts/world_ui.gd`
- `scripts/world.gd`
- `tools/verify_overlay_input_contract.gd`

Uygulama adimlari:

1. Overlay tipleri icin bloklayici ve closeable sozlesmesini tabloya cek.
2. Overlay node `process_mode` beklentisini register aninda uygula.
3. Dunya `ui_cancel` akisini merkezi UI routing fonksiyonuna indir.
4. Kontrati headless verifier ile dogrula.

Dogrulama:

1. Overlay contract verifier temiz donmeli.
2. Standart `--check-only` parse gate yesil kalmali.

### Gorev 9 - Loading API Sozlesmesi

Durum: tamamlandi

Ilerleme notu:

- `scripts/loading_overlay.gd` artik yalniz `target_scene` degil, `entry_action`, `title`, `hint_text` alanlarini iceren tek tip bir loading request kabul ediyor.
- `main_menu.gd` icindeki `start` ve `continue` akislari dogrudan `change_scene_to_file()` yerine bu loading request uzerinden `LoadingOverlay`e baglandi.
- `world_ui.gd` artik ayni `LoadingOverlay` request API'sini `OverlayManager.OverlayType.LOADING` altinda kaydediyor; boylece world tarafindaki gelecekteki scene gecisleri ayni sozlesmeyi kullanabilecek.
- `world_zone.gd` icindeki prototype tamamlama akisi artik kaydi temizleyip ayni request API uzerinden ana menuye donus yapiyor; boylece world tarafinda da gercek bir scene transition bu sozlesmeyi kullaniyor.
- `SaveManager.pending_entry_action` artik menu butonunda degil, scene degisimine en yakin noktada `LoadingOverlay` tarafindan uygulanıyor.
- `scripts/loading_overlay.gd` sahne gecisini artik `ResourceLoader.load_threaded_request()` + `load_threaded_get_status()` + `load_threaded_get()` zinciriyle onceden yukleyip `change_scene_to_packed()` uzerinden tamamliyor.
- `tools/verify_loading_api_contract.gd` artik request staging, `entry_action` aktarimi ve threaded preload akisina odakli temiz bir headless verifier.
- `tools/verify_loading_world_integration.gd` ise `WorldUI` icindeki loading overlay kaydi ile prototype completion -> main menu callback'ini ayri bir headless integration verifier olarak dogruluyor.

Amac:

- `loading/scene_changer` ve `loading/load_threaded` referanslarina gecmeden once scene gecisleri icin tek tip request contract olusturmak

Hedef dosyalar:

- `scripts/loading_overlay.gd`
- `scripts/main_menu.gd`
- `tools/verify_loading_api_contract.gd`
- `tools/verify_loading_world_integration.gd`

Uygulama adimlari:

1. `LoadingOverlay` icin tek tip request alanlarini tanimla.
2. Menu `start` ve `continue` akisini bu request ile ayni API'ye gecir.
3. `pending_entry_action` aktarimini scene degisimine en yakin yerde uygula.
4. Request contract'ini headless verifier ile dogrula.
5. World tarafindaki ilk gercek scene transition'i ayni request API'ye bagla.
6. `LoadingOverlay` icindeki sahne gecisini threaded preload tabanina tası.

Dogrulama:

1. Loading contract verifier temiz donmeli.
2. Standart `--check-only` parse gate yesil kalmali.

### Gorev 10 - World Art Upgrade Pass

Durum: backlog

Ilerleme notu:

- Mevcut 9 bolge builder ve SVG pipeline'i oynanabilir prototip kalitesinde hazir.
- Bundan sonraki is, mimariyi degistirmeden gorsel kaliteyi ikinci dalgaya tasimak.

Amac:

- `Phase 6.5` hedefindeki paper diorama kalite seviyesini mevcut zone akisini bozmadan gercek bir production pass'e cevirmek
- `GodSVG` ve resmi demo referanslarini runtime'a degil asset pipeline ve layout kararlarina tasimak

Hedef dosyalar:

- `scripts/world_builder.gd`
- `scripts/world.gd`
- `scripts/world_ui.gd`
- `scripts/colors.gd`
- `scripts/ui_tokens.gd`
- `assets/art/`
- `assets/backgrounds/`
- `artworks/`
- gerekirse yeni `docs/WORLD_ART_UPGRADE_PLAN.md`

Uygulama adimlari:

1. Her zone icin mevcut builder ciktisini referans screenshot'larla envanterle: siluet, zemin, landmark, foreground ve path katmanlarini ayir.
2. `Bandirma`, `Samsun`, `Ankara`, `Sakarya` ve `Final` icin birinci oncelikli replacement listesi cikar; hangi asset kalacak, hangisi yeniden cizilecek netlestir.
3. SVG import ve olcek kurallarini standartlastir; outline kalinligi, golge yogunlugu ve renk paletini zone bazli degil token bazli hizala.
4. `world_builder.gd` icindeki landmark, prop cluster ve strategy node kompozisyonlarini yeni asset oranlarina gore duzenle.
5. Karakter ve companion siluetlerinin yeni arka planlarla kontrastini yeniden ayarla; gerekirse `colors.gd` ve `ui_tokens.gd` uzerinden vurgu degerlerini guncelle.
6. Her buyuk art replacement sonrasinda `menu`, `dialogue`, `decision`, `info_card`, `chapter_transition` ve `completion` capture'lari ile gorsel regresyonu tekrar kontrol et.

Dogrulama:

1. Degisen asset ve script'lerle standart `--headless --check-only --path . --quit` temiz donmeli.
2. UI visual regression capture'lari yeni world art ile okunurlugu bozmadigini gostermeli.
3. En az bir zone icin once/sonra screenshot seti `artifacts/renders/` altinda karsilastirilabilir olmali.

Tamamlanma olcutu:

- En az kritik 5 zone'da prototip asset gorunumu yerine daha tutarli paper-diorama production kompozisyonu kullaniliyor olmali.
- Builder kodu yeni asset oranlariyla stabil calismali; event, marker ve player routing bozulmamis olmali.

Sprint/task kartlari:

1. Kart A - World art audit ve hedef kalite panosu
	Cikti: Zone bazli referans screenshot envanteri, replacement oncelik listesi, art direction notlari.
	Kapsam: `artworks/`, `artifacts/renders/`, gerekirse yeni `docs/WORLD_ART_UPGRADE_PLAN.md`.
	Tamamlanma sinyali: Bandirma, Samsun, Ankara, Sakarya ve Final icin once/sonra hedefleri acik yazilmis olmali.
2. Kart B - Asset pipeline standardizasyonu
	Cikti: SVG import olcekleri, outline/golge standartlari ve renk kontrast notlari.
	Kapsam: `assets/art/`, `assets/backgrounds/`, `scripts/colors.gd`, `scripts/ui_tokens.gd`.
	Tamamlanma sinyali: Yeni art uretimi icin tekrar kullanilabilir teknik kurallar dokumante edilmis olmali.
3. Kart C - Pilot zone replacement
	Cikti: Tek bir zone'da tam production-pass art degisimi.
	Kapsam: once `Bandirma` veya `Samsun`; `scripts/world_builder.gd` kompozisyon guncellemeleri dahil.
	Tamamlanma sinyali: Bir zone hem oyunda hem capture'larda yeni kalite seviyesiyle calisiyor olmali.
4. Kart D - Builder kompozisyon uyarlama dalgasi
	Cikti: Landmark, prop cluster ve strategy node yerlestirmelerinin yeni asset oranlarina gore yeniden ayarlanmasi.
	Kapsam: `scripts/world_builder.gd`, gerekirse `scripts/world.gd`, `scripts/world_ui.gd`.
	Tamamlanma sinyali: Marker, player ve overlay routing yeni art ile cakismadan calismali.
5. Kart E - Kontrast ve okunurluk kalibrasyonu
	Cikti: Karakter, companion ve UI vurgu renklerinin arka planla yeniden dengelenmesi.
	Kapsam: `scripts/colors.gd`, `scripts/ui_tokens.gd`, capture checklist'i.
	Tamamlanma sinyali: Yeni art pass sonrasi UI katmanlari ve karakterler okunakli kalmali.
6. Kart F - Regression ve kabul paketi
	Cikti: Once/sonra capture seti, UI regression sonucu ve kabul notu.
	Kapsam: `artifacts/renders/`, `docs/UI_SCREENSHOT_CHECKLIST.md`, mevcut visual regression runner.
	Tamamlanma sinyali: Art pass kabulunun tekrar edilebilir bir kontrol paketi olusmali.

Onceliklendirme, efor ve bagimlilik:

| Kart | Oncelik | Tahmini efor | Bagimlilik | Not |
|------|---------|--------------|------------|-----|
| Kart A | P0 | S | Yok | Tum art kararlarinin giris kapisi; dogrudan baslanabilir. |
| Kart B | P0 | S-M | Kart A | Yeni SVG ve kompozisyon kararlarinin teknik standardini sabitler. |
| Kart C | P1 | M-L | Kart A, Kart B | Ilk gercek zone replacement; risk ve kalite farki burada gorunur. |
| Kart D | P1 | M | Kart C | Pilot zone dersleri cikmadan butun builder kompozisyonuna yaymak riskli. |
| Kart E | P1 | S-M | Kart C | Kontrast ayari yeni art gorulmeden saglikli yapilamaz. |
| Kart F | P2 | S | Kart C, Kart D, Kart E | Kabul ve regression paketi en sona yakin anlam kazanir. |

Onerilen sira:

1. Kart A
2. Kart B
3. Kart C
4. Kart E
5. Kart D
6. Kart F

Kisa gerekce:

- Ilk iki kart karar ve teknik standart uretir; kod degisikligine erken girmeyi engeller.
- Pilot zone replacement, tum zone'lara yayilmadan once kalite/caba oranini gosterir.
- Kontrast kalibrasyonu pilot sonucunu gorunce daha az tekrar uretir.
- Regression ve kabul paketi en sonda daha degerli hale gelir.

Hazir issue/task taslaklari:

#### Issue 10A - World Art Audit ve Hedef Kalite Panosu

Calisma dosyasi:

- `docs/WORLD_ART_UPGRADE_PLAN.md`

Amac:

- Kritik 5 zone icin mevcut gorunumu, hedef kalite referansini ve replacement risklerini tek yerde toplamak.

Kapsam:

- `artworks/`
- `artifacts/renders/`
- mevcut zone capture'lari ve referans moodboard notlari
- gerekirse yeni `docs/WORLD_ART_UPGRADE_PLAN.md`

Yapilacaklar:

1. `Bandirma`, `Samsun`, `Ankara`, `Sakarya` ve `Final` icin mevcut screenshot setlerini topla.
2. Her zone icin `kalacak`, `yenilenecek`, `yeniden kompoze edilecek` katmanlari ayir.
3. Referans kalite notlarini kisa maddelere indir: siluet, zemin, landmark, foreground, renk hissi.
4. En riskli gorsel uyumsuzluklari yaz: kontrast, oran, bosluk, okunurluk, marker cakismasi.

Teslimatlar:

- Zone bazli audit tablosu
- Oncelikli replacement listesi
- Hedef kalite panosu veya yazili art-direction notu

Kabul kriterleri:

- Kritik 5 zone icin hangi asset veya kompozisyonun neden degisecegi acikca yazilmali.
- Pilot zone secimi gerekcesiyle birlikte belirlenmis olmali.

Dis kapsam:

- Bu issue yeni asset cizimi veya builder kod degisikligi yapmaz.

#### Issue 10B - Asset Pipeline Standardizasyonu

Amac:

- World art upgrade dalgasi icin tekrar kullanilabilir SVG, kontrast ve kompozisyon kurallarini sabitlemek.

Kapsam:

- `assets/art/`
- `assets/backgrounds/`
- `scripts/colors.gd`
- `scripts/ui_tokens.gd`
- varsa import/olcek notlari

Yapilacaklar:

1. SVG import olcek, outline ve opaklik beklentilerini yazili hale getir.
2. Zone'lar arasi ortak renk ve golge kurallarini mevcut token yapisiyla eslestir.
3. Character/companion/UI kontrastini etkileyen kritik renkleri listele.
4. Yeni asset geldikce uygulanacak adimlari kisa bir pipeline haline getir.

Teslimatlar:

- Teknik art pipeline notu
- Guncellenmis token/renk karar listesi
- Yeni asset entegrasyonu icin kisa uygulama akisi

Kabul kriterleri:

- Yeni bir artist veya gelistirici tek belgeye bakip asset entegrasyon kurallarini anlayabilmeli.
- Outline, golge, kontrast ve oran kararlarinin hangi dosyada kontrol edildigi net olmali.

Dis kapsam:

- Bu issue tek basina pilot zone replacement yapmaz.

P2 cikisi - teknik standardizasyon v1:

Bu issue artik yalnizca backlog notu degil; `P2` icin uygulanacak teknik kararlar asagida sabitlenmistir.

##### Sahiplik haritasi

| Karar | Sahip dosya | Not |
|------|-------------|-----|
| world palette ve zone tema aileleri | `scripts/colors.gd` | `POP_*`, `ART_*`, `SHADOW_*`, `THEME_*` |
| UI border, spacing, safe area, okunurluk boyutlari | `scripts/ui_tokens.gd` | `BORDER_*`, `SPACE_*`, `SAFE_AREA_*`, `FONT_*` |
| pilot sirasi ve zone riskleri | `docs/WORLD_ART_UPGRADE_PLAN.md` | Bandirma pilot, Samsun ikinci dalga |
| stil ve teknik sozlesme | `docs/VISUAL_DESIGN_SYSTEM.md` | `World Art Technical Contract` bolumu |

##### Sabit teknik kararlar

1. Yeni world art asset'leri `assets/art/` altinda tek master kaynak mantigiyla tutulur; capture PNG'leri kaynak asset yerine gecmez.
2. SVG oranlari dosya icinde korunur; tekrar oran yazmak yerine builder tarafinda olcek uygulanir.
3. Landmark ve foreground asset'leri koyu outline kullanir; arka plan kitleleri ayni agirlikta outline kullanmaz.
4. Paper diorama hissi icin 2-4 fill katmani ve en fazla bir shadow plate hedeflenir.
5. Yeni SVG preload akisa giriyorsa `.svg.import` dosyasi ile birlikte teslim edilir ve `--headless --import --path .` calistirilir.
6. Parse guvenligi her asset dalgasindan sonra `--headless --check-only --path . --quit` ile kontrol edilir.

##### Renk ve kontrast karar listesi

- Bandirma ve benzeri sicak deniz/seyahat bolgeleri `THEME_BANDIRMA` ailesine bagli kalir.
- Rift ve zaman-enerjisi odakli bolgeler `THEME_SAMSUN` ile calisir; `RIFT_BLUE` yalnizca rift/dream vurgu icin kullanilir.
- Town/civic bolgeler `THEME_TOWN` panel ve toprak tonlarina dayanir.
- Kongre, savas ve final agirliki tasiyan bolgeler `THEME_CONGRESS`, `ART_WAR_NAVY`, `ART_CRIMSON_BROWN`, `ART_CHESTNUT` etrafinda standardize edilir.
- UI ve karakter okunurlugu icin metin/ikon tarafinda varsayilan koyu ton `DESIGN_STORY_INK` olarak kalir.
- `POP_CRIMSON` ile `POP_GOLD` ayni odakta esit agirlikta kullanilmaz; biri ana vurgu, digeri ikincil vurgu olur.

##### Kisa pipeline akisi

1. Zone audit hedefini oku.
2. `scripts/colors.gd` icinden tema/token ailesini sec.
3. Asset'i paper-diorama rol modeliyle uret veya guncelle.
4. Import metadata'sini kontrol et.
5. Import ve parse dogrulamasini kos.
6. Capture al ve audit hedefiyle karsilastir.

##### P3 giris kosulu netlestirme

`P3` ancak su durumda baslar:

- pilot zone `Bandirma` olarak korunuyorsa,
- kullanilacak renk/token ailesi onceden secilmisse,
- outline/import/kontrast kurallari bu issue'dan okunabiliyorsa,
- capture once/sonra karsilastirma noktasi belli ise.

### Gorev 11 - Android Release Polish

Durum: backlog

Ilerleme notu:

- Android debug APK uretilmis durumda; artik odak teknik olarak export almaktan release davranisini sertlestirmeye kaymali.
- `System Bar Color Changer` ve ilgili official demo referanslari bu asamada yardimci olabilir, fakat cekirdek oyun mimarisini degistirmemeli.

Amac:

- Mevcut portrait Android build'i MVP debug seviyesinden daha guvenli bir release adimina tasimak
- Mobil UX, export ayarlari, performans ve cihaz-ustu davranis icin acik bir polish backlog'u olusturmak

Hedef dosyalar:

- `project.godot`
- `export_presets.cfg`
- `scripts/main_menu.gd`
- `scripts/world_ui.gd`
- `scripts/loading_overlay.gd`
- `scripts/exit_confirm_overlay.gd`
- `scripts/audio_manager.gd`
- `docs/UI_SCREENSHOT_CHECKLIST.md`
- gerekirse yeni `docs/ANDROID_RELEASE_CHECKLIST.md`

Uygulama adimlari:

1. Android export ayarlarini gozden gecir: orientation, package metadata, splash, icon, permissions ve texture compression secimlerini belgeye bagla.
2. Mobilde kritik akislari smoke-test listesine cevir: ilk acilis, start, continue, zone transition, exit confirm, app background/foreground donusu ve ses slider davranisi.
3. Safe-area ve sistem cubugu davranisini menu ile world overlay'lerinde gozden gecir; gerekiyorsa Android system bar rengi ve immersive davranisi icin dar bir entegrasyon katmani ekle.
4. Dusuk ve orta seviye cihazlar icin performans checklist'i olustur: yukleme bekleme suresi, frame drop gozlemi, buyuk overlay acilislarinda input gecikmesi.
5. Release oncesi save/load, first-run settings ve geri tusu davranisini cihaz-ustu smoke-test haline getir.
6. Export alinabilir tek bir release checklist'i tanimla; debug APK ile release APK arasinda fark yaratan ayarlari netlestir.

Dogrulama:

1. `--headless --check-only --path . --quit` ve mevcut headless verifier seti yesil kalmali.
2. En az bir fiziksel Android cihaz veya emulatorde acilis, menuden dunyaya gecis ve geri tusu smoke testi yapilmis olmali.
3. Export checklist'i izlenerek yeni APK tekrar uretilip acilabilmeli.

Tamamlanma olcutu:

- Android release davranisi yalniz "APK aliniyor" seviyesinde degil, tekrar edilebilir smoke-test ve export checklist'i ile dokumante edilmis olmali.
- Portrait mobil UX'te kritik bloklayici sorun kalmamali: safe-area, geri tusu, loading, ses ve temel navigation akislari stabil olmali.

Sprint/task kartlari:

1. Kart A - Export config audit
	Cikti: Android export metadata, icon, splash, permissions ve compression karar listesi.
	Kapsam: `project.godot`, `export_presets.cfg`.
	Tamamlanma sinyali: Debug ve release export farklari yazili hale gelmis olmali.
2. Kart B - Mobil UX smoke checklist
	Cikti: Start, continue, loading, exit confirm, save/load ve ses ayarlari icin cihaz-ustu test adimlari.
	Kapsam: yeni `docs/ANDROID_RELEASE_CHECKLIST.md`, gerekirse `docs/UI_SCREENSHOT_CHECKLIST.md`.
	Tamamlanma sinyali: Tekrar edilebilir Android smoke testi tek yerden okunabilir olmali.
3. Kart C - Safe-area ve system bar polish
	Cikti: Menu ve world tarafinda system bar/safe-area davranisinin netlestirilmesi.
	Kapsam: `scripts/main_menu.gd`, `scripts/world_ui.gd`, gerekirse Android system bar entegrasyonu.
	Tamamlanma sinyali: Portrait cihazlarda ust/alt alan ve sistem cubugu davranisi tutarli olmali.
4. Kart D - Navigation ve app lifecycle sertlestirme
	Cikti: Back button, background/foreground donusu ve first-run settings akislarinin sabitlenmesi.
	Kapsam: `scripts/loading_overlay.gd`, `scripts/exit_confirm_overlay.gd`, `scripts/audio_manager.gd`, `scripts/world_ui.gd`.
	Tamamlanma sinyali: Uygulama lifecycle kaynakli bloklayici navigation sorunu kalmamali.
5. Kart E - Performans ve cihaz gozlemi
	Cikti: Dusuk/orta seviye cihaz notlari, yukleme suresi ve input gecikmesi gozlemleri.
	Kapsam: cihaz smoke test raporu, gerekirse loading ve overlay script ayarlari.
	Tamamlanma sinyali: Release oncesi en az bir cihaz profili icin performans riski yazili hale gelmis olmali.
6. Kart F - Release candidate checklist ve APK dogrulamasi
	Cikti: Tekrar edilebilir release checklist'i ve yeniden uretilmis APK smoke sonucu.
	Kapsam: `export_presets.cfg`, yeni release checklist dokumani, final APK notlari.
	Tamamlanma sinyali: "yeniden build et, kur, ac, test et" akisi belgeyle birebir takip edilebilir olmali.

Onceliklendirme, efor ve bagimlilik:

| Kart | Oncelik | Tahmini efor | Bagimlilik | Not |
|------|---------|--------------|------------|-----|
| Kart A | P0 | S | Yok | Release hedefinin teknik cercevesini netlestirir. |
| Kart B | P0 | S | Kart A | Ne test edilecegi netlesmeden cihaz smoke sureci daginik kalir. |
| Kart C | P1 | M | Kart A | Export ve UX kararlarina gore safe-area/system bar duzeltmeleri sekillenir. |
| Kart D | P1 | M | Kart B | Lifecycle ve navigation sorunlari smoke checklist ile daha gorunur olur. |
| Kart E | P1 | S-M | Kart B, Kart D | Performans gozlemi once kritik navigation akisi sabitlenince daha anlamli olur. |
| Kart F | P2 | S | Kart A, Kart B, Kart C, Kart D | Release candidate paketi en sonda toplu dogrulama icin gerekir. |

Onerilen sira:

1. Kart A
2. Kart B
3. Kart C
4. Kart D
5. Kart E
6. Kart F

Kisa gerekce:

- Ilk iki kart release calismasini belirsizlikten cikartir ve test yuzeyini sabitler.
- Safe-area/system bar polish, export ve smoke hedefleri tanimlanmadan erken optimize edilmemeli.
- Navigation ve lifecycle sertlestirme, cihaz-ustu bloklayici bug riskini en hizli dusuren karttir.
- Release candidate checklist ancak onceki kartlar kapandiginda gercek deger uretir.

Hazir issue/task taslaklari:

#### Issue 11A - Export Config Audit

Amac:

- Android release icin hangi export ayarlarinin zorunlu, hangilerinin opsiyonel oldugunu netlestirmek.

Kapsam:

- `project.godot`
- `export_presets.cfg`
- mevcut Android package/export metadata bilgileri

Yapilacaklar:

1. Orientation, package name, versioning, icon, splash ve permission alanlarini gozden gecir.
2. Debug ve release export farklarini tabloya dok.
3. Texture compression, install size ve build secenekleri icin mevcut karari yaz.
4. Eksik veya belirsiz export ayarlarini backlog maddesine cevir.

Teslimatlar:

- Export config audit tablosu
- Eksik alanlar listesi
- Release icin gerekli minimum export ayarlari listesi

Kabul kriterleri:

- Bir kisi sadece audit ciktisina bakarak export tarafinda neyin eksik oldugunu gorebilmeli.
- Debug ve release davranisini etkileyen ayarlar ayri ayri listelenmis olmali.

Dis kapsam:

- Bu issue cihaz-ustu smoke test veya UI polish yapmaz.

Cikis dosyasi:

- `docs/ANDROID_EXPORT_AUDIT.md`

P7 sonucu:

- Android export audit tamamlandi.
- Debug build ile release build arasindaki ana farkin signing ve operasyonel checklist eksigi oldugu yazili hale getirildi.
- P8, P9 ve P12 icin teknik giris riskleri tek belgeye indirildi.

#### Issue 11B - Mobil UX Smoke Checklist

Amac:

- Android cihaz veya emulator uzerinde tekrar edilebilir temel UX smoke testi olusturmak.

Kapsam:

- yeni `docs/ANDROID_RELEASE_CHECKLIST.md`
- gerekirse `docs/UI_SCREENSHOT_CHECKLIST.md`
- `start`, `continue`, `loading`, `exit confirm`, `save/load`, `settings` akislari

Yapilacaklar:

1. Kritik mobil akislari test adimlari olarak listele.
2. Beklenen sonuc, hata semptomu ve not alani formatini belirle.
3. Back button, background/foreground donusu ve ses slider davranisini checklist'e ekle.
4. Checklist'i debug APK ile bir kez kuru kosu mantiginda dogrula.

Teslimatlar:

- Android smoke checklist dokumani
- Kritik akislari kapsayan test adim listesi

Kabul kriterleri:

- Baska bir kisi checklist'i izleyerek temel mobil UX smoke testini tekrar edebilmeli.
- Start, continue ve exit confirm gibi ana akislardan hicbiri checklist disinda kalmamis olmali.

Dis kapsam:

- Bu issue tek basina system bar polish veya performans optimizasyonu yapmaz.

Cikis dosyasi:

- `docs/ANDROID_RELEASE_CHECKLIST.md`

P8 sonucu:

- Android smoke checklist tamamlandi.
- Start, continue, loading, exit confirm, settings, ses ve lifecycle yuzeyleri tek matriste toplandi.
- P9 ve P10 icin hangi notlarin aktarilacagi checklist sonunda netlestirildi.

P9 ilk uygulama notu:

- `loading_overlay.gd` ve `exit_confirm_overlay.gd` ilk safe-area uyarlama slice'inda `GUIFrame` ile viewport insetlerine baglandi.
- `dialogue_overlay.gd` de ayni safe-area kontratina baglandi ve dar portrait capture ile ilk dogrulama alindi.
- Dialogue overlay'in portre, glow ve stage-light katmani da panel ile ayni safe-area rect'e gore yeniden yerlestirildi ve capture yenilendi.
- Dialogue overlay icin `1080x1920` portrait capture da alindi; gorsel sonuc beklenen yone giderken tam UI regression suite accepted baseline'lar safe-area onceki yerlesiminde kaldigi icin kirmiziya dustu.
- `artifacts/renders/ui_regression_current/` seti accepted baseline olarak `artifacts/renders/ui_checklist/` altina yenilenince tam UI regression suite yeniden yesile dondu; safe-area slice'i artik regression acisindan stabilize edildi.
- Sonraki adim cihaz-ustu veya hedef capture davranisi ile diger overlay yuzeylerinin ayni kontrata uydugunu teyit etmek.

P10 ilk uygulama notu:

- `world.gd` application pause/focus-out aldiginda `WorldUI.persist_runtime_state()` uzerinden autosave yapip exit-confirm gibi gecici overlay'leri temizliyor.
- `main_menu.gd` pause/focus-out sirasinda settings ve exit-confirm overlay'lerini kapatiyor; resume'da continue butonu durumu ve layout yeniden senkronlaniyor.
- `audio_manager.gd` icine eklenen app-pause kontrati ile world/menu lifecycle verifier'i (`tools/verify_app_lifecycle_contract.gd`) yesil dondu.
- Ikinci P10 slice'inda menu dream-intro gecisi app background olursa iptal edilip butonlar tekrar etkinlestiriliyor; verifier bu yarim-transition durumunu da kapsiyor.