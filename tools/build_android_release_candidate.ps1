param(
	[string]$GodotExe = $env:GODOT_EXE,
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[string]$OutputPath = (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")) "builds"),
	[string]$PresetName = "Android",
	[string]$ReleaseSigningConfig,
	[switch]$NoTimestamp
)

<#
.SYNOPSIS
	Android Release Candidate APK build wrapper.
.DESCRIPTION
	Godot engine CLI uzerinden Android release (imzali) APK export eder.
	KEYSECRET BILGISI ICMEZ — keystore editor uzerinden export_presets.cfg'ye
	tanimlanmis olmalidir. Sadece Godot export komutunu sarmalar.
.PARAMETER GodotExe
	Godot executable yolu. GODOT_EXE env var veya varsayilan yol kullanilir.
.PARAMETER ProjectPath
	Proje kok dizini. Varsayilan: scriptin iki ust dizini.
.PARAMETER OutputPath
	APK cikti dizini. Varsayilan: proje/builds/
.PARAMETER PresetName
	export_presets.cfg icindeki preset adi. Varsayilan: "Android"
.PARAMETER NoTimestamp
	Flag verilirse dosya adina timestamp eklenmez.
.EXAMPLE
	.\tools\build_android_release_candidate.ps1
.EXAMPLE
	.\tools\build_android_release_candidate.ps1 -PresetName "Android Release"
.NOTES
	Release build oncesinde sunlar dogrulanmalidir:
	- export_presets.cfg'de keystore/release alanlari editor'den doldurulmus olmali
	- version/code bir onceki release'den buyuk olmali
	- project.godot config/version ile export_presets.cfg version/name tutarli olmali
#>

$ErrorActionPreference = "Stop"

function Get-QuotedValue {
	param(
		[string]$Text,
		[string]$Pattern
	)

	$match = [regex]::Match($Text, $Pattern)
	if ($match.Success) {
		return $match.Groups[1].Value.Trim()
	}

	return ""
}

function Apply-ReleaseSigningConfig {
	param(
		[string]$Text,
		[hashtable]$Config
	)

	$lines = $Text -split "`r?`n"
	for ($index = 0; $index -lt $lines.Length; $index++) {
		switch -Regex ($lines[$index]) {
			'^keystore/release=' { $lines[$index] = ('keystore/release="{0}"' -f (($Config.keystore_path -replace '\\', '/'))); continue }
			'^keystore/release_user=' { $lines[$index] = ('keystore/release_user="{0}"' -f $Config.keystore_user); continue }
			'^keystore/release_password=' { $lines[$index] = ('keystore/release_password="{0}"' -f $Config.keystore_password); continue }
		}
	}

	return ($lines -join "`r`n")
}

function Update-ChecklistMarker {
	param(
		[string]$ChecklistPath,
		[string]$Marker,
		[string]$Value
	)

	if (-not (Test-Path -LiteralPath $ChecklistPath)) {
		return
	}

	$lines = Get-Content -LiteralPath $ChecklistPath
	$updated = $false
	$bulletPrefix = ('- `' + $Marker + '=')
	$plainPrefix = ($Marker + '=')
	for ($index = 0; $index -lt $lines.Length; $index++) {
		if ($lines[$index].StartsWith($bulletPrefix)) {
			$lines[$index] = ('- `{0}={1}`' -f $Marker, $Value)
			$updated = $true
			break
		}
		if ($lines[$index].StartsWith($plainPrefix)) {
			$lines[$index] = ('{0}={1}' -f $Marker, $Value)
			$updated = $true
			break
		}
	}

	if (-not $updated) {
		$lines += ('{0}={1}' -f $Marker, $Value)
	}

	($lines -join "`r`n") | Out-File -FilePath $ChecklistPath -Encoding utf8
}

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
	Join-Path $OutputPath ("BandirmaYolculugu_release_{0}.apk" -f $timestamp)
} else {
	Join-Path $OutputPath "BandirmaYolculugu_release.apk"
}

# ── Preflight checks ───────────────────────────────────────────────────────
$exportPresetPath = Join-Path $ProjectPath "export_presets.cfg"
$projectConfigPath = Join-Path $ProjectPath "project.godot"
$checklistPath = Join-Path $ProjectPath "docs\ANDROID_RELEASE_CHECKLIST.md"
$exportText = Get-Content -LiteralPath $exportPresetPath -Raw
$projectText = Get-Content -LiteralPath $projectConfigPath -Raw

if ([string]::IsNullOrWhiteSpace($ReleaseSigningConfig)) {
	$ReleaseSigningConfig = Join-Path $ProjectPath "artifacts\local\release_signing\release_signing.local.json"
}

$localSigningConfig = $null
if (Test-Path -LiteralPath $ReleaseSigningConfig) {
	$localSigningConfig = Get-Content -LiteralPath $ReleaseSigningConfig -Raw | ConvertFrom-Json -AsHashtable
	$exportText = Apply-ReleaseSigningConfig -Text $exportText -Config $localSigningConfig
}

$projectVersion = Get-QuotedValue -Text $projectText -Pattern 'config/version="([^"]*)"'
$versionName = Get-QuotedValue -Text $exportText -Pattern 'version/name="([^"]*)"'
$versionCode = Get-QuotedValue -Text $exportText -Pattern 'version/code=([^\r\n]+)'
$packageName = Get-QuotedValue -Text $exportText -Pattern 'packages/unique_name="([^"]*)"'
$releaseKeystore = Get-QuotedValue -Text $exportText -Pattern 'keystore/release="([^"]*)"'
$releaseUser = Get-QuotedValue -Text $exportText -Pattern 'keystore/release_user="([^"]*)"'

$preflightErrors = @()
if ([string]::IsNullOrWhiteSpace($packageName)) {
	$preflightErrors += "Package unique name eksik."
}
if ([string]::IsNullOrWhiteSpace($versionCode)) {
	$preflightErrors += "export_presets.cfg icinde version/code eksik."
}
if ([string]::IsNullOrWhiteSpace($versionName) -or [string]::IsNullOrWhiteSpace($projectVersion)) {
	$preflightErrors += "project.godot veya export_presets.cfg icinde version bilgisi eksik."
}
elseif ($versionName -ne $projectVersion) {
	$preflightErrors += "Version mismatch: project.godot=$projectVersion, export_presets.cfg=$versionName"
}
if ([string]::IsNullOrWhiteSpace($releaseKeystore) -or [string]::IsNullOrWhiteSpace($releaseUser)) {
	$preflightErrors += "Release signing hazir degil: keystore/release ve keystore/release_user yerel olarak tanimlanmali."
}

# ── Build ───────────────────────────────────────────────────────────────────
Write-Host ("=" * 60)
Write-Host "BUILD: Android Release Candidate APK"
Write-Host ("=" * 60)
Write-Host "Godot:     $GodotExe"
Write-Host "Project:   $ProjectPath"
Write-Host "Output:    $outputFile"
Write-Host "Preset:    $PresetName (release)"
Write-Host ""
Write-Host "NOTE: Keystore bilgisi export_presets.cfg uzerinden editor'de"
Write-Host "      tanimli olmalidir. Bu script secret icermez."
Write-Host ""

if ($preflightErrors.Count -gt 0) {
	Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_RELEASE_BUILD_STATUS" -Value "BUILD_RELEASE_BLOCKED"
	Write-Host "[BUILD] RELEASE_PREFLIGHT_BLOCKED" -ForegroundColor Red
	foreach ($error in $preflightErrors) {
		Write-Host ("[BUILD] - {0}" -f $error) -ForegroundColor Red
	}
	exit 1
}

Push-Location $ProjectPath
try {
	$originalExportText = Get-Content -LiteralPath $exportPresetPath -Raw
	if ($localSigningConfig -ne $null) {
		$exportText | Out-File -FilePath $exportPresetPath -Encoding utf8
	}

	$output = & $GodotExe @("--path", ".", "--export-release", $PresetName, $outputFile) 2>&1
	$exitCode = $LASTEXITCODE

	Write-Host $output

	if ($exitCode -eq 0 -and (Test-Path $outputFile)) {
		$fileSize = (Get-Item $outputFile).Length / 1MB
		Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_RELEASE_BUILD_STATUS" -Value "BUILD_RELEASE_OK"
		Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_FINAL_APK_PATH" -Value $outputFile
		Write-Host ("`n[BUILD] SUCCESS: Release APK olusturuldu ({0:F1} MB)" -f $fileSize) -ForegroundColor Green
		Write-Host ("[BUILD] BUILD_RELEASE_OK") -ForegroundColor Green
		exit 0
	} else {
		Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_RELEASE_BUILD_STATUS" -Value "BUILD_RELEASE_FAILED"
		Write-Host ("`n[BUILD] FAILED: exit code={0}" -f $exitCode) -ForegroundColor Red
		Write-Host ("[BUILD] BUILD_RELEASE_FAILED") -ForegroundColor Red
		exit 1
	}
}
finally {
	if ($localSigningConfig -ne $null) {
		$originalExportText | Out-File -FilePath $exportPresetPath -Encoding utf8
	}
	Pop-Location
}
