# Repo Hijyeni Politikası

## Dosya Türleri ve Beklentiler

| Tür | Dizin | Git Durumu | Açıklama |
|-----|-------|-----------|----------|
| Kaynak kod | `scripts/` | ✅ Takip edilir | Oyun script'leri |
| Sahneler | `scenes/` | ✅ Takip edilir | .tscn dosyaları |
| Asset'ler | `assets/` | ✅ Takip edilir | Sanat, veri, font, audio |
| Dokümantasyon | `docs/` | ✅ Takip edilir | Planlama, tasarım, analiz |
| Testler | `test/` | ✅ Takip edilir | GDScript testleri |
| Araçlar | `tools/` | ✅ Takip edilir | Geliştirme script'leri |
| Geçici log'lar | `artifacts/logs/` | ❌ Ignore | Smoke gate çıktıları |
| Kabul edilen log'lar | `artifacts/logs/accepted/` | ✅ Takip edilir | Onaylanmış referanslar |
| Render capture'lar | `artifacts/renders/` | ✅ Takip edilir | Görsel kabul testleri |
| Root log'lar | `./` | ❌ Ignore | Eski kontrol çıktıları |

## Git İş Akışı

1. **Yeni bir özellik eklerken:**
   - Kod: `scripts/` veya `scenes/`
   - Test: `test/`
   - Dokümantasyon: `docs/`

2. **Doğrulama çalıştırırken:**
   - Çıktılar `artifacts/logs/` altında oluşur
   - `.gitignore` tarafından ignore edilir
   - Kalıcı olması gerekenler `accepted/` altına taşınır

3. **Build alırken:**
   - Çıktılar `builds/` altında oluşur
   - `.gitignore` tarafından ignore edilir

## Unity Kalıntıları
Projede Unity'den dönüşüm referansı olarak tutulan dosyalar:
- `assets/Scenes/`, `assets/Settings/`
- Bu dosyalar migration referansı olarak korunur
- Kodda referans edilmezler

## Root Dizinde İzin Verilmeyen Dosyalar
Aşağıdaki dosya türleri root dizinde **geçici** olarak oluşabilir ancak
git tarafından **ignore edilir** (`.gitignore` kuralları):

- `check_*.txt` — P10 smoke gate çıktıları
- `final_check_*.txt` — Final doğrulama çıktıları
- `godot_*.txt` — Godot headless test log'ları
- `*_output.txt` — Her türlü script çıktısı
- `extension_api.json` — Godot API dump'ları

Bu dosyalar kalıcı hale gelmeden önce `artifacts/logs/accepted/` altına
taşınmalı ve anlamlı bir isim verilmelidir.

## Artifact Politikası Özeti

```
Root (./)
  ├── Geçici log'lar (❌ Ignore)
  │   ├── check_*.txt
  │   ├── final_check_*.txt
  │   ├── godot_*.txt
  │   ├── *_output.txt
  │   └── extension_api.json
  │
  ├── artifacts/
  │   ├── logs/           (❌ Ignore - geçici)
  │   │   ├── *.json, *.csv, *.md
  │   │   └── accepted/   (✅ Track - kalıcı)
  │   └── renders/        (✅ Track)
  │
  ├── builds/             (❌ Ignore)
  │
  └── (kod, sahne, asset, dokümantasyon) (✅ Track)
```
