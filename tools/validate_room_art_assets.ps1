$ErrorActionPreference = "Stop"

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$worldScript = Join-Path $projectRoot "scripts/world.gd"
$worldScene = Join-Path $projectRoot "scenes/world.tscn"
$source = Get-Content -LiteralPath $worldScript -Raw
$sceneSource = Get-Content -LiteralPath $worldScene -Raw

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

Assert-Contains $source "OPENING_PAPER_BENCHMARK_TEXTURE" "Missing opening benchmark world preload."
Assert-Contains $source "func _add_open_world_start_depth_pass() -> void:" "Missing opening outdoor depth pass."
Assert-Contains $source "func _add_open_world_start_asset_layer() -> void:" "Missing opening outdoor asset layer."
Assert-Contains $source "_add_open_world_start_depth_pass()" "Room build should use the outdoor depth pass."
Assert-Contains $source "_add_open_world_start_asset_layer()" "Room build should apply the outdoor asset layer."
Assert-Contains $source "paperopening.depth.open_meadow" "Opening depth should use outdoor meadow depth instead of an indoor floor band."
Assert-Contains $source "paperopening.depth.sky_overscan" "Opening render should include sky overscan so camera framing never exposes the clear color."
Assert-Contains $source "paperopening.depth.paper_overscan" "Opening render should include paper overscan below the world frame."
Assert-Contains $source 'Color("#B7D99B")' "Opening lower ground should use meadow color instead of the flat orange room floor."
Assert-Contains $source 'if current_area == "room":' "Opening area should suppress animated rectangular atmosphere washes."
Assert-Contains $source 'ambient_top_alpha = 0.0' "Opening area should keep top atmosphere alpha at zero."
Assert-Contains $source "paperopening.benchmark_world" "Missing benchmark open-world composition placement."
Assert-Contains $source "opening_ground_y := WORLD_SIZE.y * 0.55" "Opening characters should stand inside the paper island, not on the village horizon."
Assert-Contains $source "Vector2(930, opening_ground_y" "Opening player should start to the side of the central paper card so the artwork remains readable."
Assert-NotContains $source '"paperopening.sky_horizon"' "Opening scene still draws a duplicate sky asset over the benchmark composition."
Assert-NotContains $source '"paperopening.village_depth"' "Opening scene still draws duplicate village houses over the benchmark composition."
Assert-NotContains $source '"paperopening.terrain_island"' "Opening scene still draws a duplicate terrain island over the benchmark composition."
Assert-NotContains $source '"paperopening.main_path"' "Opening scene still draws a duplicate path over the benchmark composition."
Assert-NotContains $source '"paperopening.book_gate"' "Opening scene still draws a duplicate book gate over the benchmark composition."
Assert-NotContains $source '"paperopening.clue_stations"' "Opening scene still draws duplicate clue stations over the benchmark composition."
Assert-NotContains $source '"paperopening.foreground_frame"' "Opening scene still draws a duplicate foreground frame over the benchmark composition."
Assert-NotContains $source '"opening.book_gate_focus"' "Opening scene still uses rectangular placeholder focus cards."
Assert-NotContains $source '"opening.clue_glow_left"' "Opening scene still uses rectangular placeholder clue cards."
Assert-NotContains $source '"opening.clue_glow_center"' "Opening scene still uses rectangular placeholder clue cards."
Assert-Contains $sceneSource "Color(0.04, 0.05, 0.08, 0)" "Opening atmosphere vignette should be transparent for outdoor artwork."
Assert-Contains $sceneSource "Color(0.22, 0.78, 1, 0)" "Opening rift edge wash should not read as vertical bars."
Assert-Contains $sceneSource "Color(0.96, 0.72, 0.42, 0)" "Opening top glow should not create a rectangular wash."
Assert-Contains $sceneSource "Color(0.78, 0.86, 1, 0)" "Opening horizon glow should not create a rectangular wash."
Assert-Contains $sceneSource "Color(0.94, 0.96, 1, 0)" "Opening bottom fog should not create a rectangular wash."

if ($source -match "_add_room_depth_pass\(\)\s*\r?\n\s*_add_room_paper_asset_layer\(\)") {
    throw "First scene still builds the indoor room paper layer."
}

$requiredAssets = @(
    "assets/art/world/opening/paper_sky_horizon.svg",
    "assets/art/world/opening/paper_benchmark_world.svg",
    "assets/art/world/opening/paper_terrain_island.svg",
    "assets/art/world/opening/paper_main_path.svg",
    "assets/art/world/opening/paper_village_depth.svg",
    "assets/art/world/opening/paper_book_gate.svg",
    "assets/art/world/opening/paper_clue_stations.svg",
    "assets/art/world/opening/paper_foreground_frame.svg"
)

foreach ($assetPath in $requiredAssets) {
    $fullPath = Join-Path $projectRoot $assetPath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing room art asset: $assetPath"
    }
}

Write-Host "Room art asset checks passed."
