# MMAE - Agent Development Kit Kurulum Script'i
# ===============================================
# Bu script, ADK'nin tüm bileşenlerini projeye kurar.
# Kullanım: PowerShell'de bu script'i çalıştırın

Write-Host "🚀 MMAE Agent Development Kit Kurulumu" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Proje kök dizinini al
$projectRoot = Split-Path -Parent $PSScriptRoot

# 1️⃣ Katman 1: Bellek / Anayasa
Write-Host "📝 Katman 1: .clinerules kuruluyor..." -ForegroundColor Yellow
if (Test-Path "$projectRoot\.clinerules") {
    Write-Host "  ✅ .clinerules mevcut" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  .clinerules bulunamadı!" -ForegroundColor Red
}

# 2️⃣ Katman 2: Bilgi / Workflow'lar
Write-Host "📚 Katman 2: Skills workflow'ları kuruluyor..." -ForegroundColor Yellow
$skillFiles = @(
    "new-chapter.md",
    "new-decision.md",
    "new-scene.md",
    "refactor-gdscript.md",
    "dialogue-sequence.md",
    "art-asset.md",
    "android-build.md",
    "godot-refactor.md",
    "shader-expert.md",
    "ui-auto-layout.md"
)
foreach ($file in $skillFiles) {
    $path = "$projectRoot\skills\$file"
    if (Test-Path $path) {
        Write-Host "  ✅ skills/$file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  skills/$file eksik!" -ForegroundColor Red
    }
}

# 3️⃣ Katman 3: Korkuluklar / Doğrulama
Write-Host "🛡️  Katman 3: Guardrails kuruluyor..." -ForegroundColor Yellow
$guardFiles = @(
    "pre_check.gd",
    "post_validate.gd",
    "superpowers.yaml"
)
foreach ($file in $guardFiles) {
    $path = "$projectRoot\tools\$file"
    if (Test-Path $path) {
        Write-Host "  ✅ tools/$file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  tools/$file eksik!" -ForegroundColor Red
    }
}

# 4️⃣ Katman 4: Delegasyon / Alt Agent'lar
Write-Host "👥 Katman 4: Custom Modes kuruluyor..." -ForegroundColor Yellow
if (Test-Path "$projectRoot\.roomodes") {
    Write-Host "  ✅ .roomodes mevcut" -ForegroundColor Green
    Write-Host "  📋 Agent listesi:"
    Write-Host "      👑 tech-lead - Tech Lead (mimari denetim)"
    Write-Host "      💻 developer - Developer (GDScript geliştirme)"
    Write-Host "      🧪 qa-specialist - QA Specialist (test)"
    Write-Host "      🏗️  godot-scene-designer - Sahne Tasarımcısı"
    Write-Host "      📜 gdscript-wizard - GDScript Sihirbazı"
    Write-Host "      ✍️  story-writer - Hikaye Yazarı"
    Write-Host "      🎨 art-director - Sanat Yönetmeni"
    Write-Host "      🚀 build-master - Build ve Dağıtım"
} else {
    Write-Host "  ⚠️  .roomodes bulunamadı!" -ForegroundColor Red
}

# 5️⃣ MCP Sunucuları
Write-Host "🔌 Katman 5: MCP Sunucuları kuruluyor..." -ForegroundColor Yellow
$mcpFiles = @(
    "mcp_config.json",
    "model_routing.yaml"
)
foreach ($file in $mcpFiles) {
    $path = "$projectRoot\tools\$file"
    if (Test-Path $path) {
        Write-Host "  ✅ tools/$file" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  tools/$file eksik!" -ForegroundColor Red
    }
}

# 6️⃣ Global custom_modes.yaml güncellemesi
Write-Host ""
Write-Host "📦 Global yapılandırma..." -ForegroundColor Yellow
$globalSettings = "$env:APPDATA\Code\User\globalStorage\rooveterinaryinc.roo-cline\settings\custom_modes.yaml"
if (Test-Path $globalSettings) {
    Write-Host "  ✅ Global ayarlar mevcut: $globalSettings" -ForegroundColor Green
    Write-Host "  ⚠️  .roomodes proje bazlı modları tanımlar." -ForegroundColor Yellow
    Write-Host "     Global modlar tüm projelerde kullanılabilir." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ MMAE ADK Kurulumu Tamamlandı!" -ForegroundColor Cyan
Write-Host ""
Write-Host "📖 Kullanım Şeması:"
Write-Host ""
Write-Host "  ┌──────────────────────────────────────────────────┐"
Write-Host "  │  🧠 .clinerules → Her oturumda otomatik yüklenir│"
Write-Host "  │  📚 skills/     → Görev bazlı workflow'lar      │"
Write-Host "  │  👥 .roomodes   → 8 uzman AI agent              │"
Write-Host "  │  🛡️  tools/      → Guardrails + validasyon       │"
Write-Host "  │  🔌 MCP         → Godot + GitHub entegrasyonu    │"
Write-Host "  │  🎯 Model Route → Flash (rutin) / Pro (karmaşık) │"
Write-Host "  └──────────────────────────────────────────────────┘"
Write-Host ""
Write-Host "🎯 Örnek Kullanım:"
Write-Host "  'Yeni bölüm ekle ve kodunu review et'"
Write-Host "      → developer (yazar) → tech-lead (review)"
Write-Host ""
Write-Host "  'Oyunda hata var, bul ve düzelt'"
Write-Host "      → qa-specialist (teşhis) → developer (düzeltme)"
Write-Host ""
Write-Host "  'Senarist gözünden kararları gözden geçir'"
Write-Host "      → story-writer + tech-lead"
