extends Node

# ---------------------------------------------------------------------------
# audio_manager.gd — P6: Ses sistemi
# ---------------------
# Autoload singleton. Runtime'da AudioStreamPlayer node'lari olusturur.
# BGM ve SFX kanallari ayridir. Ses asset'leri henuz yok, bu nedenle
# tum cagrilar sessizce basarisiz olur (hata vermez).
#
# Kullanim:
#   AudioManager.play_bgm("samsun_dawn")
#   AudioManager.play_sfx("collect_paper")
#   AudioManager.stop_bgm()
#   AudioManager.set_master_volume(0.8)
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

# Geçici asset placeholder — ses dosyalari gelince preload() ile degistirilir
var _placeholder_stream := AudioStreamWAV.new()


func _ready() -> void:
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

	# Ses asset klasörünü kontrol et
	var audio_dir := DirAccess.open("res://assets/audio")
	if audio_dir:
		print("[AudioManager] assets/audio/ mevcut, ses dosyalari yuklenmeye hazir.")
	else:
		print("[AudioManager] assets/audio/ henuz bos. Ses dosyalari eklendiginde calisir.")


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
# Public API — BGM
# ---------------------------------------------------------------------------
func play_bgm(bgm_name: String, fade_in: float = 0.5) -> void:
	"""BGM'yi calistir. Stream bulunamazsa sessizce basarisiz olur."""
	if bgm_name == _current_bgm_name:
		return

	var stream: AudioStream = _load_stream(bgm_name)
	if not stream:
		return

	# fade_out varsa once durdur
	if _bgm_player.playing:
		await _fade_out(_bgm_player, 0.3)

	_bgm_player.stream = stream
	_bgm_player.volume_db = linear_to_db(0.0)
	_bgm_player.play()
	_current_bgm_name = bgm_name
	bgm_started.emit(bgm_name)

	if fade_in > 0.0:
		await _fade_in(_bgm_player, fade_in)
	_bgm_player.volume_db = linear_to_db(bgm_volume)


func stop_bgm(fade_out: float = 0.5) -> void:
	"""BGM'yi durdur. fade_out saniyede sessizlesir."""
	if not _bgm_player.playing:
		return

	if fade_out > 0.0:
		await _fade_out(_bgm_player, fade_out)
	_bgm_player.stop()
	_bgm_player.stream = null
	_current_bgm_name = ""
	bgm_stopped.emit()


func is_bgm_playing() -> bool:
	return _bgm_player.playing


# ---------------------------------------------------------------------------
# Public API — SFX
# ---------------------------------------------------------------------------
func play_sfx(sfx_name: String, volume_ratio: float = 1.0) -> void:
	"""Ses efektini calistir. Bos havuza sahip player bulur."""
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
# Internal
# ---------------------------------------------------------------------------
func _load_stream(resource_name: String) -> AudioStream:
	"""res://assets/audio/ altinda stream dosyasini yuklemeyi dener.
	Henuz dosya yoksa placeholder dondurur (sessiz)."""
	var path := "res://assets/audio/%s.ogg" % resource_name
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	# .wav alternatif
	path = "res://assets/audio/%s.wav" % resource_name
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	# .mp3 alternatif
	path = "res://assets/audio/%s.mp3" % resource_name
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null


func _available_sfx_player() -> AudioStreamPlayer:
	"""Mevcut en eski bos SFX player'ini dondur."""
	for player in _sfx_players:
		if not player.playing:
			return player
	# Tum doluysa ilkini kullan (kanal asimi)
	return _sfx_players[0]


func _fade_out(player: AudioStreamPlayer, duration: float) -> void:
	"""Player volume'unu linear 0.0'a dusur."""
	if not is_instance_valid(player):
		return
	var tween := create_tween()
	tween.tween_method(func(v: float): player.volume_db = linear_to_db(v), 1.0, 0.0, duration)
	await tween.finished


func _fade_in(player: AudioStreamPlayer, duration: float) -> void:
	"""Player volume'unu linear 1.0'a cikar."""
	if not is_instance_valid(player):
		return
	var target_volume := bgm_volume
	var tween := create_tween()
	tween.tween_method(func(v: float): player.volume_db = linear_to_db(v), 0.0, target_volume, duration)
	await tween.finished
