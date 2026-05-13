extends SceneTree

const DEFAULT_BASELINE_DIR := "res://artifacts/renders/ui_checklist"
const DEFAULT_CANDIDATE_DIR := "res://artifacts/renders/ui_regression_current"
const DEFAULT_DIFF_DIR := "res://artifacts/renders/ui_regression_diffs"
const DEFAULT_THRESHOLD_RATIO := 0.0015
const DEFAULT_THRESHOLD_DELTA := 0.025
const SURFACES := [
	"menu",
	"dialogue",
	"decision",
	"info_card",
	"chapter_transition",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var baseline_dir := DEFAULT_BASELINE_DIR
	var candidate_dir := DEFAULT_CANDIDATE_DIR
	var diff_dir := DEFAULT_DIFF_DIR
	var threshold_ratio := DEFAULT_THRESHOLD_RATIO
	var threshold_delta := DEFAULT_THRESHOLD_DELTA
	for index in range(args.size()):
		match args[index]:
			"--baseline-dir":
				if index + 1 < args.size():
					baseline_dir = args[index + 1]
			"--candidate-dir":
				if index + 1 < args.size():
					candidate_dir = args[index + 1]
			"--diff-dir":
				if index + 1 < args.size():
					diff_dir = args[index + 1]
			"--threshold-ratio":
				if index + 1 < args.size():
					threshold_ratio = float(args[index + 1])
			"--threshold-delta":
				if index + 1 < args.size():
					threshold_delta = float(args[index + 1])

	var failures: Array[String] = []
	for surface in SURFACES:
		var result := _compare_surface(surface, baseline_dir, candidate_dir, diff_dir, threshold_ratio, threshold_delta)
		if not bool(result.get("ok", false)):
			failures.append(String(result.get("message", surface)))
		else:
			print("UI_DIFF_OK %s ratio=%.6f max_delta=%.4f" % [surface, float(result.get("ratio", 0.0)), float(result.get("max_delta", 0.0))])

	if not failures.is_empty():
		for failure in failures:
			push_error(failure)
		quit(1)
		return

	print("UI_VISUAL_REGRESSION_OK")
	quit(0)


func _compare_surface(surface: String, baseline_dir: String, candidate_dir: String, diff_dir: String, threshold_ratio: float, threshold_delta: float) -> Dictionary:
	var baseline_path := "%s/%s_1080x1920.png" % [baseline_dir, surface]
	var candidate_path := "%s/%s_1080x1920.png" % [candidate_dir, surface]
	var baseline_image := _load_image(baseline_path)
	var candidate_image := _load_image(candidate_path)
	if baseline_image == null:
		return {"ok": false, "message": "UI diff: baseline bulunamadi: %s" % baseline_path}
	if candidate_image == null:
		return {"ok": false, "message": "UI diff: candidate bulunamadi: %s" % candidate_path}
	if baseline_image.get_size() != candidate_image.get_size():
		return {"ok": false, "message": "UI diff: boyut uyusmuyor: %s (%s vs %s)" % [surface, baseline_image.get_size(), candidate_image.get_size()]}

	var width := baseline_image.get_width()
	var height := baseline_image.get_height()
	var total_pixels := width * height
	var changed_pixels := 0
	var max_delta := 0.0
	var diff_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	diff_image.fill(Color(0.0, 0.0, 0.0, 1.0))

	for y in range(height):
		for x in range(width):
			var base := baseline_image.get_pixel(x, y)
			var candidate := candidate_image.get_pixel(x, y)
			var delta := _color_delta(base, candidate)
			max_delta = maxf(max_delta, delta)
			if delta > threshold_delta:
				changed_pixels += 1
				diff_image.set_pixel(x, y, Color(1.0, minf(1.0, delta * 6.0), 0.0, 1.0))

	var changed_ratio := float(changed_pixels) / float(total_pixels)
	var diff_absolute := ProjectSettings.globalize_path("%s/%s_diff.png" % [diff_dir, surface])
	var diff_directory := diff_absolute.get_base_dir()
	if not DirAccess.dir_exists_absolute(diff_directory):
		DirAccess.make_dir_recursive_absolute(diff_directory)
	var save_error := diff_image.save_png(diff_absolute)
	if save_error != OK:
		return {"ok": false, "message": "UI diff: diff PNG kaydedilemedi: %s" % diff_absolute}

	if changed_ratio > threshold_ratio:
		return {
			"ok": false,
			"message": "UI diff: %s ratio=%.6f esik=%.6f max_delta=%.4f diff=%s" % [surface, changed_ratio, threshold_ratio, max_delta, diff_absolute],
			"ratio": changed_ratio,
			"max_delta": max_delta,
		}

	return {"ok": true, "ratio": changed_ratio, "max_delta": max_delta, "diff": diff_absolute}


func _load_image(path: String) -> Image:
	var absolute_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(absolute_path):
		return null
	var image := Image.new()
	var error := image.load(absolute_path)
	if error != OK:
		return null
	return image


func _color_delta(a: Color, b: Color) -> float:
	return maxf(
		absf(a.r - b.r),
		maxf(
			absf(a.g - b.g),
			maxf(absf(a.b - b.b), absf(a.a - b.a))
		)
	)