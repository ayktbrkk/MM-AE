# Android Export Audit

Bu belge `P7 - Export Config Audit` cikisidir. Amac, Android export tarafinda hangi ayarlarin hazir, hangilerinin eksik ve hangilerinin release oncesi netlestirilmesi gerektigini tek yerde gostermektir.

## Durum Ozeti

- Mevcut Android debug export temeli var.
- Portrait yon, paket adi ve temel version bilgisi tanimli.
- Release imzalama ve debug/release farklari henuz kapanmamis.
- P8, P9 ve P12 icin gerekli teknik belirsizlikler artik yazili durumda.

## Kaynak Dosyalar

- `project.godot`
- `export_presets.cfg`

## Audit Tablosu

| Alan | Mevcut durum | Kaynak | Release riski | Sonraki adim |
|------|--------------|--------|---------------|--------------|
| Uygulama adi | `MMAE` | `project.godot` | Dusuk | Store-disiplini icin final urun adi sonradan netlestir |
| Ana sahne | `res://scenes/main_menu.tscn` | `project.godot` | Dusuk | P8 smoke checklist'te acilis akisi uzerinden dogrula |
| Ikon | `res://icon.svg` | `project.godot` | Orta | Android icin gerekirse ayri adaptive/store icon backlog'a alinmali |
| Viewport/orientation | `1080x1920`, portrait | `project.godot`, `export_presets.cfg` | Dusuk | Cihaz-ustu safe-area ve system bar testi ile teyit et |
| Package unique name | `com.mmae.bandirmayolculugu` | `export_presets.cfg` | Dusuk | Release onceki son isim/namespace karariyla kilitle |
| Versioning | `code=1`, `name=1.0` | `export_presets.cfg` | Orta | Ilk release planinda version artirma kuralini yaz |
| Min SDK | `21` | `export_presets.cfg` | Dusuk | Mevcut hedefle uyumlu, degistirme gerekmez |
| Target SDK | `34` | `export_presets.cfg` | Dusuk | Store/SDK takvimine gore izlemeye devam et |
| GPU / renderer | `hw_acceleration=true`, `opengl3=false` | `export_presets.cfg` | Dusuk | Cihaz smoke testlerinde goruntu acilisini dogrula |
| Texture compression | `import_etc2_astc=true` | `project.godot` | Dusuk | Android build boyutu ve cihaz acilisinda not al |
| Architectures | `arm64=true`, `arm32=true`, `x86_64=true` | `export_presets.cfg` | Orta | Emulator ihtiyaci disinda `x86_64` release icin gerekip gerekmedigini kararlastir |
| Gradle build | `use_gradle_build=false` | `export_presets.cfg` | Orta | Ozel Android entegrasyonu gerekirse P9/P12 once tekrar degerlendir |
| Custom package | debug/release bos | `export_presets.cfg` | Orta | Ozel Android template gerekip gerekmedigini kararlastir |
| Debug keystore | tanimsiz | `export_presets.cfg` | Dusuk | Lokal debug export calisiyor; belgeye baglandi |
| Release signing | tanimsiz | `export_presets.cfg` | Yuksek | P12 oncesi release keystore, alias ve imzalama akisi zorunlu |
| Permissions | acik karar listesi yok | export kaynaklarinda ayri not yok | Orta | Gerekli izinleri P12 once netlestir ve checklist'e ekle |
| Splash / launch branding | ayri Android override yok | export kaynaklarinda ayri not yok | Orta | Gerekiyorsa release polish backlog'una ekle |

## Debug ve Release Farki

Su an repo, pratikte debug export odakli durumda:

- Debug APK alinabiliyor.
- Release signing bilgileri yazili veya konfigure degil.
- Tek preset uzerinden hem debug hem release niyeti tasiniyor; ayrim operasyonel olarak net degil.

Bu nedenle mevcut sonuc sunudur:

- `Debug build`: hazir ve tekrar alinabilir.
- `Release build`: teknik olarak planlanmis ama release-ready degil.

## Eksik Alanlar Listesi

1. Release signing bilgileri ve keystore akisi tanimlanmamis.
2. Debug ile release arasinda hangi mimarilerin tasinacagi yazili degil.
3. Permissions, splash ve store icon kararlari tek yerde toplanmamis.
4. Export sonrasi smoke-test checklist'i henuz ayri bir belgeye baglanmamis.

Guncelleme:

- Bu eksik, `docs/ANDROID_RELEASE_CHECKLIST.md` olusturularak kapatildi.

## P8 ve P9 icin Net Girdi

### P8 - Mobil UX Smoke Checklist

- Acilis, menu, start, continue, loading, exit confirm ve save/load akislarinin debug APK uzerinden tekrar edilebilir kontrolu gerekli.
- Orientation ve portrait layout dogrulamasi checklist'e zorunlu satir olarak girmeli.

### P9 - Safe-area ve System Bar Polish

- `project.godot` ve export preset portrait yon konusunda uyumlu; belirsizlik export'tan cok runtime UI davranisinda.
- `scripts/gui_frame.gd` ve `scripts/ui_tokens.gd` zaten safe-area tokenlarini sagliyor; cihaz-ustu davranis artik pratik audit istiyor.

## P12 icin Release Kapisi

P12 oncesi asagidaki maddeler kapanmadan release adayina gecilmemeli:

- Release keystore ve signing akisi
- Mimari paketi karari (`x86_64` dahil mi degil mi)
- Permissions/splash/icon karar listesi
- Tekrar edilebilir Android release checklist'i