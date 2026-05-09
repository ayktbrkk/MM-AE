# Diyalog Dizisi Ekleme Workflow'u

Bu workflow, oyuna yeni bir diyalog dizisi (story event'leri zinciri) eklemek için kullanılır.

## Adımlar

1. **Diyalog event'lerini oluştur**
   - `assets/data/questions.gd` içinde `kind: "story"` ile event bloğu ekle
   - `{hero}` placeholder'ı oyuncu adı (Arda/Eda) ile değiştirilir
   - `speaker_side` kontrollü diyalog için her event'te doğru konuşmacıyı belirt

2. **Diyalog akışını yapılandır**
   - `dialogue_overlay.gd`'de `present(config)` ile diyalog gösterilir
   - Story event'leri otomatik sırayla oynatılır
   - Konuşmacıya göre portre vurgusu: left = Arda, right = Eda

3. **Görsel destek**
   - Her event `mood` alanına göre arkaplan rengi/atmosferi değişir
   - `chapter` ve `speaker` bilgisi header'da gösterilir
   - Typewriter efekti `body_label.visible_ratio` ile kontrol edilir

4. **Geçiş animasyonları**
   - Diyalog paneli yukarı kayarak/soluklaşarak açar
   - Portreler stage light efekti ile vurgulanır
   - "Devam" butonu yumuşak nefes animasyonu yapar

5. **Test et**
   - Typewriter hızı okunabilir mi? (7-8 yaş için yavaş)
   - Portre geçişleri yumuşak mı?
   - Tap-to-continue dokunmatik için duyarlı mı?
