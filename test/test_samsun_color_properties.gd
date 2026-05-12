## test_samsun_color_properties.gd
## Samsun renk sabitleri için property kontrolleri.
## Validates: Requirements 5.1, 5.4

extends RefCounted

const COLORS := preload("res://scripts/colors.gd")
const EXPECTED_THEME_KEYS: Array[String] = ["bg", "accent", "panel", "shadow", "text"]


func run_tests() -> Dictionary:
	print("=".repeat(60))
	print("Samsun Color Property Testleri")
	print("=".repeat(60))

	var results: Array[Dictionary] = [
		_test_rift_blue_components(),
		_test_theme_samsun_keys(),
		_test_theme_samsun_background(),
	]

	var passed: int = 0
	var failed: int = 0
	for result in results:
		if result["ok"]:
			passed += 1
			print("  PASS  %s" % result["name"])
		else:
			failed += 1
			print("  FAIL  %s" % result["name"])
			for error in result["errors"]:
				print("        - %s" % error)

	var total: int = passed + failed
	print("=".repeat(60))
	print("Sonuç: %d / %d geçti  (%d başarısız)" % [passed, total, failed])
	print("=".repeat(60))
	return {"passed": passed, "failed": failed, "total": total}


func _test_rift_blue_components() -> Dictionary:
	var errors: Array[String] = []
	if not _is_close(COLORS.RIFT_BLUE.r, 0.22):
		errors.append("RIFT_BLUE.r 0.22 olmalı, bulundu: %.4f" % COLORS.RIFT_BLUE.r)
	if not _is_close(COLORS.RIFT_BLUE.g, 0.78):
		errors.append("RIFT_BLUE.g 0.78 olmalı, bulundu: %.4f" % COLORS.RIFT_BLUE.g)
	if not _is_close(COLORS.RIFT_BLUE.b, 1.0):
		errors.append("RIFT_BLUE.b 1.0 olmalı, bulundu: %.4f" % COLORS.RIFT_BLUE.b)
	return {"name": "rift_blue_components", "ok": errors.is_empty(), "errors": errors}


func _test_theme_samsun_keys() -> Dictionary:
	var errors: Array[String] = []
	var actual_keys: Array[String] = []
	for key in COLORS.THEME_SAMSUN.keys():
		actual_keys.append(String(key))
	actual_keys.sort()
	var expected_keys: Array[String] = EXPECTED_THEME_KEYS.duplicate()
	expected_keys.sort()
	if actual_keys != expected_keys:
		errors.append("THEME_SAMSUN anahtarları eşleşmiyor: %s" % ", ".join(actual_keys))
	return {"name": "theme_samsun_keys", "ok": errors.is_empty(), "errors": errors}


func _test_theme_samsun_background() -> Dictionary:
	var errors: Array[String] = []
	if COLORS.THEME_SAMSUN["bg"] != COLORS.POP_DEEP_TURQUOISE:
		errors.append("THEME_SAMSUN[\"bg\"] POP_DEEP_TURQUOISE olmalı")
	return {"name": "theme_samsun_background", "ok": errors.is_empty(), "errors": errors}


func _is_close(lhs: float, rhs: float) -> bool:
	return absf(lhs - rhs) < 0.0001