# Package 9: Performance Observation and Node Count Gate

**Tarih:** 2026-05-14  
**Durum:** ✅ Baseline oluşturuldu  
**Amaç:** Her zone için measurable performance baseline'ları oluşturmak.

---

## 1. Threshold Tablosu

Aşağıdaki eşikler WARNING seviyesindedir. Aşım durumunda FAILURE oluşmaz, sadece optimization önceliği belirlenir.

| Metrik | Threshold | Açıklama |
|--------|-----------|----------|
| `total_nodes` | 2000 | Toplam node sayısı (tüm tipler) |
| `node2d` | 500 | Node2D türevi node sayısı |
| `canvas_item` | 1000 | CanvasItem türevi node sayısı |
| `sprite2d` | 300 | Sprite2D node sayısı |
| `polygon2d` | 200 | Polygon2D node sayısı |
| `markers` | 30 | Görünür marker sayısı |

---

## 2. Zone Node Karmaşıklık Tablosu

Her zone için `measure_world_complexity.gd` ile ölçülen değerler:

| Zone | TOTAL | NODE2D | CANVAS_ITEM | SPRITE2D | POLYGON2D | MARKERS | ⚠ |
|------|-------|--------|-------------|----------|-----------|---------|---|
| room | — | — | — | — | — | — | |
| ship | — | — | — | — | — | — | |
| samsun_rift | — | — | — | — | — | — | |
| havza | — | — | — | — | — | — | |
| amasya | — | — | — | — | — | — | |
| kongreler | — | — | — | — | — | — | |
| ankara | — | — | — | — | — | — | |
| sakarya | — | — | — | — | — | — | |
| final | — | — | — | — | — | — | |

> **Not:** Bu tablo `tools/run_p11_performance_gate.ps1` çalıştırıldıktan sonra doldurulacaktır.  
> Komut: `powershell -ExecutionPolicy Bypass -File tools\run_p11_performance_gate.ps1`

---

## 3. En Yüksek Node Sayılı Zone'lar (Profiling Önceliği)

*(P11 runner çalıştırıldıktan sonra güncellenecek)*

1. **—** — nodes (birincil optimizasyon hedefi)
2. **—** — nodes
3. **—** — nodes

---

## 4. Threshold Aşımları (Varsa)

*(P11 runner çalıştırıldıktan sonra güncellenecek)*

| Zone | Aşılan Threshold | Değer | Öneri |
|------|------------------|-------|-------|
| — | — | — | — |

---

## 5. Optimizasyon Önerileri (Ön Gözlem)

Bu bölüm sadece gözlem içerir. Kod değişikliği gerektirmez.

### 5.1 Polygon2D Kullanımı

- Her zone çok sayıda `Polygon2D` ile procedural terrain oluşturur
- `world_builder.gd` içinde her zone builds sırasında `Polygon2D.new()` çağrılır
- **Öneri:** Özdeş polygonlar için `MultiMeshInstance2D` veya `draw()` override düşünülebilir
- **Öneri:** Z-index katmanlaması kontrol edilmeli, gereksiz overlap var mı bakılmalı

### 5.2 Sprite2D Kullanımı

- `Sprite2D` node'ları texture-based obje ve karakterler için kullanılır
- **Öneri:** Aynı texture'ı kullanan sprite'lar için `Texture.atlas` kullanımı

### 5.3 Marker Count

- Her zone için spawn edilen marker sayısı zone tipine göre değişir
- `world_marker.gd` içinde zone başına 5-10 marker spawn edilir
- **Öneri:** Görünür olmayan marker'lar `visible = false` ile gizlenmeli (zaten yapılıyor mu?)

### 5.4 Node2d Sayısı (Genel)

- Total node sayısı threshold 2000'in altında kalmalı
- **Öneri:** `_add_rect`, `_add_soft_blob` gibi yardımcılar çok sayıda node oluşturur
- **Öneri:** Gereksiz label, outline node'ları için pooling

### 5.5 Mobile Performans

- Hedef platform Android olduğu için `_process(delta)` kullanımı minimize edilmeli
- `CanvasItem` sayısı threshold 1000'i geçmemeli (draw call sayısını etkiler)
- Polygon2D ve Sprite2D texture atlas/batching kontrolü

---

## 6. P11 Runner Kullanım Talimatı

### Basit Çalıştırma

```powershell
powershell -ExecutionPolicy Bypass -File tools\run_p11_performance_gate.ps1
```

### Çıktı Log Kaydetme

Script otomatik olarak `artifacts/logs/p11_complexity_<timestamp>.csv` dosyasına kaydeder.

### Parametreler

| Parametre | Açıklama |
|-----------|----------|
| `-GodotExe <path>` | Godot executable yolu (varsayılan: `$env:GODOT_EXE` veya sabit yol) |
| `-ProjectPath <path>` | Proje yolu (varsayılan: script'in bulunduğu dizinin parent'ı) |
| `-SkipMeasurement` | Ölçümü atla |
| `-NoTimestamp` | Timestamp kullanma (test için) |

### Headless Doğrudan Çalıştırma

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/measure_world_complexity.gd
```

---

## 7. P10 ile Entegrasyon

[`tools/run_p10_smoke_gate.ps1`](tools/run_p10_smoke_gate.ps1) P10 smoke gate'ini çalıştırır.  
[`tools/run_p11_performance_gate.ps1`](tools/run_p11_performance_gate.ps1) P11 performance gate'ini çalıştırır.

P10 ve P11 bağımsız gate'lerdir. P10 smoke gate'inden sonra P11'in çalıştırılması önerilir.

```powershell
# P10 smoke
powershell -ExecutionPolicy Bypass -File tools\run_p10_smoke_gate.ps1

# P11 performance
powershell -ExecutionPolicy Bypass -File tools\run_p11_performance_gate.ps1
```

---

## 8. Ölçüm Aracı Mimarisi

[`tools/measure_world_complexity.gd`](tools/measure_world_complexity.gd) — `extends SceneTree` tabanlı, headless çalışan bir ölçüm aracıdır.

**Çalışma prensibi:**
1. `ZONES` listesindeki her zone için `world.tscn` yüklenir
2. SubViewport içinde instantiate edilir
3. `WorldZone.transition_to(zone)` ile zone geçişi yapılır
4. Node tree recursive olarak taranır, her düğüm tipi sayılır
5. Markers node'u altındaki görünür child'lar sayılır
6. CSV formatında çıktı verilir
7. Threshold aşımları WARNING olarak işaretlenir

**Çıktı formatı:**
```
zone,total_nodes,node2d,canvas_item,sprite2d,polygon2d,markers,threshold_warnings
room,1234,345,678,123,45,12,total_nodes=1234>2000;polygon2d=45>200
```

---

## 9. Gelecek Ölçümler

- FPS baseline (Android cihazda)
- Draw call sayısı
- Memory kullanımı (zone başına)
- Loading süresi (zone geçişleri)
- Polygon count breakdown (her zone için toplam polygon vertex sayısı)

---

*Bu doküman Package 9 çıktısıdır. Tablolar `run_p11_performance_gate.ps1` çalıştırıldıktan sonra elle veya script ile doldurulmalıdır.*
