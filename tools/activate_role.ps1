#Requires -Version 5.1
<#
.SYNOPSIS
    MMAE Projesi icin Agent Rolu Aktivasyon Scripti
.DESCRIPTION
    Bu script otomatik rol algilama ve aktivasyonu saglar.
    
    Kullanim: .\activate_role.ps1 -Role architect
    Kullanim: .\activate_role.ps1 -List
.PARAMETER Role
    Aktiflestirilecek rol (architect, debug, developer, tech-lead, qa-specialist, scene-designer, gdscript-wizard, story-writer, art-director, build-master)
.PARAMETER List
    Tum rolleri listeler
.PARAMETER Analyze
    Verilen metni analiz eder ve hangi rolun eslestigini gosterir
.EXAMPLE
    .\activate_role.ps1 -Role architect
    .\activate_role.ps1 -Analyze "Dialogue acilmiyor"
#>

param(
    [string]$Role = "",
    [switch]$List,
    [string]$Analyze = ""
)

# Rol tanimlari
$roles = @{
    architect = @{ name="[Plan] Architect"; desc="Sistem tasarimi ve planlama"; skill="skills/architect-workflow.md"; triggers=@("planla","tasarim","mimari","node tree","sistem tasarimi","akis semasi","signal akisi","gereksinim analizi","proje plani") }
    debug = @{ name="[Debug] Debug"; desc="Sistematik hata ayiklama"; skill="skills/debug-workflow.md"; triggers=@("hata","calismiyor","debug","bug","broken","duzelt","sorun","problem","exception","crash","donma") }
    developer = @{ name="[Kod] Developer"; desc="Test-first GDScript gelistirme (VARSAYILAN)"; skill="skills/implement.md"; triggers=@("yaz","kod","implement et","ekle","olustur","gelistir","yap","function","script"); is_default=$true }
    "tech-lead" = @{ name="[Review] Tech Lead"; desc="Kod review ve standart denetimi"; skill=".clinerules"; triggers=@("review","gozden gecir","denetle","kalite kontrol","standart","code review","incele") }
    "qa-specialist" = @{ name="[Test] QA Specialist"; desc="Test ve kalite guvence"; skill="skills/debug-workflow.md"; triggers=@("test et","kalite kontrol","regression","performans testi","dogrula","validate") }
    "scene-designer" = @{ name="[UI] Sahne Tasarimcisi"; desc=".tscn sahne ve UI tasarimi"; skill="skills/ui-auto-layout.md"; triggers=@("sahne tasarla","ui tasarla","scene","tscn","layout","container","tema","overlay") }
    "gdscript-wizard" = @{ name="[Refactor] GDScript Sihirbazi"; desc="Kod refactoring ve modernizasyon"; skill="skills/refactor-gdscript.md"; triggers=@("refactor","yeniden duzenle","donustur","optimize et","temizle","modernize","Godot 3") }
    "story-writer" = @{ name="[Story] Hikaye Yazar"; desc="Hikaye, diyalog ve karar mekanikleri"; skill="skills/dialogue-sequence.md"; triggers=@("hikaye","diyalog","senaryo","story","bolum","karar mekanigi","event","questions.gd") }
    "art-director" = @{ name="[Art] Sanat Yonetmeni"; desc="Gorsel asset ve tasarim yonetimi"; skill="skills/art-asset.md"; triggers=@("asset","gorsel","svg","png","renk paleti","portre","diorama","shader","artwork") }
    "build-master" = @{ name="[Build] Build Master"; desc="Android build ve dagitim"; skill="skills/android-build.md"; triggers=@("build","derle","apk","aab","android","export","dagit","imzala","keystore") }
}

function Show-RoleInfo {
    param($r, $k)
    Write-Host ""
    Write-Host "$($r.name) ($k)" -ForegroundColor Cyan
    Write-Host "  Aciklama: $($r.desc)" -ForegroundColor White
    Write-Host "  Skill: $($r.skill)" -ForegroundColor Yellow
    if ($r.is_default) { Write-Host "  (VARSAYILAN ROL)" -ForegroundColor Green }
    Write-Host "  Tetikleyiciler:" -ForegroundColor Gray
    foreach ($t in $r.triggers) { Write-Host "    - $t" -ForegroundColor DarkGray }
}

function Find-MatchingRole {
    param([string]$Text)
    $lowerText = $Text.ToLowerInvariant()
    $results = @()
    foreach ($key in $roles.Keys) {
        $r = $roles[$key]
        $nl = $r.name.ToLowerInvariant()
        if ($lowerText.Contains($nl)) { $results += @{ role=$key; match="Acik etiket: $($r.name)"; score=100 } }
    }
    foreach ($key in $roles.Keys) {
        $r = $roles[$key]
        foreach ($trigger in $r.triggers) {
            if ($lowerText.Contains($trigger.ToLowerInvariant())) {
                $score = if ($r.is_default) { 50 } else { 80 }
                $results += @{ role=$key; match="Anahtar kelime: '$trigger'"; score=$score }
            }
        }
    }
    if ($results.Count -eq 0) { $results += @{ role="developer"; match="Varsayilan rol (eslesme yok)"; score=10 } }
    return ($results | Sort-Object score -Descending | Select-Object -First 1)
}

# --- Ana Mantik ---

if ($List) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   MMAE AGENT ROLLERI" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    foreach ($key in ($roles.Keys | Sort-Object)) { Show-RoleInfo -r $roles[$key] -k $key }
    Write-Host ""
    Write-Host "Kullanim: .\activate_role.ps1 -Role architect" -ForegroundColor Green
    
} elseif ($Analyze -ne "") {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   METIN ANALIZI" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Analiz: '$Analyze'" -ForegroundColor White
    
    $result = Find-MatchingRole -Text $Analyze
    $matched = $roles[$result.role]
    
    Write-Host ""
    Write-Host "[ESLESTI] Rol: $($matched.name)" -ForegroundColor Green
    Write-Host "   Sebep: $($result.match)" -ForegroundColor Yellow
    Write-Host "   Skill: $($matched.skill)" -ForegroundColor Cyan
    
    if ($matched.skill -and $matched.skill -ne ".clinerules") {
        $sp = Join-Path (Split-Path -Parent $PSScriptRoot) $matched.skill
        if (Test-Path $sp) { Write-Host "   [OK] Skill dosyasi mevcut: $sp" -ForegroundColor Green }
        else { Write-Host "   [HATA] Skill dosyasi BULUNAMADI: $sp" -ForegroundColor Red }
    }

} elseif ($Role -ne "") {
    $rk = $Role.ToLowerInvariant()
    
    if ($roles.ContainsKey($rk)) {
        $sel = $roles[$rk]
        
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "   ROL AKTIFLESTIRILDI" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        
        Show-RoleInfo -r $sel -k $rk
        
        Write-Host ""
        Write-Host "Aktif Rol: $($sel.name)" -ForegroundColor Green
        Write-Host "Kullanilacak Skill: $($sel.skill)" -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "[HATA] '$Role' gecerli bir rol degil!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Gecerli roller:" -ForegroundColor Yellow
        foreach ($key in ($roles.Keys | Sort-Object)) { Write-Host "  - $key ($($roles[$key].name))" -ForegroundColor White }
        Write-Host ""
        Write-Host "Kullanim: .\activate_role.ps1 -Role architect" -ForegroundColor Green
    }

} else {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host "   MMAE AGENT ROL AKTIVASYON" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Kullanim:" -ForegroundColor White
    Write-Host "  .\activate_role.ps1 -Role [rol_adi]" -ForegroundColor Yellow
    Write-Host "  .\activate_role.ps1 -List" -ForegroundColor Yellow
    Write-Host "  .\activate_role.ps1 -Analyze [metin]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ornekler:" -ForegroundColor White
    Write-Host "  .\activate_role.ps1 -Role architect" -ForegroundColor Gray
    Write-Host "  .\activate_role.ps1 -List" -ForegroundColor Gray
    Write-Host "  .\activate_role.ps1 -Analyze `"Dialogue panelinde hata var`"" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Roller:" -ForegroundColor White
    foreach ($key in ($roles.Keys | Sort-Object)) {
        $r = $roles[$key]
        $d = if ($r.is_default) { " (VARSAYILAN)" } else { "" }
        Write-Host "  $($r.name) -> $key$d" -ForegroundColor Cyan
    }
}
