# Bandırma Yolculuğu — Kapsamlı UI İyileştirme Analizi

> **Proje:** MMAE - Bandırma Yolculuğu (Zaman Yolcuları)  
> **Motor:** Godot 4.6.2 (GDScript 2.0)  
> **Hedef Platform:** Android (1080×1920 portrait, 9:16)  
> **Hedef Kitle:** 5-10 yaş (7-8 tasarım odağı)  
> **Analiz Tarihi:** 2026-05-10  
> **Analiz Kapsamı:** 8 overlay script + 6 yardımcı script + 7 scene dosyası + colors.gd

---

## İçindekiler

1. [UI Mimarisi ve Organizasyonu](#1-ui-mimarisi-ve-organizasyonu)
2. [Kod Kalitesi ve Refactor Fırsatları](#2-kod-kalitesi-ve-refactor-fırsatları)
3. [UX İyileştirmeleri](#3-ux-iyileştirmeleri)
4. [Performans Analizi](#4-performans-analizi)
5. [Erişilebilirlik](#5-erişilebilirlik)
6. [UI Bileşeni Spesifik Önerileri](#6-ui-bileşeni-spesifik-önerileri)

---

## 1. UI Mimarisi ve Organizasyonu

### Mevcut Durum

| Bileşen | Scene Dosyası | Script | CanvasLayer | Görünürlük Yönetimi |
|---------|--------------|--------|-------------|---------------------|
| MainMenu | [`scenes/main_menu.tscn`](scenes/main_menu.tscn) | [`scripts/main_menu.gd`](scripts/main_menu.gd) | Yok (Control root) | `visible` toggle |
| World (ana) | [`scenes/world.tscn`](scenes/world.tscn) | [`scripts/world.gd`](scripts/world.gd) | layer=10 | N/A |
| DialogueOverlay | [`scenes/dialogue_overlay.tscn`](scenes/dialogue_overlay.tscn) | [`scripts/dialogue_overlay.gd`](scripts/dialogue_overlay.gd) | Yok | `visible` + `.present()` |
| DecisionOverlay | [`scenes/decision_overlay.tscn`](scenes/decision_overlay.tscn) | [`scripts/decision_overlay.gd`](scripts/decision_overlay.gd) | Yok | `visible` + `.present()` |
| InfoCardOverlay | [`scenes/info_card_overlay.tscn`](scenes/info_card_overlay.tscn) | [`scripts/info_card_overlay.gd`](scripts/info_card_overlay.gd) | Yok | `visible` + `.present()` |
| ChapterTransitionOverlay | [`scenes/chapter_transition_overlay.tscn`](scenes/chapter_transition_overlay.tscn) | [`scripts/chapter_transition_overlay.gd`](scripts/chapter_transition_overlay.gd) | Yok | `visible` + `.present()` |
| DreamIntroOverlay | [`scenes/dream_intro_overlay.tscn`](scenes/dream_intro_overlay.tscn) | [`scripts/dream_intro_overlay.gd`](scripts/dream_intro_overlay.gd) | Yok | `visible` |
| HudBar | [`scenes/hud_bar.tscn`](scenes/hud_bar.tscn) | [`scripts/hud_bar.gd`](scripts/hud_bar.gd) | Yok | `visible` (TopPanel) |

### Scene Tree (World)
```
World (Node2D) [world.gd]
├── WorldState (Node) [world_state.gd]
├── WorldBuilder (Node) [world_builder.gd]
├── WorldMarker (Node) [world_marker.gd]
├── WorldWave (Node) [world_wave.gd]
├── Props (Node2D)
├── Markers (Node2D)
├── ForegroundProps (Node2D)
├── Player (Node2D)
├── Companion (Node2D)
├── Camera2D (Player altında)
├── CanvasLayer (layer=10)
│   ├── DreamOverlay (ColorRect)
│   ├── AtmosphereLayer (Control)
│   │   ├── TopGlow (ColorRect)
│   │   ├── HorizonGlow (ColorRect)
│   │   └── ...
│   ├── InteractButton (Button)
│   ├── DialoguePanel (PanelContainer)
│   ├── CharacterPanel (PanelContainer)
│   └── DialogueContinue (Button)
├── DialogueOverlay (instance) — overlay
├── DecisionOverlay (instance) — overlay
├── InfoCardOverlay (instance) — overlay
├── ChapterTransitionOverlay (instance) — overlay
└── HudBar (instance) — overlay
```

### Bulgular

#### 1.1 🟡 **CanvasLayer Kullanımı Eksik / Tutarsız**
Sadece [`world.tscn`](scenes/world.tscn:63)'de 1 adet `CanvasLayer` (layer=10) var. Tüm overlay'ler (`DialogueOverlay`, `DecisionOverlay`, `InfoCardOverlay`, `ChapterTransitionOverlay`, `HudBar`) **CanvasLayer içinde değil** — doğrudan World node'unun child'ı olarak eklenmişler. Bu şu anlama gelir:
- Overlay'ler dünya dönüşümlerinden (Camera2D zoom/scroll) etkilenir
- `mouse_filter` ile kısmen çözülse de, tutarlı bir z-index hiyerarşisi yok
- Overlay'ler birbirini gölgeleyebilir

#### 1.2 🟡 **Tema Sistemi Yok (Theme.tres Kullanılmıyor)**
Projede **hiçbir** `.tres` tema dosyası yok. Tüm stiller prosedürel olarak [`StyleBoxFlat`](https://docs.godotengine.org/en/stable/classes/class_styleboxflat.html) ile oluşturuluyor:
- [`main_menu.gd`](scripts/main_menu.gd:296) — `_add_button_style()` ile button stilleri
- [`world.gd`](scripts/world.gd:3113) — `_apply_ui_styles()` ile panel/button stilleri
- Her script'te stil tekrarı var

#### 1.3 🟡 **Overlay Yönetimi Dağınık**
Overlay göster/gizle mantığı [`world.gd`](scripts/world.gd) içinde `current_overlay_kind` string değişkeni ile yönetiliyor:
```gdscript
# world.gd:2786
func _close_dialogue() -> void:
    if current_overlay_kind == "dialogue":
        dialogue_overlay.hide_overlay()
    elif current_overlay_kind == "info":
        info_card_overlay.hide_overlay()
    ...
```
Bu yaklaşım ölçeklenemez — her yeni overlay türü için `_close_dialogue()`'a yeni bir `elif` eklenmeli.

#### 1.4 🔴 **interact_button ve dialogue_continue Doğrudan World'de**
Etkileşim butonu (`InteractButton`) ve diyalog devam butonu (`DialogueContinue`) doğrudan World'un `CanvasLayer`'ında. Bunların bir UI katmanına (HudBar veya ayrı bir ActionBar overlay'ine) taşınması gerekir.

### Öneriler

| # | Öneri | Öncelik | İşlem |
|---|-------|---------|-------|
| R1 | **Merkezi OverlayManager** oluştur — overlay göster/gizle/stack yönetimi için | **Yüksek** | Yeni `scripts/overlay_manager.gd` + autoload |
| R2 | **Her overlay'i kendi CanvasLayer'ına** al — tutarlı layer numaraları: HUD=50, Dialogue=60, Decision=70, InfoCard=80, Transition=90 | **Yüksek** | Tüm overlay scene'lerine CanvasLayer ekle |
| R3 | **Theme.tres dosyası oluştur** — stil sabitlerini tek kaynaktan yönet | **Orta** | [`scripts/colors.gd`](scripts/colors.gd) temelli theme.tres |
| R4 | **Overlay'leri ayrı scene ağacı dalına** taşı — CanvasLayer altında `/root/World/UIOverlays/` | **Düşük** | Scene tree yeniden düzenleme |

---

## 2. Kod Kalitesi ve Refactor Fırsatları

### 2.1 🔴 **world.gd — 3170 satır (Tek Dosya Sendromu)**
[`scripts/world.gd`](scripts/world.gd) projenin en büyük dosyası ve **6 farklı sorumluluğu** tek başına yönetiyor:

| Sorumluluk | Satır Aralığı | Tahmini Satır |
|-----------|--------------|--------------|
| Texture/Constant tanımları | 1-200 | ~200 |
| Karakter seçim akışı | 200-500 | ~300 |
| Dünya inşa helpers | 500-1300 | ~800 |
| Minimap/Rehber/Route | 1300-1800 | ~500 |
| Zone dekorasyon animasyonları | 1800-2300 | ~500 |
| Overlay yönetimi | 2300-2870 | ~570 |
| Save/Load | 2890-2920 | ~30 |
| UI Styling | 2930-3170 | ~240 |

**Ayrıştırma Önerisi:**
- [`scripts/world_player.gd`](scripts/world.gd:2300) → Oyuncu hareketi, companion, etkileşim
- [`scripts/world_ui.gd`](scripts/world.gd:2761) → Overlay göster/gizle, buton yönetimi
- [`scripts/world_zone.gd`](scripts/world.gd:2513) → Zone geçişleri, chapter yönetimi
- Mevcut [`scripts/world_state.gd`](scripts/world_state.gd) zaten iyi ayrıştırılmış

### 2.2 🔴 **Texture Sabitleri DRY İhlali — İki Kopya**

[`world.gd`](scripts/world.gd:1)'de tanımlı texture sabitleri:
```gdscript
const NOTE_ICON := preload("res://assets/art/world/marker_icons/note.png")
const TALK_ICON := preload("res://assets/art/world/marker_icons/talk.png")
const PORTAL_ICON := preload("res://assets/art/world/marker_icons/portal.png")
```

[`world_builder.gd`](scripts/world_builder.gd:1)'de **aynı sabitler tekrar tanımlanmış**:
```gdscript
const NOTE_ICON := preload("res://assets/art/world/marker_icons/note.png")  # DUPLICATE!
```

**Çözüm:** Texture sabitlerini [`scripts/colors.gd`](scripts/colors.gd) gibi merkezi bir `scripts/textures.gd` veya `scripts/resources.gd` dosyasına taşı.

### 2.3 🟡 **@onready String Path Kullanımı**

```gdscript
# world.gd
@onready var dialogue_overlay: Control = $DialogueOverlay
@onready var decision_overlay: Control = $DecisionOverlay
```

Bunlar doğru Godot 4 sözdizimi (% ile) — sorun yok. Ancak `dialogue_panel` ve `character_panel` gibi node'lar String path ile değil, `@onready var` ile referanslanmalı (şu an `$CanvasLayer/DialoguePanel` gibi).

### 2.4 🟡 **Prosedürel Texture Üretimi (Image.create)**

[`info_card_overlay.gd`](scripts/info_card_overlay.gd) ve [`world_marker.gd`](scripts/world_marker.gd) içinde **piksel seviyesinde texture üretimi**:
```gdscript
# info_card_overlay.gd (static func)
static func _make_icon_texture(kind: String) -> Texture2D:
    var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 0))
    # ... pixel drawing ...
```

**Sorun:** Her `_ready()`'de yeniden oluşturuluyor. `static` olması iyi, ama `const` veya singleton seviyesinde bir kerelik üretim daha verimli olur.

### 2.5 🟢 **Olumlu: ZONE_CONFIG Yaklaşımı**

[`world_wave.gd`](scripts/world_wave.gd) içindeki `ZONE_CONFIG` dictionary yaklaşımı **temiz ve genişletilebilir**:
```gdscript
const ZONE_CONFIG := {
    "samsun_rift": {
        "support_prompt": "...",
        "support_options": [...]
    },
    ...
}
```
Bu pattern diğer modüllere de örnek olmalı.

### Öneriler

| # | Öneri | Öncelik |
|---|-------|---------|
| R5 | `world.gd`'yi 3-4 modüle ayır (world_player, world_ui, world_zone) | **Yüksek** |
| R6 | Texture sabitlerini `scripts/textures.gd`'ye taşı | **Yüksek** |
| R7 | `_make_icon_texture()`'u singleton/autoload seviyesinde bir kere çalıştır | **Orta** |
| R8 | Tüm `@onready var` referanslarını `unique_name_in_owner` veya `%` ile değiştir | **Düşük** |
| R9 | `_close_dialogue()`'daki string-based dispatch yerine callback/dictionary kullan | **Orta** |

---

## 3. UX İyileştirmeleri

### 3.1 🟡 **Touch Hedef Boyutları Tutarsız**

| Bileşen | Minimum Boyut | Önerilen (7-8 yaş) | Durum |
|---------|--------------|-------------------|-------|
| Ana menü butonları | 104px height | ≥88px | ✅ İyi |
| InteractButton | 56×56 (varsayılan) | ≥88px | 🔴 Küçük |
| DialogueContinue | ~44px | ≥88px | 🔴 Çok küçük |
| DecisionOverlay seçenekleri | Panel boyutuna bağlı | ≥88px | 🟡 Orta |
| InfoCardOverlay kapat | Yok (arkaplan tıklama) | ≥88px | 🔴 Yok |

**Örnek — [`world.gd`](scripts/world.gd:3119):**
```gdscript
# interact_button varsayılan boyutu — touch için çok küçük
@onready var interact_button: Button = $CanvasLayer/InteractButton
# custom_minimum_size ayarlanmamış
```

### 3.2 🟡 **Yükleme/Loading Durumu Yok**
- Chapter geçişlerinde `ChapterTransitionOverlay` gösteriliyor, ancarka planında `clear_world` + `build_world` + `spawn_markers` yapılırken **herhangi bir loading göstergesi yok**
- [`world.gd`](scripts/world.gd:2516) `_setup_bandirma()` 3 ağır işlemi arka arkaya çalıştırıyor

### 3.3 🟡 **Animasyon Geçişleri Koordinasyonsuz**
Overlay'ler birbirini takip ederken (örneğin dialogue → info_card → chapter_transition) **bekleme/geçiş yönetimi** yok. `callback: Callable` parametresi ile zincirleme yapılıyor, ancak:
- Geçiş sırasında tıklanabilir alanlar yönetilmiyor
- İptal edilebilir animasyon yok (kullanıcı beklemek istemiyorsa)

### 3.4 🟡 **HUD Bağlam Duyarlılığı**
[`hud_bar.gd`](scripts/hud_bar.gd) şu an sadece metin gösteriyor. 7-8 yaş için **görsel ipuçları** eksik:
- Hedefe yaklaştıkça HUD'un parlaması veya renk değiştirmesi
- Toplama animasyonları sırasında HUD'da anlık geri bildirim

### 3.5 🟢 **Olumlu: Tween Tabanlı Animasyonlar**
Overlay'lerin çoğu `create_tween()` kullanıyor:
- [`decision_overlay.gd`](scripts/decision_overlay.gd:79) — giriş/çıkış tween zinciri
- [`chapter_transition_overlay.gd`](scripts/chapter_transition_overlay.gd:50) — 4 aşamalı otomatik geçiş
- [`dialogue_overlay.gd`](scripts/dialogue_overlay.gd:81) — reveal tween

### Öneriler

| # | Öneri | Öncelik |
|---|-------|---------|
| R10 | **InteractButton minimum boyutu** 104×104 yap (mevcut `main_menu.gd`'deki pattern'i kullan) | **Yüksek** |
| R11 | **DialogueContinue'u** 88×88 minimum boyuta çek | **Yüksek** |
| R12 | **Loading spinner** ekle — world/build/clear sırasında ChapterTransitionOverlay içinde | **Orta** |
| R13 | **Touch geri bildirimi** ekle — tüm butonlara `button_down`/`button_up` scale animasyonu | **Orta** |
| R14 | **Yükleme ekranı** — zone geçişlerinde progress bar veya ipucu metni | **Düşük** |

---

## 4. Performans Analizi

### 4.1 🔴 **_process(delta) Kullanımı (7/8 Overlay)

| Script | _process Operasyonları | Açıklama |
|--------|----------------------|----------|
| [`dialogue_overlay.gd`](scripts/dialogue_overlay.gd:103) | ~14/frame | Portre bob, stage light, glow, shine, continue icon animasyonu |
| [`decision_overlay.gd`](scripts/decision_overlay.gd:120) | ~6/frame | Backdrop fade, panel bob, glow pulse |
| [`info_card_overlay.gd`](scripts/info_card_overlay.gd:97) | ~7/frame | Sparkle 3 adet, icon glow, reward star, illustration |
| [`chapter_transition_overlay.gd`](scripts/chapter_transition_overlay.gd:85) | ~7/frame | Rift shard 4 adet, route dots |
| [`dream_intro_overlay.gd`](scripts/dream_intro_overlay.gd:81) | ~5/frame | Book glow, rift shard 5 adet |
| [`hud_bar.gd`](scripts/hud_bar.gd:80) | ~3/frame | Star pulse, chip fade |
| [`main_menu.gd`](scripts/main_menu.gd:179) | ~12/frame | Ship bob, wave, cloud drift, button pulse, glow |
| [`world.gd`](scripts/world.gd:410) | ~20+/frame | Marker animasyonları, companion, atmosfer, karakter |

**Toplamda `_process` başına ~74 animasyonel işlem.** Her overlay `visible` olduğunda çalışıyor.

**Tespit:** Overlay'ler kapalıyken (invisible) _process çalışmıyor mu? Kontrol edilmeli:
```gdscript
# info_card_overlay.gd:97
func _process(delta: float) -> void:
    if not visible:  # <-- Bazı script'lerde var, bazılarında yok
        return
```

[`dialogue_overlay.gd`](scripts/dialogue_overlay.gd:103) — `_process` içinde `if not visible: return` **yok**! Görünmezken de _process çalışıyor olabilir.

### 4.2 🟡 **Node Sayısı Yönetimi**
- Her marker ~15 Polygon2D/Label node'undan oluşur → 6 zone × ~12 marker = ~1080 node
- Her animasyonlu dekorasyon için ayrı Polygon2D
- **Toplam node sayısı** bir sahnede 1500+ olabilir (Android için sınır: ~2000)

### 4.3 🟡 **StyleBoxFat Prosedürel Üretimi**
Her `_apply_ui_styles()` çağrısında yeni `StyleBoxFlat` instance'ları oluşturuluyor:
```gdscript
# world.gd:3154
func _add_button_style(button: Button, fill: Color) -> void:
    var normal := StyleBoxFlat.new()
    var pressed := StyleBoxFlat.new()
    var disabled := StyleBoxFlat.new()
```
Bu `.new()` çağrıları her tema güncellemesinde (zone değişiminde) tekrarlanıyor.

### 4.4 🟢 **Olumlu: Tween Kullanımı**
`_process` yerine `create_tween()` ile yapılan animasyonlar (geçişler, reveal) daha performanslı çünkü Tween motor tarafından optimize edilir.

### Öneriler

| # | Öneri | Öncelik |
|---|-------|---------|
| R15 | **Tüm overlay _process()'lerine** `if not visible: return` ekle | **Yüksek** |
| R16 | **Sürekli animasyonları Tween+loop'a** taşı — _process yerine `tween.set_loops()` | **Yüksek** |
| R17 | **StyleBoxFlat'ları cache'le** — her çağrıda `.new()` yerine reuse | **Orta** |
| R18 | **Node pooling** — marker'lar için havuz sistemi (özellikle zone geçişlerinde) | **Düşük** |

---

## 5. Erişilebilirlik

### 5.1 🔴 **Font Boyutları (7-8 yaş için)**

| Bileşen | Font Size | Önerilen (7-8 yaş) | Durum |
|---------|-----------|-------------------|-------|
| Dialogue metni | 28px (RichTextLabel) | ≥32px | 🟡 Sınırda |
| Decision seçenekleri | 26px (Button) | ≥32px | 🔴 Küçük |
| HUD başlık | 34px (Label) | ≥32px | ✅ İyi |
| HUD hedef | 24px (Label) | ≥28px | 🟡 Sınırda |
| Marker etiketi | 26px (Label) | ≥28px | 🟡 Sınırda |
| InfoCard metni | 24px (Label) | ≥28px | 🟡 Sınırda |

[`dialogue_overlay.gd`](scripts/dialogue_overlay.gd:68):
```gdscript
# Diyalog metni font boyutu — 7-8 yaş için sınırda
@onready var _dialogue_text: RichTextLabel = $PortraitLayer/DialogueText
# theme_override_font_sizes/font_size = 28 (varsayılan)
```

### 5.2 🔴 **Renk Kontrastı**
- [`colors.gd`](scripts/colors.gd)'deki `UI_BUTTON_PRIMARY`: `POP_GOLD` (#FFB340) — beyaz font üzerinde WCAG AA geçer mi? Kontrol edilmeli
- `UI_BUTTON_DISABLED`: #6A6A6A — 7-8 yaş için ayrımı zor olabilir
- `UI_BUTTON_HOVER`: ayrı bir renk **tanımlanmamış** (çoğu yerde `normal` ile aynı)

### 5.3 🟡 **Sesli Geri Bildirim**
Projede [`AudioManager`](scripts/audio_manager.gd) var, ancak:
- UI etkileşimlerinde ses yok (buton tıklama, overlay açılma)
- Sadece BGM yönetiliyor
- 7-8 yaş için **dokunsal + işitsel** geri bildirim kritik

### 5.4 🟡 **Görsel İpuçları**
- Mevcut marker'lar renk + şekil ile ayırt ediliyor (iyi)
- Ancak toplanan vs toplanmamış marker ayrımı sadece `visible=false` ile yapılıyor — **gri tonlama veya checkmark** eklenebilir

### Öneriler

| # | Öneri | Öncelik |
|---|-------|---------|
| R19 | **Tüm font boyutlarını** 7-8 yaş için optimize et (minimum 28px, tercihen 32px) | **Yüksek** |
| R20 | **Renk kontrast testi** — WCAG AA (4.5:1) standardına uygunluk | **Yüksek** |
| R21 | **Sesli geri bildirim** — buton tıklama, overlay açılma, item toplama sesleri | **Orta** |
| R22 | **Toplanmış marker görseli** — `visible=false` yerine gri tonlama + tik işareti | **Düşük** |

---

## 6. UI Bileşeni Spesifik Önerileri

### 6.1 Ana Menü ([`main_menu.gd`](scripts/main_menu.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.1a | Backdrop prosedürel çizim — _process'te 12+ işlem | Arkaplanı bir kere çiz, _process'te sadece bob/glow güncelle | Yüksek |
| 6.1b | Karakter seçiminde buton hover/normal aynı renk | Hover durumuna `brightened(0.15)` ekle | Orta |
| 6.1c | Settings paneli basit (`visible` toggle) | Slide-in animasyonu ekle | Düşük |

### 6.2 Diyalog Overlay ([`dialogue_overlay.gd`](scripts/dialogue_overlay.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.2a | `_process`'te if not visible kontrolü yok | Ekle — `if not visible: return` | **Yüksek** |
| 6.2b | Continue butonu 44px altında | 88×88 minimum boyut | Yüksek |
| 6.2c | Stage light animasyonu 4 adet renk güncellemesi | Tween+loop'a taşı | Orta |
| 6.2d | Speaker side highlight (sol/sağ) 2 glock güncelleme | Ana renkleri `colors.gd`'den oku, sabit kullan | Düşük |

### 6.3 Karar Overlay ([`decision_overlay.gd`](scripts/decision_overlay.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.3a | A/B seçeneklerinde hover durumu yok | Hover'a border glow veya renk değişimi ekle | Orta |
| 6.3b | Karakter kartları giriş animasyonu sequential | Paralel giriş (0.1s gecikmeli) + daha hızlı | Düşük |
| 6.3c | Panel boyutu 920×1180 — 1080×1920'de dar | Genişlik 960'a çıkar + padding optimize et | Düşük |

### 6.4 InfoCard Overlay ([`info_card_overlay.gd`](scripts/info_card_overlay.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.4a | Sparkle animasyonu 3 TextureRect _process'te | Shader material veya Tween+loop kullan | Orta |
| 6.4b | Prosedürel texture (`_make_icon_texture`) | Bir kere oluştur, cache'le | Orta |
| 6.4c | Kapatma sadece callback ile — kullanıcı beklemek zorunda | Hızlı geçiş/atla seçeneği ekle | Düşük |

### 6.5 Chapter Transition ([`chapter_transition_overlay.gd`](scripts/chapter_transition_overlay.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.5a | 4 rift shard + route dots _process'te | Tween+loop ile değiştir | Orta |
| 6.5b | Auto-sequence süresi sabit (2.0s display) | Metin uzunluğuna göre dinamik süre | Düşük |
| 6.5c | Arkaplanda yükleme yapılırken loading göstergesi yok | Loading spinner / progress bar ekle | Orta |

### 6.6 Dream Intro ([`dream_intro_overlay.gd`](scripts/dream_intro_overlay.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.6a | Book glow + 5 rift shard _process'te | Tween+loop | Orta |
| 6.6b | Panel animasyonu sequential | Paralel giriş | Düşük |

### 6.7 HUD Bar ([`hud_bar.gd`](scripts/hud_bar.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.7a | Star counter sürekli pulse | Sadece yeni star eklendiğinde animasyon | Orta |
| 6.7b | Objective hint 5sn sonra auto-fade (Timer) | İyi mekanizma → diğer overlay'lere de uygula | ✅ Mevcut |
| 6.7c | Chip panel metin + renk — zone değiştikçe güncelleniyor | Renk geçişine tween ekle | Düşük |

### 6.8 World UI ([`world.gd`](scripts/world.gd))

| # | Bulgu | Öneri | Öncelik |
|---|-------|-------|---------|
| 6.8a | `interact_button` ve `dialogue_continue` CanvasLayer'da direct child | Ayrı bir ActionBar overlay'ine taşı | **Yüksek** |
| 6.8b | `_add_button_style` her tema güncellemesinde yeni StyleBoxFlat | Cache sistemi veya theme.tres | Orta |
| 6.8c | Companion reaction label _process'te sürekli güncelleniyor | Sadece metin değiştiğinde güncelle | Düşük |

---

## Özet — Eylem Planı (Priority Sıralı)

### Hemen Yapılması Gerekenler (Yüksek Öncelik)

| ID | Eylem | Etki |
|----|-------|------|
| R15 | Tüm overlay `_process()`'lerine `if not visible: return` ekle | ~%70 performans iyileştirmesi |
| R10 | InteractButton minimum boyut 104×104 | UX iyileştirmesi |
| R11 | DialogueContinue minimum boyut 88×88 | UX iyileştirmesi |
| R5 | `world.gd`'yi modüllere ayır (3170 satır → <1000/modül) | Bakım kolaylığı |
| R6 | Texture sabitlerini `scripts/textures.gd`'ye taşı | DRY prensibi |
| R1 | OverlayManager oluştur | Mimari standardizasyon |
| R2 | Her overlay'e CanvasLayer ekle | Z-index tutarlılığı |
| R19 | Font boyutlarını 7-8 yaşa göre büyüt | Erişilebilirlik |
| R20 | Renk kontrast testi | Erişilebilirlik |
| R16 | Sürekli _process animasyonlarını Tween+loop'a taşı | Performans |

### Kısa Vadede (Orta Öncelik)

| ID | Eylem | Etki |
|----|-------|------|
| R3 | Theme.tres dosyası oluştur | Stil tutarlılığı |
| R9 | String-based dispatch yerine callback/dictionary kullan | Kod kalitesi |
| R12 | Loading spinner ekle | UX |
| R13 | Touch geri bildirimi (scale animasyonu) | UX |
| R17 | StyleBoxFlat cache | Performans |
| R21 | Sesli geri bildirim | Erişilebilirlik |

### Gelecekte (Düşük Öncelik)

| ID | Eylem |
|----|-------|
| R4 | Overlay'leri ayrı scene ağacı dalına taşı |
| R8 | @onready referanslarını `%` ile değiştir |
| R14 | Yükleme ekranı (progress bar) |
| R18 | Node pooling (marker havuzu) |
| R22 | Toplanmış marker görseli (gri tonlama) |

---

## Ek: Dosya İstatistikleri

| Dosya | Satır | Sorumluluk |
|-------|-------|-----------|
| [`scripts/world.gd`](scripts/world.gd) | **3170** | Ana oyun döngüsü, UI yönetimi, dünya inşa (REFACTOR GEREKLİ) |
| [`scripts/world_builder.gd`](scripts/world_builder.gd) | **2260** | Dünya inşa ve dekorasyon |
| [`scripts/world_marker.gd`](scripts/world_marker.gd) | **814** | Marker oluşturma ve yönetim |
| [`scripts/world_wave.gd`](scripts/world_wave.gd) | **406** | Dalga mekaniği ve destek yönetimi |
| [`scripts/main_menu.gd`](scripts/main_menu.gd) | **388** | Ana menü |
| [`scripts/dialogue_overlay.gd`](scripts/dialogue_overlay.gd) | **183** | Diyalog katmanı |
| [`scripts/decision_overlay.gd`](scripts/decision_overlay.gd) | **178** | Karar mekaniği |
| [`scripts/info_card_overlay.gd`](scripts/info_card_overlay.gd) | **165** | Bilgi kartları |
| [`scripts/dream_intro_overlay.gd`](scripts/dream_intro_overlay.gd) | **147** | Rüya girişi |
| [`scripts/chapter_transition_overlay.gd`](scripts/chapter_transition_overlay.gd) | **125** | Bölüm geçişleri |
| [`scripts/hud_bar.gd`](scripts/hud_bar.gd) | **197** | HUD göstergeleri |
| [`scripts/colors.gd`](scripts/colors.gd) | **182** | Merkezi renk sistemi |

---

*Bu analiz, projenin mevcut kod tabanı taranarak (world.gd:3170 satır, world_builder.gd:2260 satır, world_marker.gd:814 satır dahil) ve tüm overlay script'leri, scene dosyaları ve yardımcı modüller incelenerek hazırlanmıştır.*
