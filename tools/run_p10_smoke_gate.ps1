param(
	[string]$GodotExe = $env:GODOT_EXE,
	[string]$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
	[switch]$SkipParseCheck
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($GodotExe)) {
	$defaultExe = "C:\Users\Aykut\Desktop\MM-AE-main\Godot_v4.6.2-stable_win64_console.exe"
	if (Test-Path $defaultExe) {
		$GodotExe = $defaultExe
	}
}

if ([string]::IsNullOrWhiteSpace($GodotExe) -or -not (Test-Path $GodotExe)) {
	throw "Godot executable bulunamadi. -GodotExe verin veya GODOT_EXE ortam degiskenini ayarlayin."
}

$checks = @()
if (-not $SkipParseCheck) {
	$checks += @{
		Name = "parse-check"
		Args = @("--headless", "--check-only", "--path", ".", "--quit")
	}
}

$checks += @(
	@{
		Name = "verify-app-lifecycle"
		Args = @("--headless", "--path", ".", "--script", "res://tools/verify_app_lifecycle_contract.gd")
	},
	@{
		Name = "validate-game-flow"
		Args = @("--headless", "--path", ".", "--script", "res://tools/validate_game_flow.gd")
	}
)

Push-Location $ProjectPath
try {
	foreach ($check in $checks) {
		Write-Host ("[P10] Running {0}..." -f $check.Name)
		& $GodotExe @($check.Args)
		if ($LASTEXITCODE -ne 0) {
			throw ("P10 smoke gate failed during {0}." -f $check.Name)
		}
	}

	Write-Host "P10_SMOKE_GATE_OK"
}
finally {
	Pop-Location
}