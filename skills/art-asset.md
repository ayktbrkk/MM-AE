# Yeni Görsel Asset Ekleme Workflow'u

Bu workflow, oyuna yeni bir görsel asset (SVG/PNG) eklemek için kullanılır.

## Adımlar

### 1. Asset Konumunu Belirle

```
assets/art/
├── characters/
│   ├── arda/            # Arda portreleri ve dünya spriteları
│   │   ├── portrait_arda_idle.svg
│   │   ├── portrait_arda_happy.svg
│   │   ├── portrait_arda_thinking.svg
│   │   └── char_arda_world.svg
│   └── eda/             # Eda portreleri ve dünya spriteları
│       ├── portrait_eda_idle.svg
│       ├── portrait_eda_happy.svg
│       ├── portrait_eda_thinking.svg
│       └── char_eda_world.svg
├── world/
│   ├── opening/         # Açılış dünyası benchmark asset'leri
│   ├── room/            # Öğrenci odası diorama asset'leri
│   ├── samsun/          # Samsun Rift diorama asset'leri
│   ├── bandirma/        # (gelecek) Bandırma Vapuru
│   ├── havza/           # (gelecek) Havza/Amasya
│   └── congress/        # (gelecek) Kongreler
├── ui/                  # UI elemanları (buton, kart, ikon)
├── effects/             # Partikül/fx asset'leri
└── fonts/               # Yazı tipleri
```

### 2. İsimlendirme

- **SVG/PNG dosyaları:** `snake_case_ile_aciklama.svg`
- **Önek kullanımı:**
  - `paper_` — Paper diorama dünya asset'leri
  - `portrait_karakter_` — Karakter portreleri
  - `char_karakter_` — Karakter dünya spriteları
  - `bg_` — Arkaplanlar
  - `fx_` — Efektler
  - `ui_buton_` — UI butonları
- **Texture constant:** `SCREAMING_SNAKE_CASE` + `_TEXTURE` son eki
  - `const SAMSUN_PAPER_TERRAIN_TEXTURE := preload("res://...")`

### 3. Renk Uyum Kontrolü

**ZORUNLU kontroller:**

- [ ] Renkler [`scripts/colors.gd`](scripts/colors.gd) sabitlerinden mi seçildi?
- [ ] Asset maksimum **4 renk** + 1 gölge + 1 outline kuralına uyuyor mu?
- [ ] Ana renk doygunluğu %50-70 arasında mı?
- [ ] Vurgu renkleri %70-85 doygunlukta mı?
- [ ] Bölüm temasına uygun renkler kullanıldı mı?
  - Room: `THEME_ROOM` (lacivert + altın + krem)
  - Bandirma: `THEME_BANDIRMA` (savaş laciverti + sıcak kahve)
  - Samsun: `THEME_SAMSUN` (turkuaz + altın)
  - Town: `THEME_TOWN` (zeytin + kırmızımsı kahve)
  - Congress: `THEME_CONGRESS` (lacivert + kırmızı)

### 4. Stil Uyum Kontrolü

Referans görseller: [`artworks/`](artworks/) klasöründeki 3 PNG

**Paper Diorama Kuralları:**
1. Organik `path` şekilleri kullan (sert dikdörtgenler yerine doğal eğriler)
2. En az 2 katman: gölge (`opacity: 0.2-0.3`) + ana şekil + vurgu
3. Kalın outline: `stroke-width: 8-18`, renk `#2B2730` (Story Ink)
4. Pastel palet: yüksek doygunluk yerine saydam/soft renkler
5. Cel-shading hissi: düz renk dolgular + belirgin kenar çizgileri

**Teknik SVG standardı:**
```svg
<svg xmlns="http://www.w3.org/2000/svg" width="W" height="H" viewBox="0 0 W H">
  <!-- Katman 1: Gölge / Alt katman -->
  <path d="..." fill="#10202d" opacity="0.22"/>
  <!-- Katman 2: Ana şekil -->
  <path d="..." fill="[ana_renk]"/>
  <!-- Katman 3: Vurgu / Detay -->
  <path d="..." fill="[vurgu_renk]" opacity="0.6-0.8"/>
  <!-- Katman 4: Outline -->
  <path d="..." fill="none" stroke="#2B2730" stroke-width="8-14" stroke-linecap="round"/>
</svg>
```

### 5. Boyut Standartları

| Asset Türü | Boyut | Not |
|-----------|-------|-----|
| Dünya asset'leri | 800-1200 px genişlik | Oyun alanına göre ayarlanır |
| Karakter portreleri | 520×520 px | `rx="80"` yuvarlatılmış köşe |
| UI butonlar | 300-600 px genişlik | Min 104 px yükseklik (thumb-friendly) |
| UI ikonlar | 128-256 px | Vektörel SVG tercih edilir |
| Efekt sprite'ları | Oynama bölgesine göre | PNG + Additive blend |

### 6. Texture Referansını Kaydet

Yeni asset [`scripts/world.gd`](scripts/world.gd) içinde `const` ile preload edilir:

```gdscript
const YENI_ASSET_TEXTURE := preload("res://assets/art/world/bolum/asset_adi.svg")
```

### 7. Import Ayarları (PNG için)

- PNG'ler: `Filter` = Linear, `Repeat` = Disabled
- SVG'ler: `Scale` mode = Bilinear (default)
- Mipmaps: Sadece büyük PNG'lerde aktif et
- Gerekirse `.import` dosyasını manuel düzenle

### 8. Kalite Kontrol Listesi

- [ ] Renk paleti [`scripts/colors.gd`](scripts/colors.gd) ile uyumlu
- [ ] Görsel stil [`artworks/`](artworks/) referanslarıyla tutarlı
- [ ] Çözünürlük 1080×1920 portrait ekrana uygun
- [ ] Paper diorama katman yapısına uygun (gölge + şekil + vurgu)
- [ ] Outline kalınlığı çocuk okunabilirliği için yeterli (8-18 px)
- [ ] Dosya adı `snake_case` formatında
- [ ] Texture constant `SCREAMING_SNAKE_CASE` + `_TEXTURE` ile tanımlı
