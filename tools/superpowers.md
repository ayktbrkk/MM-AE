# MMAE Superpowers Kullanım Kılavuzu

Bu kılavuz, Roo Code'un "superpowers" yeteneklerini MMAE projesinde nasıl kullanacağını açıklar.

---

## 🧠 Superpower 1: Proje Anayasası (`.clinerules`)

Her Roo Code oturumunda otomatik yüklenen proje kuralları.

**İçerir:**
- Godot 4 GDScript standartları (@onready, static typing, signal)
- İsimlendirme kuralları (snake_case, PascalCase, SCREAMING_SNAKE_CASE)
- Mimari kararlar ve sorumluluklar
- Tasarım prensipleri

---

## 📚 Superpower 2: 10 Skills / Workflow (`skills/`)

### 🎮 Oyun Mekanikleri
| Skill | Kullanım |
|-------|----------|
| [`new-chapter.md`](../skills/new-chapter.md) | "Yeni bölüm ekle" |
| [`new-decision.md`](../skills/new-decision.md) | "Karar mekaniği ekle" |
| [`new-scene.md`](../skills/new-scene.md) | "Yeni sahne oluştur" |
| [`dialogue-sequence.md`](../skills/dialogue-sequence.md) | "Diyalog dizisi ekle" |

### 🔧 Kod ve Performans
| Skill | Kullanım |
|-------|----------|
| [`refactor-gdscript.md`](../skills/refactor-gdscript.md) | "Kodu yeniden düzenle" |
| [`godot-refactor.md`](../skills/godot-refactor.md) | "Godot 3 kodunu 4'e dönüştür" |
| [`shader-expert.md`](../skills/shader-expert.md) | "Shader yaz veya optimize et" |

### 🎨 Tasarım ve UI
| Skill | Kullanım |
|-------|----------|
| [`art-asset.md`](../skills/art-asset.md) | "Görsel asset ekle" |
| [`ui-auto-layout.md`](../skills/ui-auto-layout.md) | "UI'ı Container'larla düzenle" |

### 🚀 Dağıtım
| Skill | Kullanım |
|-------|----------|
| [`android-build.md`](../skills/android-build.md) | "Android build al" |

---

## 👥 Superpower 3: 8 Custom Modes / Subagents (`.roomodes`)

| Mod | Uzmanlık | Model |
|-----|----------|-------|
| 👑 **Tech Lead** | Mimari denetim, kod review, standartlar | 🔴 Pro |
| 💻 **Developer** | GDScript geliştirme, hata düzeltme | 🔴 Pro |
| 🧪 **QA Specialist** | Test, bug tracking, regression | 🟢 Flash |
| 🏗️ **Sahne Tasarımcısı** | `.tscn` düzenleme, UI/UX | 🟢 Flash |
| 📜 **GDScript Sihirbazı** | Kod optimizasyonu, pattern | 🔴 Pro |
| ✍️ **Hikaye Yazarı** | `questions.gd`, diyalog | 🟢 Flash |
| 🎨 **Sanat Yönetmeni** | Görseller, renk paleti | 🟢 Flash |
| 🚀 **Build Master** | Android build, dağıtım | 🟢 Flash |

🔴 Pro = DeepSeek V4 Pro (yüksek thinking, karmaşık işler)
🟢 Flash = DeepSeek V4 Flash (düşük maliyet, rutin işler)

---

## 🛡️ Superpower 4: Guardrails (`tools/`)

| Dosya | Ne Kontrol Eder? |
|-------|-----------------|
| [`pre_check.gd`](pre_check.gd) | Godot 3.x sözdizimi, static typing, renk sabitleri, performans |
| [`post_validate.gd`](post_validate.gd) | Data bütünlüğü, sahne referansları, diyalog akışı |

### Otomatik Denetlenenler:
- ✅ `@onready var` vs `onready var` (Godot 3 hatası)
- ✅ `setget` kullanımı (Godot 3 hatası)
- ✅ `export var` vs `@export var` (Godot 3 hatası)
- ✅ Eksik tip belirteçleri (`var x` yerine `var x: int`)
- ✅ Eksik fonksiyon dönüş tipleri (`func()` yerine `func() -> void:`)
- ✅ `_process` içinde ağır işlemler

---

## 🔌 Superpower 5: MCP Sunucuları

### Godot MCP
- Doğrudan Godot Editor'ü başlatma
- Projeyi run etme
- Debug çıktılarını yakalama
- Scene tree'yi okuma

### GitHub MCP
- Issue okuma ve yönetme
- Gist oluşturma
- Repo dosyalarına erişim
- Pull request yönetimi

**Kurulum:** [`tools/mcp_config.json`](mcp_config.json) dosyasını Roo Code MCP ayarlarına yükle.

---

## 🎯 Superpower 6: Akıllı Model Yönlendirme

| İş Türü | Model | Maliyet |
|---------|-------|---------|
| Dosya okuma | Flash | 💰 Düşük |
| Basit refactor | Flash | 💰 Düşük |
| UI düzenleme | Flash | 💰 Düşük |
| Hikaye yazma | Flash | 💰 Düşük |
| Karmaşık kod | Pro | 🏆 Yüksek |
| Mimari tasarım | Pro | 🏆 Yüksek |
| Kod review | Pro | 🏆 Yüksek |

**Detaylı konfigürasyon:** [`tools/model_routing.yaml`](model_routing.yaml)

---

## 📦 Dağıtım

```bash
powershell -ExecutionPolicy Bypass -File tools\setup.ps1
```

**Tüm bileşenler:** `.clinerules` + `.roomodes` + `skills/` + `tools/` + MCP + Model Routing
