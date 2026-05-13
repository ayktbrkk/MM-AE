# UI Screenshot Checklist

Bu checklist, Faz 5 / 17.1 kapsaminda ana UI yuzeylerinin ekran goruntusu ile hizli regresyon kontrolu icin kullanilir.

## Hedef Yuzeyler

1. Ana menu
2. Diyalog overlay
3. Karar overlay
4. Bilgi karti overlay
5. Chapter transition overlay
6. Prototype tamamlanma karti

## Capture Komutlari

Asagidaki komutlar proje kokunden calistirilir:

```powershell
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface menu --size 1080x1920 --output res://artifacts/renders/ui_checklist/menu_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface dialogue --size 1080x1920 --output res://artifacts/renders/ui_checklist/dialogue_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface decision --size 1080x1920 --output res://artifacts/renders/ui_checklist/decision_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface info_card --size 1080x1920 --output res://artifacts/renders/ui_checklist/info_card_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface chapter_transition --size 1080x1920 --output res://artifacts/renders/ui_checklist/chapter_transition_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface completion --size 1080x1920 --output res://artifacts/renders/ui_checklist/completion_1080x1920.png
```

Pseudo-locale stres varyanti icin ayni komutlara `--pseudo` eklenir. Onerilen cikti klasoru `res://artifacts/renders/ui_checklist/pseudo/` altidir.

```powershell
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface menu --pseudo --size 1080x1920 --output res://artifacts/renders/ui_checklist/pseudo/menu_1080x1920_pseudo.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface dialogue --pseudo --size 1080x1920 --output res://artifacts/renders/ui_checklist/pseudo/dialogue_1080x1920_pseudo.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface decision --pseudo --size 1080x1920 --output res://artifacts/renders/ui_checklist/pseudo/decision_1080x1920_pseudo.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface info_card --pseudo --size 1080x1920 --output res://artifacts/renders/ui_checklist/pseudo/info_card_1080x1920_pseudo.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface chapter_transition --pseudo --size 1080x1920 --output res://artifacts/renders/ui_checklist/pseudo/chapter_transition_1080x1920_pseudo.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface completion --pseudo --size 1080x1920 --output res://artifacts/renders/ui_checklist/pseudo/completion_1080x1920_pseudo.png
```

## Kontrol Noktalari

### 1. Ana menu
- Baslik ve alt baslik ust bolgede tasmadan okunuyor mu?
- Birincil butonlar ekranin altinda kirpilmadan ve ayni hizada mi?
- Safe-area marginleri sol/sag/alt kenarlarda dengeli mi?

### 2. Diyalog overlay
- Portreler, stage light ve panel birbirine tasmadan gorunuyor mu?
- Metin blogu ve devam satiri alt bolgede rahat okunuyor mu?
- Continue satiri alt safe-area icinde kaliyor mu?
- Pseudo-locale modunda govde metni panel icinde kirpilmadan kaliyor mu?

### 3. Karar overlay
- Iki secenek butonu ayni genislik ve yeterli yukseklikte mi?
- Karakter kartlari ile secenek satiri arasinda carpisma var mi?
- Prompt ve baslik satirlari 1080x1920 dikey yuzeyde tasiyor mu?
- Pseudo-locale modunda `chapter`, `title` ve iki secenek metni satir tasmasi uretmeden okunuyor mu?

### 4. Bilgi karti overlay
- Baslik, govde metni, odul satiri ve aksiyon satiri tek ekran icinde kaliyor mu?
- Kapat ve Devam Et butonlari rahat secilebilir boyutta mi?
- Ikon/cerceve/govde metni arasinda ust uste binme var mi?
- Pseudo-locale modunda `body_label`, `back_button` ve `continue_button` satirlari panel yuksekligini bozuyor mu?

### 5. Chapter transition overlay
- Baslik, alt baslik ve progress satiri panel icinde ortali ve kirpilmamis mi?
- Route dot ve line elemanlari paneli bozmayacak sekilde ayri kaliyor mu?
- Fade sirasinda okunurluk kaybi veya ust uste binen katman problemi var mi?
- Pseudo-locale modunda `chapter_label` ve progress satiri tek panel icinde kaliyor mu?

### 6. Prototype tamamlanma karti
- Kapanis karti ekranda tek baskin yuzey olarak gorunuyor mu?
- `Ana menüye dön` aksiyon satiri rahat okunuyor ve kirpilmiyor mu?
- Objective satiri ile kart arasinda carpisma ya da tasma var mi?
- Pseudo-locale modunda kapanis metni ve aksiyon satiri panel yuksekligini bozmadan sigiyor mu?

## Uygulama Notu

- `capture_character_ui.gd` bu projede headless yerine normal Godot kosumu ile kullanilmalidir.
- `--pseudo` bayragi, capture sirasinda Godot'un `TranslationServer.pseudolocalize()` akisina dayali ikinci bir stres varyanti uretir.
- Bu checklist bir kabul kapisidir; 17.2 ve 17.3 icin ayni PNG'ler hit area, crop/overlap ve geri tusu/stack kontrollerinin gorsel referansi olarak kullanilir.

## Otomatik Regression Komutu

Checklist PNG'lerini baseline kabul edip yeni capture seti ile otomatik diff almak icin:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\run_ui_visual_regression.ps1
```

Bu komut:

- yeni capture setini `artifacts/renders/ui_regression_current/` altina uretir
- baseline olarak `artifacts/renders/ui_checklist/` altindaki PNG'leri kullanir
- piksel diff ciktisini `artifacts/renders/ui_regression_diffs/` altina yazar
- oran esigi ve kanal delta esigi asilirsa hata ile cikar