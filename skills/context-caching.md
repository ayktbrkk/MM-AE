# Context Caching - DeepSeek V4 Pro Bellek Optimizasyonu

Bu doküman, DeepSeek V4 Pro'nun otomatik önbellekleme (context caching) özelliğini kullanarak büyük Godot sahnelerini analiz ederken token tasarrufu yapmayı açıklar.

## 🎯 Amaç

Tekrarlanan context'leri önbelleğe alarak API maliyetini düşürmek ve yanıt hızını artırmak.

## Context Caching Stratejisi

### 1. Proje Anayasası (.clinerules) — Her Zaman Önbellekte
`.clinerules` dosyası her oturumda yüklenir. DeepSeek, bu içeriği otomatik olarak önbelleğe alır:
- ✅ Proje kuralları
- ✅ İsimlendirme standartları
- ✅ Godot 4 teknik kurallar
- ✅ Tasarım prensipleri

### 2. Sık Kullanılan Script'ler — Manuel Önbellekleme
Aşağıdaki script'ler sık referans alınır, önbellekte tutulması önerilir:

| Dosya | Önbellek Sebebi |
|-------|----------------|
| `scripts/world.gd` | Ana oyun döngüsü, tüm senaryolarda referans |
| `scripts/dialogue_overlay.gd` | Diyalog sistemi, sık değişir |
| `assets/data/questions.gd` | Tüm hikaye verisi, sık okunur |
| `scripts/main_menu.gd` | Ana menü mantığı |

### 3. Büyük Sahne Dosyaları (.tscn)
Büyük Godot sahnelerini analiz ederken:
```bash
# Sadece ilgili kısmı oku, tüm dosyayı değil
# Örn: world.tscn'de sadece signal bağlantılarını kontrol et
```

### 4. Session Yönetimi
```yaml
# tools/model_routing.yaml içinde:
context_caching:
  enabled: true
  cache_size: "32K"  # Varsayılan context penceresi
  auto_cached:
    - ".clinerules"
    - "scripts/world.gd"      # sık kullanılan
    - "assets/data/questions.gd"  # sık kullanılan
  strategy: >
    Uzun oturumlarda temel referans dosyaları önbellekte tutulur.
    Yeni dosyalar sadece ihtiyaç duyuldukça yüklenir.
    Büyük .tscn dosyaları tamamen değil, ilgili bölümleri okunur.
```

### 5. Token Tasarrufu İpuçları
- **Dosya başına 2000 satır limiti** kullan (`limit=2000`)
- **Sadece değişen kısmı** oku (örneğin sadece `func _on_...` kısmını)
- **Aynı dosyayı tekrar tekrar okuma** — değişmediyse önbellekten kullan
- **Büyük texture listeleri** yerine sadece ilgili sabitleri referans al

## Kullanım

"world.gd'deki decision handler'ları analiz et" → önbellekten okur
"Bu 3 dosyayı önbelleğe al ve birlikte analiz et"
