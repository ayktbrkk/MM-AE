# Android Device Smoke Test Planı

> **Proje:** MMAE — Bandırma Yolculuğu (Godot 4.6.2)
> **APK:** `builds/BandirmaYolculugu_debug.apk` (~152 MB)
> **Cihaz:** MumuPlayerGlobal-12.0-0 (Android 12, ADB: 127.0.0.1:7555)
> **Tarih:** 2026-05-15
> **Test Türü:** Manual Smoke Test (6 Adım)

---

## 1. Test Ortamı

| Parametre | Değer |
|-----------|-------|
| Emülatör | Mumu Player (Android 12) |
| ADB Bağlantısı | `127.0.0.1:7555` |
| APK Yükleme | Debug APK, başarıyla yüklendi |
| Uygulama Durumu | Çalışıyor (`PID 4048`, `topResumedActivity`) |
| Ekran Yönü | Portrait (9:16, 1080×1920) |
| Test Yöntemi | Manuel gözlem |

---

## 2. Smoke Test Senaryoları

### Adım 1 — İlk Açılış (Ana Menü)

| Alan | Detay |
|------|-------|
| **Test Adımı** | Uygulamayı başlat. Ana menü ekranının göründüğünü doğrula. |
| **Beklenen Sonuç** | "Zaman Yolcuları" başlığı, "Bandırma'dan başlayan tarih yolculuğu" alt başlığı ve şu butonlar görünür: **Oyuna Başla**, **Devam Et**, **Ayarlar**, **Erişilebilirlik**, **📖 Tarih Defteri**, **Çıkış**. Arka planda Bandırma vapuru ve Arda/Eda karakter siluetleri animasyonludur. |
| **Geçti (✔️) / Kaldı (❌)** | |
| **Gözlemler** | |

---

### Adım 2 — Karakter Seçimi (World İçinde)

| Alan | Detay |
|------|-------|
| **Test Adımı** | "Oyuna Başla" butonuna tıkla. Rüya giriş animasyonu izle. World sahnesi yüklendikten sonra karakter seçim panelini doğrula. |
| **Beklenen Sonuç** | Rüya giriş animasyonu ("Kitap Açılıyor") gösterilir. World sahnesine geçilir. Karakter seçim panelinde **Arda** ve **Eda** seçenekleri görünür. Bir karakter seçildiğinde seçim onaylanır ve "Arda ve Eda odadaki notlara yaklaşır..." giriş diyalogu başlar. |
| **Geçti (✔️) / Kaldı (❌)** | |
| **Gözlemler** | |

> **Not:** Karakter seçimi ana menüde değil, world sahnesi içinde yapılır. "Oyuna Başla" → rüya girişi → world yükleme → karakter seçim paneli sırası izlenir.

---

### Adım 3 — Bandırma (Gemi) Sahnesine Geçiş

| Alan | Detay |
|------|-------|
| **Test Adımı** | Karakter seçimi sonrası odadaki ünite notlarını topla (etkileşim noktalarına tıkla). Bandırma vapuru geçişini başlat. |
| **Beklenen Sonuç** | Odadaki notlar toplandıkça hedef göstergesi ilerler. Tüm notlar toplandığında bölüm geçişi başlar. Bandırma (ship) sahnesi yüklenir. Gemi ortamı görünür. Bandırma giriş diyalogu veya ilk karar mekaniği ekranda belirir. |
| **Geçti (✔️) / Kaldı (❌)** | |
| **Gözlemler** | |

---

### Adım 4 — İlk Karar Mekaniği (Samsun Kararı)

| Alan | Detay |
|------|-------|
| **Test Adımı** | Bandırma sahnesindeki ilk karar ekranını bekle. Karar kartlarını incele ve bir seçenek seç. |
| **Beklenen Sonuç** | Karar overlay'i açılır: "Karar Anı" başlığı, karar metni (A/B seçenekleri) ve Arda/Eda karakter kartları görünür. **Arda seçeneği** veya **Eda seçeneği** butonlarına basılabilir. Seçim yapıldığında butonda basma animasyonu oynar, seçim geri bildirimi alınır ve karar overlay'i kapanır. |
| **Geçti (✔️) / Kaldı (❌)** | |
| **Gözlemler** | |

---

### Adım 5 — Android Back Tuşu ve Çıkış Onayı

| Alan | Detay |
|------|-------|
| **Test Adımı** | Oyundayken Mumu Player'daki Android geri tuşuna (Back) bas. Çıkış onay diyalogunun açıldığını doğrula. "Hayır, kalayım" butonuna basarak oyuna dön. |
| **Beklenen Sonuç** | **⚠️ Not:** Oyunda ayrı bir pause menüsü bulunmamaktadır. Back tuşu doğrudan **çıkış onay diyalogu** açar. Diyalogda "Çıkış" (onay) ve "Hayır, kalayım" (iptal) butonları görünür. "Hayır, kalayım" seçildiğinde diyalog kapanır ve oyun kaldığı yerden devam eder. |
| **Geçti (✔️) / Kaldı (❌)** | |
| **Gözlemler** | |

> **Not [PAUSE EKSİKLİĞİ]:** Oyanda ayrı bir pause menüsü (oyunu duraklatma, devam et, ana menü vb.) **henüz implemente edilmemiştir.** Back tuşu yalnızca çıkış onay diyalogu gösterir. Bu bir eksiklik olarak değerlendirilebilir ve ilerleyen sürümlerde eklenmesi önerilir.

---

### Adım 6 — Back/Cancel Davranışı (Tüm Ekranlar)

| Alan | Detay |
|------|-------|
| **Test Adımı** | Farklı ekranlarda Android geri tuşuna basarak davranışı gözlemle: (a) Ana menü, (b) Ayarlar açıkken, (c) Diyalog açıkken, (d) Karar açıkken. |
| **Beklenen Sonuç** | **(a) Ana menüde:** Çıkış onay diyalogu açılır. **(b) Ayarlar açıkken:** Ayarlar paneli kapanır. **(c) Diyalog açıkken:** Diyalog metni varsa önce typewriter tamamlanır, tekrar back basınca diyalog kapanır. **(d) Karar açıkken:** Karar ekranı kapanır (beklenen). Hiçbir durumda uygulama direkt kapanmamalıdır. |
| **Geçti (✔️) / Kaldı (❌)** | |
| **Gözlemler** | |

---

## 3. Kod Doğrulama Referansları

Aşağıdaki kod referansları test sırasında karşılaşılabilecek davranışların kaynağını gösterir:

| Test Adımı | İlgili Kod Dosyası | Açıklama |
|-----------|-------------------|----------|
| Adım 1 | [`scripts/main_menu.gd`](scripts/main_menu.gd:140) | Ana menü kurulumu, butonlar, arkaplan |
| Adım 2 | [`scripts/world.gd`](scripts/world.gd:188) | `_enter_requested_flow()` — karakter seçim paneli |
| Adım 2 | [`scripts/main_menu.gd`](scripts/main_menu.gd:463) | `_on_start_pressed()` — rüya girişi |
| Adım 3 | [`scripts/world.gd`](scripts/world.gd:23) | Event index sabitleri (ship: 2) |
| Adım 4 | [`scripts/decision_overlay.gd`](scripts/decision_overlay.gd:181) | Karar overlay sunumu |
| Adım 5-6 | [`scripts/world_ui.gd`](scripts/world_ui.gd:393) | `handle_global_cancel()` — back tuşu yönlendirmesi |
| Adım 5-6 | [`scripts/exit_confirm_overlay.gd`](scripts/exit_confirm_overlay.gd:45) | Çıkış onay overlay'i |
| Adım 6 | [`scripts/main_menu.gd`](scripts/main_menu.gd:194) | Ana menü `_input` — back tuşu handling |
| Adım 6 | [`scripts/dialogue_overlay.gd`](scripts/dialogue_overlay.gd:112) | Diyalog `_input` — back tuşu ile devam |

---

## 4. Test Sonuç Özeti

| # | Test Adımı | Sonuç (✔️/❌) | Tester |
|---|-----------|--------------|--------|
| 1 | İlk Açılış — Ana Menü | | |
| 2 | Karakter Seçimi | | |
| 3 | Bandırma Sahnesine Geçiş | | |
| 4 | İlk Karar Mekaniği | | |
| 5 | Back Tuşu / Çıkış Onayı | | |
| 6 | Back/Cancel Tüm Ekranlar | | |
| | **Toplam** | **/ 6** | |

---

## 5. Bilinen Eksikler ve Riskler

| # | Eksiklik | Etki | Öneri |
|---|----------|------|-------|
| 1 | **Pause menüsü yok** | Oyuncu oyunu duraklatıp ana menüye dönemez. Back tuşu doğrudan çıkış onayı açar. | Pause menüsü implemente edilmeli (Devam Et / Ana Menü / Çıkış seçenekleriyle) |
| 2 | Karar ekranında back tuşu davranışı net değil | `decision_overlay.gd` içinde `ui_cancel` handling kontrol edilmeli | Back tuşu karar ekranını kapatmamalı veya net bir UX akışı tanımlanmalı |

---

*Hazırlanma Tarihi: 2026-05-15 | QA Specialist — Manuel Smoke Test*
