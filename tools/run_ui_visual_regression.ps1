param(
	[string]$GodotExe = $env:GODOT_EXE,
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[string]$BaselineDir = "res://artifacts/renders/ui_checklist",
	[string]$CandidateDir = "res://artifacts/renders/ui_regression_current",
	[string]$DiffDir = "res://artifacts/renders/ui_regression_diffs",
	[string]$Size = "1080x1920",
	[double]$ThresholdRatio = 0.0015,
	[double]$ThresholdDelta = 0.025
)

$surfaces = @("menu", "dialogue", "decision", "info_card", "chapter_transition", "completion")

if ([string]::IsNullOrWhiteSpace($GodotExe)) {
	$defaultExe = "C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe"
	if (Test-Path $defaultExe) {
		$GodotExe = $defaultExe
	}
}

if ([string]::IsNullOrWhiteSpace($GodotExe) -or -not (Test-Path $GodotExe)) {
	throw "Godot executable bulunamadi. -GodotExe verin veya GODOT_EXE ortam degiskenini ayarlayin."
}

Push-Location $ProjectPath
try {
	foreach ($surface in $surfaces) {
		$output = "$CandidateDir/$($surface)_1080x1920.png"
		& $GodotExe --path . --script res://tools/capture_character_ui.gd -- --surface $surface --size $Size --output $output
		if ($LASTEXITCODE -ne 0) {
			throw "Capture basarisiz: $surface"
		}
	}

	& $GodotExe --headless --path . --script res://tools/compare_ui_captures.gd -- --baseline-dir $BaselineDir --candidate-dir $CandidateDir --diff-dir $DiffDir --threshold-ratio $ThresholdRatio --threshold-delta $ThresholdDelta
	if ($LASTEXITCODE -ne 0) {
		throw "UI visual regression basarisiz oldu. Diff klasorunu kontrol edin: $DiffDir"
	}
}
finally {
	Pop-Location
}