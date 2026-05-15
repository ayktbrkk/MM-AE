param(
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[switch]$SkipP10Gate,
	[string]$OutputPath
)

$ErrorActionPreference = "Stop"

function Add-CheckResult {
	param(
		[string]$Name,
		[string]$Status,
		[string]$Detail
	)

	$script:checkResults += [PSCustomObject]@{
		Name = $Name
		Status = $Status
		Detail = $Detail
	}
}

function Get-QuotedValue {
	param(
		[string]$Text,
		[string]$Pattern
	)

	$match = [regex]::Match($Text, $Pattern)
	if ($match.Success) {
		return $match.Groups[1].Value
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

$script:checkResults = @()

Push-Location $ProjectPath
try {
	$logDir = Join-Path $ProjectPath "artifacts\logs"
	if (-not (Test-Path -LiteralPath $logDir)) {
		New-Item -ItemType Directory -Path $logDir -Force | Out-Null
	}

	if ([string]::IsNullOrWhiteSpace($OutputPath)) {
		$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
		$OutputPath = Join-Path $logDir ("p12_release_preflight_{0}.md" -f $timestamp)
	}

	if (-not $SkipP10Gate) {
		& (Join-Path $PSScriptRoot "run_p10_smoke_gate.ps1") -SkipAdbDeviceSmoke
		if ($LASTEXITCODE -eq 0) {
			Add-CheckResult -Name "P10 automated gate" -Status "PASS" -Detail "run_p10_smoke_gate.ps1 -SkipAdbDeviceSmoke"
		}
		else {
			Add-CheckResult -Name "P10 automated gate" -Status "FAIL" -Detail "P10 gate failed"
		}
	}
	else {
		Add-CheckResult -Name "P10 automated gate" -Status "SKIP" -Detail "SkipP10Gate ile atlandi"
	}

	$apkPath = Join-Path $ProjectPath "builds\BandirmaYolculugu_debug.apk"
	if (Test-Path -LiteralPath $apkPath) {
		Add-CheckResult -Name "Debug APK presence" -Status "PASS" -Detail $apkPath
	}
	else {
		Add-CheckResult -Name "Debug APK presence" -Status "FAIL" -Detail "builds/BandirmaYolculugu_debug.apk bulunamadi"
	}

	$exportPresetPath = Join-Path $ProjectPath "export_presets.cfg"
	$projectConfigPath = Join-Path $ProjectPath "project.godot"
	$checklistPath = Join-Path $ProjectPath "docs\ANDROID_RELEASE_CHECKLIST.md"
	$auditPath = Join-Path $ProjectPath "docs\ANDROID_EXPORT_AUDIT.md"
	$releaseSigningConfigPath = Join-Path $ProjectPath "artifacts\local\release_signing\release_signing.local.json"
	$exportText = Get-Content -LiteralPath $exportPresetPath -Raw
	$projectText = Get-Content -LiteralPath $projectConfigPath -Raw
	$checklistText = Get-Content -LiteralPath $checklistPath -Raw
	if (Test-Path -LiteralPath $releaseSigningConfigPath) {
		$localSigningConfig = Get-Content -LiteralPath $releaseSigningConfigPath -Raw | ConvertFrom-Json -AsHashtable
		$exportText = Apply-ReleaseSigningConfig -Text $exportText -Config $localSigningConfig
	}
	$projectVersion = Get-QuotedValue -Text $projectText -Pattern 'config/version="([^"]*)"'
	$packageName = Get-QuotedValue -Text $exportText -Pattern 'packages/unique_name="([^"]*)"'
	$versionName = Get-QuotedValue -Text $exportText -Pattern 'version/name="([^"]*)"'
	$versionCode = Get-QuotedValue -Text $exportText -Pattern 'version/code=([^\r\n]+)'
	$releaseKeystore = Get-QuotedValue -Text $exportText -Pattern 'keystore/release="([^"]*)"'
	$releaseUser = Get-QuotedValue -Text $exportText -Pattern 'keystore/release_user="([^"]*)"'
	$x64Enabled = Get-QuotedValue -Text $exportText -Pattern 'architectures/x86_64=([^\r\n]+)'
	$releaseBuildStatus = Get-QuotedValue -Text $checklistText -Pattern 'P12_RELEASE_BUILD_STATUS=([^\r\n]+)'
	$finalApkPathNote = Get-QuotedValue -Text $checklistText -Pattern 'P12_FINAL_APK_PATH=([^\r\n]+)'
	$finalSmokeStatus = Get-QuotedValue -Text $checklistText -Pattern 'P12_FINAL_SMOKE_STATUS=([^\r\n]+)'

	if (-not [string]::IsNullOrWhiteSpace($packageName) -and -not [string]::IsNullOrWhiteSpace($versionName) -and -not [string]::IsNullOrWhiteSpace($versionCode)) {
		Add-CheckResult -Name "Package metadata" -Status "PASS" -Detail ("{0} / {1} ({2})" -f $packageName, $versionName, $versionCode.Trim())
	}
	else {
		Add-CheckResult -Name "Package metadata" -Status "FAIL" -Detail "Package name or version metadata eksik"
	}

	if (-not [string]::IsNullOrWhiteSpace($releaseKeystore) -and -not [string]::IsNullOrWhiteSpace($releaseUser)) {
		Add-CheckResult -Name "Release signing" -Status "PASS" -Detail "release keystore ve user tanimli"
	}
	else {
		Add-CheckResult -Name "Release signing" -Status "FAIL" -Detail "export_presets.cfg icinde release signing tanimli degil"
	}

	if (-not [string]::IsNullOrWhiteSpace($projectVersion) -and -not [string]::IsNullOrWhiteSpace($versionName) -and $projectVersion -eq $versionName) {
		Add-CheckResult -Name "Version sync" -Status "PASS" -Detail ("project.godot ve export_presets.cfg = {0}" -f $projectVersion)
	}
	else {
		Add-CheckResult -Name "Version sync" -Status "FAIL" -Detail ("project.godot={0}, export_presets.cfg={1}" -f $projectVersion, $versionName)
	}

	if ($x64Enabled.Trim().ToLowerInvariant() -eq "true") {
		Add-CheckResult -Name "x86_64 architecture decision" -Status "WARN" -Detail "x86_64 aktif; release icin tasinip tasinmayacagi audit notuyla kilitlenmeli"
	}
	else {
		Add-CheckResult -Name "x86_64 architecture decision" -Status "PASS" -Detail "x86_64 release disina alinmis"
	}

	if ((Test-Path -LiteralPath $checklistPath) -and (Test-Path -LiteralPath $auditPath)) {
		Add-CheckResult -Name "Release docs presence" -Status "PASS" -Detail "Checklist ve export audit mevcut"
	}
	else {
		Add-CheckResult -Name "Release docs presence" -Status "FAIL" -Detail "Checklist veya export audit eksik"
	}

	if ($releaseBuildStatus -eq "BUILD_RELEASE_OK" -and -not [string]::IsNullOrWhiteSpace($finalApkPathNote) -and $finalApkPathNote -ne "TODO" -and $finalSmokeStatus -eq "PASS") {
		Add-CheckResult -Name "Final APK smoke evidence" -Status "PASS" -Detail $finalApkPathNote
	}
	else {
		Add-CheckResult -Name "Final APK smoke evidence" -Status "FAIL" -Detail "Checklist icinde P12 release build/smoke alanlari henuz tamamlanmamis"
	}

	$p11Reports = @(Get-ChildItem -LiteralPath $logDir -Filter "p11_device_observation_*.md" -ErrorAction SilentlyContinue)
	if ($p11Reports.Count -gt 0) {
		$p11Latest = $p11Reports | Sort-Object LastWriteTime -Descending | Select-Object -First 1
		Add-CheckResult -Name "P11 observation evidence" -Status "PASS" -Detail $p11Latest.FullName
	}
	else {
		Add-CheckResult -Name "P11 observation evidence" -Status "FAIL" -Detail "artifacts/logs altinda p11_device_observation_*.md bulunamadi"
	}

	$hasBlockingFailure = $false
	foreach ($result in $script:checkResults) {
		if ($result.Status -eq "FAIL") {
			$hasBlockingFailure = $true
			break
		}
	}

	$reportLines = @(
		"# P12 Release Preflight",
		"",
		"**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
		"**Result:** $(if ($hasBlockingFailure) { 'BLOCKED' } else { 'PASS' })",
		"",
		"| Check | Status | Detail |",
		"|-------|--------|--------|"
	)
	foreach ($result in $script:checkResults) {
		$reportLines += ("| {0} | {1} | {2} |" -f $result.Name, $result.Status, $result.Detail)
	}
	$reportLines += @(
		"",
		"## Blocking Notes",
		"",
		"- Release signing tanimi yoksa P12 release-ready sayilmaz.",
		"- project.godot ve export_presets.cfg version alanlari ayni release numarasina cekilmelidir.",
		"- P11 cihaz gozlem raporu yoksa performans riski yazili degildir.",
		"- Device smoke ve final APK smoke notlari checklist'e islenmeden release kapisi kapanmis sayilmaz.",
		"",
		"*Generated by tools/run_p12_release_preflight.ps1*"
	)

	$reportLines -join "`r`n" | Out-File -FilePath $OutputPath -Encoding utf8
	Write-Host ("P12_RELEASE_PREFLIGHT_REPORT {0}" -f $OutputPath)

	if ($hasBlockingFailure) {
		Write-Host "P12_RELEASE_PREFLIGHT_BLOCKED"
		exit 1
	}

	Write-Host "P12_RELEASE_PREFLIGHT_OK"
}
finally {
	Pop-Location
}