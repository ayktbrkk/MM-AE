<#
.SYNOPSIS
    Geçici doğrulama log'larını temizler.
.DESCRIPTION
    Root dizindeki check_*, final_check_*, godot_*, *_output.txt dosyalarını
    ve artifacts/logs/ altındaki geçici log'ları siler.
.PARAMETER DryRun
    Silme işlemini gerçekten yapmadan hangi dosyaların silineceğini gösterir.
.EXAMPLE
    .\tools\clean_temp_logs.ps1 -DryRun
    Hangi dosyaların silineceğini önizle.

    .\tools\clean_temp_logs.ps1
    Tüm geçici log'ları sil.
#>

param(
    [switch]$DryRun
)

$rootDir = "."
$logDir = "artifacts/logs"

Write-Host "=== Geçici Log Temizleyici ===" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "[DRY-RUN MODE] Hiçbir dosya silinmeyecek." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "--- Root Dizini ---" -ForegroundColor Cyan

# Root-level patterns
$rootPatterns = @(
    "check_*.txt",
    "check_*.txt.*",
    "final_check_*.txt",
    "godot_*.txt",
    "*_output.txt",
    "extension_api.json"
)

$totalDeleted = 0

foreach ($pattern in $rootPatterns) {
    $files = Get-ChildItem -Path $rootDir -Filter $pattern -File -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        if ($DryRun) {
            Write-Host "[DRY-RUN] Would delete: $($f.Name)" -ForegroundColor DarkYellow
        } else {
            try {
                Remove-Item $f.FullName -Force -ErrorAction Stop
                Write-Host "Deleted: $($f.Name)" -ForegroundColor Green
                $totalDeleted++
            } catch {
                Write-Host "FAILED: $($f.Name) — $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host ""
Write-Host "--- artifacts/logs/ ---" -ForegroundColor Cyan

# Artifacts patterns (temporary, not accepted/)
$artifactPatterns = @(
    "*.json",
    "*.csv"
)

if (Test-Path $logDir) {
    foreach ($pattern in $artifactPatterns) {
        $files = Get-ChildItem -Path $logDir -Filter $pattern -File -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            if ($DryRun) {
                Write-Host "[DRY-RUN] Would delete: artifacts/logs/$($f.Name)" -ForegroundColor DarkYellow
            } else {
                try {
                    Remove-Item $f.FullName -Force -ErrorAction Stop
                    Write-Host "Deleted: artifacts/logs/$($f.Name)" -ForegroundColor Green
                    $totalDeleted++
                } catch {
                    Write-Host "FAILED: artifacts/logs/$($f.Name) — $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
} else {
    Write-Host "artifacts/logs/ dizini bulunamadı." -ForegroundColor DarkGray
}

Write-Host ""
if ($DryRun) {
    Write-Host "[DRY-RUN] Tamamlandı. Gerçek silme için -DryRun olmadan çalıştırın." -ForegroundColor Yellow
} else {
    Write-Host "Temizlik tamamlandı. $totalDeleted dosya silindi." -ForegroundColor Green
}
