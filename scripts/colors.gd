## MMAE - Merkezi Renk Sabitleri
## ===============================
## Tüm renk sabitleri bu dosyada toplanmıştır.
## Diğer scriptlerde `const ... := Color(...)` tekrarını önlemek için:
##   @onready var _colors := preload("res://scripts/colors.gd")
##   sonra `_colors.POP_GOLD` şeklinde kullan
##
## Kaynak: docs/ART_ANALYSIS.md, docs/VISUAL_DESIGN_SYSTEM.md
## Son Güncelleme: 2026-05-09 (artwork analizi sonrası)

## ====================================
## BIRINCI PALET: POP-HISTORY (Popüler Tarih)
## ====================================

## Ana turkuaz - rüya deniz/gökyüzü
const POP_DEEP_TURQUOISE := Color(0.02, 0.47, 0.57)    # #067078

## Açık turkuaz - vurgu
const POP_TURQUOISE := Color(0.04, 0.67, 0.76)          # #0AACC2

## Kırmızı - tarihsel bayrak/karar vurgusu
## Güncelleme: artwork analizine göre topraksı kırmızı (önceden #DB0D1E idi)
const POP_CRIMSON := Color(0.72, 0.18, 0.12)            # #B82E1F

## Altın - başarı/ödül/önemli an
const POP_GOLD := Color(1.0, 0.70, 0.25)                # #FFB340

## Krem - kağıt doku/panel arkaplanı
const POP_CREAM := Color(1.0, 0.90, 0.66)               # #FFE6A8

## Rift mavisi - zaman yolculuğu/düş enerjisi
const RIFT_BLUE := Color(0.22, 0.78, 1.0)               # #38C7FF

## Cel-shading outline - ana çizgi rengi
const CEL_OUTLINE := Color(0.05, 0.07, 0.12)            # #0D121F

## ====================================
## IKINCI PALET: DESIGN SISTEMI (VISUAL_DESIGN_SYSTEM.md)
## ====================================

## Koyu lacivert - derinlik/gece/gökyüzü
const DESIGN_DEEP_NAVY := Color("#20344F")

## Okyanus grisi - orta ton deniz
const DESIGN_OCEAN_SLATE := Color("#355D78")

## Yumuşak turkuaz - doğa/detay
const DESIGN_MUTED_TEAL := Color("#5D8F92")

## Gün batımı altını - sıcak ışık
const DESIGN_SUNSET_GOLD := Color("#F2BE63")

## Sıcak kayısı - karakter vurgusu
const DESIGN_WARM_APRICOT := Color("#E89863")

## Krem kağıt - panel/UI arkaplanı
const DESIGN_CREAM_PAPER := Color("#F5E8D3")

## Yıpranmış ceviz - toprak/ahşap
const DESIGN_WEATHERED_WALNUT := Color("#7A5A42")

## Hikaye mürekkebi - koyu kontrast/metin
const DESIGN_STORY_INK := Color("#2B2730")

## Önplan koyuluk - oda/sahne derinliği
const DESIGN_ROOM_FOREGROUND := Color("#1A2A3A")

## ====================================
## UCUNCU PALET: ARTWORK ANALIZI (docs/ART_ANALYSIS.md)
## ====================================

## Sıcak toprak kahve - ilk sahne dominant (%24)
const ART_WARM_EARTH := Color("#856536")

## Koyu zeytin - ilk sahne gölge (%20)
const ART_DARK_OLIVE := Color("#483f1e")

## Kum beji - orta ton arazi (%18)
const ART_SAND_BEIGE := Color("#887f53")

## Savaş laciverti - mm-ae-independence-war dominant (%21)
const ART_WAR_NAVY := Color("#292c39")

## Kırmızımsı kahve - tarihsel vurgu (%15)
const ART_CRIMSON_BROWN := Color("#7d513a")

## Kestane - derin gölge (%15)
const ART_CHESTNUT := Color("#66321e")

## Açık krema - sahne 1 aydınlık (%18)
const ART_CREAM_LIGHT := Color("#ecdec8")

## Zeytin haki - sahne 1 gölge (%24)
const ART_OLIVE_TAN := Color("#685934")

## ====================================
## DORDUNCU PALET: GOLGE RENKLERI
## ====================================

## Sıcak gölge (mm-ae-independence-war)
const SHADOW_WARM := Color("#1A1510")

## Soğuk gölge (derin deniz/gökyüzü)
const SHADOW_COOL := Color("#0D1520")

## Kağıt gölge (SVG paper asset'lerde kullanılan)
const PAPER_SHADOW := Color("#10202d")

## ====================================
## BESINCI PALET: UI GERI BILDIRIM
## ====================================

const UI_CORRECT_GREEN := Color("#8CCB74")
const UI_RETRY_BLUE := Color("#74A8D7")
const UI_BADGE_GOLD := Color("#FFD768")
const UI_SOFT_ALERT_PLUM := Color("#7A6AA8")
const UI_DISABLED_GREY := Color("#9196A0")

## ====================================
## ALTINCI PALET: KARAKTER RENKLERI
## ====================================

## Arda renkleri
const ARDA_CORAL := Color("#D6674B")
const ARDA_AMBER := Color("#F0A24A")

## Eda renkleri
const EDA_TEAL := Color("#438A87")
const EDA_MIST := Color("#9DD3C8")

## ====================================
## YEDINCI PALET: BOLUM TEMALARI
## ====================================

## Öğrenci Odası: samimi, uykulu, sessiz
const THEME_ROOM := {
	"bg": DESIGN_DEEP_NAVY,
	"accent": DESIGN_SUNSET_GOLD,
	"panel": DESIGN_CREAM_PAPER,
	"shadow": SHADOW_COOL,
	"text": DESIGN_STORY_INK,
}

## Bandırma Vapuru: deniz, sis, macera
const THEME_BANDIRMA := {
	"bg": ART_WAR_NAVY,
	"accent": ART_WARM_EARTH,
	"panel": ART_CREAM_LIGHT,
	"shadow": SHADOW_WARM,
	"text": DESIGN_STORY_INK,
}

## Samsun Rift: varış, umut, rift enerjisi
const THEME_SAMSUN := {
	"bg": POP_DEEP_TURQUOISE,
	"accent": POP_GOLD,
	"panel": DESIGN_CREAM_PAPER,
	"shadow": PAPER_SHADOW,
	"text": DESIGN_STORY_INK,
}

## Havza/Amasya: sivil, toprak, buluşma
const THEME_TOWN := {
	"bg": ART_OLIVE_TAN,
	"accent": ART_CRIMSON_BROWN,
	"panel": ART_CREAM_LIGHT,
	"shadow": SHADOW_WARM,
	"text": DESIGN_STORY_INK,
}

## Kongreler: birlik, karar, tarihsel ağırlık
const THEME_CONGRESS := {
	"bg": ART_WAR_NAVY,
	"accent": POP_CRIMSON,
	"panel": DESIGN_CREAM_PAPER,
	"shadow": SHADOW_WARM,
	"text": DESIGN_STORY_INK,
}
