## MMAE — Audio Production Doğrulama Aracı
## =============================================
## Tüm beklenen production ses dosyalarının varlığını kontrol eder.
##
## Çalıştırma:
##   godot --headless --script tools/verify_audio_production.gd
##
## Çıkış kodu:
##   0 = tüm dosyalar mevcut
##   1 = eksik dosya var
## =============================================

extends SceneTree


const EXPECTED_BGM: Array[String] = [
	"menu", "explore", "decision", "default",
	"bandirma", "samsun", "havza", "amasya", "kongre"
]

const EXPECTED_SFX: Array[String] = [
	"click", "confirm", "transition"
]


func _init() -> void:
	var missing_bgm: Array[String] = []
	var missing_sfx: Array[String] = []
	var exit_code := 0
	
	# BGM kontrolü
	for name: String in EXPECTED_BGM:
		var path := "res://assets/audio/bgm/%s.ogg" % name
		if not ResourceLoader.exists(path):
			missing_bgm.append(name)
	
	# SFX kontrolü
	for name: String in EXPECTED_SFX:
		var path := "res://assets/audio/sfx/%s.ogg" % name
		if not ResourceLoader.exists(path):
			missing_sfx.append(name)
	
	# Rapor
	if missing_bgm.size() > 0 or missing_sfx.size() > 0:
		print("=== EKSIK SES DOSYALARI ===")
		if missing_bgm.size() > 0:
			print("BGM eksik: %s" % ", ".join(missing_bgm))
		if missing_sfx.size() > 0:
			print("SFX eksik: %s" % ", ".join(missing_sfx))
		exit_code = 1
	else:
		print("Tüm ses dosyaları mevcut. Production-ready.")
	
	# Placeholder uyarısı (info amaçlı)
	print("\nNot: Dosyalar mevcut olsa bile, placeholder sesler hala kullanılıyor olabilir.")
	print("AudioManager._load_stream() önce assets/audio/ klasörünü kontrol eder.")
	print("Eğer dosya bulunursa placeholder yerine production ses kullanılır.")
	
	quit(exit_code)
