# Zaman Yolcuları World Art Roadmap

## Quality Target

**Toca Life World + Monument Valley** arası bir görsel dil. Paper diorama stili, sıcak tonlar, yarı-çizgi film karakterler.

## Validation First Constraint

- Tüm world asset'leri sahneye yerleştiğinde **1080×1920 portrait** ekranda doğal görünmeli
- Her bölge: 5-6 SVG katmanı (sky, terrain, path, landmark, foreground + character)
- 4 renk paleti + outline kuralı korunmalı

## Neo-Historical Pop-History Direction

1919-1923 dönemi, çocuklar için **keşfedilebilir, oynanabilir** bir diorama dünyası olarak tasarlanır. Tarihi figürler yan karakter, oyuncu (Arda/Eda) zaman yolcusu olarak merkezde.

## Reference Translation

Referans görseller: [`artworks/`](artworks/) klasöründeki 3 PNG.

## Open World Diorama Production Model

### 1. Prototype Visual Kit ✅ (MEVCUT)

9 bölge için temel SVG asset'ler:

| Bölge | SVG Dosya | Renk Teması | Durum |
|-------|-----------|-------------|-------|
| room | 3 | `THEME_ROOM` | ✅ |
| bandirma | 3 | `THEME_BANDIRMA` | ✅ |
| samsun_rift | 3 | `THEME_SAMSUN` | ✅ |
| havza | 3 | `THEME_TOWN` | ✅ |
| amasya | 3 | `THEME_TOWN` | ✅ |
| kongreler | 3 | `THEME_CONGRESS` | ✅ |
| **ankara** | **5** | `THEME_ROOM` (genişletilmiş) | **✅ YENİ** |
| **sakarya** | **6** | `THEME_BANDIRMA` (genişletilmiş) | **✅ YENİ** |
| **final** | **6** | `THEME_CONGRESS` (genişletilmiş) | **✅ YENİ** |

**Toplam: ~40 SVG dosyası**

### 2. Character Emotion Kit

| Karakter | İfade | Durum |
|----------|-------|-------|
| Arda | idle, happy, thinking | ✅ Tam |
| Eda | idle, happy, thinking | ⏳ Eksik (thinking SVG) |

### 3. Asset Integration Kit (GEZİCİ — PROTOTİP)

- Tutorial integration
- NPC marker placement
- Collection item placement

### 4. World Replacement Pass (SONRAKİ SPRINT)

> Mevcut prototip SVG'ler yeterli. Yüksek kalite diorama sonraki sprint'te.

### 5. Full Character Pass (SONRAKİ SPRINT)

- Full body animation (walk cycle)
- Expression transitions
- Talking animation

### 6. Polish Pass (SONRAKİ SPRINT)

- Particle effects (dust, light rays)
- Transition animations
- Ambient animation (trees, water)

---

## Asset Needs

| Asset | Status | Notes |
|-------|--------|-------|
| Arda world sprite | ✅ | `char_arda_world.svg` |
| Eda world sprite | ⏳ | Eda karakter sprite'ı gerekiyor |
| NPC sprites | ⏳ | Mustafa Kemal, Halide Edip, vb. |
| Zone backgrounds | ✅ | 9 bölge, ~40 SVG |
| Portreler | ✅ | Arda (3), Eda (2) |
| Icon set | ✅ | Procedural textures.gd'de |
| UI elements | ✅ | Button, slider, panel |
| Audio files (.ogg) | ⏳ | 13 procedural placeholder mevcut |

---

## License Rules

- Tüm asset'ler orijinal veya CC0/MIT lisanslı olmalı
- Ticari kullanıma uygunluk kontrol edilmeli
- Referans görseller (`artworks/`) sadece stil referansı

---

## Current Implementation Status

| Alan | Durum | Not |
|------|-------|-----|
| **Prototype Visual Kit** | ✅ 9/9 bölge | 40 SVG dosyası |
| **Character Emotion Kit** | ✅ Kısmi | Arda 3/3, Eda 2/3 |
| **Asset Integration** | ✅ Prototip | Marker + NPC yerleşimi |
| **World Replacement** | 📝 Sonraki | Toca World kalitesi |
| **Full Character** | 📝 Sonraki | Animasyon + ifade geçişi |
| **Polish** | 📝 Sonraki | Partikül + ambient |
| **Audio** | ✅ Placeholder | 13 procedural, .ogg bekliyor |
| **Android Build** | ✅ | builds/BandirmaYolculugu_debug.apk |
| **E2E Test** | ✅ | 22/22 test geçti |

---

*Son güncelleme: 2026-05-11*
