<#
.SYNOPSIS
    MMAE Projesi için Agent Rolü Aktivasyon Scripti
.DESCRIPTION
    Bu script, RooCode'dan taşınan agent rollerini otomatik olarak
    yapılandırır. Hangi rolün hangi skill dosyasını kullanacağını
    ve hangi anahtar kelimelerle tetikleneceğini gösterir.
    
    Kullanım: .\activate_role.ps1 -Role architect
    Kullanım: .\activate_role.ps1 -List
.PARAMETER Role
    Aktifleştirilecek rol (architect, debug, developer, tech-lead, qa-specialist,
    scene-designer, gdscript-wizard, story-writer, art-director, build-master)
.PARAMETER List
    Tüm rolleri ve trigger kelimelerini listeler
.PARAMETER Analyze
    Verilen bir metni analiz eder ve hangi rolün eşleştiğini gösterir
.EXAMPLE
    .\activate_role.ps1 -Role architect
    .\activate_role.ps1 -List
    .\activate_role.ps1 -Analyze "Dialogue paneli açılmıyor, debug et"
#>

param(
    [string]$Role = "",
    [switch]$List,
    [string]$Analyze = ""
)

# Rol tanımları
$roles = @{
    architect = @{
        name = "🏗️ Architect"
        description = "Sistem tasarımı ve planlama"
        skill = "skills/architect-workflow.md"
        triggers = @("planla", "tasarım", "mimari", "node tree", "sistem tasarımı",
                     "akış şeması", "signal akışı", "gereksinim analizi", "proje planı")
    }
    debug = @{
        name = "🪲 Debug"
        description = "Sistematik hata ayıklama"
        skill = "skills/debug-workflow.md"
        triggers = @("hata", "çalışmıyor", "debug", "bug", "broken",
                     "düzelt", "sorun", "problem", "exception", "crash", "donma")
    }
    developer = @{
        name = "💻 Developer"
        description = "Test-first GDScript geliştirme (VARSAYILAN)"
        skill = "skills/implement.md"
        triggers = @("yaz", "kod", "implement et", "ekle", "oluştur",
                     "geliştir", "yap", "function", "script")
        is_default = $true
    }
    "tech-lead" = @{
        name = "👑 Tech Lead"
        description = "Kod review ve standart denetimi"
        skill = ".clinerules"
        triggers = @("review", "gözden geçir", "denetle", "kalite kontrol",
                     "standart", "code review", "incele")
    }
    "qa-specialist" = @{
        name = "🧪 QA Specialist"
        description = "Test ve kalite güvence"
        skill = "skills/debug-workflow.md"
        triggers = @("test et", "kalite kontrol", "regression",
                     "performans testi", "doğrula", "validate")
    }
    "scene-designer" = @{
        name = "🏗️ Sahne Tasarımcısı"
        description = ".tscn sahne ve UI tasarımı"
        skill = "skills/ui-auto-layout.md"
        triggers = @("sahne tasarla", "ui tasarla", "scene", "tscn",
                     "layout", "container", "tema", "overlay")
    }
    "gdscript-wizard" = @{
        name = "📜 GDScript Sihirbazı"
        description = "Kod refactoring ve modernizasyon"
        skill = "skills/refactor-gdscript.md"
        triggers = @("refactor", "yeniden düzenle", "dönüştür",
                     "optimize et", "temizle", "modernize", "Godot 3")
    }
    "story-writer" = @{
        name = "✍️ Hikaye Yazarı"
        description = "Hikaye, diyalog ve karar mekanikleri"
        skill = "skills/dialogue-sequence.md"
        triggers = @("hikaye", "diyalog", "senaryo", "story",
                     "bölüm", "karar mekaniği", "event", "questions.gd")
    }
    "art-director" = @{
        name = "🎨 Sanat Yönetmeni"
        description = "Görsel asset ve tasarım yönetimi"
        skill = "skills/art-asset.md"
        triggers = @("asset", "görsel", "svg", "png", "renk paleti",
                     "portre", "diorama", "shader", "artwork")
    }
    "build-master" = @{
        name = "🚀 Build Master"
        description = "Android build ve dağıtım"
        skill = "skills/android-build.md"
        triggers = @("build", "derle", "apk", "aab", "android",
                     "export", "dağıt", "imzala", "keystore")
    }
}

function Show-RoleInfo {
    param($roleData, $roleKey)
    
    Write-Host ""
    Write-Host "$($roleData.name) ($roleKey)" -ForegroundColor Cyan
    Write-Host "  Açıklama: $($roleData.description)" -ForegroundColor White
    Write-Host "  Skill: $($roleData.skill)" -ForegroundColor Yellow
    if ($roleData.is_default) {
        Write-Host "  (VARSAYILAN ROL)" -ForegroundColor Green
    }
    Write-Host "  Tetikleyiciler:" -ForegroundColor Gray
    foreach ($trigger in $roleData.triggers) {
        Write-Host "    - $trigger" -ForegroundColor DarkGray
    }
}

function Find-MatchingRole {
    param([string]$Text)
    
    $lowerText = $Text.ToLowerInvariant()
    $results = @()
    
    # Açık rol etiketi kontrolü
    foreach ($key in $roles.Keys) {
        $role = $roles[$key]
        $nameLower = $role.name.ToLowerInvariant()
        if ($lowerText.Contains($nameLower)) {
            $results += @{ role = $key; match = "Açık etiket: $($role.name)"; score = 100 }
        }
    }
    
    # Anahtar kelime kontrolü
    foreach ($key in $roles.Keys) {
        $role = $roles[$key]
        foreach ($trigger in $role.triggers) {
            if ($lowerText.Contains($trigger.ToLowerInvariant())) {
                $score = if ($role.is_default) { 50 } else { 80 }
                $results += @{ role = $key; match = "Anahtar kelime: '$trigger'"; score = $score }
            }
        }
    }
    
    if ($results.Count -eq 0) {
        # Varsayılan rol
        $results += @{ role = "developer"; match = "Varsayılan rol (eşleşme yok)"; score = 10 }
    }
    
    # En yüksek skoru al
    $best = $results | Sort-Object score -Descending | Select-Object -First 1
    return $best
}

# --- Ana Mantık ---

if ($List) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   MMAE AGENT ROLLERİ                     ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    
    foreach ($key in $roles.Keys | Sort-Object) {
        Show-RoleInfo -roleData $roles[$key] -roleKey $key
    }
    
    Write-Host ""
    Write-Host "Kullanım: .\activate_role.ps1 -Role architect" -ForegroundColor Green
    Write-Host "         .\activate_role.ps1 -Analyze ""Dialogue açılmıyor""" -ForegroundColor Green
    
} elseif ($Analyze -ne "") {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   METİN ANALİZİ                          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Analiz edilen metin: '$Analyze'" -ForegroundColor White
    
    $result = Find-MatchingRole -Text $Analyze
    $matchedRole = $roles[$result.role]
    
    Write-Host ""
    Write-Host "✅ Eşleşen Rol: $($matchedRole.name)" -ForegroundColor Green
    Write-Host "   Sebep: $($result.match)" -ForegroundColor Yellow
    Write-Host "   Skill: $($matchedRole.skill)" -ForegroundColor Cyan
    
    # Skill dosyasının varlığını kontrol et
    if ($matchedRole.skill -and $matchedRole.skill -ne ".clinerules") {
        $skillPath = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath $matchedRole.skill
        if (Test-Path $skillPath) {
            Write-Host "   ✅ Skill dosyası mevcut: $skillPath" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Skill dosyası BULUNAMADI: $skillPath" -ForegroundColor Red
        }
    }

} elseif ($Role -ne "") {
    $roleKey = $Role.ToLowerInvariant()
    
    if ($roles.ContainsKey($roleKey)) {
        $selected = $roles[$roleKey]
        
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║   ROL AKTİFLEŞTİRİLDİ                    ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
        
        Show-RoleInfo -roleData $selected -roleKey $roleKey
        
        Write-Host ""
        Write-Host "Aktif Rol: $($selected.name)" -ForegroundColor Green
        Write-Host "Kullanılacak Skill: $($selected.skill)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "İpucu: Bu rolle ilgili bir görev vermek için" -ForegroundColor Gray
        Write-Host "aşağıdaki gibi bir tetikleyici kullanabilirsiniz:" -ForegroundColor Gray
        Write-Host "  → $($selected.triggers[0])" -ForegroundColor DarkGray
    } else {
        Write-Host ""
        Write-Host "❌ HATA: '$Role' geçerli bir rol değil!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Geçerli roller:" -ForegroundColor Yellow
        foreach ($key in $roles.Keys | Sort-Object) {
            Write-Host "  - $key ($($roles[$key].name))" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "Kullanım: .\activate_role.ps1 -Role architect" -ForegroundColor Green
    }

} else {
    # Hiçbir parametre verilmediyse yardım göster
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   MMAE AGENT ROL AKTİVASYON              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Kullanım:" -ForegroundColor White
    Write-Host "  .\activate_role.ps1 -Role <rol_adı>" -ForegroundColor Yellow
    Write-Host "  .\activate_role.ps1 -List" -ForegroundColor Yellow
    Write-Host "  .\activate_role.ps1 -Analyze ""<metin>""" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Örnekler:" -ForegroundColor White
    Write-Host "  .\activate_role.ps1 -Role architect" -ForegroundColor Gray
    Write-Host "  .\activate_role.ps1 -List" -ForegroundColor Gray
    Write-Host "  .\activate_role.ps1 -Analyze ""Dialogue panelinde hata var""" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Roller:" -ForegroundColor White
    foreach ($key in $roles.Keys | Sort-Object) {
        $role = $roles[$key]
        $default = if ($role.is_default) { " (VARSAYILAN)" } else { "" }
        Write-Host "  $($role.name) -> $key$default" -ForegroundColor Cyan
    }
}
