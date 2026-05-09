# Debug Workflow - Claude Superpowers "Debug" Becerisi

Bu workflow, sistematik hata ayıklama için 6 adımlı bir süreç tanımlar.

## 🎯 Amaç

Rastgele değişiklikler yapmadan, bilimsel yöntemle hata bul ve düzelt.

## Adımlar

### 1. Hatayı Yeniden Üret 🔄
- [ ] Hatayı tetikleyen adımları yaz
- [ ] Hangi ekranda/state'teyken oluşuyor?
- [ ] Her seferinde mi? Rastgele mi?
- [ ] Log/debug çıktısı ne diyor?

### 2. İlgili Dosyaları Tara 🔍
```gdscript
# Olası sorunlu alanlar:
# 1. Signal bağlantıları (doğru bağlanmış mı?)
# 2. @onready node referansları (path doğru mu?)
# 3. Typing hataları (int vs float, null kontrolü)
# 4. _process içinde beklenmeyen durum
# 5. Event data formatı (questions.gd)
```

### 3. Hipotez Kur 🎯
- En olası 1-2 nedeni belirle
- Örn: "Dialogue overlay açılmıyor çünkü signal bağlantısı kopuk"
- Örn: "Karar sonrası oyun ilerlemiyor çünkü correct alanı yanlış"

### 4. Test Et 🧪
- Hipotezi doğrulamak için minimal test yaz
- Godot editor'de hızlı test
- Gerekirse geçici debug print ekle:
```gdscript
print("DEBUG: signal received, event_data=", event_data)
```

### 5. Çözümü Uygula 🔧
- [ ] Düzeltmeyi yap (minimal değişiklik)
- [ ] Sadece sorunlu kısmı değiştir, başka yere dokunma
- [ ] Düzeltme sonrası hatanın gittiğini doğrula

### 6. Regression Test ✅
- [ ] Düzeltilen hata tekrarlanmıyor mu?
- [ ] Yakın ilişkili diğer özellikler çalışıyor mu?
- [ ] Mobil build'de de sorunsuz mu?

## Altın Kural
❌ "Şurayı da düzelteyim" YAPMA — sadece hedef hatayı düzelt.
✅ Minimal değişiklik, maksimum etki.

## Kullanım

"Dialogue paneli açılmıyor, debug et"
"Karar sonrası oyun donuyor, sebebini bul"
