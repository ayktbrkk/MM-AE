# Implement Workflow - Claude Superpowers "Implement" Becerisi

Bu workflow, yeni bir özelliği "önce test yaz, sonra uygula" prensibiyle geliştirmeyi tanımlar.

## 🎯 Amaç

Test edilebilir, tip güvenli ve bakımı kolay GDScript kodu yazmak.

## Adımlar

### 1. Test Tanımı (Önce)
Kod yazmadan önce, neyin test edileceğini tanımla:

```gdscript
# Örnek: Karar mekaniği test tanımı
#
# Test 1: Doğru cevap seçildiğinde "correct" callback tetiklenmeli
# Test 2: Yanlış cevap seçildiğinde "retry" mesajı gösterilmeli
# Test 3: Bilgi kartı (info) doğru veriyi göstermeli
```

### 2. İmza ve Tip Tanımı
Fonksiyon imzalarını ve tipleri önceden belirle:

```gdscript
# Fonksiyon imzaları
signal decision_made(is_correct: bool)
signal info_requested

func show_decision(config: Dictionary) -> void:
func _on_option_selected(option: String) -> void:
func _show_result(is_correct: bool) -> void:
```

### 3. Uygulama
İmzalara sadık kalarak kodu yaz:

```gdscript
func show_decision(config: Dictionary) -> void:
    # 1. Veriyi doğrula
    assert(config.has("option_a"), "option_a gerekli")
    assert(config.has("option_b"), "option_b gerekli")
    
    # 2. UI'ı göster
    option_a_button.text = String(config["option_a"])
    option_b_button.text = String(config["option_b"])
    
    # 3. State'i güncelle
    current_decision = config
    visible = true
```

### 4. Doğrulama
- [ ] Statik typing kullanıldı mı? (var x: Type)
- [ ] Fonksiyon dönüş tipleri belirtildi mi? (-> void:)
- [ ] Signal imzaları doğru mu? (signal name(param: Type))
- [ ] @onready var kullanıldı mı? (onready var DEĞİL)
- [ ] Godot 3.x sözdizimi var mı? (setget, export var, onready var)

### 5. Entegrasyon Testi
- [ ] Mevcut akışla uyumlu mu?
- [ ] Event zinciri kırılmıyor mu?
- [ ] Mobil ekranda UI taşması yok mu?

## Kullanım

"Şu özelliği implement et: [description]"
"Bu fonksiyonu test-first yaklaşımıyla yaz"
