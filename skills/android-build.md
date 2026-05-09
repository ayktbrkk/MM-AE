# Android Build Hazırlama Workflow'u

Bu workflow, oyunu Android platformu için build etmek ve dağıtmak için kullanılır.

## Adımlar

1. **Export template'leri kontrol et**
   - Godot 4.6 Android export template'leri yüklü mü?
   - Gerekirse: Editor → Manage Export Templates
   - JDK, Android SDK ve gradle yolları doğru ayarlanmış mı?

2. **Export ayarları**
   - Proje → Export → Android
   - Custom Package: imzalı APK/AAB yapılandırması
   - Screen Orientation: Portrait
   - Min API Level: 21 (Android 5.0+)
   - Texture Format: ASTC (mobile için optimize)

3. **İmzalama (Signing)**
   - Debug keystore: `tools/debug.keystore`
   - Release keystore: güvenli bir yerde saklanmalı
   - Gradle build tipi: Release

4. **Build komutu**
   ```bash
   godot --headless --export-release "Android" ./build/bandirma-yolculugu.aab
   ```

5. **Test et**
   - APK/AAB dosyasını fiziksel cihazda test et
   - Performans (FPS, bellek kullanımı)
   - Dokunmatik girişler doğru çalışıyor mu?
   - Portrait modda UI taşması var mı?
