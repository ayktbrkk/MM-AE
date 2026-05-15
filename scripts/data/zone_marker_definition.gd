# scripts/data/zone_marker_definition.gd
# ZoneDefinition içinde kullanılacak her bir marker'ın veri tanımı.
# Resource olarak .tres dosyasında saklanır.
# ============================================
# MMAE - Bandırma Yolculuğu
# Godot 4.6 · GDScript 2.0 · Static Typing
# ============================================
extends Resource
class_name ZoneMarkerDefinition

## Hangi tür marker: "note", "collectible", "story_trigger", vb.
@export var kind: String = ""

## Çeviri anahtarı — marker başlığı (ui_texts.csv'deki KEY)
@export var title_key: String = ""

## Çeviri anahtarı — marker açıklama metni (ui_texts.csv'deki KEY)
@export var text_key: String = ""

## Dünya uzayındaki pozisyon (Vector2)
@export var position: Vector2 = Vector2.ZERO

## Toplanmış mı? (save/load için)
@export var collected: bool = false
