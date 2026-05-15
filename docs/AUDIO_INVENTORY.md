# Ses Envanteri (Audio Inventory)

## Mevcut Durum: %100 Placeholder (Procedural)
Tüm sesler `AudioStreamWAV` ile runtime'da üretilmektedir.

## Production Audio'ya Geçiş
`scripts/audio_manager.gd` içindeki `_load_stream()` mekanizması, 
`assets/audio/{name}.ogg` dosyasını otomatik olarak yükler. 
Sadece doğru isimde `.ogg` dosyasını ilgili klasöre koymak yeterlidir.

## BGM (Background Music) — assets/audio/bgm/

| Anahtar | Frekans | Süre | Duygu | Dosya Adı |
|---------|---------|------|-------|-----------|
| `BGM_MENU` | 220 Hz | 4 sn loop | Sakin, ana menü | `menu.ogg` |
| `BGM_EXPLORE` | 180 Hz | 4 sn loop | Yumuşak, keşif | `explore.ogg` |
| `BGM_DECISION` | 260 Hz | 4 sn loop | Gerilim, karar anı | `decision.ogg` |
| `bgm_default` | 200 Hz | 4 sn loop | Genel amaçlı | `default.ogg` |
| `bgm_bandirma` | 165 Hz | 4 sn loop | Deniz, alçak | `bandirma.ogg` |
| `bgm_samsun` | 195 Hz | 4 sn loop | Umut, orta | `samsun.ogg` |
| `bgm_havza` | 210 Hz | 4 sn loop | Hareketli | `havza.ogg` |
| `bgm_amasya` | 230 Hz | 4 sn loop | Kararlı | `amasya.ogg` |
| `bgm_kongre` | 250 Hz | 4 sn loop | Yükselen | `kongre.ogg` |

## SFX (Sound Effects) — assets/audio/sfx/

| Anahtar | Tür | Süre | Kullanım | Dosya Adı |
|---------|-----|------|----------|-----------|
| `SFX_CLICK` | 800Hz click | 50 ms | Buton tıklamaları | `click.ogg` |
| `SFX_CONFIRM` | 440→880Hz sweep | 150 ms | Onay efektleri | `confirm.ogg` |
| `SFX_TRANSITION` | 120Hz tone | 300 ms | Geçiş efektleri | `transition.ogg` |

## Production İçin Teknik Şartname

### Format
- **BGM:** Ogg Vorbis (.ogg), 44100 Hz, stereo, variable bitrate (quality 0.5-0.7)
- **SFX:** Ogg Vorbis (.ogg), 44100 Hz, mono, variable bitrate (quality 0.3-0.5)

### BGM Loop
- Her BGM parçası **sorunsuz loop** yapabilmelidir (zero-crossing loop points)
- Süre: 15-60 saniye arası (mevcut 4 sn placeholder'dan uzun)
- Fade in/out: AudioManager zaten Tween tabanlı cross-fade yapıyor (0.5 sn)

### SFX
- Maksimum 1 saniye (kısa ve tepkisel)
- Mobile cihazlarda düşük latency için ön yüklenebilir olmalı

### Ses Seviyesi
- BGM: -14 dB LUFS (integrated)
- SFX: -10 dB LUFS (integrated)
- Dinamik aralık: 6-10 dB

## Dosya İsmi → Kod Anahtarı Eşlemesi
Dosya adı, küçük harf + `.ogg` uzantısı ile kod anahtarından türetilir:
- `BGM_MENU` → `bgm_menu.ogg` → aslında `_load_stream()` içinde `name.to_lower()` ile `menu.ogg` aranır
- Kod anahtarlarının `to_lower()` halleri dosya adı olarak kullanılır
