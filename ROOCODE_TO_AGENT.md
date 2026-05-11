# RooCode → Agent Mode Dönüşüm Kılavuzu

Bu doküman, RooCode'da tanımlı özelliklerin (Custom Modes, Skills) mevcut agent ortamında nasıl kullanılacağını açıklar.

## 📂 Dosya Yapısı

```
proje/
├── .clinerules          # (Güncellendi) Tüm proje kuralları + agent rolleri
├── .roomodes            # (Korundu) RooCode custom mode tanımları
├── .continuerc          # (YENİ) Continue extension kuralları
├── ROOCODE_TO_AGENT.md  # (YENİ) Bu kılavuz
├── skills/              # (Korundu) Workflow talimatları
│   ├── README.md        # Skill listesi ve açıklamaları
│   ├── architect-workflow.md
│   ├── implement.md
│   ├── debug-workflow.md
│   ├── refactor-gdscript.md
│   ├── godot-refactor.md
│   ├── new-chapter.md
│   ├── new-decision.md
│   ├── new-scene.md
│   ├── dialogue-sequence.md
│   ├── art-asset.md
│   ├── ui-auto-layout.md
│   ├── shader-expert.md
│   ├── android-build.md
│   ├── context-caching.md
│   └── superpowers-14-skills.md
```

## 🎯 Nasıl Kullanılır?

### 1. Agent Rolleri (Eski Custom Modes)

RooCode'daki 10 custom mode, artık `.clinerules` içinde **Agent Rolleri** olarak tanımlandı.
Agent'a hangi rolü kullanacağını söylemek için:

```
🏗️ Architect: "Şu özelliği planla: yeni bölüm ekleme"
💻 Developer:  "Şu fonksiyonu implement et"
🪲 Debug:      "Dialogue paneli açılmıyor, debug et"
👑 Tech Lead:  "Kodu review et, standartları denetle"
✍️ Hikaye:     "Yeni bir diyalog dizisi yaz"
🎨 Sanat:      "Yeni bir karakter portresi ekle"
🚀 Build:      "Android build al"
```

### 2. Skill/Workflow Dosyaları

Her rolün `skills/` klasöründe bir workflow dosyası vardır.
Agent, ilgili dosyayı okuyarak adım adım talimatları takip eder.

**Örnek kullanım:**
1. "Yeni bir karar mekaniği ekle" deyin
2. Agent `skills/new-decision.md`'yi okur
3. Adımları takip ederek uygular

### 3. Proje Kuralları

`.clinerules` dosyası, tüm proje standartlarını içerir:
- Godot 4 GDScript kuralları
- İsimlendirme standartları
- Mimari kararlar
- Görsel stil kuralları
- Renk sistemi

## 🔄 Uyumluluk

| Özellik | RooCode | Bu Agent | Not |
|---------|---------|----------|-----|
| Custom Modes | `.roomodes` | `.clinerules` (roller) | Roller .clinerules'a eklendi |
| Skills | `skills/` | `skills/` (aynı) | Doğrudan okunabilir |
| Proje Kuralları | `.clinerules` | `.clinerules` (genişletildi) | Agent rolleri eklendi |
| Continue Uyumu | - | `.continuerc` (yeni) | Continue extension için |

## 📖 Hızlı Referans

Godot 4 kuralları için: `.clinerules` dosyası
Workflow adımları için: `skills/[gorev].md`
Agent rolleri için: `.clinerules` -> "RooCode Custom Modes" bölümü
