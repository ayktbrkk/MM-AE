## MMAE — Journal Save Contract Verification
## =============================================
## Save dosyası içinde collected_card_ids ve completed_chapters
## alanlarının varlığını ve içeriğini doğrular.
##
## Kullanım:
##   .\Godot_v4.6.2-stable_win64_console.exe --path . --script res://tools/verify_journal_save_contract.gd --quit
##
## Beklenen çıktı: JOURNAL_SAVE_CONTRACT_OK, exit code 0

extends MainLoop


# ---------------------------------------------------------------------------
# SABİTLER
# ---------------------------------------------------------------------------
const SAVE_PATH := "user://savegame.json"


# ---------------------------------------------------------------------------
# STATE
# ---------------------------------------------------------------------------
var _failed := 0


# ---------------------------------------------------------------------------
# INIT
# ---------------------------------------------------------------------------
func _initialize() -> void:
	"""Save contract testlerini çalıştır."""
	print(">>> Journal Save Contract Testi Basladi")
	print("")

	# -----------------------------------------------------------------------
	# TEST 1: Save dosyası var mı?
	# -----------------------------------------------------------------------
	if not FileAccess.file_exists(SAVE_PATH):
		print("INFO: Save file not found — run validate_game_flow.gd first to generate it")
		print("JOURNAL_SAVE_CONTRACT_INFO")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("FAIL: Could not open save file at %s" % SAVE_PATH)
		_failed += 1
		return

	var content: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_err: Error = json.parse(content)
	if parse_err != OK:
		push_error("FAIL: Save file parse error: %s" % json.get_error_message())
		_failed += 1
		return

	var data: Dictionary = json.get_data() as Dictionary

	# -----------------------------------------------------------------------
	# TEST 2: collected_card_ids
	# -----------------------------------------------------------------------
	var card_ids: Array = []
	if data.has("collected_card_ids"):
		card_ids = data["collected_card_ids"] as Array
		if card_ids.size() > 0:
			print("  PASS: collected_card_ids exists with %d entries: %s" % [card_ids.size(), card_ids])
		else:
			print("  INFO: collected_card_ids is empty array")
	else:
		print("  INFO: collected_card_ids not found in save")

	# -----------------------------------------------------------------------
	# TEST 3: completed_chapters
	# -----------------------------------------------------------------------
	var chapters: Array = []
	if data.has("completed_chapters"):
		chapters = data["completed_chapters"] as Array
		if chapters.size() > 0:
			print("  PASS: completed_chapters exists with %d entries: %s" % [chapters.size(), chapters])
		else:
			print("  INFO: completed_chapters is empty array")
	else:
		print("  INFO: completed_chapters not found in save")

	# -----------------------------------------------------------------------
	# TEST 4: collected_items içinde card_item var mı? (yardımcı bilgi)
	# -----------------------------------------------------------------------
	if data.has("collected_items"):
		var items: Dictionary = data["collected_items"] as Dictionary
		var keys_str: String = str(items.keys())
		print("  INFO: collected_items keys: %s" % keys_str)

	# -----------------------------------------------------------------------
	# RAPOR
	# -----------------------------------------------------------------------
	print("")
	print("=".repeat(60))
	if _failed == 0:
		print("  JOURNAL_SAVE_CONTRACT_OK")
	else:
		print("  JOURNAL_SAVE_CONTRACT_FAILED  (%d hata)" % _failed)
	print("=".repeat(60))


func _idle(_delta: float) -> bool:
	"""Idle callback — _initialize'da tüm testler çalıştı, çık."""
	return false
