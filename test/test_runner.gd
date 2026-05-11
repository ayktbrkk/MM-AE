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
