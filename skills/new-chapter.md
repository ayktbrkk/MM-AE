# Yeni Bölüm Ekleme Workflow'u

Bu workflow, oyuna yeni bir tarihsel bölüm eklemek için adımları tanımlar.

## Adımlar

1. **questions.gd'ye veri ekle**
   - `assets/data/questions.gd` dosyasındaki `EVENTS` dizisine yeni event'leri ekle
   - Her bölüm için: story (giriş) + decision (karar) + story (çıkış) event'leri
   - `kind`, `chapter`, `unit`, `location`, `mood`, `speaker`, `story` alanlarını doldur
   - Karar event'lerinde: `option_a`, `option_b`, `correct`, `retry`, `info` ekle

2. **Sahne dioramasını oluştur**
   - `assets/art/world/{bolum_adi}/` altında SVG asset'leri hazırla
   - Paper diorama katmanları: terrain, path, landmark, foreground, sky

3. **world.gd'ye bölüm ekle**
   - `_setup_{bolum}_events()` fonksiyonu oluştur
   - Event trigger'larını ve interaktif objeleri bağla
   - Karar anı için `decision_overlay`'i yapılandır

4. **Strateji node'larını tanımla**
   - Her bölüm için 3 destek node'u belirle
   - Node temalarını bölüme uygun reskin et (bkz: DESIGN_DECISIONS.md)

5. **Test et**
   - `chapter_transition_overlay` ile giriş/çıkış geçişlerini doğrula
   - Tüm kararların doğru/yanlış geri bildirimlerini kontrol et
