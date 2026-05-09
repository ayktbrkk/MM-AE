# Yeni Sahne Dosyası Oluşturma Workflow'u

Bu workflow, Godot'da yeni bir .tscn sahnesi oluşturmak için izlenmesi gereken adımları tanımlar.

## Adımlar

1. **Sahne tipini belirle**
   - `Control` → UI overlay'leri (dialogue, decision, menu)
   - `Node2D` → Oyun dünyaları, dioramalar
   - `CanvasLayer` → HUD, sabit UI katmanları

2. **Scene tree yapısını kur**
   - Root node: `PascalCase` isimlendirme (örn: `DialoguePanel`)
   - Alt düğümler: anlamlı gruplama (PortraitLayer, BottomArea, HeaderRow)
   - Tema değişkenleri için `theme_override_*` kullan

3. **Script bağla**
   - `scripts/` altında `snake_case.gd` scripti oluştur
   - `extends` ile doğru node tipini belirt
   - Gerekli `@onready` değişkenlerini tanımla

4. **Sinyalleri tanımla**
   - `signal` anahtar kelimesiyle `snake_case` isimlendirme
   - Örn: `signal continue_pressed`, `signal decision_made(is_correct: bool)`

5. **Referansları güncelle**
   - `world.tscn` veya ana sahnede yeni sahneyi child olarak ekle
   - Kod içinde gerekli `preload()` ifadelerini ekle
