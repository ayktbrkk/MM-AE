# scripts/data/zone_loader.gd
# ZoneDefinition Resource'larını .tres dosyalarından yükleyen yardımcı.
# Statik metotlar — her yerden çağrılabilir.
# ============================================
# MMAE - Bandırma Yolculuğu
# Godot 4.6 · GDScript 2.0 · Static Typing
# ============================================
extends RefCounted
class_name ZoneLoader

## .tres dosyalarının bulunduğu dizin (proje köküne göre)
const ZONES_DIR: String = "res://assets/data/zones/"


## Verilen zone_id için ZoneDefinition yükler.
## Dosya bulunamazsa null döner.
static func load_zone(zone_id: String) -> ZoneDefinition:
	var path: String = ZONES_DIR.path_join(zone_id + ".tres")
	if ResourceLoader.exists(path):
		var resource: Resource = ResourceLoader.load(path)
		if resource is ZoneDefinition:
			return resource as ZoneDefinition
	return null


## Verilen zone_id için bir .tres tanımı olup olmadığını kontrol eder.
static func has_definition(zone_id: String) -> bool:
	var path: String = ZONES_DIR.path_join(zone_id + ".tres")
	return ResourceLoader.exists(path)
