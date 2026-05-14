extends SceneTree

const _questions := preload("res://assets/data/questions.gd")
const _world_zone := preload("res://scripts/world_zone.gd")
var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var intro := _questions.localized_event(0, "Arda")
	_assert_equal(String(intro.get("chapter", "")), "Giriş: Sınav Gecesi", "event 0 chapter should resolve through translation key")
	_assert_equal(String(intro.get("speaker", "")), "Anlatıcı", "event 0 speaker should resolve through translation key")
	_assert_true(String(intro.get("story", "")).contains("Arda"), "event 0 story should replace the hero placeholder")
	_assert_true(not String(intro.get("story", "")).contains("{hero}"), "event 0 story should not keep raw hero placeholder")

	var samsun_decision := _questions.localized_event(5, "Eda")
	_assert_equal(String(samsun_decision.get("option_b", "")), "Önce durumu gözlemle ve güvenilir kişilerle bağlantı kur.", "event 5 option_b should resolve through translation key")
	_assert_true(String(samsun_decision.get("story", "")).contains("Eda"), "event 5 story should replace the hero placeholder")

	var fallback_event := _questions.localized_event(8, "Arda")
	_assert_true(String(fallback_event.get("story", "")).contains("Arda"), "non-keyed events should still replace the hero placeholder")
	_assert_equal(String(fallback_event.get("option_a", "")), "Milleti bilinçli ve düzenli protestolara çağır.", "non-keyed event text should still fall back to raw data")
	_assert_equal(_questions.event_text_key(8, "story"), "story.event.008.story", "event key generation should be stable for non-keyed events")

	_assert_equal(
		_world_zone.resolve_world_text("missing.world.copy", "Merhaba {hero}", {"hero": "Arda"}),
		"Merhaba Arda",
		"world text helper should replace placeholders in fallback copy"
	)

	if _failed:
		quit(1)
		return

	print("VERIFY_QUESTIONS_LOCALIZATION_OK")
	quit(0)


func _assert_equal(actual: String, expected: String, message: String) -> void:
	if actual != expected:
		_failed = true
		push_error("%s (expected=%s actual=%s)" % [message, expected, actual])


func _assert_true(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)