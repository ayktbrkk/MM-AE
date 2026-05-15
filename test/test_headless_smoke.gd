## MMAE — Headless Smoke Test
## ============================
## Sadece headless-safe testleri çalıştırır.
## `test_runner.gd`'den farklı olarak:
##   - world.tscn / sahne yüklemesi yapmaz
##   - autoload singleton'larına güvenmez
##   - Sadece FileAccess + RefCounted + constant analizi testlerini içerir
##   - _process döngüsü başlatmaz
##
## Kullanım:
##   Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://test/test_headless_smoke.gd --quit
##
## Çıkış Kodu:
##   0 → tüm testler geçti
##   1 → en az bir test kaldı
##
## Bu smoke test, P10/P11 gate'lerinde CI/CD pipeline'ında çağrılabilir.

extends Node


const SEPARATOR := "============================================="

# RUN_TEST_SCRIPTS — test_runner.gd ile aynı, RefCounted tabanlı, headless-safe
const RUN_TEST_SCRIPTS: Array[Script] = [
	preload("res://test/test_samsun_svg_validity.gd"),
	preload("res://test/test_samsun_svg_properties.gd"),
	preload("res://test/test_samsun_color_properties.gd"),
	preload("res://test/test_samsun_builder_properties.gd"),
	preload("res://test/test_havza_svg_validity.gd"),
	preload("res://test/test_amasya_svg_validity.gd"),
	preload("res://test/test_room_svg_validity.gd"),
	preload("res://test/test_bandirma_svg_validity.gd"),
	preload("res://test/test_bandirma_builder_properties.gd"),
]

# Headless-safe Node tabanlı testler — sadece FileAccess / constant okuma yaparlar.
const HEADLESS_SAFE_TEST_SCRIPTS: Array[Script] = [
	preload("res://test/test_bug_fixes.gd"),
	preload("res://test/test_event_chain.gd"),
	preload("res://test/test_overlay.gd"),
	preload("res://test/test_journal.gd"),
]


func _ready() -> void:
	var passed := 0
	var failed := 0
	var skipped := 0
	var results: Array[String] = []

	# --- Aşama 1: Node tabanlı headless-safe testler ---
	for test_script: Script in HEADLESS_SAFE_TEST_SCRIPTS:
		var test_instance: Node = test_script.new() as Node
		if test_instance == null:
			failed += 1
			results.append("  [KALDI] %s::new() basarisiz" % [test_script.resource_path.get_file().get_basename()])
			continue

		add_child(test_instance)
		var methods := test_instance.get_method_list()
		for method: Dictionary in methods:
			var name: String = method.get("name", "")
			if name.begins_with("test_"):
				var result: Variant = test_instance.call(name)
				if result is String and result == "OK":
					passed += 1
					results.append("  [GECTI] %s::%s" % [test_instance.name, name])
				elif result is String and result.begins_with("SKIP"):
					skipped += 1
					results.append("  [ATLANDI] %s::%s: %s" % [test_instance.name, name, str(result)])
				else:
					failed += 1
					results.append("  [KALDI] %s::%s: %s" % [test_instance.name, name, str(result)])

	# --- Aşama 2: RefCounted RUN_TEST_SCRIPTS ---
	for test_script: Script in RUN_TEST_SCRIPTS:
		var test_ref: RefCounted = test_script.new()
		var summary: Variant = test_ref.run_tests()
		var test_name: String = test_script.resource_path.get_file().get_basename()
		if summary is Dictionary:
			var summary_dict: Dictionary = summary
			var local_passed: int = int(summary_dict.get("passed", 0))
			var local_failed: int = int(summary_dict.get("failed", 0))
			var local_total: int = int(summary_dict.get("total", local_passed + local_failed))
			passed += local_passed
			failed += local_failed
			if local_failed == 0:
				results.append("  [GECTI] %s::run_tests (%d/%d)" % [test_name, local_passed, local_total])
			else:
				results.append("  [KALDI] %s::run_tests (%d/%d)" % [test_name, local_failed, local_total])
		else:
			failed += 1
			results.append("  [KALDI] %s::run_tests: Beklenmeyen sonuc %s" % [test_name, str(summary)])

	# --- Rapor ---
	print("")
	print(SEPARATOR)
	print("    MMAE — HEADLESS SMOKE TEST SONUCLARI")
	print(SEPARATOR)
	print("  (Sadece headless-safe testler calistirildi)")
	print(SEPARATOR)
	for r: String in results:
		print(r)
	print(SEPARATOR)
	print("  Gecen: %d  |  Kalan: %d  |  Atlanan: %d  |  Toplam: %d" % [passed, failed, skipped, passed + failed + skipped])
	print(SEPARATOR)

	if failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)
