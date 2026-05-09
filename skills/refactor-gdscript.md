# GDScript Yeniden Düzenleme Workflow'u

Bu workflow, mevcut GDScript kodunu proje standartlarına uygun şekilde yeniden düzenlemek için kullanılır.

## Adımlar

1. **Kod analizi**
   - Dosyadaki tüm fonksiyonları ve değişkenleri listele
   - Proje anayasasındaki isimlendirme kurallarına uygunluğu kontrol et
   - Gereksiz `@export` kullanımı var mı? (mümkün olduğunca kaçın)

2. **Pattern uyumluluğu**
   - State machine pattern'i kullanılıyor mu? (`_state` değişkeni, `_transition_to()`)
   - Signal'ler doğru bağlanmış mı? (`func _on_...()` otomatik bağlama)
   - `_process` gereksiz mi? (mobile performans için minimize et)

3. **Sabitleri merkezileştir**
   - Renk sabitleri `world.gd`'deki `DESIGN_*` pattern'ini mi takip ediyor?
   - Texture sabitleri `SCREAMING_SNAKE_CASE` ve `_TEXTURE` son ekine sahip mi?
   - Sihirli sayılar (magic numbers) const olarak tanımlanmış mı?

4. **Performans denetimi**
   - `_process` döngüsünde ağır işlem var mı?
   - `queue_redraw()` gereksiz sıklıkta çağrılıyor mu?
   - Texture preload'ları optimize edilmiş mi?

5. **Dokümantasyon güncelleme**
   - Karmaşık fonksiyonlara yorum satırı ekle
   - `docs/` altındaki ilgili dokümanları güncelle
