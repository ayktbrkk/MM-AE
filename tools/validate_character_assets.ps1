$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Read-ProjectFile($RelativePath) {
    return Get-Content -LiteralPath (Join-Path $projectRoot $RelativePath) -Raw
}

function Assert-Contains($Text, $Pattern, $Message) {
    if ($Text -notmatch [regex]::Escape($Pattern)) {
        throw $Message
    }
}

function Assert-NotContains($Text, $Pattern, $Message) {
    if ($Text -match [regex]::Escape($Pattern)) {
        throw $Message
    }
}

$world = Read-ProjectFile "scripts/world.gd"
$dialogue = Read-ProjectFile "scripts/dialogue_overlay.gd"
$decision = Read-ProjectFile "scripts/decision_overlay.gd"
$mainMenu = Read-ProjectFile "scripts/main_menu.gd"

$scriptBundle = $world + "`n" + $dialogue + "`n" + $decision + "`n" + $mainMenu

Assert-Contains $scriptBundle "assets/art/characters/arda/char_arda_world.svg" "Arda world sprite is not wired into gameplay scripts."
Assert-Contains $scriptBundle "assets/art/characters/eda/char_eda_world.svg" "Eda world sprite is not wired into gameplay scripts."
Assert-Contains $scriptBundle "assets/art/characters/arda/portrait_arda_idle.svg" "Arda idle portrait is not wired into overlays."
Assert-Contains $scriptBundle "assets/art/characters/eda/portrait_eda_idle.svg" "Eda idle portrait is not wired into overlays."
Assert-NotContains $scriptBundle "kenney/kenney_platformer-characters/PNG/Player/Poses/player_stand.png" "Arda still uses the Kenney placeholder."
Assert-NotContains $scriptBundle "kenney/kenney_platformer-characters/PNG/Female/Poses/female_stand.png" "Eda still uses the Kenney placeholder."

$requiredAssets = @(
    "assets/art/characters/arda/char_arda_world.svg",
    "assets/art/characters/arda/portrait_arda_idle.svg",
    "assets/art/characters/arda/portrait_arda_thinking.svg",
    "assets/art/characters/arda/portrait_arda_happy.svg",
    "assets/art/characters/eda/char_eda_world.svg",
    "assets/art/characters/eda/portrait_eda_idle.svg",
    "assets/art/characters/eda/portrait_eda_thinking.svg",
    "assets/art/characters/eda/portrait_eda_happy.svg"
)

foreach ($assetPath in $requiredAssets) {
    $fullPath = Join-Path $projectRoot $assetPath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing character asset: $assetPath"
    }
}

Write-Host "Character asset replacement checks passed."
