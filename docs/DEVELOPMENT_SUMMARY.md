# Bandırma Yolculuğu — Geliştirme Özeti

> **Oyun:** Bandırma Yolculuğu (Zaman Yolcuları / MMAE)  
> **Motor:** Godot 4.6 (GDScript 2.0) — Static Typing zorunlu  
> **Platform:** Android (portrait 9:16, 1080×1920)  
> **Hedef Kitle:** 5-10 yaş (7-8 tasarım odağı)  
> **Görsel Ton:** Sıcak, yarı-çizgi film, kağıt diorama stili  

---

## 📁 Proje Klasör Yapısı

```
├── assets/
│   ├── art/          # Görsel asset'ler (SVG)
│   │   ├── characters/  # Karakter portreleri ve world sprite'ları
│   │   ├── world/       # Dünya katmanları (room, samsun, opening)
│   │   ├── fx/          # Efektler
│   │   └── ui/          # UI öğeleri
│   ├── audio/        # Ses dosyaları (henüz boş)
│   └── data/         # Oyun verisi (questions.gd, learning_map.json)
├── docs/             # Dokümantasyon
├── scenes/           # Godot sahneleri (.tscn)
├── scripts/          # GDScript dosyaları
├── captures/         # Ekran görüntüleri (gitignore)
├── kenney/           # Kenney asset pack'leri (gitignore)
├── artworks/         # Referans görseller
├── .clinerules       # Roo Code proje kuralları
├── .roomodes         # Roo Code özel mod tanımları
└── project.godot     # Godot proje dosyası
```

---

## 🧩 Modüler Mimari (P4)

### world.gd — Orchestrator (~3100 satır → hedef ~700 satır)
Ana oyun döngüsü, overlay yönetimi, UI bağlantıları, player hareketi.
Modülleri `_ready()` içinde sırayla başlatır:
1. State başlangıç değerleri
2. Canvas / UI temel kurulum
3. Karakter görsel kurulum
4. Modül kurulum: builder → marker → wave
5. Sinyal bağlantıları
6. Oyun başlangıcı (karakter seçimi)
7. Ses sistemi başlatma

### Modül 1: world_state.gd (~200 satır)
- **Sorumluluk:** Oyun durumu yönetimi (state)
- **Veriler:** `selected_character`, `current_zone`, `current_goal_kind`, `collected_items`, `leadership_points`, `wave_attempts`
- **Sinyaller:** `state_changed(key, value)` — her state değişiminde tetiklenir
- **Save/Load:** `to_dict()` / `from_dict()` ile serialize/deserialize
- **Bağımlılık:** Yok (en alt seviye modül)

### Modül 2: world_builder.gd (~2,000 satır)
- **Sorumluluk:** Dünya inşası, görsel dekorasyon, marker spawn
- **Core builders:** `build_world(zone, world_ref)`, zone bazlı inşa
- **Decorators:** dalga efektleri, rift dekorasyonu, UI stilleri
- **Sinyaller:** `goal_visual_registered(kind, node)`
- **Bağımlılık:** `world_state.gd`, `colors.gd`

### Modül 3: world_marker.gd (~770 satır)
- **Sorumluluk:** Marker yönetimi (spawn, interaction, feedback, query)
- **Interaction:** yakın marker tespiti, etkileşim metni
- **Feedback:** marker animasyonları, toplama efektleri
- **Bağımlılık:** `world_state.gd`

### Modül 4: world_wave.gd (~350 satır)
- **Sorumluluk:** Dalga mekaniği (dağınıklık dalgası mini-game)
- **Wave state:** dalga pozisyonu, hız, genlik
- **Support:** `_ellipse_points()` yardımcı fonksiyonu
- **Bağımlılık:** `world_state.gd`

---

## 📜 Tamamlanan Fazlar (P1-P7)

### P1: Renk Sabiti Refaktörü
- **Amaç:** Tüm renk sabitlerini `scripts/colors.gd`'de topla
- **Yapılan:** 6 script'teki dağınık `const` tanımları → merkezi `colors.gd`
- **Kurallar:** `POP_` (pop-history), `DESIGN_` (tasarım), `ART_` (artwork), `SHADOW_`, `UI_`, `ARDA_`/`EDA_` (karakter), `THEME_` (bölüm)
- **Yasak:** Script içinde `const POP_CRIMSON := Color(...)` tekrarı

### P2: Ölü Kod Temizliği
- **Amaç:** `_decorate_samsun_rift()` ve benzeri kullanılmayan fonksiyonları temizle
- **Yapılan:** Decorator fonksiyonları `world_builder.gd`'ye taşındı, ölü kod kaldırıldı

### P3: Veri Odaklı Mimari — questions.gd
- **Amaç:** Tüm hikaye olayları ve kararlar `assets/data/questions.gd`'de toplansın
- **Yapılan:** `EVENTS` dizisi ile olay/karar/strateji verileri merkezileştirildi
- **Event yapısı:** `kind` ("story"/"decision"), `option_a`, `option_b`, `correct`, `retry`, `info`

### P4: Modülerleştirme (Adım 1-6)
- **P4 Adım 1:** Modül iskeletleri oluşturuldu (`world_state.gd`, `world_builder.gd`, `world_marker.gd`, `world_wave.gd`)
- **P4 Adım 2:** State verileri `world_state.gd`'ye taşındı
- **P4 Adım 3:** Builder fonksiyonları `world_builder.gd`'ye taşındı
- **P4 Adım 4:** Builder migration cleanup — orchestrator çağrıları düzenlendi, sinyal bağlantıları yapıldı
- **P4 Adım 5:** Marker modülüne taşıma — `format_marker_text()`, `mark_collected()`, `hide_nearby_collection_visuals()` ve diğer marker sorguları `world_marker.gd`'ye; `_ellipse_points()` `world_wave.gd`'ye taşındı
- **P4 Adım 6:** Orchestrator temizlik — `_ready()` yeniden sıralandı, eski fonksiyonlar kaldırıldı, Godot `--check-only` ile doğrulama

### P5: Portre Ekspresyon Routing
- **Amaç:** Diyalog sırasında karakter portrelerinin ifade değiştirmesi
- **Yapılan:**
  - `dialogue_overlay.gd`: 6 expression texture sabiti (`ARDA_IDLE`, `ARDA_HAPPY`, `ARDA_THINKING` + Eda versiyonları)
  - Ekspresyon routing map'leri: `ARDA_EXPRESSIONS` / `EDA_EXPRESSIONS`
  - `_apply_portrait_expression(speaker_side, expression)` metodu
  - `world.gd`: `_show_dialogue()`'a opsiyonel `expression` parametresi (default: "idle")
- **Kullanım:** `_show_dialogue("Arda", "Harika!", callback, "happy")`

### P6: Ses Sistemi
- **Amaç:** Merkezi ses yönetimi (BGM + SFX)
- **Yapılan:**
  - `scripts/audio_manager.gd` — Autoload singleton
  - BGM kanalı: `play_bgm()`, `stop_bgm()`, fade in/out
  - SFX kanalı: 5'li player pool
  - Ses seviyesi: `master_volume`, `bgm_volume`, `sfx_volume` (linear → dB dönüşüm)
  - Otomatik bus oluşturma (Master/BGM/SFX)
  - `ResourceLoader.exists()` ile güvenli yükleme (asset yoksa sessizce başarısız olur)
  - `world.gd`: `_ready()`'de varsayılan bgm, `_show_chapter_transition()`'da bölüm bazlı bgm
- **Bekleyen:** `assets/audio/` klasörüne ses dosyaları eklendiğinde otomatik çalışır

### P7: Save/Load Sistemi
- **Amaç:** JSON tabanlı oyun kaydetme/yükleme
- **Yapılan:**
  - `scripts/save_manager.gd` — Autoload singleton
  - `save_game(data)` → `user://savegame.json` (JSON formatında)
  - `load_game()` → Dictionary, hata yönetimi ile
  - `has_save()`, `delete_save()`, `get_save_timestamp()`
  - `world_state.gd`: `to_dict()` / `from_dict()` serialize/deserialize
  - `world.gd`: `_save_game()`, `_load_game()`, bölüm geçişinde otomatik kaydetme

---

## 🔧 Teknik Standartlar

### GDScript 2.0 Kuralları
```gdscript
# ✓ DOGRU — Static typing
var health: int = 100
func heal(amount: int) -> void:
	health += amount

# ✓ DOGRU — @onready anotasyonu
@onready var player: Node2D = $Player

# ✓ DOGRU — @export anotasyonu
@export var speed: float = 100.0

# ✓ DOGRU — Signal tabanlı
signal continue_pressed
func _on_continue_pressed() -> void:
	pass

# ✗ YANLIS — Godot 3.x syntax
# onready var player = get_node("Player")
# export var speed = 100.0
# setget ile property
```

### Autoload Singleton'lar
| Ad | Dosya | Görev |
|----|-------|-------|
| `AudioManager` | `scripts/audio_manager.gd` | Ses yönetimi (BGM/SFX) |
| `SaveManager` | `scripts/save_manager.gd` | Kaydetme/Yükleme |

### İsimlendirme
- **Dosyalar/Dizinler:** `snake_case`
- **Sabitler:** `SCREAMING_SNAKE_CASE`
- **Değişkenler/Fonksiyonlar:** `snake_case`
- **Sinyaller:** `snake_case`
- **Node isimleri (sahne içi):** `PascalCase`

---

## 📡 Sinyal Bağlantı Şeması

```
world.gd (Orchestrator)
  │
  ├── world_state.gd ───── state_changed(key, value)
  │
  ├── world_builder.gd ─── goal_visual_registered(kind, node)
  │
  ├── world_marker.gd
  │
  ├── world_wave.gd
  │
  ├── dialogue_overlay.gd ─ continue_pressed
  ├── decision_overlay.gd ─ choice_selected(index)
  ├── info_card_overlay.gd ─ continue_pressed
  ├── chapter_transition_overlay.gd ─ transition_finished
  │
  ├── AudioManager ─────── bgm_started, sfx_played, volume_changed
  └── SaveManager ──────── game_saved, game_loaded
```

---

## 🚀 Sıradaki Adımlar

### Potansiyel Gelecek Geliştirmeler
- **main_menu.gd'ye "Devam Et" butonu:** `SaveManager.has_save()` kontrolü ile
- **Ses asset'leri:** `assets/audio/` klasörüne .ogg/.wav dosyaları
- **Yeni bölüm dünyaları:** Ankara, Meclis (skills/new-chapter.md rehberi ile)
- **Yeni kararlar:** `assets/data/questions.gd`'ye `EVENTS` dizisine ekleme
- **Android build:** `skills/android-build.md` rehberi ile
- **World art upgrade:** `docs/ART_WORLD_ROADMAP.md` rehberi ile

### Yeni Karar Ekleme
```gdscript
# assets/data/questions.gd - EVENTS dizisine ekle
{
	"kind": "decision",
	"chapter": "samsun",
	"title": "Liman Gözlemi",
	"text": "Kıyıda bir balıkçı teknesi var...",
	"option_a": "Balıkçıya yardım et",
	"option_b": "Rıhtımdaki memurla konuş",
	"correct": "a",
	"retry": "Balıkçı senden bir ip uzatmanı istiyor...",
	"info": "Balıkçılar, bölgedeki düşman hareketlerini en iyi bilenlerdir."
}
```

### Yeni Bölüm Dünyası Ekleme
```bash
# skills/new-chapter.md rehberini takip et
# 1. assets/art/world/[zone_name]/ katmanlarını oluştur
# 2. scenes/world.tscn'ye yeni zone referansını ekle
# 3. scripts/world_builder.gd'ye _build_[zone_name]() ekle
# 4. scripts/world_marker.gd'ye marker spawn ekle
# 5. scripts/world_state.gd'ye zone item total ekle
```

---

## 🔍 Hata Ayıklama İpuçları

```bash
# Godot parse kontrolü (tüm script'ler)
.\Godot_v4.6.2-stable_win64_console.exe --headless --check-only --path .

# Sadece hataları göster
.\Godot_v4.6.2-stable_win64_console.exe --headless --check-only --path . 2>&1 | findstr /i "error"

# Git durumu
git status
git log --oneline -10
```

---

## 📚 Referans Dokümanlar

| Dosya | İçerik |
|-------|--------|
| [`docs/ART_ANALYSIS.md`](docs/ART_ANALYSIS.md) | Sanat analizi ve renk paleti referansı |
| [`docs/VISUAL_DESIGN_SYSTEM.md`](docs/VISUAL_DESIGN_SYSTEM.md) | Görsel tasarım sistemi |
| [`docs/DESIGN_DECISIONS.md`](docs/DESIGN_DECISIONS.md) | Mimari kararlar ve modül planı |
| [`docs/ROADMAP.md`](docs/ROADMAP.md) | Ürün yol haritası |
| [`docs/ART_WORLD_ROADMAP.md`](docs/ART_WORLD_ROADMAP.md) | World art yol haritası |
| [`.clinerules`](.clinerules) | Roo Code proje kuralları ve anayasa |
| [`scripts/colors.gd`](scripts/colors.gd) | Merkezi renk sabitleri |
| [`assets/data/questions.gd`](assets/data/questions.gd) | Hikaye olayları ve karar verileri |

---

> **Son Güncelleme:** Mayıs 2026  
> **Git Commit:** P7 dahil tüm fazlar tamamlandı
