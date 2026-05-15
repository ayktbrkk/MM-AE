param(
	[string]$GodotExe = $env:GODOT_EXE,
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[string]$OutputPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")) "builds"),
	[switch]$NoTimestamp
)

<#
.SYNOPSIS
	Android Debug APK build wrapper.
.DESCRIPTION
	Godot engine CLI uzerinden Android debug APK export eder.
	Keystore bilgisi icermez — sadece Godot export komutunu sarmalar.
.PARAMETER GodotExe
	Godot executable yolu. GODOT_EXE env var veya varsayilan yol kullanilir.
.PARAMETER ProjectPath
	Proje kok dizini. Varsayilan: scriptin iki ust dizini.
.PARAMETER OutputPath
	APK cikti dizini. Varsayilan: proje/builds/
.PARAMETER NoTimestamp
	Flag verilirse dosya adina timestamp eklenmez.
.EXAMPLE
	.\tools\build_android_debug.ps1
.EXAMPLE
	.\tools\build_android_debug.ps1 -GodotExe "C:\Godot\Godot_v4.6.2-stable_win64_console.exe"
#>

$ErrorActionPreference = "Stop"

# ── Godot executable ────────────────────────────────────────────────────────
if ([string]::IsNullOrWhiteSpace($GodotExe)) {
	$defaultExe = "C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe"
	if (Test-Path $defaultExe) {
		$GodotExe = $defaultExe
	}
}

if ([string]::IsNullOrWhiteSpace($GodotExe) -or -not (Test-Path $GodotExe)) {
	Write-Host "[BUILD] ERROR: Godot executable bulunamadi."
	Write-Host "[BUILD] GODOT_EXE env variable ayarlayin veya -GodotExe ile belirtin."
	exit 1
}

# ── Output path ─────────────────────────────────────────────────────────────
if (-not (Test-Path $OutputPath)) {
	New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$timestamp = if ($NoTimestamp) { "" } else { (Get-Date -Format "yyyyMMdd_HHmmss") }
$outputFile = if ($timestamp) {
	Join-Path $OutputPath ("BandirmaYolculugu_debug_{0}.apk" -f $timestamp)
} else {
	Join-Path $OutputPath "BandirmaYolculugu_debug.apk"
}

# ── Build ───────────────────────────────────────────────────────────────────
Write-Host ("=" * 60)
Write-Host "BUILD: Android Debug APK"
Write-Host ("=" * 60)
Write-Host "Godot:     $GodotExe"
Write-Host "Project:   $ProjectPath"
Write-Host "Output:    $outputFile"
Write-Host "Preset:    Android (debug)"
Write-Host ""

Push-Location $ProjectPath
try {
	$output = & $GodotExe @("--path", ".", "--export-debug", "Android", $outputFile) 2>&1
	$exitCode = $LASTEXITCODE

	Write-Host $output

	if ($exitCode -eq 0 -and (Test-Path $outputFile)) {
		$fileSize = (Get-Item $outputFile).Length / 1MB
		Write-Host ("`n[BUILD] SUCCESS: Debug APK olusturuldu ({0:F1} MB)" -f $fileSize) -ForegroundColor Green
		Write-Host ("[BUILD] BUILD_DEBUG_OK") -ForegroundColor Green
		exit 0
	} else {
		Write-Host ("`n[BUILD] FAILED: exit code={0}" -f $exitCode) -ForegroundColor Red
		Write-Host ("[BUILD] BUILD_DEBUG_FAILED") -ForegroundColor Red
		exit 1
	}
}
finally {
	Pop-Location
}
