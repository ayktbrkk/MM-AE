param(
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[string]$AdbExe,
	[string]$DeviceSerial,
	[string]$ApkPath
)

$ErrorActionPreference = "Stop"

function Resolve-AdbExe {
	param([string]$RequestedPath)

	if (-not [string]::IsNullOrWhiteSpace($RequestedPath)) {
		if (-not (Test-Path -LiteralPath $RequestedPath)) {
			throw "ADB bulunamadi: $RequestedPath"
		}
		return (Resolve-Path -LiteralPath $RequestedPath).Path
	}

	$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
	if ($adbCommand) {
		return $adbCommand.Source
	}

	$defaultAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
	if (Test-Path -LiteralPath $defaultAdb) {
		return $defaultAdb
	}

	return $null
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

function Get-AdbDeviceLines {
	param(
		[string]$ResolvedAdb,
		[string]$RequestedSerial
	)

	$deviceOutput = & $ResolvedAdb devices
	$deviceLines = @($deviceOutput | Where-Object {
		$_ -match "\S+\s+device$" -and $_ -notmatch "^List of devices attached"
	})

	if ([string]::IsNullOrWhiteSpace($RequestedSerial)) {
		return $deviceLines
	}

	return @($deviceLines | Where-Object { $_ -match "^$([regex]::Escape($RequestedSerial))\s+device$" })
}

$checklistPath = Join-Path $ProjectPath "docs\ANDROID_RELEASE_CHECKLIST.md"

Push-Location $ProjectPath
try {
	$resolvedAdb = Resolve-AdbExe -RequestedPath $AdbExe
	if ([string]::IsNullOrWhiteSpace($resolvedAdb)) {
		Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_FINAL_SMOKE_STATUS" -Value "SKIPPED_NO_DEVICE"
		Write-Host "P12_RELEASE_SMOKE_SKIPPED_NO_DEVICE"
		return
	}

	$deviceLines = Get-AdbDeviceLines -ResolvedAdb $resolvedAdb -RequestedSerial $DeviceSerial
	if ($deviceLines.Count -eq 0) {
		Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_FINAL_SMOKE_STATUS" -Value "SKIPPED_NO_DEVICE"
		Write-Host "P12_RELEASE_SMOKE_SKIPPED_NO_DEVICE"
		return
	}

	if ($deviceLines.Count -gt 1 -and [string]::IsNullOrWhiteSpace($DeviceSerial)) {
		throw "Birden fazla cihaz bagli. -DeviceSerial verin."
	}

	if ([string]::IsNullOrWhiteSpace($DeviceSerial)) {
		$DeviceSerial = ($deviceLines[0] -split "\s+")[0]
	}

	if ([string]::IsNullOrWhiteSpace($ApkPath)) {
		$latestApk = Get-ChildItem -LiteralPath (Join-Path $ProjectPath "builds") -Filter "BandirmaYolculugu_release_*.apk" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
		if ($null -eq $latestApk) {
			throw "Release APK bulunamadi."
		}
		$ApkPath = $latestApk.FullName
	}

	$adbPrefix = if ([string]::IsNullOrWhiteSpace($DeviceSerial)) { @() } else { @("-s", $DeviceSerial) }
	$deviceModel = (& $resolvedAdb @($adbPrefix + @("shell", "getprop", "ro.product.model"))) -join ""
	$deviceAndroid = (& $resolvedAdb @($adbPrefix + @("shell", "getprop", "ro.build.version.release"))) -join ""

	& $resolvedAdb @($adbPrefix + @("install", "-r", $ApkPath))
	if ($LASTEXITCODE -ne 0) {
		throw "Release APK install failed."
	}

	& $resolvedAdb @($adbPrefix + @("shell", "monkey", "-p", "com.mmae.bandirmayolculugu", "-c", "android.intent.category.LAUNCHER", "1"))
	if ($LASTEXITCODE -ne 0) {
		throw "Release APK launch failed."
	}

	Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_FINAL_APK_PATH" -Value $ApkPath
	Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_RELEASE_DEVICE" -Value (("{0} / Android {1}" -f $deviceModel.Trim(), $deviceAndroid.Trim()))
	Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_FINAL_SMOKE_STATUS" -Value "READY_FOR_MANUAL_CHECK"
	Update-ChecklistMarker -ChecklistPath $checklistPath -Marker "P12_RELEASE_NOTES" -Value "APK kuruldu ve acildi; manuel checklist sonucu bekleniyor"

	Write-Host "P12_RELEASE_SMOKE_READY"
}
finally {
	Pop-Location
}