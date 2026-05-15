# Polish Backlog

> Son güncelleme: 2026-05-14
> Bu backlog, "Bandırma Yolculuğu" için tespit edilen tüm iyileştirme fırsatlarını içerir.
> Her madde, MVP çıkışı sonrası eklenecek potansiyel özellikleri temsil eder.

## Kategoriler

### 1. Animasyon İyileştirmeleri

| # | Başlık | Alan | Etki | Tahmini Süre | Bağımlılık |
|---|--------|------|------|-------------|-----------|
| A01 | Karakter giriş/çıkış animasyonları (portre slide-in) | [`dialogue_overlay.gd`](scripts/dialogue_overlay.gd) | Yüksek | 2 gün | — |
| A02 | Karar kartları flip/rotate açılış animasyonu | [`decision_overlay.gd`](scripts/decision_overlay.gd) | Orta | 1 gün | — |
| A03 | Info card açılışında scale+bounce efekti | [`info_card_overlay.gd`](scripts/info_card_overlay.gd) | Düşük | 0.5 gün | — |
| A04 | Bölüm geçişlerinde parallax scroll | [`chapter_transition_overlay.gd`](scripts/chapter_transition_overlay.gd) | Yüksek | 3 gün | — |
| A05 | Marker toplama animasyonu (orbit + collect) | [`world_marker.gd`](scripts/world_marker.gd) | Yüksek | 2 gün | — |
| A06 | Wave spawn animasyonu (scale up + fade) | [`world_wave.gd`](scripts/world_wave.gd) | Orta | 1 gün | — |
| A07 | HUD bar animasyonları (score increment) | [`hud_bar.gd`](scripts/hud_bar.gd) | Düşük | 0.5 gün | — |
| A08 | Buton hover/press state animasyonları | Tüm UI | Orta | 2 gün | — |
| A09 | Journal kart açılış animasyonu (staggered grid) | [`journal_overlay.gd`](scripts/journal_overlay.gd) | Düşük | 1 gün | — |

### 2. Görsel Efektler

| # | Başlık | Alan | Etki | Tahmini Süre | Bağımlılık |
|---|--------|------|------|-------------|-----------|
| V01 | Partikül sistemi: kar taneleri (Samsun) | [`world_builder.gd`](scripts/world_builder.gd) | Yüksek | 2 gün | — |
| V02 | Partikül sistemi: yaprak dökümü (Havza) | [`world_builder.gd`](scripts/world_builder.gd) | Orta | 1 gün | — |
| V03 | Partikül sistemi: deniz spreyi (Bandırma) | [`world_builder.gd`](scripts/world_builder.gd) | Orta | 1 gün | — |
| V04 | Sevgi/patika göstergesi (soft glow trail) | [`world_player.gd`](scripts/world_player.gd) | Yüksek | 3 gün | — |
| V05 | Gölge iyileştirmeleri (soft shadow, dynamic) | Shader | Orta | 2 gün | `shader-expert` |
| V06 | Kağıt doku overlay (tüm dünyada) | [`world_builder.gd`](scripts/world_builder.gd) | Orta | 2 gün | — |
| V07 | Kenar karartması (vignette) | Shader | Düşük | 1 gün | `shader-expert` |
| V08 | Diyalog arkaplanı blur efekti | [`dialogue_overlay.gd`](scripts/dialogue_overlay.gd) | Düşük | 1 gün | — |
| V09 | Rüya sahnesi geçiş efektleri (dream sequence) | [`dream_intro_overlay.gd`](scripts/dream_intro_overlay.gd) | Orta | 2 gün | — |

### 3. Ses İyileştirmeleri

| # | Başlık | Alan | Etki | Tahmini Süre | Bağımlılık |
|---|--------|------|------|-------------|-----------|
| S01 | Production BGM dosyalarını ekle (9 parça) | [`assets/audio/bgm/`](assets/audio/bgm/) | Yüksek | 5 gün | Ses üreticisi |
| S02 | Production SFX dosyalarını ekle (3 parça) | [`assets/audio/sfx/`](assets/audio/sfx/) | Yüksek | 2 gün | Ses üreticisi |
| S03 | UI feedback sesleri ekle (hover, error, success) | [`audio_manager.gd`](scripts/audio_manager.gd) | Orta | 1 gün | S01, S02 |
| S04 | Ambient ortam sesleri (rüzgar, dalga, kalabalık) | [`audio_manager.gd`](scripts/audio_manager.gd) | Orta | 3 gün | Ses üreticisi |
| S05 | Voice-over (NPC selamlaşmaları, rehber) | Yeni sistem | Düşük | 10 gün | S01 |
| S06 | Ses seviyesi dinamik aralık sıkıştırması | Bus ayarı | Düşük | 0.5 gün | S01, S02 |

### 4. UI İyileştirmeleri

| # | Başlık | Alan | Etki | Tahmini Süre | Bağımlılık |
|---|--------|------|------|-------------|-----------|
| U01 | Micro-interaction: buton haptik feedback | [`world_ui.gd`](scripts/world_ui.gd) | Orta | 2 gün | Android haptik |
| U02 | Loading ekranı progress bar | [`loading_overlay.gd`](scripts/loading_overlay.gd) | Düşük | 1 gün | — |
| U03 | Tutorial'da animasyonlu ok/el imleci | [`tutorial_controller.gd`](scripts/tutorial_controller.gd) | Yüksek | 2 gün | — |
| U04 | Kayıt göstergesi (oto-save ikonu) | [`world_ui.gd`](scripts/world_ui.gd) | Düşük | 1 gün | — |
| U05 | Network bağlantı kontrolü (offline uyarısı) | Yeni | Düşük | 1 gün | — |
| U06 | Ekran okuyucu desteği (TalkBack) | Tüm overlay'ler | Düşük | 5 gün | — |
| U07 | Dil seçimi (İngilizce desteği) | [`main_menu.gd`](scripts/main_menu.gd) | Orta | 3 gün | Çeviri |
| U08 | Font seçimi (disleksi dostu font) | Tüm overlay'ler | Düşük | 2 gün | — |

### 5. Performans İyileştirmeleri

| # | Başlık | Alan | Etki | Tahmini Süre | Bağımlılık |
|---|--------|------|------|-------------|-----------|
| P01 | Texture atlas kullanımı (SVG → atlas) | Asset pipeline | Yüksek | 3 gün | — |
| P02 | Gereksiz _process() döngülerini temizle | Tüm script'ler | Orta | 2 gün | — |
| P03 | Viewport culling optimizasyonu | [`world.gd`](scripts/world.gd) | Orta | 1 gün | — |
| P04 | Object pooling (marker/wave) | [`world_marker.gd`](scripts/world_marker.gd) | Düşük | 2 gün | — |
| P05 | Light2D performans profili | [`world_builder.gd`](scripts/world_builder.gd) | Düşük | 1 gün | — |
| P06 | Mobile GPU instancing | Shader | Düşük | 3 gün | `shader-expert` |

### 6. İçerik İyileştirmeleri

| # | Başlık | Alan | Etki | Tahmini Süre | Bağımlılık |
|---|--------|------|------|-------------|-----------|
| C01 | Ek hikaye event'leri (her bölgeye +2 olay) | [`questions.gd`](assets/data/questions.gd) | Yüksek | 4 gün | Hikaye yazarı |
| C02 | Ek collectible kartlar (tarihi figürler) | [`questions.gd`](assets/data/questions.gd) | Orta | 3 gün | Hikaye yazarı |
| C03 | Başarım sistemi (achievement) | Yeni sistem | Orta | 5 gün | — |
| C04 | Replay değeri: farklı karar → farklı sonuç | [`questions.gd`](assets/data/questions.gd) | Yüksek | 5 gün | Hikaye yazarı |
| C05 | Gizli koleksiyon öğeleri (easter egg) | [`world_marker.gd`](scripts/world_marker.gd) | Düşük | 2 gün | — |

### 7. Genel İyileştirmeler

| # | Başlık | Etki | Tahmini Süre | Not |
|---|--------|------|-------------|-----|
| G01 | Oyun içi screenshot/paylaşım | Düşük | 2 gün | Android intent |
| G02 | Oyun içi geri bildirim formu | Düşük | 1 gün | URL link |
| G03 | Crash reporting (Firebase veya custom) | Orta | 3 gün | — |
| G04 | Analytics (Google Analytics veya custom) | Düşük | 3 gün | — |
| G05 | Rate my app prompt | Düşük | 1 gün | — |

---

## Öncelik Matrisi

### Yüksek Öncelik (MVP Sonrası Hemen)

| ID | Başlık | Gerekçe |
|----|--------|---------|
| A01 | Karakter giriş/çıkış animasyonları | İlk izlenim kritik |
| A05 | Marker toplama animasyonu | Oyun hissi |
| S01 | Production BGM | Ses kalitesi |
| U03 | Tutorial animasyonlu ok | Kullanıcı deneyimi |
| C01 | Ek hikaye event'leri | İçerik derinliği |

### Orta Öncelik (2. Sprint)

| ID | Başlık | Gerekçe |
|----|--------|---------|
| A04 | Parallax scroll | Görsel kalite |
| V01-V03 | Partikül sistemleri | Atmosfer |
| V04 | Patika glow | Yönlendirme |
| P01 | Texture atlas | Performans |
| C04 | Replay değeri | Tekrar oynanabilirlik |

### Düşük Öncelik (Backlog)

| ID | Başlık | Gerekçe |
|----|--------|---------|
| G01-G05 | Genel iyileştirmeler | MVP sonrası |
| U06 | Ekran okuyucu | Niş kitle |
| S05 | Voice-over | Yüksek maliyet |
| C05 | Easter egg | Düşük etki |

---

## Backlog Kart Detayları

### [A01] Karakter giriş/çıkış animasyonları (portre slide-in)
- **Alan:** [`scripts/dialogue_overlay.gd`](scripts/dialogue_overlay.gd)
- **Etki:** Yüksek
- **Tahmini Süre:** 2 gün
- **Bağımlılık:** —
- **Öncelik:** Yüksek
- **Tanım:** Diyalog açılışında portrelerin kenardan slide-in animasyonu ile gelmesi. Konuşma bitince slide-out ile çıkması. `Tween` tabanlı, `_process` kullanılmaz.
- **Kabul Kriterleri:**
  - [ ] Sol portre soldan, sağ portre sağdan slide-in yapar
  - [ ] Animasyon süresi 0.3-0.5 sn arası
  - [ ] Arka arkaya hızlı diyalog geçişlerinde animasyon kuyruğa alınır
  - [ ] Erişilebilirlik modunda animasyon devre dışı bırakılabilir
- **Teknik Notlar:**
  - `dialogue_overlay.gd::present()` içinde Tween kullan
  - Mevcut `show()` çağrısı yerine pozisyon bazlı animasyon

### [A02] Karar kartları flip/rotate açılış animasyonu
- **Alan:** [`scripts/decision_overlay.gd`](scripts/decision_overlay.gd)
- **Etki:** Orta
- **Tahmini Süre:** 1 gün
- **Bağımlılık:** —
- **Öncelik:** Orta
- **Tanım:** Karar anında iki kartın 3D flip veya scale-up ile açılması. Çocuklar için eğlenceli bir karar anı atmosferi.
- **Kabul Kriterleri:**
  - [ ] Kartlar açılırken 0.2 sn bekleme ile sırayla gelir
  - [ ] Kartlar dokunmaya hazır olduğunda belirgin sinyal verir
  - [ ] Animasyon iptal edilebilir (arka arkaya karar)
- **Teknik Notlar:**
  - `Tweener` veya `AnimationPlayer` kullan
  - `scale` property'si ile 0→1 animasyonu

### [A05] Marker toplama animasyonu (orbit + collect)
- **Alan:** [`scripts/world_marker.gd`](scripts/world_marker.gd)
- **Etki:** Yüksek
- **Tahmini Süre:** 2 gün
- **Bağımlılık:** —
- **Öncelik:** Yüksek
- **Tanım:** Marker toplandığında karakterin etrafında dönen küçük partiküller ve "puf" efekti. Çocuklarda anlık ödül hissi yaratır.
- **Kabul Kriterleri:**
  - [ ] Marker toplanınca 0.5 sn orbit animasyonu
  - [ ] Orbit tamamlanınca marker kaybolur
  - [ ] Ses efekti ile senkronize
- **Teknik Notlar:**
  - `GPUParticles2D` ile partikül efekti
  - `world_marker.gd::_on_marker_collected()` içinde tetiklenir

### [S01] Production BGM dosyalarını ekle
- **Alan:** [`assets/audio/bgm/`](assets/audio/bgm/)
- **Etki:** Yüksek
- **Tahmini Süre:** 5 gün
- **Bağımlılık:** Ses üreticisi
- **Öncelik:** Yüksek
- **Tanım:** Mevcut 9 procedural placeholder BGM'nin gerçek .ogg dosyaları ile değiştirilmesi. Her bölge için ayrı BGM.
- **Kabul Kriterleri:**
  - [ ] Her zone için 15-60 sn loop'lu BGM
  - [ ] Sorunsuz loop (zero-crossing)
  - [ ] -14 dB LUFS seviyesinde
  - [ ] Godot'a import edilmiş ve `.import` dosyaları commit edilmiş
  - [ ] `tools/verify_audio_production.gd` ile doğrulanmış
- **Teknik Notlar:**
  - [`docs/AUDIO_INVENTORY.md`](docs/AUDIO_INVENTORY.md) içindeki dosya adları kullanılır
  - [`scripts/audio_manager.gd`](scripts/audio_manager.gd) otomatik yükler

### [S02] Production SFX dosyalarını ekle
- **Alan:** [`assets/audio/sfx/`](assets/audio/sfx/)
- **Etki:** Yüksek
- **Tahmini Süre:** 2 gün
- **Bağımlılık:** Ses üreticisi
- **Öncelik:** Yüksek
- **Tanım:** Mevcut 3 procedural SFX'in (click, confirm, transition) gerçek .ogg dosyaları ile değiştirilmesi.
- **Kabul Kriterleri:**
  - [ ] click.ogg (50 ms, mono)
  - [ ] confirm.ogg (150 ms, mono)
  - [ ] transition.ogg (300 ms, mono)
  - [ ] -10 dB LUFS seviyesinde
  - [ ] Düşük latency için ön yüklenebilir
- **Teknik Notlar:**
  - [`docs/AUDIO_PRODUCTION_GUIDE.md`](docs/AUDIO_PRODUCTION_GUIDE.md) teknik şartnameyi içerir

### [U03] Tutorial'da animasyonlu ok/el imleci
- **Alan:** [`scripts/tutorial_controller.gd`](scripts/tutorial_controller.gd)
- **Etki:** Yüksek
- **Tahmini Süre:** 2 gün
- **Bağımlılık:** —
- **Öncelik:** Yüksek
- **Tanım:** İlk 3 dakikalık tutorial'da dokunulması gereken yere animasyonlu ok veya el imleci gösterimi.
- **Kabul Kriterleri:**
  - [ ] Ok hedefe doğru yumuşça hareket eder (bounce/pulse)
  - [ ] Çocuk doğru yere dokununca ok kaybolur
  - [ ] Tutorial'ın her 5 fazında çalışır
  - [ ] Erişilebilirlik modunda animasyon hızı ayarlanabilir
- **Teknik Notlar:**
  - `tutorial_controller.gd::show_callout()` içinde `Tween` kullan
  - `TextureRect` ile ok sprite'ı

### [C01] Ek hikaye event'leri
- **Alan:** [`assets/data/questions.gd`](assets/data/questions.gd)
- **Etki:** Yüksek
- **Tahmini Süre:** 4 gün
- **Bağımlılık:** Hikaye yazarı
- **Öncelik:** Yüksek
- **Tanım:** Her bölgeye (9 zone) +2 ek olay eklenmesi. Toplam 31 → 49 event. Oyun süresini ~15 dk → ~25 dk'ya çıkarır.
- **Kabul Kriterleri:**
  - [ ] Her zone'da en az 2 yeni event
  - [ ] Mevcut event zinciri bozulmamalı
  - [ ] Yeni event'ler `CHAPTER_EVENT_CHAINS` içinde doğru sırada
  - [ ] `validate_game_flow.gd` geçer
- **Teknik Notlar:**
  - [`skills/dialogue-sequence.md`](skills/dialogue-sequence.md) workflow'u kullan
  - `kind: "story"` veya `kind: "decision"` etiketi zorunlu

---

## Backlog Kart Şablonu

Her kart aşağıdaki formatta tutulacak:

```markdown
## [Kod] Başlık
- **Alan:** `scripts/dosya.gd`
- **Etki:** Yüksek / Orta / Düşük
- **Tahmini Süre:** X gün
- **Bağımlılık:** Varsa diğer kart kodları
- **Öncelik:** Acil / Yüksek / Orta / Düşük
- **Tanım:** Ne yapılacağı
- **Kabul Kriterleri:
  - [ ] Kriter 1
  - [ ] Kriter 2
- **Teknik Notlar:**
  - İlgili fonksiyonlar
  - Dikkat edilmesi gerekenler
```

---

## Ek Notlar

- Bu backlog **kod değişikliği gerektirmez** — sadece planlama ve dokümantasyon çıktısıdır.
- Her kart MVP çıkışı sonrası ayrı bir sprint'te implement edilebilir.
- Önceliklendirme; etki, tahmini süre ve bağımlılıklara göre yapılmıştır.
- Ses ile ilgili kartlar (S01-S06) ses üreticisi çıktısına bağımlıdır.
- Shader ile ilgili kartlar (V05, V07, P06) `shader-expert` rolü gerektirir.
