# DeepSeek Next Phase Review & Recovery Plan

Tarih: 2026-05-14  
Sahip rol: GPT-5.5 / Senior Game Director, Technical Lead, Systems Architect, Production Planner  
Uygulayıcı rol: DeepSeek V4 Pro  
Kapsam: Sadece planlama, denetim, kabul kanıtı ve eksik önceki paketlerin kapatılması. Yeni oyun sistemi geliştirme yok.

## PROJECT OVERVIEW

Bu fazın amacı yeni özellik eklemek değil, DeepSeek'in ilk paket ve devamındaki değişikliklerinin gerçekten kabul edilebilir, tekrar üretilebilir ve izlenebilir olup olmadığını doğrulamaktır.

Mevcut repo dirty durumdadır ve birçok paket dosyası, araç, test, doküman ve sahne değişikliği aynı anda görünmektedir. Bu nedenle sıradaki doğru aşama doğrudan Package 7/8/10/12 geliştirmesine geçmek değildir. Önce paket durumu, takip dokümanı, test çıktıları ve üretilen dosyalar aynı gerçeklikte buluşturulmalıdır.

Ana karar:

- Yeni feature freeze uygulanacak.
- Önce Package 1 kesin kabul edilecek veya DeepSeek'e geri düzeltme verilecek.
- Package 9 performans kanıtı eksikse geri tamamlatılacak.
- Package 11, 2, 3, 4, 5, 6 out-of-order görünse bile kanıtla doğrulanacak.
- Package 7, 8, 10, 12 için repoda görünen dosyalar "tamamlandı" kabul edilmeyecek; önce triage yapılacak.

## CRITICAL ISSUES

### CRITICAL: Tracking ile repo gerçekliği tutarsız

`docs/EXECUTION_TRACKING.md` Package 1 için hala inceleme/bekleme sinyali taşırken, sonraki paketlerden bazıları tamamlandı olarak işaretlenmiş görünüyor. Buna ek olarak repoda Package 7, 8, 10 ve 12'ye ait gibi duran untracked dosyalar mevcut.

Impact: Hangi paketin gerçekten kabul edildiği bilinmeden yeni iş başlatılırsa regressions, yarım sistemler ve yanlış roadmap oluşur.

Risk: Çok yüksek. Bu durum üretim planlamasını ve kabul güvenilirliğini bozar.

### CRITICAL: Package 1 kabulü kanıtsız veya eksik olabilir

`tools/run_p10_smoke_gate.ps1` mevcut ancak Package 1'in tamamlandığını kabul etmek için test çıktısı, log kanıtı ve takip güncellemesi net değildir.

DeepSeek özellikle şunları kanıtlamalıdır:

- Komut tek seferde tüm P10 gate'lerini çalıştırıyor.
- Başarısız gate durumunda non-zero exit veriyor.
- Başarılı çıktıda `APP_LIFECYCLE_CONTRACT_OK` görünüyor.
- Device smoke sonucu açık: `DEVICE_AVAILABLE` veya `DEVICE_SMOKE_SKIPPED_NO_ADB_OR_DEVICE`.
- Package dokümanında iddia edilen JSON + MD log çıktısı gerçekten üretiliyor veya dokümandaki iddia düzeltiliyor.

### HIGH: Package 9 performans raporu doldurulmamış görünüyor

`docs/PERFORMANCE_OBSERVATION.md` içinde zone node karmaşıklık tablosu placeholder değerler taşıyor. Bu, Package 9'un araç bazında eklenmiş ama kabul raporu olarak tamamlanmamış olabileceğini gösterir.

Impact: Performans gate'i var gibi görünür ama baseline olmadığı için gelecekte regressions yakalanamaz.

Risk: Yüksek. Özellikle mobil hedefte node count ve complexity sınırları ölçümsüz kalır.

### HIGH: Sonraki paketlere ait dosyalar takip edilmeden oluşmuş olabilir

Repo izlerinde journal, audio, accessibility ve P12 release araçlarına ait dosyalar görünmektedir. Bunlar tracking'e tam ve güvenilir şekilde bağlanmadan kabul edilmemelidir.

Impact: Yarım feature'lar oyuna sessizce girebilir.

Risk: Yüksek. Özellikle save, overlay stack, accessibility ve release pipeline alanları hassastır.

## ARCHITECTURE REVIEW

Bu fazda mimari karar yeni sistem eklemek değil, mevcut mimari üzerindeki kabul sözleşmelerini güvenceye almaktır.

DeepSeek'in öncelikli mimari görevi:

1. Paket bazlı dosya sahipliği çıkarmak.
2. Her yeni araç/test/dokümanın hangi package'a ait olduğunu etiketlemek.
3. Tracking dosyasını gerçek test kanıtı dışında güncellememek.
4. Untracked veya out-of-order geliştirmeleri "accepted" değil, "triage pending" olarak sınıflandırmak.

Architecture acceptance rule:

Bir paket ancak şu üç kanıt aynı anda varsa tamamlandı sayılır:

- İlgili dosyalar mevcut ve amacına uygun.
- Paket testleri ve ana regression gate'leri geçiyor.
- `docs/EXECUTION_TRACKING.md` içinde komut, çıktı marker'ı ve gözden geçirme notu var.

## GAME DESIGN REVIEW

Bu faz oyun tasarımını genişletmeyecek. Bandırma demo ve mevcut oyun loop'u için oyun tasarım riski şu anda feature eksikliği değil, kabul yüzeyinin güvenilir olmamasıdır.

Bu yüzden tasarım kararı:

- Yeni tutorial, journal, audio veya accessibility davranışı tasarlanmayacak.
- Eğer bu sistemlere ait dosyalar zaten oluşturulduysa önce "partial / complete / unsafe" sınıflaması yapılacak.
- Oyuncu-facing değişiklikler ancak önceki paket kabulü netleşirse sonraki feature fazında ele alınacak.

## PERFORMANCE REVIEW

Package 9 için performans araçları kabul edilebilirse bu projenin üretim kalitesine doğrudan katkı verir. Ancak placeholder raporla kabul edilirse performans gate'i sadece görünürde kalır.

DeepSeek performans kabulünde şunları kanıtlamalıdır:

- `tools/run_p11_performance_gate.ps1` çalışıyor.
- `tools/measure_world_complexity.gd` zone başına gerçek node ve marker sayılarını çıkarıyor.
- `artifacts/logs/p11_complexity_<timestamp>.csv` üretiliyor.
- `docs/PERFORMANCE_OBSERVATION.md` gerçek ölçüm değerleriyle güncelleniyor.
- Threshold aşımı varsa package complete değil, repair required olarak işaretleniyor.

## VISUAL REVIEW

Bu faz görsel üretim veya yeni capture istemez. Görsel kanıt sadece kabul için gerekirse alınır.

Gerekli görsel kontrol alanları:

- Bandırma capture'da transition overlay kalıntısı yok.
- Objective, guidance ve location sign üst üste binmiyor.
- P10 smoke gate veya capture tool dokümanı görsel kabulün tekrar üretilebilir komutunu açıkça gösteriyor.

Yeni sanat, yeni UI redesign veya polish backlog uygulaması bu fazda yapılmayacak.

## QUICK WINS

1. `docs/EXECUTION_TRACKING.md` içindeki Package 1 durumunu gerçek P10 smoke çıktısıyla netleştir.
2. `docs/PERFORMANCE_OBSERVATION.md` placeholder tablosunu gerçek ölçümle doldur.
3. Untracked dosyaları package sahipliğine göre sınıflandır.
4. Package 7/8/10/12 için "başlandı mı, tamamlandı mı, yoksa yanlışlıkla mı üretildi" sorusuna kanıtlı cevap ver.
5. Her package için acceptance marker listesini tracking dosyasına ekle.

## HIGH IMPACT IMPROVEMENTS

Bu fazdaki en yüksek etkili iyileştirme yeni özellik değil, release disiplinidir.

DeepSeek'in bu faz sonunda üretmesi gereken ana çıktı:

- `docs/DEEPSEEK_REVIEW_REPORT.md`
- Güncellenmiş `docs/EXECUTION_TRACKING.md`
- Package 1 için P10 smoke log kanıtı
- Package 9 için gerçek performans baseline kanıtı
- Package 7/8/10/12 için triage tablosu

## TECHNICAL DEBT

Şu teknik borçlar bu fazın odak alanıdır:

- Paketlerin out-of-order tamamlandı görünmesi
- Test kanıtı olmadan completed durumuna geçme riski
- Placeholder performans dokümanı
- Untracked dosyaların hangi package'a ait olduğunun belirsizliği
- Log format iddiaları ile gerçek script çıktılarının uyuşmama ihtimali

Bu borçlar çözülmeden yeni gameplay sistemi açılmayacak.

## ROADMAP

### Short-Term: Review Freeze ve Kabul Geri Kazanımı

Priority: CRITICAL  
Complexity: MEDIUM  
Risk: LOW, çünkü yeni feature yok  
Expected Impact: Çok yüksek  
Dependencies: Mevcut dirty state korunmalı, revert yapılmamalı

Implementation order:

1. Current dirty state snapshot al.
2. Package ownership map oluştur.
3. Package 1 P10 smoke gate'i çalıştır ve raporla.
4. Package 1 eksikse sadece onu düzeltmek için DeepSeek repair task'ı aç.
5. Package 9 performans baseline'ını gerçek değerlerle tamamla.
6. Package 11, 2, 3, 4, 5, 6 için kabul gate'lerini tekrar çalıştır.
7. Package 7, 8, 10, 12 dosyalarını triage et.
8. Tracking dosyasını yalnızca doğrulanmış sonuçlarla güncelle.

### Mid-Term: Partially Started Packages Stabilization

Priority: HIGH  
Complexity: MEDIUM-HIGH  
Risk: MEDIUM  
Expected Impact: Yüksek  
Dependencies: Short-Term review tamamlanmış olmalı

Implementation order:

1. Eğer Package 7 journal dosyaları gerçekten başladıysa Package 7'yi sıfırdan başlatma; review/finalize paketi aç.
2. Package 8 audio üretim sistemi dosyaları varsa önce doğrulama ve envanter tutarlılığı yap.
3. Package 10 accessibility dosyaları varsa önce UI focus ve save uyumluluğunu test et.
4. Package 12 release araçları P10/P11 gate'lerine bağlı şekilde tekrar konumlandır.

### Long-Term: Production Roadmap Resume

Priority: MEDIUM  
Complexity: HIGH  
Risk: MEDIUM  
Expected Impact: Yüksek  
Dependencies: Tüm önceki package kabul kanıtları tamamlanmalı

Implementation order:

1. Journal MVP kullanıcı akışını stabilize et.
2. Audio integration production pass yap.
3. Accessibility reading comfort pass'i çocuk oyuncu hedefiyle tamamla.
4. Commercial polish backlog'u gerçek release candidate gate'lerine bağla.

## DEEPSEEK IMPLEMENTATION PACKAGES

### PACKAGE R1: Review Freeze and Package Ownership Map

TITLE  
Review Freeze ve Package Ownership Map

OBJECTIVE  
Mevcut dirty repo durumunu bozmadan bütün değişiklikleri package sahipliğine göre sınıflandırmak.

CONTEXT  
Önce şu dosyalar incelenecek:

- `docs/EXECUTION_TRACKING.md`
- `docs/MASTER_PLANNER_GODOT_ANALYSIS_AND_DEEPSEEK_PACKAGES.md`
- `docs/EXECUTION_PACKAGES_PLAN.md`
- `git status --short --untracked-files=all` çıktısı

IMPLEMENTATION DETAILS  
DeepSeek kod veya sahne davranışı değiştirmeyecek. Önce review snapshot çıkaracak.

Komutlar:

```powershell
git status --short --untracked-files=all
```

Ardından bir review raporu oluştur:

- Dosya: `docs/DEEPSEEK_REVIEW_REPORT.md`
- Bölümler:
  - Current Dirty State Summary
  - Package Ownership Map
  - Accepted Packages
  - Packages Requiring Repair
  - Untracked / Out-of-Order Package Evidence
  - Commands Run
  - Final Recommendation

FILES TO MODIFY

- `docs/DEEPSEEK_REVIEW_REPORT.md`
- `docs/EXECUTION_TRACKING.md` yalnızca doğrulanmış sonuçlar için

GODOT BEST PRACTICES

- Sahne veya script davranışı değiştirme.
- Godot import/artifact dosyalarını manuel temizleme.
- Dirty worktree içindeki kullanıcı veya başka model değişikliklerini revert etme.

DO NOT BREAK

- Mevcut package dosyaları
- Existing test tools
- Tracking history
- Dirty state içindeki hiçbir dosya

ACCEPTANCE CRITERIA

- Her changed/untracked dosya bir package, artifact veya unknown bucket altında listelenmiş.
- Unknown bucket boş değilse gerekçeli açıklama var.
- Hiçbir production code değişmemiş.
- Tracking dosyasında sadece kanıtlanmış bilgiler güncellenmiş.

OPTIONAL POLISH

- Package map'i tablo formatında yaz.

TEST CHECKLIST

- `git diff -- docs/DEEPSEEK_REVIEW_REPORT.md docs/EXECUTION_TRACKING.md`
- Review raporunda Package 1, 9, 11, 2, 3, 4, 5, 6, 7, 8, 10, 12 ayrı ayrı görünüyor.

### PACKAGE R2: Package 1 P10 Smoke Gate Acceptance or Repair

TITLE  
Package 1 P10 Smoke Gate Kabulü veya Onarımı

OBJECTIVE  
Package 1'in gerçekten tamamlandığını kanıtlamak veya eksikse DeepSeek'e geri repair yaptırmak.

CONTEXT  
Önce şu dosyalar incelenecek:

- `tools/run_p10_smoke_gate.ps1`
- `docs/ANDROID_RELEASE_CHECKLIST.md`
- `docs/EXECUTION_TRACKING.md`
- `docs/MASTER_PLANNER_GODOT_ANALYSIS_AND_DEEPSEEK_PACKAGES.md`

IMPLEMENTATION DETAILS  
Komut:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1
```

Başarı için required markers:

- `P10_SMOKE_GATE_OK`
- `FLOW_VALIDATION_OK`
- `APP_LIFECYCLE_CONTRACT_OK`
- `DEVICE_AVAILABLE` veya `DEVICE_SMOKE_SKIPPED_NO_ADB_OR_DEVICE`

DeepSeek ayrıca şunları doğrulamalı:

- Gate failure olduğunda script non-zero exit veriyor.
- Godot bulunamadığında skip davranışı dokümanla uyumlu. Eğer local Godot mevcutsa skip kabul edilmez.
- Dokümanda JSON + MD log iddiası varsa script gerçekten iki formatı da üretiyor. Üretmiyorsa ya script tamamlanır ya doküman iddiası düzeltilir.
- Log dosyası `artifacts/logs/p10_smoke_<timestamp>.md` altında oluşuyor.

FILES TO MODIFY

- `tools/run_p10_smoke_gate.ps1`, sadece acceptance eksikse
- `docs/ANDROID_RELEASE_CHECKLIST.md`, sadece komut/log gerçekliğiyle uyuşmuyorsa
- `docs/EXECUTION_TRACKING.md`
- `docs/DEEPSEEK_REVIEW_REPORT.md`

GODOT BEST PRACTICES

- Smoke gate headless çalışmalı.
- Test komutları deterministic olmalı.
- Device yoksa failure değil açık skip marker olmalı.
- Actual gate failure hiçbir şekilde success gibi raporlanmamalı.

DO NOT BREAK

- `tools/validate_game_flow.gd`
- `tools/verify_app_lifecycle_contract.gd`
- `tools/verify_overlay_input_contract.gd`
- `tools/verify_ui_focus_accessibility.gd`
- Android release checklist

ACCEPTANCE CRITERIA

- Package 1 ancak P10 smoke command başarılı çalışırsa tamamlandı işaretlenir.
- Tracking entry içinde komut, tarih, marker'lar ve log path yer alır.
- Missing Godot skip'i varsa Package 1 complete değil, environment-blocked olarak işaretlenir.
- JSON + MD log tutarlılığı netleşmiştir.

OPTIONAL POLISH

- P10 smoke markdown log'una compact summary table ekle.

TEST CHECKLIST

- `powershell -ExecutionPolicy Bypass -File tools/run_p10_smoke_gate.ps1`
- Log path doğrulaması
- Exit code doğrulaması

### PACKAGE R3: Package 9 Performance Baseline Repair

TITLE  
Package 9 Performans Baseline Onarımı

OBJECTIVE  
Performance Observation dokümanını gerçek ölçüm değerleriyle tamamlamak ve Package 9'u kanıta bağlamak.

CONTEXT  
Önce şu dosyalar incelenecek:

- `tools/run_p11_performance_gate.ps1`
- `tools/measure_world_complexity.gd`
- `docs/PERFORMANCE_OBSERVATION.md`
- `docs/EXECUTION_TRACKING.md`

IMPLEMENTATION DETAILS  
Komut:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_p11_performance_gate.ps1
```

DeepSeek şunları yapacak:

- CSV/artifact çıktısının oluştuğunu doğrula.
- Zone node complexity tablosundaki placeholder değerleri gerçek değerlerle doldur.
- Threshold aşımları varsa complete değil repair required yaz.
- Package 9 tracking entry'sine log path ve marker ekle.

FILES TO MODIFY

- `docs/PERFORMANCE_OBSERVATION.md`
- `docs/EXECUTION_TRACKING.md`
- `docs/DEEPSEEK_REVIEW_REPORT.md`
- `tools/run_p11_performance_gate.ps1` veya `tools/measure_world_complexity.gd`, sadece ölçüm tool'u bozuksa

GODOT BEST PRACTICES

- Ölçüm headless çalışmalı.
- Runtime olmayan editor/import node'ları yanlış sayılmamalı.
- Threshold değerleri dokümanda ve scriptte çelişmemeli.

DO NOT BREAK

- World generation
- Zone loading
- Capture tools
- Existing P10 smoke gate

ACCEPTANCE CRITERIA

- `docs/PERFORMANCE_OBSERVATION.md` placeholder tablo taşımıyor.
- En az Bandırma/Samsun/Amasya/Erzurum/Sivas için gerçek ölçüm var veya eksik zone gerekçesi yazılmış.
- P11 performance command başarıyla çalışmış.
- Tracking entry kanıtlı şekilde güncellenmiş.

OPTIONAL POLISH

- CSV kolonlarını dokümanda kısa açıklama ile ver.

TEST CHECKLIST

- `powershell -ExecutionPolicy Bypass -File tools/run_p11_performance_gate.ps1`
- `docs/PERFORMANCE_OBSERVATION.md` gerçek değer kontrolü
- Artifact path kontrolü

### PACKAGE R4: Previously Marked Complete Packages Verification

TITLE  
Package 11, 2, 3, 4, 5, 6 Kabul Doğrulaması

OBJECTIVE  
Tracking'de tamamlandı görünen paketleri yeniden test ederek out-of-order riskini kapatmak.

CONTEXT  
Önce package tracking entry'leri ve ilgili package dokümanları incelenecek.

IMPLEMENTATION DETAILS  
DeepSeek aşağıdaki doğrulama komutlarını çalıştıracak ve sonuçlarını `docs/DEEPSEEK_REVIEW_REPORT.md` içine yazacak.

Core gates:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --check-only --path . --quit
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/validate_game_flow.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_overlay_input_contract.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_ui_focus_accessibility.gd
```

Package-specific gates, dosya varsa:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_zone_definition_contract.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_tutorial_contract.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_p5_late_zone_benchmark_contract.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_samsun_benchmark_contract.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_capture_world_render_contract.gd
```

FILES TO MODIFY

- `docs/DEEPSEEK_REVIEW_REPORT.md`
- `docs/EXECUTION_TRACKING.md`, sadece doğrulama sonucu değişirse
- İlgili tool/test dosyaları, sadece acceptance blocker varsa

GODOT BEST PRACTICES

- Eksik optional verify script varsa failure gibi davranma; package context'e göre "not applicable" yaz.
- Var olan verify script fail ederse package complete kalamaz.

DO NOT BREAK

- Zone resource pilot
- Marker data / visual split
- World builder decomposition
- First-run tutorial layer
- Release candidate pipeline

ACCEPTANCE CRITERIA

- Her completed package için en az bir somut test veya static verification kanıtı var.
- Fail eden package tracking'de repair required durumuna çekiliyor.
- Komut çıktıları özetlenmiş ve marker'lar rapora yazılmış.

OPTIONAL POLISH

- Review report'a package status matrix ekle.

TEST CHECKLIST

- Core gates çalıştı.
- Package-specific gates çalıştı veya gerekçeli skipped yazıldı.
- Tracking ile review report aynı sonucu söylüyor.

### PACKAGE R5: Unreported Package Triage for 7, 8, 10, 12

TITLE  
Package 7/8/10/12 Unreported Work Triage

OBJECTIVE  
Repoda görünen journal, audio, accessibility ve P12 release dosyalarının gerçek durumunu sınıflandırmak.

CONTEXT  
Önce aşağıdaki potansiyel dosyalar incelenecek:

- `scenes/journal_overlay.tscn`
- `scripts/journal_overlay.gd`
- `test/test_journal.gd`
- `assets/audio/bgm/.gitkeep`
- `assets/audio/sfx/.gitkeep`
- `docs/AUDIO_INVENTORY.md`
- `docs/AUDIO_PRODUCTION_GUIDE.md`
- `tools/verify_audio_production.gd`
- `test/test_audio.gd`
- `scenes/accessibility_panel.tscn`
- `scripts/accessibility_panel.gd`
- `test/test_accessibility.gd`
- `docs/POLISH_BACKLOG.md`
- `docs/RELEASE_GATES.md`
- `tools/run_p12_release_preflight.ps1`
- `tools/run_p12_release_device_smoke.ps1`
- `tools/setup_local_release_signing.ps1`

IMPLEMENTATION DETAILS  
DeepSeek her package için şu sınıflardan birini verecek:

- `NOT_STARTED`
- `PARTIAL_UNSAFE`
- `PARTIAL_REVIEWABLE`
- `COMPLETE_BUT_UNTRACKED`
- `ACCEPTED_AFTER_REVIEW`

Hiçbir package bu triage sonunda otomatik accepted olmayacak. Accepted olması için ilgili test ve tracking kanıtı şarttır.

Suggested checks:

```powershell
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://test/test_journal.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/verify_audio_production.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://test/test_audio.gd
Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://test/test_accessibility.gd
powershell -ExecutionPolicy Bypass -File tools/run_p12_release_preflight.ps1
```

P12 preflight sadece P10 ve P11 kabulü netleştiyse çalıştırılacak.

FILES TO MODIFY

- `docs/DEEPSEEK_REVIEW_REPORT.md`
- `docs/EXECUTION_TRACKING.md`, sadece kanıtlı status güncellemesi için

GODOT BEST PRACTICES

- Overlay tabanlı sistemlerde input focus contract bozulmamalı.
- Journal veya accessibility save alanı eklediyse backward compatibility kontrol edilmeli.
- Audio üretim placeholder'ları runtime failure yaratmamalı.

DO NOT BREAK

- Save/load
- Overlay manager
- Input focus
- Existing UI accessibility gate
- Release scripts

ACCEPTANCE CRITERIA

- Package 7/8/10/12 için net status sınıfı var.
- Her status kanıta bağlı.
- Partial işler accepted görünmüyor.
- Sonraki gerçek implementation package açıkça belirlenmiş.

OPTIONAL POLISH

- Triage tablosunda "next action" kolonu kullan.

TEST CHECKLIST

- Journal test sonucu
- Audio verify sonucu
- Accessibility test sonucu
- P12 preflight sonucu veya skip gerekçesi

### PACKAGE R6: Next Implementation Decision Gate

TITLE  
Sonraki Implementation Karar Kapısı

OBJECTIVE  
Review bittikten sonra DeepSeek'in hangi pakete geçeceğini güvenli biçimde belirlemek.

CONTEXT  
Bu package sadece R1-R5 tamamlandıktan sonra çalışır.

IMPLEMENTATION DETAILS  
Karar kuralları:

1. Package 1 fail veya environment-blocked ise sıradaki iş Package 1 repair'dir.
2. Package 9 placeholder veya ölçüm fail ise sıradaki iş Package 9 repair'dir.
3. Package 11/2/3/4/5/6 içinden fail eden varsa sıradaki iş en erken fail eden package repair'dir.
4. Package 7 dosyaları `PARTIAL_REVIEWABLE` veya `COMPLETE_BUT_UNTRACKED` ise sıradaki iş Package 7 review/finalize'dır, sıfırdan journal implementasyonu değildir.
5. Package 7 gerçekten `NOT_STARTED` ise sıradaki normal implementation Package 7 Journal / Tarih Defteri MVP'dir.
6. Package 8/10/12 Package 7 tamamlanmadan production priority alamaz; sadece blocking regression varsa repair yapılır.

FILES TO MODIFY

- `docs/DEEPSEEK_REVIEW_REPORT.md`
- `docs/EXECUTION_TRACKING.md`

GODOT BEST PRACTICES

- Roadmap state test kanıtıyla ilerlemeli.
- Gameplay-facing sistemler release gates'ten bağımsız merge edilmemeli.

DO NOT BREAK

- Tracking chronology
- Existing package docs
- Acceptance history

ACCEPTANCE CRITERIA

- Review report sonunda tek bir next package recommendation var.
- Recommendation gerekçesi package status matrix'e dayanıyor.
- "Yeni feature'a geç" kararı ancak P10/P11 ve prior packages green ise veriliyor.

OPTIONAL POLISH

- Review report sonunda DeepSeek için copy-ready next prompt ekle.

TEST CHECKLIST

- R1-R5 statusları tamamlanmış.
- Next action tekil ve çelişkisiz.
- Tracking dosyası ile next action uyumlu.

## FINAL DIRECTIVE TO DEEPSEEK V4 PRO

DeepSeek bu fazda yeni sistem geliştirmeye başlamayacak. İlk görevi mevcut package durumunu kanıtla sabitlemektir.

Öncelik sırası değiştirilemez:

1. R1 Review Freeze and Package Ownership Map
2. R2 Package 1 P10 Smoke Gate Acceptance or Repair
3. R3 Package 9 Performance Baseline Repair
4. R4 Previously Marked Complete Packages Verification
5. R5 Unreported Package Triage for 7, 8, 10, 12
6. R6 Next Implementation Decision Gate

Bu fazın sonunda beklenen sonuç: "Sıradaki implementation package hangisi?" sorusunun tek, kanıtlı ve takip dosyasıyla uyumlu cevabı.
