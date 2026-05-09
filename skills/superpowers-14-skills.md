# Claude Superpowers → Roo Code Dönüşüm Tablosu

Bu doküman, Claude Superpowers'daki 14 becerinin Roo Code + MMAE projesindeki karşılıklarını gösterir.

## 14 Beceri Dönüşüm Tablosu

| # | Claude Superpower | MMAE Karşılığı | Mod / Skill |
|---|------------------|----------------|-------------|
| 1 | **Plan** | Mimari planlama workflow'u | 🏗️ [`architect`](../.roomodes) → [`architect-workflow.md`](architect-workflow.md) |
| 2 | **Architect** | Sistem tasarımı ve node tree planı | 🏗️ [`architect`](../.roomodes) → [`architect-workflow.md`](architect-workflow.md) |
| 3 | **Implement** | Test-first GDScript geliştirme | 💻 [`developer`](../.roomodes) → [`implement.md`](implement.md) |
| 4 | **Debug** | 6 adımlı sistematik hata ayıklama | 🪲 [`debug`](../.roomodes) → [`debug-workflow.md`](debug-workflow.md) |
| 5 | **Refactor** | Godot 3→4 dönüşümü + kod iyileştirme | 📜 [`gdscript-wizard`](../.roomodes) → [`godot-refactor.md`](godot-refactor.md) |
| 6 | **Review** | Kod review ve standart denetimi | 👑 [`tech-lead`](../.roomodes) |
| 7 | **Test** | QA test süreçleri ve regression | 🧪 [`qa-specialist`](../.roomodes) |
| 8 | **Document** | Dokümantasyon yönetimi | 📚 [`skills/`](../skills/) + `docs/` |
| 9 | **Ship** | Build ve dağıtım süreci | 🚀 [`build-master`](../.roomodes) → [`android-build.md`](android-build.md) |
| 10 | **Ask** | Soru-cevap ve açıklama | ❓ Roo Code Ask modu |
| 11 | **Design** | Görsel tasarım ve UI/UX | 🎨 [`art-director`](../.roomodes) + 🏗️ [`godot-scene-designer`](../.roomodes) |
| 12 | **Configure** | Proje ve sistem yapılandırması | 👑 [`tech-lead`](../.roomodes) + 🚀 [`build-master`](../.roomodes) |
| 13 | **Learn** | Yeni teknoloji öğrenme | 📚 [`skills/`](../skills/) + ❓ Ask modu |
| 14 | **Communicate** | Ekip iletişimi ve raporlama | 👑 [`tech-lead`](../.roomodes) (standart denetim raporu) |

## Hızlı Başvuru: Hangi Durumda Hangi Mod?

| Durum | Kullanılacak Mod | Referans Skill |
|-------|------------------|----------------|
| "Yeni özellik planla" | 🏗️ **Architect** | `architect-workflow.md` |
| "Hata var, bul" | 🪲 **Debug** | `debug-workflow.md` |
| "Kodu yaz" | 💻 **Developer** | `implement.md` |
| "Kodu gözden geçir" | 👑 **Tech Lead** | `.clinerules` standartları |
| "Eski kodu dönüştür" | 📜 **GDScript Sihirbazı** | `godot-refactor.md` |
| "Test et" | 🧪 **QA Specialist** | `debug-workflow.md` |
| "Build al" | 🚀 **Build Master** | `android-build.md` |
| "Sahne tasarla" | 🏗️ **Sahne Tasarımcısı** | `ui-auto-layout.md` |
| "Hikaye yaz" | ✍️ **Hikaye Yazarı** | `dialogue-sequence.md` |
| "Asset ekle" | 🎨 **Sanat Yönetmeni** | `art-asset.md` |

## Çalışma Akışı Örneği

```
1. "Samsun bölümüne yeni bir karar mekaniği eklemek istiyorum"
   → 🏗️ Architect: Plan çıkar, node tree ve signal akışını belirle

2. Plan onaylandı
   → 💻 Developer: GDScript'i test-first yöntemiyle yaz

3. Kod yazıldı
   → 👑 Tech Lead: Kod review yap, standartları denetle

4. "Karar mekaniğinde hata var"
   → 🪲 Debug: Sistematik hata ayıklama yap

5. Düzeltme yapıldı
   → 🧪 QA Specialist: Regression test yap

6. Her şey çalışıyor
   → 🚀 Build Master: Android build al
```
