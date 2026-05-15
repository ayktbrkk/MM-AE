extends Node

# ---------------------------------------------------------------------------
# audio_manager.gd — P6: Ses sistemi
# ---------------------
# Autoload singleton. Runtime'da AudioStreamPlayer node'lari olusturur.
# BGM ve SFX kanallari ayridir.
#
# assets/audio/ klasoru bos oldugu surece procedural (programatik) ses
# ureteci devreye girer. Gercek ses dosyalari eklendiginde otomatik
# olarak oncelik kazanir.
#
# Kullanim:
#   AudioManager.play_bgm("BGM_MENU")
#   AudioManager.play_sfx("SFX_CLICK")
#   AudioManager.stop_bgm()
#   AudioManager.set_bgm_volume(0.8)
#   AudioManager.get_bgm_volume() -> 0.8
# ---------------------------------------------------------------------------

# Sinyaller
signal bgm_started(bgm_name: String)
signal bgm_stopped()
signal sfx_played(sfx_name: String)
signal master_volume_changed(value: float)
signal bgm_volume_changed(value: float)
signal sfx_volume_changed(value: float)

# Sabitler
const BGM_BUS := "BGM"
const SFX_BUS := "SFX"
const MASTER_BUS := "Master"

# Procedural ses sabitleri
const PLACEHOLDER_SAMPLE_RATE := 22050  # Mobile performans icin dusuk kalite
const BGM_LOOP_DURATION := 4.0  # 4 saniyelik loop

# Varsayilan ses seviyeleri (0.0 - 1.0)
var master_volume: float = 1.0:
	set(value):
		master_volume = clampf(value, 0.0, 1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MASTER_BUS), linear_to_db(master_volume))
		master_volume_changed.emit(master_volume)

var bgm_volume: float = 0.7:
	set(value):
		bgm_volume = clampf(value, 0.0, 1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BGM_BUS), linear_to_db(bgm_volume))
		bgm_volume_changed.emit(bgm_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), linear_to_db(sfx_volume))
		sfx_volume_changed.emit(sfx_volume)

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _current_bgm_name: String = ""
var _bgm_fade_tween: Tween
var _audio_disabled := false
var _app_paused := false
var _is_android := false  # Android tespiti — native crash onlemi icin
var _android_audio_ready := false  # Android native AudioTrack pipeline hazir mi?
var _android_bgm_pending: Dictionary = {}  # Android'de ertelenmis BGM istegi

# Placeholder ses cache'i — procedural sesler burada saklanir
var _placeholder_sounds: Dictionary = {}


func _ready() -> void:
	_audio_disabled = DisplayServer.get_name() == "headless"
	if _audio_disabled:
		print("[AudioManager] Headless doğrulamada ses kurulumu atlandı.")
		return

	# Android tespiti — native crash onlemi icin
	_is_android = DisplayServer.get_name() == "Android"

	# GECICI COZUM: Xiaomi Android 16'da Godot 4.6.2'nin native
	# AudioTrack pipeline'i (libwilhelm.so -> AudioTrackCallback::onMoreData)
	# SIGSEGV crash'ine neden oluyor. call_deferred, Timer ile erteleme
	# gibi tum yontemler yetersiz kaldi. Bu bir Godot engine bug'i.
	# Cozum: Android'de ses sistemini gecici olarak devre disi birak.
	# Not: Godot 4.6.3+ veya custom build ile fixlenebilir.
	if _is_android:
		print("[AudioManager] Android tespit edildi — native AudioTrack crash onlemi icin ses devre disi.")
		_audio_disabled = true
		return

	# Ses bus'larini olustur (Editor'de otomatik olusmadiysa)
	_ensure_audio_buses()

	# BGM player
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.bus = BGM_BUS
	add_child(_bgm_player)

	# SFX player pool (5 kanal)
	for index in range(5):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % index
		player.bus = SFX_BUS
		add_child(player)
		_sfx_players.append(player)

	# Placeholder sesleri olustur
	_init_placeholder_sounds()

	# Ses asset klasorunu kontrol et
	var audio_dir := DirAccess.open("res://assets/audio")
	if audio_dir:
		print("[AudioManager] assets/audio/ mevcut, ses dosyalari yuklenmeye hazir.")
	else:
		print("[AudioManager] assets/audio/ henuz bos. Procedural placeholder sesler kullaniliyor.")


func _exit_tree() -> void:
	if _audio_disabled:
		return
	_android_bgm_pending = {}
	_cancel_bgm_fade()
	if is_instance_valid(_bgm_player):
		_bgm_player.stop()
		_bgm_player.stream = null
	for player in _sfx_players:
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	_placeholder_sounds.clear()


func _ensure_audio_buses() -> void:
	"""Eksik ses bus'larini olustur (Master varsayilan olarak gelir)."""
	var bus_count := AudioServer.get_bus_count()
	var bus_names: Array[String] = []
	for i in range(bus_count):
		bus_names.append(AudioServer.get_bus_name(i))

	if not MASTER_BUS in bus_names:
		var idx := AudioServer.get_bus_count()
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, MASTER_BUS)

	if not BGM_BUS in bus_names:
		var idx := AudioServer.get_bus_count()
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, BGM_BUS)
		# BGM bus'unu Master'a bagla
		AudioServer.set_bus_send(idx, MASTER_BUS)

	if not SFX_BUS in bus_names:
		var idx := AudioServer.get_bus_count()
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, SFX_BUS)
		AudioServer.set_bus_send(idx, MASTER_BUS)


# ---------------------------------------------------------------------------
# Public API — Volume Kontrol
# ---------------------------------------------------------------------------
func set_bgm_volume(value: float) -> void:
	"""BGM ses seviyesini 0.0-1.0 arasinda ayarla."""
	if _audio_disabled:
		bgm_volume = clampf(value, 0.0, 1.0)
		return
	bgm_volume = value


func get_bgm_volume() -> float:
	"""Mevcut BGM ses seviyesini 0.0-1.0 arasinda dondur."""
	return bgm_volume


func set_sfx_volume(value: float) -> void:
	"""SFX ses seviyesini 0.0-1.0 arasinda ayarla."""
	if _audio_disabled:
		sfx_volume = clampf(value, 0.0, 1.0)
		return
	sfx_volume = value


func get_sfx_volume() -> float:
	"""Mevcut SFX ses seviyesini 0.0-1.0 arasinda dondur."""
	return sfx_volume


# ---------------------------------------------------------------------------
# Public API — BGM
# ---------------------------------------------------------------------------
func play_bgm(bgm_name: String, fade_in: float = 0.5) -> void:
	"""BGM'yi calistir. Stream bulunamazsa procedural placeholder kullanir."""
	if _audio_disabled:
		return
	if bgm_name == _current_bgm_name and _bgm_player.playing:
		return

	var stream: AudioStream = _load_stream(bgm_name)
	if not stream:
		return

	_cancel_bgm_fade()
	if _bgm_player.playing:
		var tween := create_tween()
		_bgm_fade_tween = tween
		tween.finished.connect(_clear_bgm_fade_tween)
		tween.tween_method(_set_bgm_volume_ratio, _current_bgm_volume_ratio(), 0.0, 0.3)
		tween.tween_callback(Callable(self, "_start_bgm_stream").bind(stream, bgm_name, fade_in))
		return

	_start_bgm_stream(stream, bgm_name, fade_in)


func stop_bgm(fade_out: float = 0.5) -> void:
	"""BGM'yi durdur. fade_out saniyede sessizlesir."""
	if _audio_disabled:
		return
	if not _bgm_player.playing:
		return

	_cancel_bgm_fade()
	if fade_out > 0.0:
		var tween := create_tween()
		_bgm_fade_tween = tween
		tween.finished.connect(_clear_bgm_fade_tween)
		tween.tween_method(_set_bgm_volume_ratio, _current_bgm_volume_ratio(), 0.0, fade_out)
		tween.tween_callback(Callable(self, "_stop_bgm_immediately"))
		return
	_stop_bgm_immediately()


func crossfade_bgm(bgm_name: String, fade_duration: float = 1.0) -> void:
	"""Mevcut BGM'den yeni BGM'ye crossfade yap.

	Eski BGM'yi fade_out süresinde kısarken yeni BGM'yi fade_in süresinde açar.
	Her iki BGM de geçiş süresince kısa bir an birlikte duyulur.
	"""
	if _audio_disabled:
		return
	if bgm_name == _current_bgm_name and _bgm_player.playing:
		return

	var stream: AudioStream = _load_stream(bgm_name)
	if not stream:
		return

	# Eski BGM'yi fade out, yeni BGM'yi fade in ile başlat
	_cancel_bgm_fade()
	var half_fade: float = fade_duration * 0.5

	if _bgm_player.playing:
		var tween := create_tween()
		_bgm_fade_tween = tween
		tween.finished.connect(_clear_bgm_fade_tween)
		# Fade out mevcut
		tween.tween_method(_set_bgm_volume_ratio, _current_bgm_volume_ratio(), 0.0, half_fade)
		# Yeni BGM'yi başlat ve fade in
		tween.tween_callback(Callable(self, "_start_bgm_stream").bind(stream, bgm_name, half_fade))
		return

	# Hiçbir şey çalmıyorsa direkt başlat
	_start_bgm_stream(stream, bgm_name, fade_duration)


func is_bgm_playing() -> bool:
	if _audio_disabled:
		return false
	return _bgm_player.playing


func set_app_paused(paused: bool) -> void:
	if _audio_disabled or _app_paused == paused:
		_app_paused = paused
		return
	_app_paused = paused
	if is_instance_valid(_bgm_player):
		_bgm_player.stream_paused = paused
	for player in _sfx_players:
		if is_instance_valid(player):
			player.stream_paused = paused


func is_app_paused() -> bool:
	return _app_paused


# ---------------------------------------------------------------------------
# Public API — SFX
# ---------------------------------------------------------------------------
func play_sfx(sfx_name: String, volume_ratio: float = 1.0) -> void:
	"""Ses efektini calistir. Bos havuza sahip player bulur."""
	if _audio_disabled:
		return
	var stream: AudioStream = _load_stream(sfx_name)
	if not stream:
		return

	var player := _available_sfx_player()
	if not player:
		return

	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume * volume_ratio)
	player.play()
	sfx_played.emit(sfx_name)


# ---------------------------------------------------------------------------
# Internal — Stream Yukleme
# ---------------------------------------------------------------------------
func _load_stream(sound_name: String) -> AudioStream:
	"""Once placeholder cache'e, sonra assets/audio/ klasorune bakar.
	Bulamazsa talep uzerine yeni placeholder uretir."""
	# 1. Placeholder cache kontrol
	if _placeholder_sounds.has(sound_name):
		return _placeholder_sounds[sound_name]

	# 2. assets/audio/ klasorundeki dosyalari dene
	for ext in [".ogg", ".wav", ".mp3"]:
		var path := "res://assets/audio/%s%s" % [sound_name, ext]
		if ResourceLoader.exists(path):
			return load(path) as AudioStream

	# 3. Talep uzerine placeholder uret ve cache'e ekle
	var stream := _generate_placeholder_sound(sound_name)
	if stream:
		_placeholder_sounds[sound_name] = stream
		print("[AudioManager] Placeholder ses uretildi: %s (freq=%d)" % [sound_name, _guess_frequency(sound_name)])
		return stream

	return null


func _available_sfx_player() -> AudioStreamPlayer:
	"""Mevcut en eski bos SFX player'ini dondur."""
	for player in _sfx_players:
		if not player.playing:
			return player
	# Tum doluysa ilkini kullan (kanal asimi)
	return _sfx_players[0]


# ---------------------------------------------------------------------------
# Procedural Ses Uretici — Placeholder'lar
# ---------------------------------------------------------------------------
func _init_placeholder_sounds() -> void:
	"""Baslica placeholder sesleri onceden olustur."""
	# BGM'ler (looping)
	_placeholder_sounds["BGM_MENU"] = _generate_tone(220.0, BGM_LOOP_DURATION, true)       # Sakin, ana menu
	_placeholder_sounds["BGM_EXPLORE"] = _generate_tone(180.0, BGM_LOOP_DURATION, true)    # Yumusak, kesif
	_placeholder_sounds["BGM_DECISION"] = _generate_tone(260.0, BGM_LOOP_DURATION, true)   # Gerilim, karar ani

	# Bolum BGM'leri (farkli frekanslar)
	_placeholder_sounds["bgm_default"] = _generate_tone(200.0, BGM_LOOP_DURATION, true)
	_placeholder_sounds["bgm_bandirma"] = _generate_tone(165.0, BGM_LOOP_DURATION, true)   # Deniz, alcalak
	_placeholder_sounds["bgm_samsun"] = _generate_tone(195.0, BGM_LOOP_DURATION, true)     # Umut, orta
	_placeholder_sounds["bgm_havza"] = _generate_tone(210.0, BGM_LOOP_DURATION, true)      # Hareketli
	_placeholder_sounds["bgm_amasya"] = _generate_tone(230.0, BGM_LOOP_DURATION, true)     # Kararli
	_placeholder_sounds["bgm_kongre"] = _generate_tone(250.0, BGM_LOOP_DURATION, true)     # Yükselen

	# SFX'ler (kisa)
	_placeholder_sounds["SFX_CLICK"] = _generate_click()                         # Tik: 800Hz
	_placeholder_sounds["SFX_CONFIRM"] = _generate_sweep(440.0, 880.0, 0.15)    # Onay: 440→880Hz
	_placeholder_sounds["SFX_TRANSITION"] = _generate_tone(120.0, 0.3, false)   # Gecis: dusuk

	# Oda ortami (world.gd'de kullanilan eski referans)
	_placeholder_sounds["room_ambient"] = _generate_tone(150.0, BGM_LOOP_DURATION, true)

	print("[AudioManager] %d placeholder ses olusturuldu." % _placeholder_sounds.size())


func _generate_placeholder_sound(sound_name: String) -> AudioStreamWAV:
	"""Bilinmeyen bir ses adi icin otomatik placeholder uret."""
	var freq: float = _guess_frequency(sound_name)
	var is_bgm: bool = sound_name.begins_with("BGM_") or sound_name.begins_with("bgm_")
	return _generate_tone(freq, BGM_LOOP_DURATION if is_bgm else 0.3, is_bgm)


func _guess_frequency(sound_name: String) -> float:
	"""Ses adina gore mantikli bir frekans tahmini yap."""
	if sound_name.begins_with("BGM_") or sound_name.begins_with("bgm_"):
		# BGM'ler icin 150-300Hz arasi
		var hash_val: int = abs(sound_name.hash())
		return 150.0 + float(hash_val % 150)
	# SFX'ler icin 400-900Hz arasi
	var sfx_hash_val: int = abs(sound_name.hash())
	return 400.0 + float(sfx_hash_val % 500)


# ---------------------------------------------------------------------------
# Static Yardimcilar — Ses Uretimi
# ---------------------------------------------------------------------------
static func _generate_tone(frequency: float, duration: float, loop: bool = false) -> AudioStreamWAV:
	"""Belirtilen frekansta sinüs dalgasi uretir.
	Parametreler:
	- frequency: Hz cinsinden frekans
	- duration: saniye cinsinden sure
	- loop: True ise sonsuz donguye alinir (BGM icin)
	Donus: AudioStreamWAV (16-bit, mono, 22050Hz)"""
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = PLACEHOLDER_SAMPLE_RATE
	stream.stereo = false

	var sample_rate: int = PLACEHOLDER_SAMPLE_RATE
	var total_samples: int = maxi(1, int(sample_rate * duration))
	var data := PackedByteArray()
	data.resize(total_samples * 2)  # 16-bit = 2 bytes per sample

	var fade_samples: int = mini(200, int(total_samples / 4.0))

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		# Sinüs dalgasi
		var sample: float = sin(2.0 * PI * frequency * t)

		# Zarf (envelope) — tıklama önleme
		var envelope: float = 1.0
		if i < fade_samples:
			envelope = float(i) / float(fade_samples)  # Fade in
		elif i > total_samples - fade_samples:
			envelope = float(total_samples - i) / float(fade_samples)  # Fade out

		sample *= envelope * 0.35  # %35 maksimum amplitude (distorsiyon onlemi)

		var val: int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	stream.data = data

	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = total_samples

	return stream


static func _generate_click() -> AudioStreamWAV:
	"""Kisa tik sesi (800Hz, 50ms). Buton tiklamalari icin."""
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = PLACEHOLDER_SAMPLE_RATE
	stream.stereo = false

	var sample_rate: int = PLACEHOLDER_SAMPLE_RATE
	var total_samples: int = int(sample_rate * 0.05)
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var sample: float = sin(2.0 * PI * 800.0 * t)
		# Hizli sönümleme
		var envelope: float = 1.0 - (float(i) / float(total_samples))
		sample *= envelope * 0.25

		var val: int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	stream.data = data
	return stream


static func _generate_sweep(start_freq: float, end_freq: float, duration: float) -> AudioStreamWAV:
	"""Frekans kaydirmali ses (sweep). Onay efektleri icin.
	Ornek: SFX_CONFIRM = _generate_sweep(440.0, 880.0, 0.15)"""
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = PLACEHOLDER_SAMPLE_RATE
	stream.stereo = false

	var sample_rate: int = PLACEHOLDER_SAMPLE_RATE
	var total_samples: int = maxi(1, int(sample_rate * duration))
	var data := PackedByteArray()
	data.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(total_samples)
		var freq: float = lerpf(start_freq, end_freq, t)
		var phase: float = 2.0 * PI * freq * float(i) / float(sample_rate)
		var sample: float = sin(phase)
		# Hafif sönümleme
		var envelope: float = 1.0 - t * 0.4
		sample *= envelope * 0.3

		var val: int = int(clamp(sample * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)

	stream.data = data
	return stream


# ---------------------------------------------------------------------------
# Internal — Fade Mekanizmasi
# ---------------------------------------------------------------------------
func _start_bgm_stream(stream: AudioStream, bgm_name: String, fade_in: float) -> void:
	if not is_instance_valid(_bgm_player):
		return

	# Android'de ses devre disi, buraya hic gelinmemeli ama guvenlik olsun
	if _is_android and _audio_disabled:
		return

	_start_bgm_stream_impl(stream, bgm_name, fade_in)


func _start_bgm_stream_impl(stream: AudioStream, bgm_name: String, fade_in: float) -> void:
	if not is_instance_valid(_bgm_player):
		return
	_bgm_player.stop()
	_bgm_player.stream = stream
	_bgm_player.volume_db = linear_to_db(0.0)
	_bgm_player.play()
	_current_bgm_name = bgm_name
	bgm_started.emit(bgm_name)
	if fade_in > 0.0:
		var tween := create_tween()
		_bgm_fade_tween = tween
		tween.finished.connect(_clear_bgm_fade_tween)
		tween.tween_method(_set_bgm_volume_ratio, 0.0, bgm_volume, fade_in)
		return
	_set_bgm_volume_ratio(bgm_volume)


func _stop_bgm_immediately() -> void:
	if not is_instance_valid(_bgm_player):
		return
	_bgm_player.stop()
	_bgm_player.stream = null
	_current_bgm_name = ""
	bgm_stopped.emit()


func _cancel_bgm_fade() -> void:
	if _bgm_fade_tween != null:
		_bgm_fade_tween.kill()
		_bgm_fade_tween = null


func _clear_bgm_fade_tween() -> void:
	_bgm_fade_tween = null


func _set_bgm_volume_ratio(value: float) -> void:
	if not is_instance_valid(_bgm_player):
		return
	if value <= 0.0:
		_bgm_player.volume_db = linear_to_db(0.0)
		return
	_bgm_player.volume_db = linear_to_db(value)


func _current_bgm_volume_ratio() -> float:
	if not is_instance_valid(_bgm_player) or not _bgm_player.playing:
		return 0.0
	if is_inf(_bgm_player.volume_db) and _bgm_player.volume_db < 0.0:
		return 0.0
	return db_to_linear(_bgm_player.volume_db)
