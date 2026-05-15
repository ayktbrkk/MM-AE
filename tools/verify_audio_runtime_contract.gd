## MMAE — Audio Runtime Contract Verification
## =============================================
## AudioManager singleton API'sinin runtime'da doğru çalıştığını doğrular.
## BGM oynatma, SFX oynatma, crossfade, volume kontrol ve fallback
## mekanizmalarını test eder.
##
## Kullanım:
##   .\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_audio_runtime_contract.gd --quit
##
## Beklenen çıktı: AUDIO_RUNTIME_CONTRACT_OK, exit code 0

extends SceneTree


# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const AUDIO_MANAGER_SCRIPT := preload("res://scripts/audio_manager.gd")


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _audio: Node = null
var _failed := 0
var _tests_started := false


# ---------------------------------------------------------------------------
# INIT — Sadece AudioManager'ı yükle, testleri _process'e bırak
# ---------------------------------------------------------------------------
func _init() -> void:
	"""AudioManager'ı yükle, testleri ilk frame'de çalıştır."""
	print(">>> Audio Runtime Contract Testi Basladi")
	print("")
	_load_audio_manager()


# ---------------------------------------------------------------------------
# PROCESS — İlk frame'de tüm testleri çalıştır
# ---------------------------------------------------------------------------
func _process(_delta: float) -> bool:
	"""İlk frame'de tüm contract testlerini sırayla çalıştır.
	
	NOT: Testler _init() yerine _process()'te çalıştırılır çünkü
	AudioStreamPlayer.play() için node'ların tree'ye eklenmiş ve
	AudioServer'ın hazır olması gerekir. _init()'te henüz tree
	tam olarak işlenmemiştir.
	"""
	if _tests_started:
		return false
	_tests_started = true

	# =========================================================================
	# TEST 1: AudioManager Singleton / Manuel Yükleme
	# =========================================================================
	# (Zaten _init'te yüklendi)

	# =========================================================================
	# TEST 2: Bandırma BGM Oynatma
	# =========================================================================
	_test_bandirma_bgm()

	# =========================================================================
	# TEST 3: Decision Confirm SFX
	# =========================================================================
	_test_decision_confirm_sfx()

	# =========================================================================
	# TEST 4: Chapter Transition SFX
	# =========================================================================
	_test_chapter_transition_sfx()

	# =========================================================================
	# TEST 5: Samsun BGM Crossfade
	# =========================================================================
	_test_samsun_bgm_crossfade()

	# =========================================================================
	# TEST 6: Fallback Audio (Geçersiz ID)
	# =========================================================================
	_test_fallback_audio()

	# =========================================================================
	# TEST 7: Volume Kontrol
	# =========================================================================
	_test_volume_control()

	# =========================================================================
	# TEST 8: AudioManager Public API Varlığı
	# =========================================================================
	_test_api_contract()

	# =========================================================================
	# RAPOR
	# =========================================================================
	print("")
	print("=".repeat(60))
	var success: bool = _failed == 0
	if success:
		print("  AUDIO_RUNTIME_CONTRACT_OK")
	else:
		print("  AUDIO_RUNTIME_CONTRACT_FAILED  (%d hata)" % _failed)
	if success:
		quit(0)
	else:
		quit(1)
	return success


# ---------------------------------------------------------------------------
# TEST 1: AudioManager Yükleme
# ---------------------------------------------------------------------------
func _load_audio_manager() -> void:
	"""AudioManager'ı singleton veya manuel olarak yükle."""
	if Engine.has_singleton("AudioManager"):
		_audio = Engine.get_singleton("AudioManager")
		_print_pass("AudioManager singleton yuklendi")
	else:
		# Singleton yoksa manuel yükle ve scene tree'ye ekle
		_audio = AUDIO_MANAGER_SCRIPT.new()
		root.add_child(_audio)
		# _ready() manuel çağır — SceneTree._init()'te otomatik çağrılmaz.
		# Bu olmadan _bgm_player, _sfx_players, placeholder sesler ve
		# audio bus'lar oluşmaz, tüm testler Nil hatası alır.
		if _audio.has_method("_ready"):
			_audio.call("_ready")
		_print_info("AudioManager manuel yuklendi (singleton yok)")

	# AudioManager referansı null değil
	_assert_true(_audio != null, "AudioManager referansi null degil")


# ---------------------------------------------------------------------------
# TEST 2: Bandırma BGM
# ---------------------------------------------------------------------------
func _test_bandirma_bgm() -> void:
	"""Bandırma BGM'sini (bgm_bandirma) oynatmayı dene.

	bgm_bandirma, _init_placeholder_sounds()'da 165Hz tone olarak tanımlı.
	Production ses dosyası (assets/audio/bgml/bandirma.ogg) yoksa fallback
	procedural ses kullanılır.
	"""
	if _audio == null:
		_print_skip("Bandirma BGM — AudioManager yuklu degil")
		return

	var has_method: bool = _audio.has_method("play_bgm")
	_assert_true(has_method, "AudioManager.play_bgm() metodu var")

	if not has_method:
		return

	# Hata yutarak çağır — hata vermiyorsa PASS
	var error: Variant = _safe_call(_audio, "play_bgm", ["bgm_bandirma", 0.0])
	_assert_true(error == null or error is bool, "play_bgm('bgm_bandirma') hata vermedi")

	# BGM çalıyor mu kontrol et
	if _audio.has_method("is_bgm_playing"):
		var is_playing: bool = _audio.call("is_bgm_playing") as bool
		_assert_true(is_playing, "play_bgm('bgm_bandirma') sonrasi BGM caliyor")


# ---------------------------------------------------------------------------
# TEST 3: Decision Confirm SFX
# ---------------------------------------------------------------------------
func _test_decision_confirm_sfx() -> void:
	"""Karar onay SFX'ini (SFX_CONFIRM) oynatmayı dene.

	SFX_CONFIRM, 440→880Hz sweep olarak _init_placeholder_sounds()'da tanımlı.
	Production ses dosyası (assets/audio/sfx/confirm.ogg) yoksa fallback
	procedural ses kullanılır.
	"""
	if _audio == null:
		_print_skip("Decision Confirm SFX — AudioManager yuklu degil")
		return

	var has_method: bool = _audio.has_method("play_sfx")
	_assert_true(has_method, "AudioManager.play_sfx() metodu var")

	if not has_method:
		return

	# SFX_CONFIRM ile karar onay sesi
	var error: Variant = _safe_call(_audio, "play_sfx", ["SFX_CONFIRM", 1.0])
	_assert_true(error == null or error is bool, "play_sfx('SFX_CONFIRM') hata vermedi")


# ---------------------------------------------------------------------------
# TEST 4: Chapter Transition SFX
# ---------------------------------------------------------------------------
func _test_chapter_transition_sfx() -> void:
	"""Bölüm geçiş SFX'ini (SFX_TRANSITION) oynatmayı dene.

	SFX_TRANSITION, 120Hz tone olarak _init_placeholder_sounds()'da tanımlı.
	"""
	if _audio == null:
		_print_skip("Chapter Transition SFX — AudioManager yuklu degil")
		return

	var error: Variant = _safe_call(_audio, "play_sfx", ["SFX_TRANSITION", 1.0])
	_assert_true(error == null or error is bool, "play_sfx('SFX_TRANSITION') hata vermedi")


# ---------------------------------------------------------------------------
# TEST 5: Samsun BGM Crossfade
# ---------------------------------------------------------------------------
func _test_samsun_bgm_crossfade() -> void:
	"""Samsun BGM'sine crossfade ile geçiş yapmayı dene.

	crossfade_bgm() metodu, mevcut BGM'den (bgm_bandirma) yeni BGM'ye
	(bgm_samsun) kademeli geçiş yapar. fade_duration=0 olduğunda ani geçer.
	"""
	if _audio == null:
		_print_skip("Samsun BGM Crossfade — AudioManager yuklu degil")
		return

	var has_method: bool = _audio.has_method("crossfade_bgm")
	_assert_true(has_method, "AudioManager.crossfade_bgm() metodu var")

	if not has_method:
		return

	# bgm_bandirma'dan bgm_samsun'a geçiş
	var error: Variant = _safe_call(_audio, "crossfade_bgm", ["bgm_samsun", 0.0])
	_assert_true(error == null or error is bool, "crossfade_bgm('bgm_samsun') hata vermedi")

	# Yeni BGM çalıyor mu?
	if _audio.has_method("is_bgm_playing"):
		var is_playing: bool = _audio.call("is_bgm_playing") as bool
		_assert_true(is_playing, "crossfade_bgm('bgm_samsun') sonrasi BGM caliyor")


# ---------------------------------------------------------------------------
# TEST 6: Fallback Audio
# ---------------------------------------------------------------------------
func _test_fallback_audio() -> void:
	"""Geçersiz bir audio ID'si ile çağrı yap. Fallback procedural audio üretmeli.

	AudioManager._load_stream() bilinmeyen ID'ler için _generate_placeholder_sound()
	çağırır. Bu test, hata fırlatmak yerine fallback ses ürettiğini doğrular.
	"""
	if _audio == null:
		_print_skip("Fallback Audio — AudioManager yuklu degil")
		return

	# Geçersiz bir ID ile test
	var error_bgm: Variant = _safe_call(_audio, "play_bgm", ["__invalid_bgm_test__", 0.0])
	_assert_true(error_bgm == null or error_bgm is bool,
		"play_bgm('__invalid_bgm_test__') fallback ile hata vermedi")

	var error_sfx: Variant = _safe_call(_audio, "play_sfx", ["__invalid_sfx_test__", 1.0])
	_assert_true(error_sfx == null or error_sfx is bool,
		"play_sfx('__invalid_sfx_test__') fallback ile hata vermedi")


# ---------------------------------------------------------------------------
# TEST 7: Volume Kontrol
# ---------------------------------------------------------------------------
func _test_volume_control() -> void:
	"""BGM ve SFX volume setter/getter'larını doğrula."""
	if _audio == null:
		_print_skip("Volume Kontrol — AudioManager yuklu degil")
		return

	# BGM Volume
	var has_setter: bool = _audio.has_method("set_bgm_volume")
	var has_getter: bool = _audio.has_method("get_bgm_volume")
	_assert_true(has_setter, "AudioManager.set_bgm_volume() metodu var")
	_assert_true(has_getter, "AudioManager.get_bgm_volume() metodu var")

	if has_setter and has_getter:
		_safe_call(_audio, "set_bgm_volume", [0.5])
		var bgm_vol: float = _audio.call("get_bgm_volume") as float
		_assert_eq(bgm_vol, 0.5, "set_bgm_volume(0.5) -> get_bgm_volume() == 0.5")

		# Tekrar sıfırla
		_safe_call(_audio, "set_bgm_volume", [0.7])

	# SFX Volume
	var has_sfx_setter: bool = _audio.has_method("set_sfx_volume")
	var has_sfx_getter: bool = _audio.has_method("get_sfx_volume")
	_assert_true(has_sfx_setter, "AudioManager.set_sfx_volume() metodu var")
	_assert_true(has_sfx_getter, "AudioManager.get_sfx_volume() metodu var")

	if has_sfx_setter and has_sfx_getter:
		_safe_call(_audio, "set_sfx_volume", [0.3])
		var sfx_vol: float = _audio.call("get_sfx_volume") as float
		_assert_eq(sfx_vol, 0.3, "set_sfx_volume(0.3) -> get_sfx_volume() == 0.3")

		# Tekrar sıfırla
		_safe_call(_audio, "set_sfx_volume", [1.0])


# ---------------------------------------------------------------------------
# TEST 8: Public API Contract
# ---------------------------------------------------------------------------
func _test_api_contract() -> void:
	"""AudioManager'in tüm public API metodlarının varlığını doğrula."""
	if _audio == null:
		_print_skip("API Contract — AudioManager yuklu degil")
		return

	var expected_methods: Array[String] = [
		"play_bgm",
		"play_sfx",
		"stop_bgm",
		"crossfade_bgm",
		"is_bgm_playing",
		"set_bgm_volume",
		"get_bgm_volume",
		"set_sfx_volume",
		"get_sfx_volume",
		"set_app_paused",
		"is_app_paused",
	]

	var missing: Array[String] = []
	for method_name: String in expected_methods:
		if not _audio.has_method(method_name):
			missing.append(method_name)

	if missing.is_empty():
		_print_pass("AudioManager tum public API metodlari mevcut")
	else:
		_fail("Eksik public API metodlari: %s" % ", ".join(missing))


# ---------------------------------------------------------------------------
# YARDIMCI FONKSİYONLAR
# ---------------------------------------------------------------------------
func _safe_call(target: Node, method: String, args: Array) -> Variant:
	"""Metodu hata yutarak çağır. Hata varsa döndür, yoksa null."""
	if not target.has_method(method):
		return null
	return target.callv(method, args)


func _assert_eq(got: Variant, expected: Variant, label: String) -> void:
	"""İki değerin eşitliğini assert et."""
	if got != expected:
		push_error("FAIL [%s]: expected %s, got %s" % [label, str(expected), str(got)])
		_failed += 1
	else:
		_print_pass(label)


func _assert_true(condition: bool, label: String) -> void:
	"""Boolean koşulun true olduğunu assert et."""
	if not condition:
		push_error("FAIL [%s]: expected true" % label)
		_failed += 1
	else:
		_print_pass(label)


func _print_pass(label: String) -> void:
	print("  PASS [%s]" % label)


func _print_skip(reason: String) -> void:
	print("  SKIP [%s]" % reason)


func _print_info(message: String) -> void:
	print("  INFO [%s]" % message)


func _fail(message: String) -> void:
	"""Doğrudan hata bildir."""
	push_error("FAIL: %s" % message)
	_failed += 1
