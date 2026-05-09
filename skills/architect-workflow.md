# Architect Workflow - Claude Superpowers "Architect & Plan" Becerisi

Bu workflow, yeni bir özellik geliştirmeden ÖNCE izlenecek planlama sürecini tanımlar.

## 🎯 Amaç

"Önce düşün, sonra kodla." Herhangi bir kod yazmadan önce sistem tasarımını yap.

## Adımlar

### 1. Gereksinim Analizi
- [ ] Ne inşa ediyoruz? (feature/component/system)
- [ ] Hangi mevcut sistemlerle etkileşime girecek?
- [ ] Kullanıcı (7-8 yaş oyuncu) bu özelliği nasıl deneyimleyecek?
- [ ] Performans kısıtları var mı? (mobile Android)

### 2. Sistem Tasarımı (Plan)
Node tree, signal akışı ve script sorumluluklarını belirle:

```gdscript
# Örnek: Yeni "Havza" bölümü için plan
#
# Scene Tree:
# └── World (Node2D)
#     ├── HavzaDiorama (Node2D)
#     │   ├── Terrain (Sprite2D)
#     │   ├── Path (Sprite2D)
#     │   ├── Landmarks (Node2D)
#     │   └── NPCs (Node2D)
#     └── UI (CanvasLayer)
#         ├── DialogueOverlay
#         ├── DecisionOverlay
#         └── HUD
#
# Signal Flow:
# npc_interacted → world._on_npc_interacted() → dialogue_overlay.present()
# decision_made → world._on_decision_made() → chapter_transition()
#
# Scripts:
# - world.gd: ana oyun döngüsü (mevcut, genişletilecek)
# - Yeni: havza_events.gd → event trigger'ları
```

### 3. Plan Onayı
- [ ] Tasarım mevcut pattern'lere uyuyor mu? (bkz: `.clinerules`)
- [ ] Statik typing kullanılmış mı?
- [ ] Signal tabanlı mı?
- [ ] Godot 3.x sözdizimi yok mu?

### 4. Uygulama Geçişi
- Plan onaylandıktan sonra Developer moduna geç
- Veya doğrudan Developer alt modunda uygula

## Kullanım

"Şu özelliği planla: [feature description]"
→ Architect modu, yukarıdaki adımları takip eder.
