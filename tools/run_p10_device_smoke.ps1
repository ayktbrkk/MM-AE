param(
	[string]$GodotExe = $env:GODOT_EXE,
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[string]$AdbExe,
	[string]$ApkPath = "builds/BandirmaYolculugu_debug.apk",
	[string]$PackageName = "com.mmae.bandirmayolculugu",
	[string]$DeviceSerial,
	[switch]$SkipGate,
	[switch]$SkipInstall
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

function Get-AdbInvocationPrefix {
	param([string]$RequestedSerial)

	if ([string]::IsNullOrWhiteSpace($RequestedSerial)) {
		return @()
	}

	return @("-s", $RequestedSerial)
}

$gateScript = Join-Path $PSScriptRoot "run_p10_smoke_gate.ps1"
$resolvedAdb = Resolve-AdbExe -RequestedPath $AdbExe

Push-Location $ProjectPath
try {
	if (-not $SkipGate) {
		Write-Host "[P10] Running automated preflight gate..."
		if ([string]::IsNullOrWhiteSpace($GodotExe)) {
			& $gateScript
		}
		else {
			& $gateScript -GodotExe $GodotExe
		}
		if ($LASTEXITCODE -ne 0) {
			throw "P10 automated preflight gate failed."
		}
	}

	if ([string]::IsNullOrWhiteSpace($resolvedAdb)) {
		Write-Host "DEVICE_SMOKE_SKIPPED_NO_ADB"
		return
	}

	$deviceLines = Get-AdbDeviceLines -ResolvedAdb $resolvedAdb -RequestedSerial $DeviceSerial
	if ($deviceLines.Count -eq 0) {
		Write-Host "DEVICE_SMOKE_SKIPPED_NO_DEVICE"
		Write-Host "Connect a device or boot an emulator, then rerun tools/run_p10_device_smoke.ps1."
		return
	}

	if ($deviceLines.Count -gt 1 -and [string]::IsNullOrWhiteSpace($DeviceSerial)) {
		throw "Birden fazla cihaz bagli. -DeviceSerial verin."
	}

	if ([string]::IsNullOrWhiteSpace($DeviceSerial)) {
		$DeviceSerial = ($deviceLines[0] -split "\s+")[0]
	}

	$adbPrefix = Get-AdbInvocationPrefix -RequestedSerial $DeviceSerial
	$resolvedApk = if ([System.IO.Path]::IsPathRooted($ApkPath)) {
		$ApkPath
	}
	else {
		Join-Path $ProjectPath $ApkPath
	}

	if (-not $SkipInstall -and -not (Test-Path -LiteralPath $resolvedApk)) {
		throw "APK bulunamadi: $resolvedApk"
	}

	$deviceModel = (& $resolvedAdb @($adbPrefix + @("shell", "getprop", "ro.product.model"))) -join ""
	$deviceAndroid = (& $resolvedAdb @($adbPrefix + @("shell", "getprop", "ro.build.version.release"))) -join ""

	Write-Host ("P10_DEVICE_SERIAL={0}" -f $DeviceSerial)
	Write-Host ("P10_DEVICE_MODEL={0}" -f $deviceModel.Trim())
	Write-Host ("P10_DEVICE_ANDROID={0}" -f $deviceAndroid.Trim())

	if (-not $SkipInstall) {
		Write-Host ("[P10] Installing APK: {0}" -f $resolvedApk)
		& $resolvedAdb @($adbPrefix + @("install", "-r", $resolvedApk))
		if ($LASTEXITCODE -ne 0) {
			throw "APK install failed."
		}
	}

	Write-Host ("[P10] Launching package: {0}" -f $PackageName)
		& $resolvedAdb @($adbPrefix + @("shell", "monkey", "-p", $PackageName, "-c", "android.intent.category.LAUNCHER", "1"))
	if ($LASTEXITCODE -ne 0) {
		throw "App launch failed."
	}

	Write-Host "P10_DEVICE_SMOKE_READY"
	Write-Host "Run order: A12.1 -> A12.2 -> A12.3 -> A16.1 -> A16.2 -> A16.3 -> A15 -> A16.4"
	Write-Host "Record model, Android version, and observed regressions in docs/ANDROID_RELEASE_CHECKLIST.md."
}
finally {
	Pop-Location
}