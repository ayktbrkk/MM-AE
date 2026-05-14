# World Art Upgrade Plan

Bu belge, [docs/GODOT_OFFICIAL_DEMO_ADAPTATION.md](c:/Users/Aykut/Documents/Godot/mmae/docs/GODOT_OFFICIAL_DEMO_ADAPTATION.md) icindeki `Issue 10A - World Art Audit ve Hedef Kalite Panosu` icin dogrudan uygulanabilir calisma dosyasidir.

## Durum

Durum: ilk tur audit tamamlandi
Oncelik: P0
Tahmini efor: S
Bagimlilik: yok

## Amac

- Kritik 5 zone icin mevcut world art kalitesini tek yerde envanterlemek.
- Pilot zone replacement oncesi gorsel kalite hedefini netlestirmek.
- Sonraki art replacement islerinde kullanilacak kabul dilini sabitlemek.

## Kapsam

- `Bandirma`
- `Samsun`
- `Ankara`
- `Sakarya`
- `Final`
- `artworks/` referanslari
- `artifacts/renders/` capture ciktilari
- ilgili builder kompozisyon notlari

## Dis Kapsam

- Bu belge yeni asset cizimi yapmaz.
- Bu belge dogrudan `world_builder.gd` degisikligi yapmaz.
- Bu belge tek basina renk token guncellemesi veya SVG import standardi karari kapatmaz; onlar `Issue 10B` altina gider.

## Teslimatlar

- Zone bazli audit tablosu
- Pilot zone onerisi ve gerekcesi
- `kalacak / yenilenecek / yeniden kompoze edilecek` listesi
- Hedef kalite dili ve kabul notlari

## Kabul Kriterleri

- Kritik 5 zone icin hangi katmanin neden degisecegi yazili olmali.
- Pilot zone secimi acik bir gerekceyle belirlenmis olmali.
- En az bir once/sonra capture stratejisi tanimlanmis olmali.
- Sonraki `Issue 10B` ve `Kart C` calismalari bu belgeye bakarak baslayabilmeli.

## Referanslar

- [docs/ROADMAP.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ROADMAP.md)
- [docs/GODOT_OFFICIAL_DEMO_ADAPTATION.md](c:/Users/Aykut/Documents/Godot/mmae/docs/GODOT_OFFICIAL_DEMO_ADAPTATION.md)
- [docs/ART_WORLD_ROADMAP.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ART_WORLD_ROADMAP.md)
- [docs/ART_ANALYSIS.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ART_ANALYSIS.md)
- [docs/VISUAL_DESIGN_SYSTEM.md](c:/Users/Aykut/Documents/Godot/mmae/docs/VISUAL_DESIGN_SYSTEM.md)
- [docs/UI_SCREENSHOT_CHECKLIST.md](c:/Users/Aykut/Documents/Godot/mmae/docs/UI_SCREENSHOT_CHECKLIST.md)

## Calisma Akisi

1. Mevcut capture ve referanslari topla.
2. Her zone icin katman envanteri cikar.
3. Sorunlari ortak basliklarda isaretle: oran, kontrast, kompozisyon, okunurluk, tarihsel ton.
4. Pilot zone sec.
5. Sonraki kartlar icin aktarim notu yaz.

## Ortak Degerlendirme Rubrigi

Her zone icin asagidaki 1-5 skalasini kullan:

| Alan | 1 | 3 | 5 |
|------|---|---|---|
| Siluet okunurlugu | daginik | yeterli | tek bakista guclu |
| Zemin/path kompozisyonu | yon kayip | takip edilebilir | akisi net yonlendiriyor |
| Landmark etkisi | zayif | fark edilir | sahnenin odagi |
| Foreground derinligi | duz | katmanli | sahneyi canlandiriyor |
| Karakter kontrasti | kayboluyor | kabul edilebilir | her durumda net |
| Tarihsel ton | generic | kismen uygun | guclu tema hissi |
| Cocuk okunurlugu | karisik | idare eder | sade ve guvenli |

## Zone Audit Tablosu

| Zone | Mevcut kalite | Ana sorun | Kalacak katmanlar | Degisecek katmanlar | Kompozisyon notu | Pilot aday? |
|------|---------------|-----------|-------------------|---------------------|------------------|-------------|
| Bandirma | Orta-iyi | Gorsel dil var ama production-pass derinlik ve landmark vurgusu zayif | Sicak kahve-altin paleti, temel path akisi | Foreground derinligi, landmark okumasi, paper katman zenginligi | Mevcut capture seti zengin; dar scope ile pilot icin en kontrollu alan | Evet |
| Samsun | Orta | Referans tonu dogru yone gidiyor ama paper asset zenginligi ve rift/yer dokusu yetersiz | Rift mavi-altin fikri, temel zone akisi | Yeni paper asset seti, zemin ve foreground zenginlestirmesi | Tek temiz capture var; palette art analysis ile destekleniyor ama pilot icin gozlem yuzeyi daha dar | Yedek aday |
| Ankara | Orta | Meclis temasi var ama `THEME_ROOM` genisletmesi sahne kimligini zayiflatiyor | Meclis odagi, stratejik node yapisi | Tema ayrisma, landmark etkisi, foreground ritmi | Capture eksigi var; once audit sonrasi hedef capture uretilmeli | Hayir |
| Sakarya | Orta-dusuk | Savas tonu mevcut ama dramatik lacivert-kestane-altin dil yeterince guclu degil | Savunma/cephe fikri, genisletilmis asset sayisi | Renk tonu, savas atmosferi, topografik derinlik | `mm-ae-independence-war.png` ile ton guclendirilebilir; capture eksigi nedeniyle ikinci dalga | Hayir |
| Final | Orta-dusuk | Cumhuriyet/final kimligi var ama doruk an hissi ve sivil simgesellik daha guclu olmali | Final zone yapisi, meclis/zafer/gelecek ekseni | Landmark etkisi, kutlama/cumhuriyet tonu, final kompozisyonu | Kabul seviyesi icin yeni capture ve gorsel zirve hissi gerekli | Hayir |

## Zone Kartlari

### Bandirma

Referans capture:
- `artifacts/renders/bandirma/bandirma_world.png`
- `artifacts/renders/bandirma/bandirma_world_clean.png`
- `artifacts/renders/bandirma/bandirma_world_postfix.png`
- `artifacts/renders/bandirma/bandirma_world_ultraclean.png`
- `artifacts/renders/bandirma/bandirma_world_p3.png`
- `artifacts/renders/bandirma/bandirma_world_p3_clean.png`
- referans artwork: `artworks/ilk sahne.png`

Mevcut gucler:
- Sicak kahve-altin ekseni artik dogru yone bakiyor.
- Erken oyun akisi oldugu icin sahne okunurlugu cocuk kullanici icin net.
- Aynı zone icin birden fazla render varyanti var; bu da degisimi olcmeyi kolaylastiriyor.

Sorunlar:
- Landmark ve foreground katmanlari production-pass seviyesinde yeterince ayristirilmamis.
- Paper diorama derinligi ve siluet zenginligi hala prototip hissi veriyor.
- Gemi/sahne kimligi daha guclu tek bakis odak noktasi istemekte.

Kalacaklar:
- Sicak palet yonu
- Temel path akisi
- Zone'in erken bolum sadeligi

Degisecekler:
- Foreground ve landmark katman zenginligi
- Paper cutout hissini arttiracak ek katmanlar
- Derinlik ve siluet ayrimi

Kompozisyon notu:
- Pilot zone icin en guvenli aday; mevcut render cesitliligi sayesinde once/sonra karsilastirma kolay.

Kabul notu:
- Yeni versiyon mevcut sadeligi kaybetmeden daha guclu bir diorama hissi vermeli.

P3 ilk slice notu:
- Eski rehber/placeholder yogunlugu azaltildi; story banner, ekstra rota seridi, gecici NPC ve kart/token bindirmeleri Bandirma pilotundan cikarildi.
- Ilk temiz capture, paper katmanlarin landmark ve zemin okumasi icin daha fazla alan actigini gosteriyor.
- Sonraki slice, dikey frame/cabin katman agirligini ve foreground ritmini daha rafine hale getirmeye odaklanmali.

### Samsun

Referans capture:
- `artifacts/renders/samsun/samsun_world_clean.png`
- referans artwork: `artworks/ilk sahne.png`
- renk/ton notu: [docs/ART_ANALYSIS.md](c:/Users/Aykut/Documents/Godot/mmae/docs/ART_ANALYSIS.md) icinde `ilk sahne.png` ve Samsun terrain notlari

Mevcut gucler:
- Rift mavi-altin kimligi fark edilir.
- Tarihsel acilis bolgesi olarak atmosferik potansiyeli yuksek.

Sorunlar:
- `ART_ANALYSIS` notuna gore yeni Samsun paper asset'leri hala gerekli.
- Tek temiz capture oldugu icin degisimleri olcmek Bandirma kadar rahat degil.
- Zemin ve foreground katmanlari production-pass seviyesinde yeterince katmanli degil.

Kalacaklar:
- Rift cekirdegi fikri
- Mavi-altin vurgu ekseni
- Acik ve yonlendirici zone akisi

Degisecekler:
- Yeni paper terrain ve foreground asset'leri
- Liman/cevre tarihi atmosferinin guclendirilmesi
- Katman ve derinlik ritmi

Kompozisyon notu:
- Bandirma sonrasi ikinci guclu aday; palette ve referanslar net ama once pilotta gozlem standardi kurulmasi daha guvenli.

Kabul notu:
- Yeni versiyon rift vurgusunu korurken daha sicak, daha taktil ve daha tarihsel hissettirmeli.

### Ankara

Referans capture:
- henuz dedicated capture yok
- referans ton: `artworks/mm-ae-independence-war.png`

Mevcut gucler:
- Meclis odagi ve stratejik merkez fikri acik.
- Builder tarafinda landmark cesitliligi mevcut.

Sorunlar:
- `THEME_ROOM` genisletmesi sahneye yeterince ayri bir siyasi/kurumsal kimlik vermiyor.
- Dedicated capture olmayisi ilk tur audit'i zayiflatiyor.

Kalacaklar:
- Meclis ana odagi
- Halk/telgraf/meclis ekseni

Degisecekler:
- Tema ayrismasi
- Landmark dramatikligi
- Foreground ve katman ritmi

Kompozisyon notu:
- P1 sonrasi hedef capture uretilmeden pilot olarak secilmemeli.

Kabul notu:
- Sahne tek bakista "Ankara/Meclis iradesi" hissi vermeli.

### Sakarya

Referans capture:
- henuz dedicated capture yok
- referans artwork: `artworks/mm-ae-independence-war.png`

Mevcut gucler:
- Cephe/karargah ekseni net.
- Asset sayisi diger son bolgelere gore daha zengin.

Sorunlar:
- Duygusal ton, savas ve fedakarlik hissini yeterince yuksek kontrastla vermiyor.
- Dramatik lacivert-kestane-altin dil daha guclu kurulabilir.

Kalacaklar:
- Karargah/cephe kurgusu
- Savunma karar atmosferi

Degisecekler:
- Renk tonu
- Topografik derinlik
- Landmark ve foreground vurgu dili

Kompozisyon notu:
- Savas dili daha agir oldugu icin pilot sonrasi ikinci dalgada ele alinmali.

Kabul notu:
- Sahnede hem savas gerilimi hem cocuk-uyumlu okunurluk korunmali.

### Final

Referans capture:
- henuz dedicated capture yok
- referans artwork: `artworks/mm-ae-independence-war.png`

Mevcut gucler:
- Final meclis/zafer/gelecek ekseni dogru bir iskelet sunuyor.
- Cumhuriyet dorugu icin builder tarafinda temel landmark seti var.

Sorunlar:
- Doruk an hissi ve gorsel zirve production-pass seviyesinde degil.
- Kutlama/cumhuriyet tonu ile devlet kurucu ciddiyet arasindaki denge netlesmemis.

Kalacaklar:
- Final ekseninin uclu yapisi
- Meclis ve gelecek baglantisi

Degisecekler:
- Landmark vurgusu
- Final sahne ritmi
- Gorsel kutlama ve bitis hissi

Kompozisyon notu:
- Kabul paketi oncesi en cok "zirve hissi" testi gerektiren zone.

Kabul notu:
- Final sahne oyunun kapanisini gorsel olarak tasiyabilecek seviyeye ulasmali.

## Pilot Zone Karari

Onerilen pilot zone: Bandirma

Gerekce:
- En zengin mevcut capture seti Bandirma'da; degisimi olcmek en kolay burada.
- Erken oyun bolgesi oldugu icin daha dar scope ile daha hizli geri bildirim verir.
- `ilk sahne.png` referansi ile sicak paper-diorama diline net bir bag kurulabiliyor.

Beklenen risk:
- Erken bolum sadeligini korurken production-pass derinligini fazla yuklemek.

Beklenen ogrenim:
- Paper katman sayisini arttirirken okunurlugu nasil koruyacagimiz.
- Landmark ve foreground derinligini hangi maliyetle iyilestirecegimiz.
- Sonraki Samsun/Ankara dalgasinda hangi capture standardini kullanacagimiz.

## Sonraki Aktarim

### P2 standardizasyon baglari

- Teknik art sozlesmesi: `docs/VISUAL_DESIGN_SYSTEM.md` icindeki `World Art Technical Contract`
- Issue/backlog standardizasyon kaydi: `docs/GODOT_OFFICIAL_DEMO_ADAPTATION.md` icindeki `Issue 10B - Asset Pipeline Standardizasyonu`
- Token sahibi kod dosyalari: `scripts/colors.gd`, `scripts/ui_tokens.gd`

### Issue 10B icin aktarim

- Standartlastirilacak outline kurallari: paper cutout stroke kalinliklari ve foreground/landmark outline farklari yazili hale getirilmeli.
- Standartlastirilacak renk/kontrast kararlar: Bandirma ve Samsun icin sicak kahve-altin ile mavi-altin ayrimi token bazinda netlestirilmeli; savas bolgeleri icin lacivert-kestane-altin varyanti tanimlanmali.
- Import veya oran riski tasiyan asset turleri: yeni terrain/foreground SVG'leri ve landmark silhouette boyutlari.

### Kart C icin aktarim

- Ilk replacement'ta degisecek zone: Bandirma
- Builder tarafinda en kritik kompozisyon noktasi: landmark odagi ile foreground derinliginin player/marker akisini bozmadan guclendirilmesi.
- Capture ve regression sirasinda ozellikle bakilacak alan: erken bolum okunurlugu, karakter kontrasti, path yonlendirmesi ve zone'in tek bakis odagi.

## Hemen Sonraki Adimlar

- [x] Kritik 5 zone icin mevcut capture linklerini bu belgeye ekle
- [x] Zone audit tablosundaki `TBD` alanlarini ilk tur doldur
- [x] Pilot zone'u sec ve gerekcesini yaz
- [x] `Issue 10B` icin aktarim notlarini tamamla

## P1 Cikis Ozeti

- Ilk tur audit tamamlandi.
- Pilot zone olarak `Bandirma` onerildi.
- `Samsun` ikinci dalga guclu aday olarak ayrildi.
- `Ankara`, `Sakarya` ve `Final` icin dedicated capture eksigi sonraki audit/capture ihtiyaci olarak not edildi.

## P2 Hazirlik Sonucu

- Asset pipeline standardizasyonu icin sahip dosyalar ve teknik sozlesme baglandi.
- `Bandirma` pilot uygulamasi icin outline, import ve kontrast kurallari artik tek akista okunabiliyor.

## P3 Ilk Uygulama Sonucu

- `Bandirma` pilotunda ilk production-pass temizlik dilimi uygulandi.
- Parse dogrulamasi temiz dondu.
- Yeni capture referanslari `bandirma_world_p3.png` ve `bandirma_world_p3_clean.png` olarak eklendi.
- Ikinci mikro dilimde `cabin_wall`, `sea_window` ve `foreground_frame` opakliklari dusurulerek gemi ve rota odagi bir miktar acildi.
- Ucuncu mikro dilimde prosedurel bulut ve duman sprite bindirmeleri kaldirilarak atmosferin kaynagi tekrar paper sky/fog katmanlarina cekildi.
- Dorduncu mikro dilimde `map_table` ve `telegraph_props` destek katmanlari kucultulup soldurularak ship landmark okumasina daha fazla alan acildi.
- Besinci mikro dilimde `uniform_stand` destek prop'u da geri cekilerek ust sol kompozisyonun ship/panel odagi ile yarismasi azaltildi.
- Altinci mikro dilimde `compass` destek prop'u da kucultulup soldurularak sag alt yardimci odagin ship ve rota uzerindeki baskisi dusuruldu.
- Bu mikro dilimlerin sonunda `Bandirma` pilotunda destek-prop temizlik turu yeterli seviyeye geldi; bir sonraki odak `P4` kontrast ve okunurluk kalibrasyonu.
- `P4` ilk kalibrasyon slice'inda world HUD icin `STATUS_PANEL_HEIGHT` ve `HUD_HINT_HEIGHT` yukseltilerek Bandirma objective/hint kopyasinin daha rahat okunmasi saglandi; `bandirma_world_p4_hud.png` capture'i yenilendi.
- Ikinci `P4` slice'inda `world_player.gd` icindeki outline altyapisi fiilen devreye alindi; player ve companion silhouette ayrimi ayni `bandirma_world_p4_hud.png` capture'inda daha net hale geldi.
- Ucuncu `P4` slice'inda guidance label, companion reaction ve world marker yuzeyleri ayni kontrast diline cekildi; `ui_tokens.gd`, `world_ui.gd`, `world_player.gd` ve `world_marker.gd` uzerinden panel, outline ve metin yuzeyleri Bandirma arka planina karsi daha yuksek ayrim verdi.
- Dorduncu `P4` slice'inda overlap kaynagi guidance label degil, Bandirma zone location sign olarak ayrildi; objective hint aktifken bu world-guide yuzey gecici olarak bastirilarak ust ekran cakisimi temizlendi.
- Besinci `P4` slice'inda `capture_world_render.gd` chapter transition overlay'ini hardcoded path yerine `OverlayManager` uzerinden bulacak sekilde duzeltildi; boylece Bandirma kabul capture'i transition kalintisi uretmeden tekrar alinabiliyor.
- Altinci `P4` slice'inda Bandirma loop'u icin `validate_game_flow.gd`, `verify_capture_world_render_contract.gd`, `verify_bandirma_guidance_contract.gd` ve `verify_bandirma_copy_contract.gd` kapilari eklendi; ship clue -> decision akisi, guidance de-stack ve kisa marker kopyasi testle sabitlendi.
- Bu slice sonunda ayni `bandirma_world_p4_hud.png` capture'inda marker kartlari, companion reaction ve ust ekran objective akisi ayni anda daha temiz okunur hale geldi; Bandirma pilotu tekrar uretilebilir `P4` readability kalibrasyon kapisindan gecerek `P5` rollout'una hazir duruma geldi.
- `P5` ilk rollout slice'inda ikinci dalga anchor'i olarak `Samsun` secildi; `world_builder.gd` icindeki `_add_samsun_foreground_silhouettes()` uzerinden tam boy yan frame agirligi geri cekildi ve alt banda daha sicak paper-bank foreground bloblari eklendi.
- Bu slice'in capture'i `artifacts/renders/samsun/samsun_world_p5_probe.png` olarak alindi; ilk sonuc merkezi rota/marker akisini bozmadan daha taktil bir alt-yan derinlik verdigi icin `Samsun` ikinci kompozisyon kararina veya sonraki hedef zone gecisine hazir ara durum olarak not edildi.
- `P5` ikinci rollout slice'inda `Samsun` alt-band kompozisyonu builder + marker + companion spot ekseninde tekrar dagitildi; `Halk` ve `Dalga` odaklari ayni yatay cizgiden ayrildi, `samsun.core` reaction spot'i spawn hattindan cekildi.
- Aynı `artifacts/renders/samsun/samsun_world_p5_probe.png` capture'inin yenilenmis halinde merkez reaction copy kayboldu ve alt bolgedeki `Halk Destek Noktasi`, `Kararsizlik Dalgasi` ve `Cesaret Cicegi` etiketleri ayni karede ust uste binmeden okunabilir hale geldi; bu da `Samsun` rollout'unun ikinci slice icin kabul edilebilir ara ritme ulastigini gosterdi.
- `P5` ucuncu rollout slice'inda sonraki zone olarak `Ankara` secildi; ilk probe `artifacts/renders/ankara/ankara_world_p5_probe.png` capture'inda ust HUD bandinin `Meclis`, `Rehber`, `Telgraf` ve merkez karar/reaction yuzeylerini ezdigi goruldu.
- Ayni slice icinde `world_marker.gd` ve `world_zone.gd` uzerinden Ankara'nin ust interactive anchor'lari daha alt bir oyun koridoruna cekildi; `Merkez Karari` ve `ankara.core` reaction spot'i de oyuncu spawn hattindan saga tasindi.
- Yenilenen `artifacts/renders/ankara/ankara_world_p5_probe.png` capture'inda ust iki destek karti Journey/Minimap bandinin altina indi ve ilk probe'a gore merkez reaction baskisi azaldi; Ankara rollout'u birinci slice sonunda ikinci mikro kompozisyon veya sonraki zone gecisi icin kabul edilebilir ara ritme geldi.
