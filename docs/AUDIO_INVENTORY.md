# Ses Envanteri (Audio Inventory)

## Runtime Acceptance Durumu: ✅ KABUL EDİLDİ
- **Contract Test:** `tools/verify_audio_runtime_contract.gd` → `AUDIO_RUNTIME_CONTRACT_OK` (16/16 PASS)
- **Kapsam:** Bandırma BGM, Decision Confirm SFX, Chapter Transition SFX, Samsun BGM Crossfade, Fallback Audio, Volume Control, Public API Contract
- **Tarih:** 2026-05-15

## Mevcut Durum: %100 Placeholder (Procedural)
Tüm sesler `AudioStreamWAV` ile runtime'da üretilmektedir.

### AudioManager API Yetenekleri
| Metod | Açıklama | Test Durumu |
|-------|----------|-------------|
| `play_bgm(bgm_name, fade_in)` | BGM oynat/geçiş yap | ✅ PASS |
| `play_sfx(sfx_name, volume_ratio)` | SFX oynat | ✅ PASS |
| `stop_bgm(fade_out)` | BGM'yi durdur | ✅ PASS |
| `crossfade_bgm(bgm_name, fade_duration)` | Mevcut BGM'den yeni BGM'ye kademeli geçiş | ✅ PASS (eklendi) |
| `is_bgm_playing()` | BGM çalıyor mu sorgula | ✅ PASS |
| `set_bgm_volume(vol)` / `get_bgm_volume()` | BGM ses seviyesi | ✅ PASS |
| `set_sfx_volume(vol)` / `get_sfx_volume()` | SFX ses seviyesi | ✅ PASS |
| `set_app_paused(paused)` / `is_app_paused()` | Uygulama askıya alma | ✅ PASS (API mevcut) |

### Crossfade Mekanizması
`crossfade_bgm()` metodu (`scripts/audio_manager.gd` içinde):
- Mevcut BGM'yi `half_fade` sürede kısar (Tween ile `linear_to_db(0.0)`)
- Ardından yeni BGM'yi `half_fade` sürede açar
- Varsayılan `fade_duration: float = 1.0` (0.5sn fade-out + 0.5sn fade-in)
- Aynı BGM çağrılırsa hiçbir şey yapmaz (gereksiz geçiş engellenir)
- `_cancel_bgm_fade()` ile önceki tween iptal edilir

### Fallback Procedural Audio
- Geçersiz/eksik ses ID'leri için `_generate_placeholder_sound()` ile frekans tabanlı placeholder üretilir
- Frekans, ID string'inin hash'inden türetilir (deterministik)
- Test: `play_bgm('__invalid_bgm_test__')` ve `play_sfx('__invalid_sfx_test__')` ✅ PASS
- Production ses dosyası eklendiğinde `_load_stream()` öncelikle `assets/audio/{name}.ogg`'yi dener

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
