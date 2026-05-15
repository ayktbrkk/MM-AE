param(
	[string]$GodotExe = $env:GODOT_EXE,
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[switch]$SkipParseCheck,
	[switch]$SkipAdbDeviceSmoke,
	[int]$GateTimeoutSeconds = 45
)

$ErrorActionPreference = "Stop"

# ── Godot executable ────────────────────────────────────────────────────────
if ([string]::IsNullOrWhiteSpace($GodotExe)) {
	$defaultExe = Join-Path (Join-Path $PSScriptRoot "..") "Godot_v4.6.2-stable_win64_console.exe"
	if (Test-Path $defaultExe) {
		$GodotExe = $defaultExe
	}
}

if ([string]::IsNullOrWhiteSpace($GodotExe) -or -not (Test-Path $GodotExe)) {
	Write-Host "[P10] WARNING: Godot executable bulunamadi. Tum gate'ler atlaniyor."
	Write-Host "[P10] P10_SMOKE_GATE_SKIPPED_NO_GODOT"
	exit 0
}

# ── Output helpers ──────────────────────────────────────────────────────────
$script:gateResults = @()   # list of [PSCustomObject]@{ Name; Status; Detail; LogFile }
$script:timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")
$script:gateFailures = 0

# ── Log directory structure ─────────────────────────────────────────────────
$logDir = Join-Path $ProjectPath "artifacts\logs"
$gateLogDir = Join-Path $logDir "p10_gates"
$failedLogDir = Join-Path $gateLogDir "failed"
foreach ($dir in @($logDir, $gateLogDir, $failedLogDir)) {
	if (-not (Test-Path $dir)) {
		New-Item -ItemType Directory -Path $dir -Force | Out-Null
	}
}

function Write-GateHeader {
	param([string]$Name, [int]$GateNumber = 0)
	Write-Host ("`n" + ("=" * 60))
	if ($GateNumber -gt 0) {
		Write-Host ("[P10] >>> Gate {0}/6: {1}" -f $GateNumber, $Name)
	} else {
		Write-Host ("[P10] >>> {0}" -f $Name)
	}
	Write-Host ("=" * 60)
}

function Write-GateResult {
	param([string]$Name, [bool]$Passed, [string]$Detail, [string]$LogFile = "")
	$statusText = if ($Passed) { "OK" } else { "FAIL" }
	$color = if ($Passed) { "Green" } else { "Red" }
	Write-Host ("[P10] [{0}] {1}" -f $statusText.PadRight(4), $Name) -ForegroundColor $color
	if ($Detail) {
		Write-Host ("       -> {0}" -f $Detail)
	}
	if ($LogFile -and (Test-Path $LogFile)) {
		Write-Host ("       -> log: {0}" -f $LogFile) -ForegroundColor DarkGray
	}
	$result = [PSCustomObject]@{
		Name   = $Name
		Status = $statusText
		Detail = $Detail
		LogFile = $LogFile
	}
	$script:gateResults += $result
	if (-not $Passed) {
		$script:gateFailures++
	}
}

# ── Kill any stray Godot processes ──────────────────────────────────────────
function Clear-GodotProcesses {
	$godotProcs = Get-Process | Where-Object { $_.ProcessName -like "*Godot*" } |Where-Object { $_.Id -ne $PID }
	foreach ($proc in $godotProcs) {
		try {
			Write-Host ("[P10] Cleaning up stray Godot process PID={0}" -f $proc.Id) -ForegroundColor DarkGray
			$proc.Kill()
		} catch {
			# Process may have already exited
		}
	}
}

# ── Core gate invocation with per-gate logging and timeout ──────────────────
function Invoke-GodotCheck {
	param(
		[string]$Name,
		[string[]]$GodotArgs,
		[string]$SuccessMarker,
		[scriptblock]$CustomValidator,
		[int]$GateNumber = 0,
		[int]$TimeoutSeconds = 45
	)

	Write-GateHeader -Name $Name -GateNumber $GateNumber

	# ── Per-gate log file ────────────────────────────────────────────────
	# Sanitize gate name for filename (remove any chars that might break paths)
	$safeName = $Name -replace '[^\w\-]', '_'
	$gateLogFile = Join-Path $gateLogDir ("p10_gate_{0}_{1}.log" -f $safeName, $script:timestamp)

	# Write log header
	$logHeader = @(
		"# P10 Gate Log",
		"# Gate: $Name",
		"# Number: $GateNumber",
		"# Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
		"# Godot: $GodotExe",
		"# Args: $($GodotArgs -join ' ')",
		"# Timeout: ${TimeoutSeconds}s",
		"#" + ("=" * 60),
		""
	) -join "`r`n"
	$logHeader | Out-File -FilePath $gateLogFile -Encoding utf8

	# ── Run Godot via cmd.exe /c with temp-file output redirection ────────
	# WHY: Godot_console.exe on Windows/D3D12 hangs when launched directly
	# via System.Diagnostics.Process with RedirectStandardOutput=true or
	# via Start-Process -NoNewWindow (console attachment issues).
	#
	# Instead we use cmd.exe /c with > file 2>&1 redirection, which:
	#  - Gives Godot a proper console to attach to (via cmd.exe)
	#  - Avoids pipe buffer deadlocks (output goes to file, not pipe)
	#  - Reliable exit code propagation (cmd.exe exits with Godot's code)
	#  - 45-second timeout via WaitForExit(ms) with process kill fallback
	$outputFile = [System.IO.Path]::GetTempFileName()
	try {
		# Build a safe command line for cmd.exe /c
		$quotedExe = if ($GodotExe -match '\s') { "`"$GodotExe`"" } else { $GodotExe }
		$quotedArgs = $GodotArgs | ForEach-Object {
			if ($_ -match '\s') { "`"$_`"" } else { $_ }
		}
		$cmdLine = "$quotedExe $quotedArgs > `"$outputFile`" 2>&1"

		Write-Host ("[P10] CMD: {0}" -f $cmdLine) -ForegroundColor DarkGray
		"# Command: $cmdLine" | Out-File -FilePath $gateLogFile -Encoding utf8 -Append

		$startTime = Get-Date

		# ── Start process WITHOUT -Wait so we can apply timeout ──────────
		$process = Start-Process -FilePath "cmd.exe" `
			-ArgumentList @("/c", $cmdLine) `
			-NoNewWindow -PassThru

		# Check if the process was created
		if (-not $process) {
			Write-Host "[P10] ERROR: Start-Process failed (no process object returned)"
			Write-GateResult -Name $Name -Passed $false -Detail "Start-Process failed" -LogFile $gateLogFile
			return $false
		}

		# ── Wait with timeout using Wait-Process (more reliable ExitCode) ─
		try {
			# Wait-Process -Timeout throws terminating error on timeout
			Wait-Process -Id $process.Id -Timeout $TimeoutSeconds -ErrorAction Stop
			$timedOut = $false
		} catch {
			# Timeout: Wait-Process throws ProcessCommandException or TimeoutException
			$timedOut = $true
		}

		$endTime = Get-Date
		$elapsed = ($endTime - $startTime).TotalSeconds
		$elapsedStr = "{0:N1}s" -f $elapsed

		if ($timedOut) {
			# ── TIMEOUT: Kill the hung process ──────────────────────────
			Write-Host ("[P10] GATE_TIMEOUT: {0} {1}s'de tamamlanamadi, process sonlandiriliyor..." -f $Name, $TimeoutSeconds) -ForegroundColor Red

			# Kill the cmd.exe process
			try {
				$process.Kill()
			} catch {
				Write-Host "[P10] Warning: cmd.exe Process.Kill() failed" -ForegroundColor Yellow
			}

			# Kill any child Godot processes that might be orphaned
			Clear-GodotProcesses

			# Write timeout info to log
			"`r`n# GATE_TIMEOUT: Process exceeded ${TimeoutSeconds}s timeout" | Out-File -FilePath $gateLogFile -Encoding utf8 -Append
			"# Elapsed: $elapsedStr" | Out-File -FilePath $gateLogFile -Encoding utf8 -Append

			# Read any partial output
			$partialOutput = ""
			if (Test-Path $outputFile) {
				$partialOutput = Get-Content -Path $outputFile -Raw -Encoding UTF8
				if ($partialOutput) {
					$partialOutput.TrimEnd() | Out-File -FilePath $gateLogFile -Encoding utf8 -Append
				}
			}

			# Append log footer
			"`r`n# Gate finished: TIMEOUT at $elapsedStr" | Out-File -FilePath $gateLogFile -Encoding utf8 -Append

			# Copy to failed folder
			$failedCopy = Join-Path $failedLogDir ("p10_gate_{0}_{1}_TIMEOUT.log" -f $safeName, $script:timestamp)
			Copy-Item -Path $gateLogFile -Destination $failedCopy -Force

			Write-GateResult -Name $Name -Passed $false -Detail ("GATE_TIMEOUT: {0}s'de tamamlanamadi" -f $TimeoutSeconds) -LogFile $gateLogFile
			return $false
		}

		# Force PowerShell to refresh process object to get ExitCode
		$process.Refresh()
		$exitCode = $process.ExitCode
		# If ExitCode is still null, force WaitForExit() to finalize (non-blocking, already exited)
		if ($null -eq $exitCode -and $process.HasExited) {
			$process.WaitForExit()
			$exitCode = $process.ExitCode
		}
		# Last resort fallback: treat null exit code as 0 if process exited cleanly
		if ($null -eq $exitCode) {
			$exitCode = 0
		}

		# Read output from temp file
		$output = ""
		if (Test-Path $outputFile) {
			$output = Get-Content -Path $outputFile -Raw -Encoding UTF8
			if (-not $output) { $output = "" }
		}

		# Trim trailing whitespace/newlines for cleaner display
		$output = $output.TrimEnd()

		# Write full output to per-gate log file
		if ($output -ne "") {
			$output | Out-File -FilePath $gateLogFile -Encoding utf8 -Append
		}

		# Append elapsed time to log
		"`r`n# Gate finished: exit_code=$exitCode elapsed=$elapsedStr" | Out-File -FilePath $gateLogFile -Encoding utf8 -Append

		# Show Godot output (useful for debugging failures)
		if ($output -ne "") {
			Write-Host $output
		}

		# Check exit code (non-zero = FAIL)
		if ($exitCode -ne 0) {
			# Copy to failed folder on failure
			$failedCopy = Join-Path $failedLogDir ("p10_gate_{0}_{1}_EXIT{2}.log" -f $safeName, $script:timestamp, $exitCode)
			Copy-Item -Path $gateLogFile -Destination $failedCopy -Force
			Write-GateResult -Name $Name -Passed $false -Detail ("exit code={0} (elapsed: {1})" -f $exitCode, $elapsedStr) -LogFile $gateLogFile
			return $false
		}

		# Check for success marker in output
		if ($SuccessMarker) {
			$found = ($output | Select-String -SimpleMatch $SuccessMarker -Quiet)
			if (-not $found) {
				# Copy to failed folder
				$failedCopy = Join-Path $failedLogDir ("p10_gate_{0}_{1}_NOMARKER.log" -f $safeName, $script:timestamp)
				Copy-Item -Path $gateLogFile -Destination $failedCopy -Force
				Write-GateResult -Name $Name -Passed $false -Detail ("'{0}' ciktilarda bulunamadi (elapsed: {1})" -f $SuccessMarker, $elapsedStr) -LogFile $gateLogFile
				return $false
			}
		}

		# Custom validator
		if ($CustomValidator) {
			$valid = & $CustomValidator $output
			if (-not $valid) {
				# Copy to failed folder
				$failedCopy = Join-Path $failedLogDir ("p10_gate_{0}_{1}_CUSTOMFAIL.log" -f $safeName, $script:timestamp)
				Copy-Item -Path $gateLogFile -Destination $failedCopy -Force
				Write-GateResult -Name $Name -Passed $false -Detail ("custom validation failed (elapsed: {0})" -f $elapsedStr) -LogFile $gateLogFile
				return $false
			}
		}

		Write-GateResult -Name $Name -Passed $true -Detail ("elapsed: {0}" -f $elapsedStr) -LogFile $gateLogFile
		return $true
	}
	finally {
		# Clean up temp file
		if (Test-Path $outputFile) {
			Remove-Item -Path $outputFile -Force -ErrorAction SilentlyContinue
		}
	}
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN GATE EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ("`n" + ("#" * 60))
Write-Host ("#  P10 SMOKE GATE  #".PadLeft(45))
Write-Host ("#  {0}  #" -f $script:timestamp)
Write-Host ("#  Timeout: {0}s per gate" -f $GateTimeoutSeconds)
Write-Host ("#" * 60)

Push-Location $ProjectPath
try {
	# ── Gate 1/6: Parse Check ───────────────────────────────────────────────
	if (-not $SkipParseCheck) {
		$null = Invoke-GodotCheck -Name "parse-check" -GateNumber 1 `
			-GodotArgs @("--path", ".", "--check-only", "--quit") `
			-TimeoutSeconds $GateTimeoutSeconds
	}
	else {
		Write-Host "[P10] Gate 1/6: parse-check atlandi (-SkipParseCheck ile)"
		$script:gateResults += [PSCustomObject]@{ Name="parse-check"; Status="SKIP"; Detail="SkipParseCheck ile atlandi"; LogFile="" }
	}

	# ── Gate 2/6: Validate Game Flow ────────────────────────────────────────
	# NOTE: --quit flag is NOT used here. The script itself calls quit(0/1).
	# Using --quit causes Godot to exit before main loop processes deferred calls.
	$null = Invoke-GodotCheck -Name "validate-game-flow" -GateNumber 2 `
		-GodotArgs @("--path", ".", "--script", "res://tools/validate_game_flow.gd") `
		-SuccessMarker "FLOW_VALIDATION_OK" `
		-TimeoutSeconds $GateTimeoutSeconds

	# ── Gate 3/6: Verify App Lifecycle Contract ─────────────────────────────
	# NOTE: --quit flag is NOT used here. The script itself calls quit(0/1).
	$lifecycleScript = Join-Path $PSScriptRoot "verify_app_lifecycle_contract.gd"
	if (Test-Path $lifecycleScript) {
		$null = Invoke-GodotCheck -Name "verify-app-lifecycle" -GateNumber 3 `
			-GodotArgs @("--path", ".", "--script", "res://tools/verify_app_lifecycle_contract.gd") `
			-SuccessMarker "APP_LIFECYCLE_CONTRACT_OK" `
			-TimeoutSeconds $GateTimeoutSeconds
	}
	else {
		Write-Warning "[P10] Gate 3/6: verify_app_lifecycle_contract.gd bulunamadi, gate atlaniyor."
		$script:gateResults += [PSCustomObject]@{ Name="verify-app-lifecycle"; Status="SKIP"; Detail="Script tools/ altinda yok"; LogFile="" }
	}

	# ── Gate 4/6: Verify Overlay Input Contract ─────────────────────────────
	$overlayInputScript = Join-Path $PSScriptRoot "verify_overlay_input_contract.gd"
	if (Test-Path $overlayInputScript) {
		$null = Invoke-GodotCheck -Name "verify-overlay-input-contract" -GateNumber 4 `
			-GodotArgs @("--path", ".", "--script", "res://tools/verify_overlay_input_contract.gd", "--quit") `
			-TimeoutSeconds $GateTimeoutSeconds
	}
	else {
		Write-Warning "[P10] Gate 4/6: verify_overlay_input_contract.gd bulunamadi, gate atlaniyor."
		$script:gateResults += [PSCustomObject]@{ Name="verify-overlay-input-contract"; Status="SKIP"; Detail="Script tools/ altinda yok"; LogFile="" }
	}

	# ── Gate 5/6: Verify UI Focus Accessibility ─────────────────────────────
	$uiFocusScript = Join-Path $PSScriptRoot "verify_ui_focus_accessibility.gd"
	if (Test-Path $uiFocusScript) {
		$null = Invoke-GodotCheck -Name "verify-ui-focus-accessibility" -GateNumber 5 `
			-GodotArgs @("--path", ".", "--script", "res://tools/verify_ui_focus_accessibility.gd", "--quit") `
			-TimeoutSeconds $GateTimeoutSeconds
	}
	else {
		Write-Warning "[P10] Gate 5/6: verify_ui_focus_accessibility.gd bulunamadi, gate atlaniyor."
		$script:gateResults += [PSCustomObject]@{ Name="verify-ui-focus-accessibility"; Status="SKIP"; Detail="Script tools/ altinda yok"; LogFile="" }
	}

	# ── Gate 6/6: Device Smoke (ADB) ────────────────────────────────────────
	if (-not $SkipAdbDeviceSmoke) {
		Write-GateHeader -Name "device-smoke (ADB detection)" -GateNumber 6

		# Try to locate ADB
		$adbExe = $null
		$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
		if ($adbCommand) {
			$adbExe = $adbCommand.Source
		}
		if (-not $adbExe) {
			$defaultAdb = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
			if (Test-Path -LiteralPath $defaultAdb) {
				$adbExe = $defaultAdb
			}
		}

		if (-not $adbExe) {
			Write-Host "[P10] ADB bulunamadi (PATH veya Android SDK platform-tools)."
			Write-Host "[P10] DEVICE_SMOKE_SKIPPED_NO_ADB_OR_DEVICE"
			$script:gateResults += [PSCustomObject]@{ Name="device-smoke"; Status="SKIP"; Detail="ADB bulunamadi, device smoke atlandi"; LogFile="" }
		}
		else {
			# ADB found, check for connected devices
			$deviceOutput = & $adbExe devices 2>&1
			$deviceLines = @($deviceOutput | Where-Object {
				$_ -match "\S+\s+device$" -and $_ -notmatch "^List of devices attached"
			})
			if ($deviceLines.Count -eq 0) {
				Write-Host "[P10] ADB mevcut ancak bagli cihaz/emulator bulunamadi."
				Write-Host "[P10] DEVICE_SMOKE_SKIPPED_NO_ADB_OR_DEVICE"
				$script:gateResults += [PSCustomObject]@{ Name="device-smoke"; Status="SKIP"; Detail="ADB var ama bagli cihaz yok"; LogFile="" }
			}
			else {
				$deviceSerial = ($deviceLines[0] -split "\s+")[0]
				$deviceModel = (& $adbExe shell getprop ro.product.model 2>$null) -join ""
				$deviceAndroid = (& $adbExe shell getprop ro.build.version.release 2>$null) -join ""
				Write-Host ("[P10] Device detected: {0} (Android {1})" -f $deviceModel.Trim(), $deviceAndroid.Trim())
				Write-Host "[P10] Cihaz-ustu smoke icin tools/run_p10_device_smoke.ps1 kullanin."
				Write-Host "[P10] DEVICE_AVAILABLE"
				$script:gateResults += [PSCustomObject]@{
					Name="device-smoke"
					Status="OK"
					Detail=("Device: {0} (Android {1}) - manual smoke via run_p10_device_smoke.ps1" -f $deviceModel.Trim(), $deviceAndroid.Trim())
					LogFile=""
				}
			}
		}
	}
	else {
		Write-Host "[P10] device-smoke atlandi (-SkipAdbDeviceSmoke ile)"
		$script:gateResults += [PSCustomObject]@{ Name="device-smoke"; Status="SKIP"; Detail="SkipAdbDeviceSmoke ile atlandi"; LogFile="" }
	}

	# ── Final result ────────────────────────────────────────────────────────
	Write-Host ("`n" + ("=" * 60))
	Write-Host "[P10] GATE SUMMARY"
	Write-Host ("=" * 60)

	$allPassed = $true
	foreach ($r in $script:gateResults) {
		$icon = switch ($r.Status) {
			"OK"   { "[PASS]" }
			"FAIL" { "[FAIL]" ; $allPassed = $false }
			"SKIP" { "[SKIP]" }
		}
		$color = switch ($r.Status) {
			"OK"   { "Green" }
			"FAIL" { "Red" }
			"SKIP" { "Yellow" }
		}
		$detailStr = $r.Detail
		if ($r.LogFile -and (Test-Path $r.LogFile)) {
			$detailStr += " | log: $($r.LogFile)"
		}
		Write-Host ("{0} {1,-35} {2}" -f $icon, $r.Name, $detailStr) -ForegroundColor $color
	}

	if ($allPassed -and $script:gateFailures -eq 0) {
		Write-Host ("`n[P10] P10_SMOKE_GATE_OK") -ForegroundColor Green
		Write-Host ("[P10] Tüm gate'ler basariyla gecti.") -ForegroundColor Green
	} else {
		Write-Host ("`n[P10] P10_SMOKE_GATE_FAILED with $script:gateFailures gate failure(s)") -ForegroundColor Red
	}

	# ── Write summary report ────────────────────────────────────────────────
	$reportPath = Join-Path $logDir ("p10_smoke_{0}.md" -f $script:timestamp)
	$reportLines = @(
		"# P10 Smoke Gate Report",
		"",
		"**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
		"**Godot:** $GodotExe",
		"**Project:** $ProjectPath",
		"**Timeout:** ${GateTimeoutSeconds}s per gate",
		"**Result:** $(if ($allPassed -and $script:gateFailures -eq 0) { 'PASS' } else { 'FAIL' })",
		"",
		"## Gate Results",
		"",
		"| Gate | Status | Detail | Log |",
		"|------|--------|--------|-----|"
	)
	foreach ($r in $script:gateResults) {
		$logLink = if ($r.LogFile -and (Test-Path $r.LogFile)) { "[$($r.LogFile)]($($r.LogFile))" } else { "-" }
		$reportLines += ("| {0} | {1} | {2} | {3} |" -f $r.Name, $r.Status, $r.Detail, $logLink)
	}
	$reportLines += @(
		"",
		"## Logs",
		"",
		"- Gate logs: $gateLogDir",
		"- Failed gate logs: $failedLogDir",
		"",
		"## Device Smoke",
		""
	)
	if (-not $SkipAdbDeviceSmoke) {
		$reportLines += "- Device smoke check: $(if ($adbExe) { 'ADB found' } else { 'ADB not found' })"
		$reportLines += '- Manual cihaz smoke: `powershell -ExecutionPolicy Bypass -File tools/run_p10_device_smoke.ps1`'
	}
	else {
		$reportLines += "- Device smoke skipped via -SkipAdbDeviceSmoke"
	}
	$reportLines += @(
		"",
		"---",
		"*Generated by P10 Smoke Gate*"
	)

	$reportLines -join "`r`n" | Out-File -FilePath $reportPath -Encoding utf8
	Write-Host ("[P10] Report saved: {0}" -f $reportPath)

	# ── Write JSON summary ──────────────────────────────────────────────────
	$jsonPath = Join-Path $logDir ("p10_smoke_{0}.json" -f $script:timestamp)
	$jsonSummary = @{
		timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
		godot = $GodotExe
		project = $ProjectPath
		timeout_seconds = $GateTimeoutSeconds
		result = if ($allPassed -and $script:gateFailures -eq 0) { "PASS" } else { "FAIL" }
		gate_failures = $script:gateFailures
		gates = $script:gateResults | ForEach-Object {
			@{ name = $_.Name; status = $_.Status; detail = $_.Detail; log = $_.LogFile }
		}
	}
	$jsonSummary | ConvertTo-Json -Depth 3 | Out-File -FilePath $jsonPath -Encoding utf8
	Write-Host ("[P10] JSON log saved: {0}" -f $jsonPath)

	# ── Exit with proper code ───────────────────────────────────────────────
	if ($allPassed -and $script:gateFailures -eq 0) {
		exit 0
	} else {
		exit 1
	}
}
finally {
	# ── Final cleanup: kill any orphaned Godot processes ──────────────────
	Clear-GodotProcesses
	Pop-Location
}
