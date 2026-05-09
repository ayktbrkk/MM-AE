# UI Auto-Layout Skill - Godot Container Yapıları ile Otomatik Düzenleme

Bu skill, Godot 4'ün Control düğümlerini ve Container yapılarını kullanarak responsive UI düzenlemeyi öğretir.

## Godot 4 Container Türleri

### 1. MarginContainer - Kenar Boşlukları
```
En dış katman için idealdir.
├── Theme: MarginContainer
│   ├── theme_override/constants/margin_left = 24
│   ├── theme_override/constants/margin_top = 24
│   ├── theme_override/constants/margin_right = 24
│   └── theme_override/constants/margin_bottom = 24
```

### 2. VBoxContainer - Dikey Hizalama
```
Elemanları dikeyde sıralar.
├── Theme: VBoxContainer
│   ├── Button 1
│   ├── Button 2
│   └── Button 3
```

### 3. HBoxContainer - Yatay Hizalama
```
Elemanları yatayda sıralar.
├── Theme: HBoxContainer
│   ├── Icon
│   ├── Label (size_flags_horizontal = 3 → expand)
│   └── Button
```

### 4. GridContainer - Izgara Düzeni
```
Sabit sütun sayısı ile ızgarada sıralar.
├── Theme: GridContainer
│   ├── columns = 2
│   ├── Item 1    ├── Item 2
│   ├── Item 3    ├── Item 4
```

### 5. CenterContainer - Ortalama
```
Çocukları merkeze hizalar.
├── Theme: CenterContainer
│   └── (Çocuk otomatik ortalanır)
```

### 6. Control (Layout Mode = Anchors) - Tam Ekran
```
Root düğüm için ideal.
├── Theme: Control
│   ├── Layout > Mode: Anchors
│   ├── Anchor: Full Rect
│   └── (Tüm UI buraya gömülür)
```

## MMAE Projesi İçin UI Şablonları

### Diyalog Paneli (Dialogue Overlay)
```
CanvasLayer (full rect)
└── Control (full rect)
    ├── PortraitLayer (anchors: top)
    │   ├── LeftPortrait (TextureRect, center-left)
    │   └── RightPortrait (TextureRect, center-right)
    ├── BackdropSoft (ColorRect, full rect)
    ├── PanelGlow (ColorRect, bottom half)
    └── BottomArea (anchors: bottom)
        └── DialoguePanel (MarginContainer)
            └── VBoxContainer
                ├── HeaderRow
                │   └── HeaderText
                │       ├── ChapterLabel
                │       └── NameLabel
                ├── BodyText (RichTextLabel, expand fill)
                └── ContinueRow (HBoxContainer)
                    ├── ContinueIcon
                    └── ContinueLabel
```

### Karar Kartları (Decision Overlay)
```
CanvasLayer (full rect)
└── CenterContainer
    └── VBoxContainer
        ├── TitleLabel (h_align = center)
        ├── StoryLabel (autowrap, expand)
        ├── HBoxContainer (seçenekler)
        │   ├── OptionAPanel (PanelContainer)
        │   │   └── MarginContainer > Label
        │   └── OptionBPanel (PanelContainer)
        │       └── MarginContainer > Label
        └── InfoButton (alignment = center)
```

## Altın Kurallar

1. **Position kullanma, Container kullan** - Manuel pozisyonlama yerine Container nesting yap
2. **size_flags_horizontal/vertical** kullan:
   - `0` = shrink center (sabit boyut)
   - `1` = shrink begin (sola yasla)
   - `3` = expand fill (kalan alanı doldur)
   - `4` = expand (genişle, eşit dağıt)
3. **theme_overrides** kullan - Stilleri her node'da ayrı ayrı tanımlamak yerine merkezi tema kullan
4. **Anchor presets** kullan - "Full Rect", "Bottom Wide", "Center" gibi hazır preset'ler
5. **Control margins** - Kenar boşlukları için margin kullan, position değil
6. **Safe area** - Mobile için güvenli alan margin'lerini unutma (24-28px)
