# Keystore Yapılandırma Kılavuzu

> **Proje:** MMAE — Bandırma Yolculuğu (Godot 4.6.2)
> **Hedef:** Release APK imzalama için keystore oluşturma ve yapılandırma
> **Tarih:** 2026-05-15

---

## 1. Ön Koşullar

- **Java JDK (keytool):** `keytool` komutu JDK ile gelir. `cmd` veya PowerShell'de şununla doğrula:
  ```powershell
  keytool -help
  ```
  Eğer `keytool` bulunamazsa:
  - Java JDK 11+ yükle: https://adoptium.net/
  - Veya Android Studio ile gelen JDK'yı kullan (genelde `C:\Program Files\Android\Android Studio\jbr\bin\`)

---

## 2. Keystore Oluşturma

Aşağıdaki komutu **PowerShell** veya **cmd**'de çalıştır:

```powershell
keytool -genkey -v -keystore "C:\Users\Aykut\Documents\Godot\mmae\builds\release.keystore" -alias bandirma -keyalg RSA -keysize 2048 -validity 10000
```

### Parametre Açıklamaları

| Parametre | Değer | Açıklama |
|-----------|-------|----------|
| `-keystore` | `builds/release.keystore` | Keystore dosyasının kaydedileceği yol |
| `-alias` | `bandirma` | Keystore içindeki anahtarın alias adı |
| `-keyalg` | `RSA` | Anahtar algoritması |
| `-keysize` | `2048` | Anahtar boyutu (2048 bit önerilir) |
| `-validity` | `10000` | Geçerlilik süresi (gün, ~27 yıl) |

### Çalıştırma Adımları

1. Yukarıdaki komutu PowerShell veya cmd'de çalıştır
2. **İstenen bilgileri gir:**
   - 🔑 **Keystore şifresi** (ana parola) — **GÜVENLİ BİR YERE KAYDET**
   - 👤 Ad, soyad (isminizi veya "Bandirma Yolculugu" yazın)
   - 🏢 Birim/Şirket (opsiyonel, "MMAE" veya boş geçilebilir)
   - 🏙️ Şehir, ilçe (opsiyonel)
   - 🌍 İl (opsiyonel)
   - 🇹🇷 Ülke kodu: `TR`
3. 🔑 **Alias şifresi** sorulduğunda: Keystore şifresiyle **aynı** olması önerilir (Enter'a bas)
4. ✅ Komut başarılı olursa `builds/release.keystore` dosyası oluşur

> ⚠️ **GÜVENLİK UYARISI:** Keystore şifrelerini ASLA Git reposuna ekleme!
> - `release.keystore` dosyası `.gitignore`'da olmalı
> - Şifreler sadece yerel makinede, Godot Editor Export > Keystore alanında saklanmalı

---

## 3. export_presets.cfg'yi Güncelleme

Keystore oluşturulduktan sonra, [`export_presets.cfg`](export_presets.cfg) dosyasında aşağıdaki alanların doldurulması gerekir:

### Yöntem A: Godot Editor Üzerinden (ÖNERİLEN)

1. Godot Editor'de `Proje > Export` menüsünü aç
2. "Android" preset'ini seç
3. "Keystore" sekmesine tıkla
4. **Release** bölümündeki alanları doldur:
   - **Keystore File:** `builds/release.keystore` (veya tam yol)
   - **Keystore Password:** (oluştururken girdiğin şifre)
   - **Keystore Alias:** `bandirma`
   - **Alias Password:** (keystore şifresiyle aynıysa boş bırak)
5. "Save & Export" ile değişiklikleri kaydet

### Yöntem B: Doğrudan export_presets.cfg Düzenleme

```ini
keystore/release="builds/release.keystore"
keystore/release_user="bandirma"
keystore/release_password="BurayaSifreGir"
```

> ⚠️ **NOT:** Şifreyi direkt cfg'ye yazmak güvenlik riski taşır.
>   - Build script'i (`build_android_release_candidate.ps1`) alternatif olarak
>     `artifacts/local/release_signing/release_signing.local.json` dosyasını kullanır
>   - Bu `.gitignore`'da olmalıdır

---

## 4. Local Signing Config (Build Script İçin)

Release build script'i [`tools/build_android_release_candidate.ps1`](tools/build_android_release_candidate.ps1), keystore bilgilerini `artifacts/local/release_signing/release_signing.local.json` dosyasından okur.

Bu dosyayı oluşturmak için:

```powershell
# artifacts/local/release_signing/ klasörünü oluştur
New-Item -ItemType Directory -Path "artifacts/local/release_signing" -Force | Out-Null

# release_signing.local.json dosyasını oluştur
@{
    keystore_path = "C:\Users\Aykut\Documents\Godot\mmae\builds\release.keystore"
    keystore_user = "bandirma"
    keystore_password = "BurayaSifreGir"
} | ConvertTo-Json | Out-File -FilePath "artifacts/local/release_signing/release_signing.local.json" -Encoding utf8
```

> ⚠️ **GÜVENLİK:** Bu dosyayı `.gitignore`'a eklediğinden emin ol:
> ```
> artifacts/local/
> ```

---

## 5. export_presets.cfg'de Doldurulması Gereken Alanlar

| Alan | Açıklama | Durum |
|------|----------|-------|
| `keystore/debug` | Debug keystore yolu (Godot varsayılan debug keystore kullanılır, genelde boş bırakılır) | ❌ Boş |
| `keystore/debug_user` | Debug keystore alias | ❌ Boş |
| `keystore/debug_password` | Debug keystore şifresi | ❌ Boş |
| `keystore/release` | Release keystore dosya yolu | ❌ **Boş — ZORUNLU** |
| `keystore/release_user` | Release keystore alias (`bandirma`) | ❌ **Boş — ZORUNLU** |
| `keystore/release_password` | Release keystore şifresi | ❌ **Boş — ZORUNLU** |

---

## 6. Doğrulama

Keystore yapılandırmasını doğrulamak için:

```powershell
# Keystore içeriğini listele (şifre sorar)
keytool -list -v -keystore "builds\release.keystore"
```

Build script'ini çalıştırarak da doğrulama yapılabilir:
```powershell
.\tools\build_android_release_candidate.ps1
```

Eğer keystore doğru yapılandırılmışsa script başarılı bir release APK üretir.

---

## 7. Sorun Giderme

| Sorun | Çözüm |
|-------|-------|
| `keytool` bulunamıyor | JDK kurulu değil. Android Studio JDK'sını kullan veya Adoptium JDK 11+ yükle |
| `jarsigner` hatası | Keystore bozuk veya şifre yanlış. `keytool -list` ile doğrula |
| Keystore yolu yanlış | Göreceli yol (`builds/release.keystore`) veya tam yol kullan |
| "INVALID KEYSTORE FORMAT" | Eski JKS formatı yerine PKCS12 kullan. Yeni `keytool` versiyonları PKCS12 varsayılandır |
| Build script "Release signing hazir degil" hatası | Keystore alanları export_presets.cfg'de veya release_signing.local.json'da tanımlı değil |

---

## 8. Hızlı Başlangıç (TL;DR)

```powershell
# 1. Keystore oluştur
keytool -genkey -v -keystore "builds\release.keystore" -alias bandirma -keyalg RSA -keysize 2048 -validity 10000

# 2. Local signing config oluştur
New-Item -ItemType Directory -Path "artifacts/local/release_signing" -Force | Out-Null
@{
    keystore_path = "C:\Users\Aykut\Documents\Godot\mmae\builds\release.keystore"
    keystore_user = "bandirma"
    keystore_password = "OLUSTURDUGUN_SIFRE"
} | ConvertTo-Json | Out-File -FilePath "artifacts/local/release_signing/release_signing.local.json" -Encoding utf8

# 3. Build al
.\tools\build_android_release_candidate.ps1
```
