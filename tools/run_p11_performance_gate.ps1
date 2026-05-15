param(
	[string]$GodotExe = $env:GODOT_EXE,
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[switch]$SkipMeasurement,
	[switch]$NoTimestamp
)

$ErrorActionPreference = "Stop"

# ── Godot executable ────────────────────────────────────────────────────────
if ([string]::IsNullOrWhiteSpace($GodotExe)) {
	$defaultExe = "C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe"
	if (Test-Path $defaultExe) {
		$GodotExe = $defaultExe
	}
}

if ([string]::IsNullOrWhiteSpace($GodotExe) -or -not (Test-Path $GodotExe)) {
	Write-Host "[P11] WARNING: Godot executable bulunamadi. Tum gate'ler atlaniyor."
	Write-Host "[P11] P11_PERFORMANCE_GATE_SKIPPED_NO_GODOT"
	exit 0
}

# ── Output helpers ──────────────────────────────────────────────────────────
$script:gatePassed = $true
$script:gateResults = @()
$script:timestamp = if ($NoTimestamp) { "notimestamp" } else { (Get-Date -Format "yyyyMMdd_HHmmss") }

function Write-GateHeader {
	param([string]$Name)
	Write-Host ("`n" + ("=" * 60))
	Write-Host ("[P11] >>> {0}" -f $Name)
	Write-Host ("=" * 60)
}

function Write-GateResult {
	param([string]$Name, [bool]$Passed, [string]$Detail)
	$statusText = if ($Passed) { "OK" } else { "WARN" }
	$color = if ($Passed) { "Green" } else { "Yellow" }
	Write-Host ("[P11] [{0}] {1}" -f $statusText.PadRight(4), $Name) -ForegroundColor $color
	if ($Detail) {
		Write-Host ("       -> {0}" -f $Detail)
	}
	$script:gateResults += [PSCustomObject]@{
		Name   = $Name
		Status = $statusText
		Detail = $Detail
	}
}

# ── Artifact / log directory ────────────────────────────────────────────────
$logDir = Join-Path $ProjectPath "artifacts\logs"
if (-not (Test-Path $logDir)) {
	New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN GATE EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

Write-Host ("`n" + ("#" * 60))
Write-Host ("#  P11 PERFORMANCE GATE  #".PadLeft(42))
Write-Host ("#  {0}  #" -f $script:timestamp)
Write-Host ("#" * 60)

Push-Location $ProjectPath
try {
	# ── Gate 1/1: World Complexity Measurement ──────────────────────────────
	if (-not $SkipMeasurement) {
		Write-GateHeader -Name "world-complexity-measurement"

		$output = & $GodotExe @("--headless", "--path", ".", "--script", "res://tools/measure_world_complexity.gd") 2>&1
		$exitCode = $LASTEXITCODE

		# Çıktıyı göster
		Write-Host $output

		if ($exitCode -ne 0) {
			Write-GateResult -Name "world-complexity-measurement" -Passed $false -Detail "exit code=$exitCode"
			$script:gatePassed = $false
		}
		else {
			Write-GateResult -Name "world-complexity-measurement" -Passed $true -Detail "exit code=0"

			# CSV çıktısını log dosyasına kaydet
			$csvFile = Join-Path $logDir ("p11_complexity_{0}.csv" -f $script:timestamp)
			$output | Out-File -FilePath $csvFile -Encoding utf8
			Write-Host ("[P11] CSV log saved: {0}" -f $csvFile)

			# Threshold warning'leri tara
			$thresholdWarnings = $output | Select-String -Pattern "WARNING" -SimpleMatch -Quiet
			if (-not $thresholdWarnings) {
				$thresholdLines = $output | Select-String -Pattern ">>> Threshold warnings"
				if ($thresholdLines) {
					$countMatch = [regex]::Match($thresholdLines, "(\d+)")
					if ($countMatch.Success -and $countMatch.Groups[1].Value -ne "0") {
						Write-GateResult -Name "threshold-check" -Passed $false -Detail ("{0} threshold warning(s) found" -f $countMatch.Groups[1].Value)
					}
					else {
						Write-GateResult -Name "threshold-check" -Passed $true -Detail "all zones within limits"
					}
				}
				else {
					Write-GateResult -Name "threshold-check" -Passed $true -Detail "no warnings detected"
				}
			}
			else {
				Write-GateResult -Name "threshold-check" -Passed $false -Detail "WARNING patterns found in output"
			}
		}
	}
	else {
		Write-Host "[P11] world-complexity-measurement atlandi (-SkipMeasurement ile)"
		$script:gateResults += [PSCustomObject]@{ Name="world-complexity-measurement"; Status="SKIP"; Detail="SkipMeasurement ile atlandi" }
	}

	# ── Summary ─────────────────────────────────────────────────────────────
	Write-Host ("`n" + ("=" * 60))
	Write-Host "P11 PERFORMANCE GATE SUMMARY"
	Write-Host ("=" * 60)
	foreach ($r in $script:gateResults) {
		$color = switch ($r.Status) {
			"OK"   { "Green" }
			"WARN" { "Yellow" }
			"SKIP" { "Cyan" }
			default { "White" }
		}
		Write-Host ("  [{0}] {1}" -f $r.Status.PadRight(4), $r.Name) -ForegroundColor $color
		if ($r.Detail) {
			Write-Host ("         -> {0}" -f $r.Detail)
		}
	}

	if ($script:gatePassed) {
		Write-Host ("`n[P11] P11_PERFORMANCE_GATE_PASSED") -ForegroundColor Green
	}
	else {
		Write-Host ("`n[P11] P11_PERFORMANCE_GATE_PASSED_WITH_WARNINGS") -ForegroundColor Yellow
	}
}
finally {
	Pop-Location
}
