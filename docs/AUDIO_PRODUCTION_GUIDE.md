# Audio Production Guide

## Projeye Ses Dosyası Ekleme Rehberi

### Nasıl Çalışır?
`scripts/audio_manager.gd` içindeki `_load_stream(name)` metodu:
1. Önce `assets/audio/{name}.ogg` dosyasını arar
2. Bulursa yükler ve kullanır
3. Bulamazsa procedural placeholder ses üretir

Yani: **sadece doğru isimde .ogg dosyasını assets/audio/ klasörüne atmak yeterlidir.**

### Dosya İsimlendirme
Dosya adı, kod anahtarının `to_lower()` halidir:
- `BGM_MENU` → `menu.ogg`
- `SFX_CLICK` → `click.ogg`

### Adım Adım
1. Ses dosyasını Ogg Vorbis formatına dönüştür
2. Doğru isimle kaydet:
   - BGM: `assets/audio/bgm/{name}.ogg`
   - SFX: `assets/audio/sfx/{name}.ogg`
3. Godot'u yeniden başlat (veya Editor → Project → Reload Current Project)
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

### Ses Mimarisi
```
Master Bus
├── BGM Bus (müzik)
│   └── AudioStreamPlayer (_bgm_player)
└── SFX Bus (efektler)
    └── 5 kanallı AudioStreamPlayer pool'u
```

### Tüm Ses Referansları
Bkz: [`docs/AUDIO_INVENTORY.md`](docs/AUDIO_INVENTORY.md)
