## MMAE — E2E Test Koşucusu
## ============================
## Tüm test dosyalarını preload eder, test_* metodlarını sırayla çalıştırır.
## Kullanım:
##   Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://test/test_runner.gd --quit
##
## Çıkış Kodu:
##   0 → tüm testler geçti
##   1 → en az bir test kaldı

extends Node

const SEPARATOR := "============================================="
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


func _ready() -> void:
	var tests: Array[Node] = [
		preload("res://test/test_bug_fixes.gd").new(),
		preload("res://test/test_event_chain.gd").new(),
		preload("res://test/test_overlay.gd").new(),
		preload("res://test/test_audio.gd").new(),
		preload("res://test/test_save.gd").new(),
	]

	var passed := 0
	var failed := 0
	var skipped := 0
	var results: Array[String] = []

	for test: Node in tests:
		add_child(test)
		var methods := test.get_method_list()
		for method: Dictionary in methods:
			var name: String = method.get("name", "")
			if name.begins_with("test_"):
				var result: Variant = test.call(name)
				if result is String and result == "OK":
					passed += 1
					results.append("  [GECTI] %s::%s" % [test.name, name])
				elif result is String and result.begins_with("SKIP"):
					skipped += 1
					results.append("  [ATLANDI] %s::%s: %s" % [test.name, name, str(result)])
				else:
					failed += 1
					results.append("  [KALDI] %s::%s: %s" % [test.name, name, str(result)])

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

	print("")
	print(SEPARATOR)
	print("        MMAE — TEST SONUCLARI")
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
