# Yeni Karar Mekaniği Ekleme Workflow'u

Bu workflow, oyuna yeni bir A/B karar mekaniği eklemek için kullanılır.

## Adımlar

1. **Karar datasını oluştur**
   - `assets/data/questions.gd` içinde `kind: "decision"` ile yeni bir event bloğu ekle
   - Tüm alanları doldur:
     ```gdscript
     {
         "kind": "decision",
         "chapter": "Bölüm Adı",
         "unit": "Ünite",
         "location": "Mekan",
         "mood": "mood_key",
         "speaker": "Konuşmacı",
         "story": "Hikaye metni ({hero} oyuncu adı)",
         "option_a": "Seçenek A",
         "option_b": "Seçenek B",
         "correct": "a veya b",
         "retry": "Yanlış seçim sonrası açıklama",
         "info": "Tarihsel bilgi metni"
     }
     ```

2. **Karar görsellerini kontrol et**
   - `decision_overlay.tscn` mevcut görsel template'i kullanır
   - Opsiyonel: her karar için özel arkaplan SVG'si ekle

3. **world.gd'ye event handler ekle**
   - `_on_decision_made(is_correct)` sinyalini bağla
   - Doğru/yanlış durumunda oyun akışını belirle

4. **Test et**
   - Yanlış cevapta `retry` mesajı gösteriliyor mu?
   - Bilgi kartı (`info`) düzgün görüntüleniyor mu?
   - Doğru cevap oyunu ilerletiyor mu?
