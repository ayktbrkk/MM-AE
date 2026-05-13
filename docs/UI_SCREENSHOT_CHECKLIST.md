# UI Screenshot Checklist

Bu checklist, Faz 5 / 17.1 kapsaminda ana UI yuzeylerinin ekran goruntusu ile hizli regresyon kontrolu icin kullanilir.

## Hedef Yuzeyler

1. Ana menu
2. Diyalog overlay
3. Karar overlay
4. Bilgi karti overlay
5. Chapter transition overlay

## Capture Komutlari

Asagidaki komutlar proje kokunden calistirilir:

```powershell
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface menu --size 1080x1920 --output res://artifacts/renders/ui_checklist/menu_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface dialogue --size 1080x1920 --output res://artifacts/renders/ui_checklist/dialogue_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface decision --size 1080x1920 --output res://artifacts/renders/ui_checklist/decision_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface info_card --size 1080x1920 --output res://artifacts/renders/ui_checklist/info_card_1080x1920.png
C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/capture_character_ui.gd -- --surface chapter_transition --size 1080x1920 --output res://artifacts/renders/ui_checklist/chapter_transition_1080x1920.png
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

### 3. Karar overlay
- Iki secenek butonu ayni genislik ve yeterli yukseklikte mi?
- Karakter kartlari ile secenek satiri arasinda carpisma var mi?
- Prompt ve baslik satirlari 1080x1920 dikey yuzeyde tasiyor mu?

### 4. Bilgi karti overlay
- Baslik, govde metni, odul satiri ve aksiyon satiri tek ekran icinde kaliyor mu?
- Kapat ve Devam Et butonlari rahat secilebilir boyutta mi?
- Ikon/cerceve/govde metni arasinda ust uste binme var mi?

### 5. Chapter transition overlay
- Baslik, alt baslik ve progress satiri panel icinde ortali ve kirpilmamis mi?
- Route dot ve line elemanlari paneli bozmayacak sekilde ayri kaliyor mu?
- Fade sirasinda okunurluk kaybi veya ust uste binen katman problemi var mi?

## Uygulama Notu

- `capture_character_ui.gd` bu projede headless yerine normal Godot kosumu ile kullanilmalidir.
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