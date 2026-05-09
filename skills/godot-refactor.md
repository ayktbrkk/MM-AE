# Godot Refactor Skill - Modern Godot 4 Standartlarına Dönüşüm

Bu skill, Godot 3.x tarzı kodları modern Godot 4 standartlarına dönüştürmek için kullanılır.

## Dönüşüm Kuralları

### 1. `onready var` → `@onready var`
```gdscript
// ❌ ESKİ (Godot 3)
onready var sprite := $Sprite
onready var label = $Label

// ✅ YENİ (Godot 4)
@onready var sprite: Sprite2D = $Sprite
@onready var label: Label = $Label
```

### 2. `export var` → `@export var`
```gdscript
// ❌ ESKİ (Godot 3)
export var speed := 100.0
export(int) var max_health := 3

// ✅ YENİ (Godot 4)
@export var speed: float = 100.0
@export var max_health: int = 3
```

### 3. `setget` → Setter/Getter Fonksiyonları
```gdscript
// ❌ ESKİ (Godot 3)
var health setget set_health, get_health

// ✅ YENİ (Godot 4) - set_get kullanma, direkt erişim
var health: int = 100
// Veya setter fonksiyonu yaz:
func set_health(value: int) -> void:
    health = clampi(value, 0, max_health)
    health_changed.emit(health)
```

### 4. Tip Belirteci Eklemeyi Unutma
```gdscript
// ❌ EKSİK TİP
var score = 0
func add_points(p) -> void:

// ✅ STATIC TYPING
var score: int = 0
func add_points(points: int) -> void:
```

### 5. Signal Bildirimi
```gdscript
// ✅ Godot 4 standardı
signal health_changed(new_health: int)
signal died

func _on_health_changed(new_health: int) -> void:
    # otomatik bağlantı
    
// Manuel bağlantı:
health_changed.connect(_on_health_changed)
```

### 6. `yield()` → `await`
```gdscript
// ❌ ESKİ (Godot 3)
yield(get_tree().create_timer(1.0), "timeout")

// ✅ YENİ (Godot 4)
await get_tree().create_timer(1.0).timeout
```

### 7. Fonksiyon İmzaları
```gdscript
// ❌ ESKİ (Godot 3)
func _ready():
    pass
func _process(delta):
    pass

// ✅ YENİ (Godot 4) - dönüş tipi ZORUNLU
func _ready() -> void:
    pass
func _process(delta: float) -> void:
    pass  # sadece gerektiğinde kullan!
```

## Adımlar

1. **Kod taraması yap** - Tüm .gd dosyalarını Godot 3.x sözdizimi için tara
2. **Her bulunan hatayı düzelt** - Yukarıdaki kurallara göre dönüştür
3. **Static typing ekle** - Eksik tip belirteçlerini tamamla
4. **Performans kontrolü** - Gereksiz `_process` kullanımını temizle
5. **Test et** - Dönüşüm sonrası oyunun çalıştığını doğrula
