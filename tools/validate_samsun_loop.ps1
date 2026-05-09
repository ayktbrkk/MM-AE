$ErrorActionPreference = "Stop"

$worldScript = Join-Path $PSScriptRoot "..\scripts\world.gd"
$source = Get-Content -LiteralPath $worldScript -Raw
$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")

function Assert-Contains($Text, $Pattern, $Message) {
    if ($Text -notmatch [regex]::Escape($Pattern)) {
        throw $Message
    }
}

Assert-Contains $source "func _samsun_intro_goal_text() -> String:" "Missing Samsun intro goal helper."
Assert-Contains $source "2 liderlik izi" "Samsun intro goal should tell the player to find 2 leadership clues."
Assert-Contains $source "2 destek noktası" "Samsun intro goal should tell the player to build 2 support points."
Assert-Contains $source "Liman, Telgraf ve Halk" "Samsun intro dialogue should name the three civic support areas."
Assert-Contains $source "Gözlem ve bağlantı birlikte güç olur" "Samsun companion reaction should reinforce the learning payoff."
Assert-Contains $source "Yan patikalar da hikaye taşır" "Samsun route reaction should reward off-path exploration."
Assert-Contains $source "Güvenli açıklıklar, plan yapmak için iyi duraklar" "Samsun safe clearing reaction should make rest points readable."
Assert-Contains $source "Ufuktaki bayraklar yolun devam ettiğini fısıldıyor" "Samsun vista reaction should deepen the open-world horizon."
Assert-Contains $source "samsun_open_world_overview_time_left" "Missing Samsun open-world overview camera timer."
Assert-Contains $source "func _start_samsun_open_world_overview() -> void:" "Missing Samsun open-world overview starter."
Assert-Contains $source "_start_samsun_open_world_overview()" "Samsun setup should start the open-world overview."
Assert-Contains $source "Vector2(0.56, 0.56)" "Samsun overview should zoom out enough to show the diorama."
Assert-Contains $source "func _samsun_overview_camera_offset() -> Vector2:" "Missing Samsun overview camera offset helper."
Assert-Contains $source "func _add_samsun_paper_asset_layer() -> void:" "Missing Samsun paper asset layer."
Assert-Contains $source "SAMSUN_PAPER_TERRAIN_TEXTURE" "Missing paper terrain preload."
Assert-Contains $source "SAMSUN_PAPER_HARBOR_TEXTURE" "Missing paper harbor preload."
Assert-Contains $source "SAMSUN_PAPER_TELEGRAPH_TEXTURE" "Missing paper telegraph preload."
Assert-Contains $source "SAMSUN_PAPER_PEOPLE_TEXTURE" "Missing paper people preload."
Assert-Contains $source "SAMSUN_PAPER_RIFT_TEXTURE" "Missing paper rift preload."
Assert-Contains $source "SAMSUN_PAPER_MAIN_PATH_TEXTURE" "Missing paper main path preload."
Assert-Contains $source "SAMSUN_PAPER_CIVIC_CLUSTER_TEXTURE" "Missing paper civic cluster preload."
Assert-Contains $source "SAMSUN_PAPER_WAVE_GATE_TEXTURE" "Missing paper wave gate preload."
Assert-Contains $source "SAMSUN_PAPER_DISTANT_TOWN_TEXTURE" "Missing paper distant town preload."
Assert-Contains $source "SAMSUN_PAPER_HARBOR_WATER_TEXTURE" "Missing paper harbor water preload."
Assert-Contains $source "SAMSUN_PAPER_FOREGROUND_FRAME_TEXTURE" "Missing paper foreground frame preload."
Assert-Contains $source "SAMSUN_PAPER_SIDE_PATHS_TEXTURE" "Missing paper side paths preload."
Assert-Contains $source "SAMSUN_PAPER_HARBOR_BOATS_TEXTURE" "Missing paper harbor boats preload."
Assert-Contains $source "SAMSUN_PAPER_SIGNAL_RIDGE_TEXTURE" "Missing paper signal ridge preload."
Assert-Contains $source "SAMSUN_PAPER_SKY_LIFE_TEXTURE" "Missing paper sky life preload."
Assert-Contains $source "SAMSUN_PAPER_DISCOVERY_PROPS_TEXTURE" "Missing paper discovery props preload."
Assert-Contains $source "SAMSUN_PAPER_COAST_DETAILS_TEXTURE" "Missing paper coast details preload."
Assert-Contains $source "SAMSUN_PAPER_ROUTE_BEADS_TEXTURE" "Missing paper route beads preload."
Assert-Contains $source "SAMSUN_PAPER_SAFE_CLEARINGS_TEXTURE" "Missing paper safe clearings preload."
Assert-Contains $source "SAMSUN_PAPER_VISTA_FLAGS_TEXTURE" "Missing paper vista flags preload."
Assert-Contains $source "SAMSUN_PAPER_SKYLINE_DEPTH_TEXTURE" "Missing paper skyline depth preload."
Assert-Contains $source "SAMSUN_PAPER_HARBOR_DOCK_PROPS_TEXTURE" "Missing paper harbor dock props preload."
Assert-Contains $source "SAMSUN_PAPER_COASTAL_LIFE_TEXTURE" "Missing paper coastal life preload."
Assert-Contains $source "paperworld.samsun_main_path" "Missing paper main path placement."
Assert-Contains $source "paperworld.samsun_civic_cluster" "Missing paper civic cluster placement."
Assert-Contains $source "paperworld.samsun_wave_gate" "Missing paper wave gate placement."
Assert-Contains $source "paperworld.samsun_distant_town" "Missing paper distant town placement."
Assert-Contains $source "paperworld.samsun_harbor_water" "Missing paper harbor water placement."
Assert-Contains $source "paperworld.samsun_foreground_frame" "Missing paper foreground frame placement."
Assert-Contains $source "paperworld.samsun_side_paths" "Missing paper side paths placement."
Assert-Contains $source "paperworld.samsun_harbor_boats" "Missing paper harbor boats placement."
Assert-Contains $source "paperworld.samsun_signal_ridge" "Missing paper signal ridge placement."
Assert-Contains $source "paperworld.samsun_sky_life" "Missing paper sky life placement."
Assert-Contains $source "paperworld.samsun_discovery_props" "Missing paper discovery props placement."
Assert-Contains $source "paperworld.samsun_coast_details" "Missing paper coast details placement."
Assert-Contains $source "paperworld.samsun_route_beads" "Missing paper route beads placement."
Assert-Contains $source "paperworld.samsun_safe_clearings" "Missing paper safe clearings placement."
Assert-Contains $source "paperworld.samsun_vista_flags" "Missing paper vista flags placement."
Assert-Contains $source "paperworld.samsun_skyline_depth" "Missing paper skyline depth placement."
Assert-Contains $source "paperworld.samsun_harbor_dock_props" "Missing paper harbor dock props placement."
Assert-Contains $source "paperworld.samsun_coastal_life" "Missing paper coastal life placement."
Assert-Contains $source "func _add_foreground_paper_cutout_asset(" "Missing foreground paper cutout helper."
Assert-Contains $source "paper_drift" "Missing paper drift animation metadata."
Assert-Contains $source "paper_parallax_strength" "Missing paper parallax metadata."
Assert-Contains $source "func _paper_parallax_offset(strength: float) -> Vector2:" "Missing paper parallax offset helper."
Assert-Contains $source "_paper_parallax_offset" "Paper parallax helper is not used."

$requiredAssets = @(
    "assets/art/world/samsun/paper_terrain_island.svg",
    "assets/art/world/samsun/paper_harbor_landmark.svg",
    "assets/art/world/samsun/paper_telegraph_landmark.svg",
    "assets/art/world/samsun/paper_people_plaza.svg",
    "assets/art/world/samsun/paper_rift_core.svg",
    "assets/art/world/samsun/paper_main_path.svg",
    "assets/art/world/samsun/paper_civic_cluster.svg",
    "assets/art/world/samsun/paper_wave_gate.svg",
    "assets/art/world/samsun/paper_distant_town.svg",
    "assets/art/world/samsun/paper_harbor_water.svg",
    "assets/art/world/samsun/paper_foreground_frame.svg",
    "assets/art/world/samsun/paper_side_paths.svg",
    "assets/art/world/samsun/paper_harbor_boats.svg",
    "assets/art/world/samsun/paper_signal_ridge.svg",
    "assets/art/world/samsun/paper_sky_life.svg",
    "assets/art/world/samsun/paper_discovery_props.svg",
    "assets/art/world/samsun/paper_coast_details.svg",
    "assets/art/world/samsun/paper_route_beads.svg",
    "assets/art/world/samsun/paper_safe_clearings.svg",
    "assets/art/world/samsun/paper_vista_flags.svg",
    "assets/art/world/samsun/paper_skyline_depth.svg",
    "assets/art/world/samsun/paper_harbor_dock_props.svg",
    "assets/art/world/samsun/paper_coastal_life.svg"
)

foreach ($assetPath in $requiredAssets) {
    $fullPath = Join-Path $projectRoot $assetPath
    if (-not (Test-Path -LiteralPath $fullPath)) {
        throw "Missing paper-world asset: $assetPath"
    }
}

Write-Host "Samsun loop readability checks passed."
