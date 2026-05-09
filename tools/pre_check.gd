extends RefCounted
# tools/pre_check.gd
# ====================
# Pre-Check: Her tool call öncesi çalışan doğrulama script'i.
# Bu script, proje standartlarına uygunluğu kontrol eder.

# Uyarı: Bu bir Godot GDScript validasyon aracıdır.
# Roo Code hooks sistemine bağlanmak için aşağıdaki kontroller yapılır.

static func validate_naming(path: String) -> Dictionary:
	"""İsimlendirme kurallarını kontrol eder."""
	var errors := []
	
	if path.ends_with(".gd") or path.ends_with(".tscn"):
		var filename := path.get_file()
		if filename != filename.to_lower():
			errors.append("HATA: Dosya adı snake_case olmalı: " + filename)
	
	if path.ends_with(".tscn"):
		if not path.begins_with("scenes/"):
			errors.append("UYARI: Sahne dosyası scenes/ klasöründe olmalı: " + path)
	
	return {
		"valid": errors.is_empty(),
		"errors": errors
	}

static func validate_color_constants(source_code: String) -> Dictionary:
	"""Renk sabitlerinin merkezi colors.gd kullanımını kontrol eder."""
	var errors := []
	var warnings := []
	var lines := source_code.split("\n")
	
	# İzin verilen önekler (merkezi colors.gd'de tanımlı)
	var valid_prefixes := ["POP_", "DESIGN_", "ART_", "SHADOW_", "UI_",
		"ARDA_", "EDA_", "RIFT_", "THEME_", "CEL_", "PAPER_"]
	
	for line in lines:
		var trimmed := line.strip_edges()
		
		# Script içinde direkt Color tanımı yasak (sadece colors.gd'de olmalı)
		if "Color(" in trimmed and "const" in trimmed:
			if not "colors.gd" in source_code:
				# colors.gd dışındaki dosyalarda const Color tanımı uyarısı
				var has_valid_prefix := false
				for prefix in valid_prefixes:
					if prefix in trimmed:
						has_valid_prefix = true
						break
				
				if not has_valid_prefix:
					errors.append("HATA: Renk sabiti geçerli önek içermeli (" + \
						", ".join(valid_prefixes) + "): " + trimmed)
				else:
					warnings.append("UYARI: " + trimmed + " — Bu sabit colors.gd'ye taşınmalı")
		
		# SVG asset'lerde renk sınırı kontrolü (yorum satırı olarak)
		if ".svg" in trimmed and "preload" in trimmed:
			# Sadece uyarı, her SVG asset için geçerli değil
			pass
	
	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": warnings
	}

static func validate_artwork_references(source_code: String) -> Dictionary:
	"""Artwork referans görsellerine atıf yapılıp yapılmadığını kontrol eder."""
	var warnings := []
	
	# artworks/ klasöründeki görseller
	var artwork_refs := ["ilk sahne.png", "mm-ae-independence-war.png", "sahne 1.png"]
	
	for ref in artwork_refs:
		if ref in source_code:
			return {
				"valid": true,
				"warnings": [],
				"note": "Artwork referansı bulundu: " + ref
			}
	
	return {
		"valid": true,
		"warnings": warnings,
		"note": "Artwork referansı aranmıyor (opsiyonel)"
	}

static func validate_performance(source_code: String) -> Dictionary:
	"""Performans sorunlarını kontrol eder."""
	var warnings := []
	
	if "_process(delta)" in source_code:
		var lines := source_code.split("\n")
		var in_process := false
		var heavy_ops := 0
		
		for line in lines:
			if "_process(delta)" in line:
				in_process = true
			elif in_process and "func _" in line and "_process" not in line:
				in_process = false
			elif in_process:
				if "load(" in line or "preload(" in line or "instantiate(" in line:
					heavy_ops += 1
		
		if heavy_ops > 0:
			warnings.append("UYARI: _process içinde ağır işlem var (" + str(heavy_ops) + " tane)")
	
	return {
		"valid": true,
		"warnings": warnings
	}

static func validate_godot3_syntax(source_code: String) -> Dictionary:
	"""Godot 3.x sözdizimi kullanımını kontrol eder."""
	var errors := []
	var lines := source_code.split("\n")
	
	for i in range(lines.size()):
		var line := lines[i]
		var trimmed := line.strip_edges()
		
		# Godot 3 onready var (4'te @onready var olmalı)
		if trimmed.begins_with("onready var") and not trimmed.begins_with("@onready var"):
			errors.append("HATA (satır " + str(i + 1) + "): 'onready var' yerine '@onready var' kullan: " + trimmed)
		
		# Godot 3 setget
		if "setget" in trimmed and not trimmed.begins_with("#"):
			errors.append("HATA (satır " + str(i + 1) + "): 'setget' Godot 4'te kullanılmaz, setter/getter fonksiyonu yaz: " + trimmed)
		
		# Godot 3 export var
		if trimmed.begins_with("export var") and not trimmed.begins_with("@export var"):
			errors.append("HATA (satır " + str(i + 1) + "): 'export var' yerine '@export var' kullan: " + trimmed)
		
		# Tip belirteci kontrolü (var tanımlarında)
		if trimmed.begins_with("var ") and ":" not in trimmed and "=" not in trimmed:
			errors.append("UYARI (satır " + str(i + 1) + "): Tip belirteci eklenmemiş: " + trimmed)
		elif trimmed.begins_with("var ") and ":" not in trimmed and "=" in trimmed:
			errors.append("UYARI (satır " + str(i + 1) + "): Tip belirteci eklenmemiş: " + trimmed)
		
		# Fonksiyon dönüş tipi kontrolü
		if "func " in trimmed and "->" not in trimmed and not trimmed.ends_with(":") and "signal" not in trimmed:
			if not trimmed.contains("(") and not trimmed.contains(")"):
				pass
			elif trimmed.contains("(") and trimmed.contains(")"):
				errors.append("UYARI (satır " + str(i + 1) + "): Fonksiyon dönüş tipi belirtilmemiş: " + trimmed)
	
	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"warnings": errors
	}

static func validate(text: String, file_path: String) -> Dictionary:
	"""Tüm validasyonları çalıştırır."""
	var results := {}
	results["naming"] = validate_naming(file_path)
	results["color_constants"] = validate_color_constants(text)
	results["performance"] = validate_performance(text)
	results["artwork_refs"] = validate_artwork_references(text)
	
	# Sadece .gd dosyaları için Godot 3.x sözdizimi kontrolü
	if file_path.ends_with(".gd"):
		results["godot3_syntax"] = validate_godot3_syntax(text)
	
	var all_valid := true
	var all_errors := []
	var all_warnings := []
	
	for key in results:
		if not results[key]["valid"]:
			all_valid = false
		if results[key].has("errors"):
			all_errors.append_array(results[key]["errors"])
		if results[key].has("warnings"):
			all_warnings.append_array(results[key]["warnings"])
	
	return {
		"valid": all_valid,
		"errors": all_errors,
		"warnings": all_warnings,
		"details": results
	}
