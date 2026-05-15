# Release Gates

> Bu doküman, "Bandırma Yolculuğu" için release öncesi geçilmesi gereken gate'leri tanımlar.
> Her gate, bir sonraki aşamaya geçmeden önce %100 tamamlanmalıdır.
>
> **Tamamlayıcı doküman:** [`docs/ANDROID_RELEASE_CHECKLIST.md`](docs/ANDROID_RELEASE_CHECKLIST.md) — cihaz-üstü smoke test adımları
> **Çakışma:** Bu doküman ANDROID_RELEASE_CHECKLIST.md ile çakışmaz, onu üst seviyede tamamlar.

---

## Gate 0: Development Gate (Günlük)

Her commit/push öncesi otomatikleştirilmiş kalite kapısı.

- [ ] `godot --headless --check-only --path . --quit` çalışır (parse hatası yok)
- [ ] GUT testlerinin tamamı geçer (`test/` klasörü)
- [ ] Yeni test, eklenen kod için yazılmıştır
- [ ] `.clinerules` standartlarına uygunluk:
  - [ ] Static typing (tip belirteci) zorunlu: `var health: int = 100`
  - [ ] `@onready var` anotasyonu kullanılır, asla `onready var` yazılmaz
  - [ ] Godot 3.x sözdizimi yasak (`setget`, `export var`, eski `onready var`)
  - [ ] Signal tabanlı mimari: `signal` + `func _on_...()` otomatik bağlama
- [ ] Log dosyaları `artifacts/logs/` altında tutulur, repo kökünde geçici dosya bırakılmaz

---

## Gate 1: Feature Gate (Her Feature Branch)

Her feature branch tamamlandığında uygulanır.

### Kod Kalitesi
- [ ] Feature GUT testleri yazıldı ve geçiyor
- [ ] `.clinerules` standartlarına uygunluk denetlendi
- [ ] Statik typing doğrulandı
- [ ] Kod review (Tech Lead) tamamlandı

### Fonksiyonel Doğrulama
- [ ] Manuel smoke test: feature çalışıyor
- [ ] Regresyon testleri geçiyor (mevcut testler bozulmamış)
- [ ] Feature başka bir sistemi kırmıyor

### Headless Doğrulama
- [ ] `--headless --check-only --path . --quit` geçer
- [ ] İlgili headless verifier script'i (varsa) çalışır

---

## Gate 2: Integration Gate (Haftalık)

Tüm feature'lar entegre edildiğinde uygulanır.

### Otomatik Kapılar
- [ ] [`tools/run_p10_smoke_gate.ps1`](tools/run_p10_smoke_gate.ps1) → 6 gate'in tamamı geçer:
  - [ ] Parse Check (exit code 0)
  - [ ] Game Flow Validation (`FLOW_VALIDATION_OK`)
  - [ ] App Lifecycle Contract (`APP_LIFECYCLE_CONTRACT_OK`)
  - [ ] Overlay Input Contract (exit code 0)
  - [ ] UI Focus Accessibility (exit code 0)
  - [ ] ADB Device Smoke (`DEVICE_AVAILABLE` / `DEVICE_SMOKE_SKIPPED_NO_ADB_OR_DEVICE`)
- [ ] [`tools/run_p11_performance_gate.ps1`](tools/run_p11_performance_gate.ps1) → threshold aşılmamış:
  - [ ] Tüm zone'lar ölçüldü
  - [ ] Threshold warnings raporlandı
  - [ ] `PASSED_WITH_WARNINGS` veya `PASSED` statüsü

### Manuel Doğrulama
- [ ] Uçtan uca manuel test: menü → yeni oyun → keşif → karar → bölüm geçişi
- [ ] Tüm overlay'ler doğru CanvasLayer sırasında (50-110)
- [ ] Input blocking doğru (overlay açıkken world input bloklanır)
- [ ] Save/load çalışıyor (yeni kayıt → kapat → devam et)
- [ ] Journal ve tutorial sistemi çalışıyor (varsa)

### Performans
- [ ] FPS profili alındı (ortalama 60 FPS hedef)
- [ ] Zone geçişlerinde belirgin donma yok
- [ ] Bellek kullanımı kabul edilebilir seviyede

---

## Gate 3: QA Gate (Sürüm Öncesi)

### Test Raporu
- [ ] QA Specialist test raporu hazır
- [ ] Tüm kritik (P0) ve yüksek (P1) hatalar çözülmüş
- [ ] Açık hataların hepsi belgelenmiş ve risk seviyesi not edilmiş

### Cihaz Testi
- [ ] Performans profili çekilmiş ve threshold altında
- [ ] En az bir Android cihazda smoke test yapılmış
- [ ] [`docs/ANDROID_RELEASE_CHECKLIST.md`](docs/ANDROID_RELEASE_CHECKLIST.md) cihaz bölümleri doldurulmuş:
  - [ ] A12 serisi (background/foreground)
  - [ ] A16 serisi (back button)
  - [ ] A15 (continue flow)

### Görsel Doğrulama
- [ ] Ekran görüntüleri alınmış (UI regression)
- [ ] [`docs/UI_SCREENSHOT_CHECKLIST.md`](docs/UI_SCREENSHOT_CHECKLIST.md) güncellenmiş
- [ ] Tüm overlay'ler portrait safe-area içinde
- [ ] Metin taşması/kırpılması yok

### Erişilebilirlik
- [ ] Erişilebilirlik ayarları test edilmiş (text speed, large text, high contrast)
- [ ] Touch target minimum 104×104 px kontrolü
- [ ] Ekran okuyucu uyumluluğu (varsa)

---

## Gate 4: Release Gate (Yayın)

### Build
- [ ] [`docs/ANDROID_RELEASE_CHECKLIST.md`](docs/ANDROID_RELEASE_CHECKLIST.md) tamamı işaretlenmiş
- [ ] Sürüm notları (release notes) hazır
- [ ] APK/AAB imzalanmış ve doğrulanmış:
  - [ ] Keystore doğru
  - [ ] İmza algoritması doğru
  - [ ] `apksigner verify` geçer
- [ ] Version bump kuralları uygulanmış:
  - [ ] `project.godot` → `config/version` güncellenmiş
  - [ ] `export_presets.cfg` → `version/name` senkronize
  - [ ] `version/code` bir önceki release'den +1 büyük
- [ ] Debug ve Release preset ayrımı net

### Dağıtım
- [ ] Beta test grubuna dağıtılmış
- [ ] Store listing güncellenmiş:
  - [ ] Açıklama metni
  - [ ] Ekran görüntüleri
  - [ ] Kategori ve yaş sınıflandırması
  - [ ] Gizlilik politikası bağlantısı

### Yedekleme
- [ ] Git version tag eklenmiş (örn: `v1.0.0-rc1`)
- [ ] Build dosyası arşivlenmiş (`builds/` klasörü)
- [ ] Keystore yedeği güvenli konumda (proje dışı)

---

## Gate 5: Post-Release Gate (Yayın Sonrası)

### Monitoring
- [ ] Hata izleme (crash reporting) aktif
- [ ] Kullanıcı geri bildirim kanalı açık (oyun içi form veya e-posta)
- [ ] İlk 48 saat monitoring planı hazır:
  - [ ] Crash rate takibi
  - [ ] Kullanıcı yorumları takibi
  - [ ] Performans metrikleri (ANR, FPS)

### Acil Durum
- [ ] Hotfix planı hazır
- [ ] Hotfix branch protokolü tanımlı:
  - [ ] `release/x.y.z` branch'inden hotfix branch'i açılır
  - [ ] Sadece kritik hatalar fix'lenir
  - [ ] Patch version bump yapılır
  - [ ] Release gate 4 tekrarlanır

### Toparlama
- [ ] Post-mortem hazırlığı başlatılmış
- [ ] Öğrenilen dersler dokümante edilmiş
- [ ] Backlog güncellenmiş (ertelenen polish maddeleri)

---

## Özet Tablosu

| Gate | Ne Zaman | Süre | Kim(ler) | Çıktı |
|------|----------|------|----------|-------|
| Gate 0 | Her commit/push | 1-2 dk | CI/Agent | Parse OK + Test OK |
| Gate 1 | Her feature branch | 1-4 saat | Developer | Feature test OK + Review OK |
| Gate 2 | Haftalık | 1-2 saat | Developer + QA | P10 + P11 gate OK |
| Gate 3 | Sürüm öncesi | 1-2 gün | QA + Tech Lead | QA raporu + Cihaz testi |
| Gate 4 | Yayın anı | 1 gün | Build Master | İmzalı APK + Store listing |
| Gate 5 | Yayın sonrası | 48 saat | Tüm ekip | Monitoring + Hotfix planı |

---

## Acil Durum Prosedürü (Rollback)

Eğer release sonrası kritik bir hata tespit edilirse:

1. **Tespit:** Crash rate > %1 veya kullanıcıların %5'i olumsuz bildirim yaparsa
2. **Karar:** Tech Lead + Build Master rollback kararı verir
3. **Rollback:** Google Play Console'dan önceki working version'a dön
4. **Hotfix:** `hotfix/x.y.z+1` branch'inde fix hazırlanır
5. **Yeniden Release:** Gate 4 tekrarlanır
6. **Post-mortem:** Hata kök neden analizi yapılır

---

*Bu doküman Package 12 çıktısıdır. [`docs/ANDROID_RELEASE_CHECKLIST.md`](docs/ANDROID_RELEASE_CHECKLIST.md) ile birlikte okunmalıdır.*
