# scripts/data/zone_definition.gd
# Bir bölgenin (zone) tüm veri tanımını taşıyan Resource.
# .tres dosyası olarak kaydedilir, ZoneLoader ile yüklenir.
# ============================================
# MMAE - Bandırma Yolculuğu
# Godot 4.6 · GDScript 2.0 · Static Typing
# ============================================
extends Resource
class_name ZoneDefinition

## Eşsiz zone tanımlayıcısı (örn: "ship", "samsun_rift")
@export var zone_id: String = ""

## Çeviri anahtarı — bölge başlığı (ui_texts.csv'deki KEY)
@export var display_title_key: String = ""

## Çeviri anahtarı — kurulum/goal açıklaması (ui_texts.csv'deki KEY)
@export var setup_goal_key: String = ""

## Goal/hedef türü: "collect" | "support" | "explore"
@export var goal_kind: String = "collect"

## Çeviri anahtarı — toplanan eşya sayacı etiketi
@export var item_counter_key: String = ""

## Bölgede toplanması gereken toplam eşya / marker
@export var item_total: int = 0

## Bölgeyi tamamlamak için gereken destek (support) sayısı
@export var required_supports: int = 0

## Bölgedeki marker'lar (ZoneMarkerDefinition dizisi)
@export var markers: Array[ZoneMarkerDefinition] = []

## Yardımcı karakterlerin duracağı noktalar (world-space)
@export var companion_spots: Array[Vector2] = []

## Hangi dalga konfigürasyonu kullanılacak (world_wave.gd'deki ZONE_CONFIG anahtarı)
@export var wave_config_id: String = ""
