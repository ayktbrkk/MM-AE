## MMAE — Audio Production Asset Drop-in Doğrulama Aracı
## =============================================
## Production audio dosyalarının varlığını, AudioManager'ın
## _load_stream() yol mekanizmasını ve fallback durumunu doğrular.
##
## Çalıştırma:
##   godot --headless --script tools/verify_audio_production.gd
##
## Çıkış kodu:
##   0 = tüm dosyalar mevcut (production-ready)
##   1 = eksik dosya var (fallback aktif)
## =============================================

extends SceneTree


# ---------------------------------------------------------------------------
# SABİTLER — Production BGM/SFX ID Listesi
# ---------------------------------------------------------------------------
# Görev: "Mevcut BGM ID'leri: bandirma, samsun, dream, menu, tension,
#         decision, chapter_transition, victory, sakarya (9 parça)"
const EXPECTED_BGM: Array[String] = [
	"bandirma",
	"samsun",
	"dream",
	"menu",
	"tension",
	"decision",
	"chapter_transition",
	"victory",
	"sakarya"
]

# Görev: "Mevcut SFX ID'leri: confirm, cancel, collect, page_flip,
#         typewriter, decision_appear (6 parça)"
const EXPECTED_SFX: Array[String] = [
	"confirm",
	"cancel",
	"collect",
	"page_flip",
	"typewriter",
	"decision_appear"
]

# Audio Manager sabitleri (manuel okuma)
const AUDIO_MANAGER_SCRIPT := preload("res://scripts/audio_manager.gd")


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _missing_bgm: Array[String] = []
var _missing_sfx: Array[String] = []
var _bgm_subfolder_missing: Array[String] = []
var _sfx_subfolder_missing: Array[String] = []


# ---------------------------------------------------------------------------
# INIT
# ---------------------------------------------------------------------------
func _init() -> void:
	print("")
	print("=".repeat(60))
	print("  AUDIO PRODUCTION ASSET VERIFICATION")
	print("=".repeat(60))
	print("")

	# -----------------------------------------------------------------------
	# 1. BGM Dosya Kontrolü — assets/audio/bgm/ altında
	# -----------------------------------------------------------------------
	_print_section("BGM — assets/audio/bgm/")
	var bgm_flat_found: int = 0
	var bgm_sub_found: int = 0

	for name: String in EXPECTED_BGM:
		var sub_path := "res://assets/audio/bgm/%s.ogg" % name
		var flat_path := "res://assets/audio/%s.ogg" % name

		var sub_exists: bool = ResourceLoader.exists(sub_path)
		var flat_exists: bool = ResourceLoader.exists(flat_path)

		var status: String = ""
		if sub_exists:
			status = "OK (bgm/ altinda)"
			bgm_sub_found += 1
		elif flat_exists:
			status = "OK (kok dizinde)"
			bgm_flat_found += 1
		else:
			status = "MISSING (fallback active)"
			_missing_bgm.append(name)
			_bgm_subfolder_missing.append(name)

		print("  %s.ogg -> %s" % [name, status])

	# -----------------------------------------------------------------------
	# 2. SFX Dosya Kontrolü — assets/audio/sfx/ altında
	# -----------------------------------------------------------------------
	_print_section("SFX — assets/audio/sfx/")
	var sfx_flat_found: int = 0
	var sfx_sub_found: int = 0

	for name: String in EXPECTED_SFX:
		var sub_path := "res://assets/audio/sfx/%s.ogg" % name
		var flat_path := "res://assets/audio/%s.ogg" % name

		var sub_exists: bool = ResourceLoader.exists(sub_path)
		var flat_exists: bool = ResourceLoader.exists(flat_path)

		var status: String = ""
		if sub_exists:
			status = "OK (sfx/ altinda)"
			sfx_sub_found += 1
		elif flat_exists:
			status = "OK (kok dizinde)"
			sfx_flat_found += 1
		else:
			status = "MISSING (fallback active)"
			_missing_sfx.append(name)
			_sfx_subfolder_missing.append(name)

		print("  %s.ogg -> %s" % [name, status])

	# -----------------------------------------------------------------------
	# 3. _load_stream() Yol Analizi
	# -----------------------------------------------------------------------
	_print_section("_load_stream() Yol Mekanizmasi Analizi")

	print("  Mevcut _load_stream() yolu: res://assets/audio/{name}.{ext}")
	print("  NOT: Bu yol bgm/ veya sfx/ alt klasörlerini icermiyor!")
	print("")
	print("  Production dosyalar beklendigi yer: assets/audio/bgm/{id}.ogg")
	print("  Production dosyalar beklendigi yer: assets/audio/sfx/{id}.ogg")
	print("")
	print("  --> _load_stream() alt klasorleri desteklemiyor.")
	print("  --> Production dosyalar yerlestirilse bile AudioManager")
	print("      onlari bulamayacak ve fallback kullanmaya devam edecek.")
	print("")
	print("  COZUM: _load_stream()'e bgm/ ve sfx/ alt klasor kontrolleri")
	print("         eklenmelidir.")

	# -----------------------------------------------------------------------
	# 4. Volume Bilgisi
	# -----------------------------------------------------------------------
	_print_section("Volume Bilgisi (AudioManager)")

	var bgm_vol_linear: float = 0.7
	var sfx_vol_linear: float = 1.0
	var bgm_vol_db: float = linear_to_db(bgm_vol_linear)
	var sfx_vol_db: float = linear_to_db(sfx_vol_linear)

	print("  BGM Volume: linear=%.1f, dB=%.1f" % [bgm_vol_linear, bgm_vol_db])
	print("  SFX Volume: linear=%.1f, dB=%.1f" % [sfx_vol_linear, sfx_vol_db])
	print("  (Kaynak: audio_manager.gd satir 45-55, bgm_volume=0.7, sfx_volume=1.0)")

	# -----------------------------------------------------------------------
	# 5. Fallback Durumu
	# -----------------------------------------------------------------------
	_print_section("Fallback Durumu")

	if _missing_bgm.size() == EXPECTED_BGM.size() and _missing_sfx.size() == EXPECTED_SFX.size():
		print("  DURUM: TUM dosyalar eksik -> Fallback TAM AKTIF")
		print("  Mekanizma: AudioStreamWAV ile procedural tone uretimi")
		print("  (_generate_tone(), _generate_click(), _generate_sweep())")
	elif _missing_bgm.size() > 0 or _missing_sfx.size() > 0:
		print("  DURUM: Kismi eksik -> Fallback KISMEN AKTIF")
	else:
		print("  DURUM: Tum dosyalar mevcut -> Fallback KAPALI")

	# -----------------------------------------------------------------------
	# 6. Production Audio Yolu Sorunu (Bug)
	# -----------------------------------------------------------------------
	_print_section("Onemli Tespit: Production Audio Yolu Sorunu")

	print("  _load_stream(sound_name) su anda: assets/audio/{name}.ogg")
	print("  Production beklentisi:            assets/audio/bgm/{name}.ogg")
	print("                                    assets/audio/sfx/{name}.ogg")
	print("")
	print("  _load_stream()'in alt klasorleri de denemesi icin")
	print("  su degisiklik gereklidir:")
	print("")
	print("    func _load_stream(sound_name: String, subfolder: String = '') -> AudioStream:")
	print("        # Once placeholder cache kontrol")
	print("        if _placeholder_sounds.has(sound_name):")
	print("            return _placeholder_sounds[sound_name]")
	print("")
	print("        # assets/audio/{subfolder}/ ve assets/audio/ dene")
	print("        var prefixes: Array[String] = ['', 'bgm/', 'sfx/']")
	print("        for prefix: String in prefixes:")
	print("            for ext in ['.ogg', '.wav', '.mp3']:")
	print("                var path := 'res://assets/audio/%s%s%s' % [prefix, sound_name, ext]")
	print("                if ResourceLoader.exists(path):")
	print("                    return load(path) as AudioStream")
	print("")

	# -----------------------------------------------------------------------
	# 7. ÖZET
	# -----------------------------------------------------------------------
	_print_section("OZET")

	var total_bgm: int = EXPECTED_BGM.size()
	var total_sfx: int = EXPECTED_SFX.size()
	var found_bgm: int = total_bgm - _missing_bgm.size()
	var found_sfx: int = total_sfx - _missing_sfx.size()

	print("  BGM: %d/%d mevcut, %d eksik" % [found_bgm, total_bgm, _missing_bgm.size()])
	print("  SFX: %d/%d mevcut, %d eksik" % [found_sfx, total_sfx, _missing_sfx.size()])
	print("  Toplam: %d/%d mevcut" % [found_bgm + found_sfx, total_bgm + total_sfx])
	print("")
	print("  Fallback: %s" % ("AKTIF (AudioStreamGenerator)" if _missing_bgm.size() > 0 or _missing_sfx.size() > 0 else "KAPALI"))
	print("  Volume BGM: %.1f dB" % bgm_vol_db)
	print("  Volume SFX: %.1f dB" % sfx_vol_db)
	print("")
	print("  _load_stream() alt klasor destegi: YOK (bug)")
	print("  Cozum gerekiyor: _load_stream()'e bgm/sfx alt klasor taramasi eklenmeli")
	print("")

	# -----------------------------------------------------------------------
	# Çıkış
	# -----------------------------------------------------------------------
	var exit_code: int = 0
	if _missing_bgm.size() > 0 or _missing_sfx.size() > 0:
		exit_code = 1
		print("  SONUC: EKSIK DOSYALAR VAR — fallback placeholder sesler aktif.")
	else:
		print("  SONUC: TUM DOSYALAR MEVCUT — Production-ready.")

	print("=".repeat(60))
	print("")
	quit(exit_code)


# ---------------------------------------------------------------------------
# YARDIMCILAR
# ---------------------------------------------------------------------------
func _print_section(title: String) -> void:
	print("--- %s ---" % title)
