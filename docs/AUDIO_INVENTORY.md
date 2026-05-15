# Ses Envanteri (Audio Inventory)

## Runtime Acceptance Durumu: ✅ KABUL EDİLDİ
- **Contract Test:** [`tools/verify_audio_runtime_contract.gd`](tools/verify_audio_runtime_contract.gd) → `AUDIO_RUNTIME_CONTRACT_OK` (18/18 PASS)
- **Production Asset Test:** [`tools/verify_audio_production.gd`](tools/verify_audio_production.gd) → Production dosyalar eksik
- **Kapsam:** Bandırma BGM, Decision Confirm SFX, Chapter Transition SFX, Samsun BGM Crossfade, Fallback Audio, Volume Control, Public API Contract
- **Tarih:** 2026-05-15

## Mevcut Durum: %100 Placeholder (Procedural) — Fallback AKTİF
Tüm sesler `AudioStreamWAV` ile runtime'da üretilmektedir.
Production `.ogg` dosyaları `assets/audio/bgm/` ve `assets/audio/sfx/` klasörlerinde **mevcut değil**.

### Production File Drop-in Durumu
| Kategori | Mevcut | Eksik | Toplam | Fallback |
|----------|--------|-------|--------|----------|
| BGM | 0 | 9 | 9 | ✅ AKTİF (procedural tone) |
| SFX | 0 | 6 | 6 | ✅ AKTİF (procedural tone) |
| **Toplam** | **0** | **15** | **15** | **✅ Fallback tam aktif** |

### ⚠️ Tespit Edilen Bug: `_load_stream()` Alt Klasör Desteği Yok
[`scripts/audio_manager.gd`](scripts/audio_manager.gd:294) içindeki [`_load_stream()`](scripts/audio_manager.gd:294) metodu:
```gdscript
var path := "res://assets/audio/%s%s" % [sound_name, ext]
```
Bu yol **`bgm/` veya `sfx/` alt klasörlerini içermiyor**. Production dosyalar `assets/audio/bgm/{id}.ogg` ve `assets/audio/sfx/{id}.ogg` yolunda beklense de, `_load_stream()` sadece `assets/audio/{id}.ogg`'yi arıyor.

**Etki:** Production `.ogg` dosyaları doğru klasörlere konsa bile AudioManager onları bulamayacak ve fallback kullanmaya devam edecek.

**Çözüm:** `_load_stream()`'e `bgm/` ve `sfx/` ön eklerini de deneyecek şekilde güncelleme yapılmalı.

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
[`crossfade_bgm()`](scripts/audio_manager.gd:215) metodu:
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
[`scripts/audio_manager.gd`](scripts/audio_manager.gd) içindeki [`_load_stream()`](scripts/audio_manager.gd:294) mekanizması,
`assets/audio/{name}.ogg` dosyasını otomatik olarak yükler.
Sadece doğru isimde `.ogg` dosyasını ilgili klasöre koymak yeterlidir.

**⚠️ NOT:** `_load_stream()` şu anda alt klasör (`bgm/`, `sfx/`) desteğine sahip değil.
Production dosyaların yüklenebilmesi için `_load_stream()`'in güncellenmesi gerekiyor.
(Bkz: yukarıdaki bug tespiti)

## Volume Bilgisi
| Kanal | Linear | dB (decibel) | Kaynak |
|-------|--------|--------------|--------|
| BGM | 0.7 | -3.1 dB | [`audio_manager.gd:45`](scripts/audio_manager.gd:45) (`bgm_volume`) |
| SFX | 1.0 | 0.0 dB | [`audio_manager.gd:51`](scripts/audio_manager.gd:51) (`sfx_volume`) |
| Master | 1.0 | 0.0 dB | [`audio_manager.gd:39`](scripts/audio_manager.gd:39) (`master_volume`) |

## BGM (Background Music) — assets/audio/bgm/

| Anahtar | Production File | Beklenen Dosya | Duygu | Durum |
|---------|----------------|----------------|-------|-------|
| `bandirma` | ❌ | `bandirma.ogg` | Deniz yolculuğu, macera | Fallback (procedural) |
| `samsun` | ❌ | `samsun.ogg` | Umut, karaya çıkış | Fallback (procedural) |
| `dream` | ❌ | `dream.ogg` | Rüya sahnesi, gizem | Fallback (procedural) |
| `menu` | ❌ | `menu.ogg` | Ana menü, sakin | Fallback (procedural) |
| `tension` | ❌ | `tension.ogg` | Gerilim, kritik an | Fallback (procedural) |
| `decision` | ❌ | `decision.ogg` | Karar anı, düşünceli | Fallback (procedural) |
| `chapter_transition` | ❌ | `chapter_transition.ogg` | Bölüm geçişi, epik | Fallback (procedural) |
| `victory` | ❌ | `victory.ogg` | Başarı, zafer | Fallback (procedural) |
| `sakarya` | ❌ | `sakarya.ogg` | Sakarya bölgesi | Fallback (procedural) |

## SFX (Sound Effects) — assets/audio/sfx/

| Anahtar | Production File | Beklenen Dosya | Kullanım | Durum |
|---------|----------------|----------------|----------|-------|
| `confirm` | ❌ | `confirm.ogg` | Onay butonu | Fallback (procedural) |
| `cancel` | ❌ | `cancel.ogg` | İptal butonu | Fallback (procedural) |
| `collect` | ❌ | `collect.ogg` | Öğe toplama | Fallback (procedural) |
| `page_flip` | ❌ | `page_flip.ogg` | Sayfa çevirme (journal) | Fallback (procedural) |
| `typewriter` | ❌ | `typewriter.ogg` | Tip yazı efekti (diyalog) | Fallback (procedural) |
| `decision_appear` | ❌ | `decision_appear.ogg` | Karar kartı açılması | Fallback (procedural) |

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
- `_load_stream()` içinde `name.to_lower()` ile dosya adı aranır
- Production için: `assets/audio/bgm/{name}.ogg` veya `assets/audio/sfx/{name}.ogg`
- **⚠️ Mevcut `_load_stream()` alt klasör desteği olmadığı için önce `_load_stream()` güncellenmelidir**
