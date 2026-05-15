# Audio Production Guide

## Projeye Ses Dosyası Ekleme Rehberi

### Nasıl Çalışır?
[`scripts/audio_manager.gd`](scripts/audio_manager.gd) içindeki [`_load_stream(name)`](scripts/audio_manager.gd:294) metodu:
1. Önce `assets/audio/{name}.ogg` dosyasını arar (⚠️ alt klasör desteği yok)
2. Bulursa yükler ve kullanır
3. Bulamazsa procedural placeholder ses üretir

Yani: **sadece doğru isimde .ogg dosyasını assets/audio/ klasörüne atmak yeterlidir.**

### ⚠️ ÖNEMLİ: `_load_stream()` Alt Klasör Desteği Eksikliği
[`_load_stream()`](scripts/audio_manager.gd:294) metodu şu anda **sadece** `res://assets/audio/{name}.ogg` yolunu arıyor.
`bgm/` veya `sfx/` alt klasörlerini desteklemiyor.

Production dosyalar `assets/audio/bgm/` ve `assets/audio/sfx/` altında beklense de,
`_load_stream()` bunları bulamayacaktır.

**Geçici Çözüm:** Production dosyaları doğrudan `assets/audio/` klasörüne koyun:
- `assets/audio/bandirma.ogg`
- `assets/audio/confirm.ogg`

**Kalıcı Çözüm:** `_load_stream()`'e `bgm/` ve `sfx/` ön eklerini tarama desteği eklenmeli.

### Dosya İsimlendirme
Dosya adı, kod anahtarının `to_lower()` halidir:

| Kategori | ID (Anahtar) | Dosya Adı |
|----------|-------------|-----------|
| BGM | `bandirma` | `bandirma.ogg` |
| BGM | `samsun` | `samsun.ogg` |
| BGM | `dream` | `dream.ogg` |
| BGM | `menu` | `menu.ogg` |
| BGM | `tension` | `tension.ogg` |
| BGM | `decision` | `decision.ogg` |
| BGM | `chapter_transition` | `chapter_transition.ogg` |
| BGM | `victory` | `victory.ogg` |
| BGM | `sakarya` | `sakarya.ogg` |
| SFX | `confirm` | `confirm.ogg` |
| SFX | `cancel` | `cancel.ogg` |
| SFX | `collect` | `collect.ogg` |
| SFX | `page_flip` | `page_flip.ogg` |
| SFX | `typewriter` | `typewriter.ogg` |
| SFX | `decision_appear` | `decision_appear.ogg` |

### Adım Adım

#### Geçici Çözüm (`_load_stream()` güncellenene kadar):
1. Ses dosyasını Ogg Vorbis formatına dönüştür
2. Doğru isimle `assets/audio/` klasörüne kaydet (alt klasör OLMAZ):
   - `assets/audio/bandirma.ogg`
   - `assets/audio/confirm.ogg`
3. Godot'u yeniden başlat (veya Editor → Project → Reload Current Project)
4. Test et: `godot --headless --script tools/verify_audio_production.gd`

#### Kalıcı Çözüm (`_load_stream()` güncellendikten sonra):
1. Ses dosyasını Ogg Vorbis formatına dönüştür
2. Doğru isimle kaydet:
   - BGM: `assets/audio/bgm/{name}.ogg`
   - SFX: `assets/audio/sfx/{name}.ogg`
3. Godot'u yeniden başlat
4. Test et: `godot --headless --script tools/verify_audio_production.gd`

### Format Şartnamesi
| Özellik | BGM | SFX |
|---------|-----|-----|
| Format | Ogg Vorbis | Ogg Vorbis |
| Örnekleme | 44100 Hz | 44100 Hz |
| Kanal | Stereo | Mono |
| Kalite | 0.5-0.7 (variable) | 0.3-0.5 (variable) |
| Maks. Süre | 15-60 sn (loop) | 1 sn |
| Hedef Seviye | -14 dB LUFS | -10 dB LUFS |
| Loop | Zero-crossing | Yok |

### Volume Bilgisi (AudioManager Varsayılanları)
| Kanal | Linear | dB | Açıklama |
|-------|--------|-----|----------|
| BGM | 0.7 | -3.1 dB | Hafif kısık, diyalog/efektlere yer açmak için |
| SFX | 1.0 | 0.0 dB | Tam ses, efektler duyulabilir olmalı |
| Master | 1.0 | 0.0 dB | Genel ses seviyesi |

**Üretim önerisi:** Production ses dosyaları -14 dB LUFS (BGM) ve -10 dB LUFS (SFX)
seviyesinde normalize edilmelidir. AudioManager'ın linear volume ayarları
(0.7 BGM, 1.0 SFX) ile birleştiğinde dengeli bir mix elde edilir.

### Ses Mimarisi
```
Master Bus
├── BGM Bus (müzik)
│   └── AudioStreamPlayer (_bgm_player)
└── SFX Bus (efektler)
    └── 5 kanallı AudioStreamPlayer pool'u
```

### Fallback Mekanizması
Production dosyalar mevcut olmadığı sürece AudioManager `AudioStreamWAV` ile
procedural ses üretir:
- **BGM:** Sinüs dalgası (150-300 Hz, 4 sn loop, %35 amplitude)
- **SFX:** Click (800 Hz, 50 ms) / Sweep (440→880 Hz, 150 ms) / Tone (120 Hz, 300 ms)

Fallback'i bypass etmek için: Dosyayı doğru yola koymak yeterlidir.
`_load_stream()` önce dosya sistemini kontrol eder.

### Test
Production dosyalar eklendikten sonra:
```bash
godot --headless --script tools/verify_audio_production.gd
```
Beklenen çıktı: "TUM DOSYALAR MEVCUT — Production-ready."

### Tüm Ses Referansları
Detaylı envanter: [`docs/AUDIO_INVENTORY.md`](docs/AUDIO_INVENTORY.md)
