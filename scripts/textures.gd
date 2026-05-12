## MMAE - Merkezi Texture Sabitleri
## =================================
## Tüm texture sabitleri bu dosyada toplanmıştır.
## DRY prensibi: aynı texture hiçbir dosyada tekrarlanmaz.
##
## Kullanım:
##   @onready var _textures := preload("res://scripts/textures.gd")
##   sonra `_textures.ARDA_TEXTURE` şeklinde kullan
##
## Kaynak: scripts/world.gd, scripts/world_builder.gd
## Son Güncelleme: 2026-05-10 (R6 - texture sabitlerini merkezileştirme)

extends Node

# ====================================
# KARAKTER TEXTURE'LARI
# ====================================
const ARDA_TEXTURE := preload("res://assets/art/characters/arda/char_arda_world.svg")
const EDA_TEXTURE := preload("res://assets/art/characters/eda/char_eda_world.svg")

# ====================================
# İKON TEXTURE'LARI (kenney_board-game-icons)
# ====================================
const NOTE_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/notepad.svg")
const TALK_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/pawn_table.svg")
const PORTAL_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/flag_square.svg")
const DECISION_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/hand_card.svg")
const RESOURCE_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/token_add.svg")
const SUPPORT_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/structure_watchtower.svg")
const WAVE_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/hourglass.svg")
const BADGE_ICON := preload("res://kenney/kenney_medals/PNG/flat_medal3.png")

# ====================================
# ARKAPLAN BACKGROUND ELEMENTS (kenney_background-elements)
# ====================================
const CLOUD_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/cloud3.png")
const CLOUD_TEXTURE_ALT := preload("res://kenney/kenney_background-elements/PNG/cloud7.png")
const MOON_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/moon_full.png")
const TREE_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/tree01.png")
const TREE_TEXTURE_ALT := preload("res://kenney/kenney_background-elements/PNG/tree05.png")
const HOUSE_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/house_beige_front.png")
const HOUSE_TEXTURE_ALT := preload("res://kenney/kenney_background-elements/PNG/house_grey_side.png")
const FENCE_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/fence.png")

# ====================================
# FLAT BACKGROUND (kenney_background-elements/Flat)
# ====================================
const BG_FLAT_HILLS_1_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/hills1.png")
const BG_FLAT_HILLS_2_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/hills2.png")
const BG_FLAT_MOUNTAIN_1_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/mountain1.png")
const BG_FLAT_MOUNTAIN_2_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/mountain2.png")
const BG_FLAT_POINTY_MOUNTAINS_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/pointy_mountains.png")
const BG_FLAT_HOUSE_SHORT_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/house_front_short.png")
const BG_FLAT_HOUSE_TALL_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/house_front_tall.png")
const BG_FLAT_TREE_03_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/tree03.png")
const BG_FLAT_TREE_08_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/tree08.png")

# ====================================
# GEMİ PARÇALARI (kenney_pirate-pack)
# ====================================
const SHIP_HULL_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/hullLarge (1).png")
const SHIP_HULL_ALT_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/hullLarge (3).png")
const SHIP_SAIL_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/sailLarge (3).png")
const SHIP_SMALL_SAIL_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/sailSmall (4).png")
const SHIP_MAST_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/pole.png")
const SHIP_CREW_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/crew (3).png")
const SHIP_CREW_ALT_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/crew (5).png")
const SHIP_FLAG_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/flag (3).png")
const SHIP_FLAG_ALT_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/flag (6).png")
const SHIP_CANNON_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/cannonMobile.png")
const SHIP_WOOD_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/wood (2).png")
const SHIP_NEST_TEXTURE := preload("res://kenney/kenney_pirate-pack/PNG/Default size/Ship parts/nest.png")
const SMOKE_TEXTURE := preload("res://kenney/kenney_smoke-particles/PNG/Black smoke/blackSmoke10.png")

# ====================================
# SKETCH TOWN (kenney_sketch-town)
# ====================================
const SKETCH_GRASS_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_center_S.png")
const SKETCH_PATH_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_path_S.png")
const SKETCH_PATH_CROSS_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_pathCrossing_S.png")
const SKETCH_PATH_CORNER_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_pathCorner_S.png")
const SKETCH_PATH_END_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_pathEndSquare_S.png")
const SKETCH_RIVER_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_river_S.png")
const SKETCH_RIVER_BEND_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_riverBend_S.png")
const SKETCH_RIVER_BRIDGE_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/grass_riverBridge_S.png")
const SKETCH_BUILDING_DOOR_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/building_doorBeige_S.png")
const SKETCH_BUILDING_WINDOW_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/building_windowBeige_S.png")
const SKETCH_BUILDING_WINDOWS_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/building_windowsBeige_S.png")
const SKETCH_BUILDING_CENTER_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/building_centerBeige_S.png")
const SKETCH_BUILDING_CORNER_TEXTURE := preload("res://kenney/kenney_sketch-town/Tiles/building_cornerBeige_S.png")

# ====================================
# BLOCK PACK (kenney_block-pack)
# ====================================
const BLOCK_BOX_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/box.png")
const BLOCK_BOX_WIDE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/box_wide.png")
const BLOCK_CART_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/cart.png")
const BLOCK_CART_TOP_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/cart_top.png")
const BLOCK_CHARACTER_MAN_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/character_man.png")
const BLOCK_CHARACTER_WOMAN_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/character_woman.png")
const BLOCK_CHARACTER_HORSE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/character_horse.png")
const BLOCK_FENCE_SINGLE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/fence_single.png")
const BLOCK_FENCE_DOUBLE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/fence_double.png")
const BLOCK_BUSH_LARGE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/foliageBush_large.png")
const BLOCK_BUSH_SMALL_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/foliageBush_small.png")
const BLOCK_TREE_GREEN_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/foliageTree_green.png")
const BLOCK_TREE_ORANGE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/foliageTree_orange.png")
const BLOCK_MARKET_STALL_BLUE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/market_stallBlue.png")
const BLOCK_MARKET_STALL_RED_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/market_stallRed.png")
const BLOCK_TILE_BRIDGE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileBridge.png")
const BLOCK_TILE_WATER_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileWater_1.png")
const BLOCK_TILE_WOOD_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileWood_flat.png")
const BLOCK_BUILDING_SAND_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileBuilding_sand.png")
const BLOCK_BUILDING_STONE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileBuilding_stone.png")
const BLOCK_BUILDING_FRAME_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileBuilding_frame.png")
const BLOCK_BUILDING_ROOF_BLUE_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileBuilding_roofBlue.png")
const BLOCK_BUILDING_ROOF_RED_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/tileBuilding_roofRed.png")
const BLOCK_DOOR_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/door.png")
const BLOCK_WINDOW_TEXTURE := preload("res://kenney/kenney_block-pack/PNG/Default (64px)/detail_window.png")

# ====================================
# BOARD GAME (kenney_boardgame-pack)
# ====================================
const BOARD_CARD_BLUE_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Cards/cardBack_blue3.png")
const BOARD_CARD_RED_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Cards/cardBack_red3.png")
const BOARD_CARD_GREEN_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Cards/cardBack_green3.png")
const BOARD_CHIP_BLUE_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Chips/chipBlueWhite.png")
const BOARD_CHIP_GREEN_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Chips/chipGreenWhite.png")
const BOARD_CHIP_RED_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Chips/chipRedWhite.png")

# ====================================
# GAME ICONS (kenney_game-icons)
# ====================================
const GAME_ARROW_RIGHT_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/arrowRight.png")
const GAME_ARROW_UP_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/arrowUp.png")
const GAME_INFO_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/information.png")
const GAME_CHECK_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/checkmark.png")
const GAME_STAR_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/star.png")
const GAME_TARGET_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/target.png")

# ====================================
# SAMSUN PAPER CUTOUT (özel asset)
# ====================================
const SAMSUN_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/samsun/paper_terrain_island.svg")
const SAMSUN_PAPER_HARBOR_TEXTURE := preload("res://assets/art/world/samsun/paper_harbor_landmark.svg")
const SAMSUN_PAPER_TELEGRAPH_TEXTURE := preload("res://assets/art/world/samsun/paper_telegraph_landmark.svg")
const SAMSUN_PAPER_PEOPLE_TEXTURE := preload("res://assets/art/world/samsun/paper_people_plaza.svg")
const SAMSUN_PAPER_RIFT_TEXTURE := preload("res://assets/art/world/samsun/paper_rift_core.svg")
const SAMSUN_PAPER_MAIN_PATH_TEXTURE := preload("res://assets/art/world/samsun/paper_main_path.svg")
const SAMSUN_PAPER_CIVIC_CLUSTER_TEXTURE := preload("res://assets/art/world/samsun/paper_civic_cluster.svg")
const SAMSUN_PAPER_WAVE_GATE_TEXTURE := preload("res://assets/art/world/samsun/paper_wave_gate.svg")
const SAMSUN_PAPER_DISTANT_TOWN_TEXTURE := preload("res://assets/art/world/samsun/paper_distant_town.svg")
const SAMSUN_PAPER_HARBOR_WATER_TEXTURE := preload("res://assets/art/world/samsun/paper_harbor_water.svg")
const SAMSUN_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/samsun/paper_foreground_frame.svg")
const SAMSUN_PAPER_SIDE_PATHS_TEXTURE := preload("res://assets/art/world/samsun/paper_side_paths.svg")
const SAMSUN_PAPER_HARBOR_BOATS_TEXTURE := preload("res://assets/art/world/samsun/paper_harbor_boats.svg")
const SAMSUN_PAPER_SIGNAL_RIDGE_TEXTURE := preload("res://assets/art/world/samsun/paper_signal_ridge.svg")
const SAMSUN_PAPER_SKY_LIFE_TEXTURE := preload("res://assets/art/world/samsun/paper_sky_life.svg")
const SAMSUN_PAPER_DISCOVERY_PROPS_TEXTURE := preload("res://assets/art/world/samsun/paper_discovery_props.svg")
const SAMSUN_PAPER_COAST_DETAILS_TEXTURE := preload("res://assets/art/world/samsun/paper_coast_details.svg")
const SAMSUN_PAPER_ROUTE_BEADS_TEXTURE := preload("res://assets/art/world/samsun/paper_route_beads.svg")
const SAMSUN_PAPER_SAFE_CLEARINGS_TEXTURE := preload("res://assets/art/world/samsun/paper_safe_clearings.svg")
const SAMSUN_PAPER_VISTA_FLAGS_TEXTURE := preload("res://assets/art/world/samsun/paper_vista_flags.svg")
const SAMSUN_PAPER_SKYLINE_DEPTH_TEXTURE := preload("res://assets/art/world/samsun/paper_skyline_depth.svg")
const SAMSUN_PAPER_HARBOR_DOCK_PROPS_TEXTURE := preload("res://assets/art/world/samsun/paper_harbor_dock_props.svg")
const SAMSUN_PAPER_COASTAL_LIFE_TEXTURE := preload("res://assets/art/world/samsun/paper_coastal_life.svg")
const SAMSUN_PAPER_SKY_SAMSUN_TEXTURE := preload("res://assets/art/world/samsun/paper_sky_samsun.svg")
const SAMSUN_PAPER_MAP_COMPASS_TEXTURE := preload("res://assets/art/world/samsun/paper_map_compass.svg")

# ====================================
# ROOM PAPER CUTOUT (özel asset)
# ====================================
const ROOM_PAPER_WALL_TEXTURE := preload("res://assets/art/world/room/paper_wall_window.svg")
const ROOM_PAPER_STUDY_NOOK_TEXTURE := preload("res://assets/art/world/room/paper_study_nook.svg")
const ROOM_PAPER_FLOOR_RUG_TEXTURE := preload("res://assets/art/world/room/paper_floor_rug.svg")
const ROOM_PAPER_BOOK_PORTAL_TEXTURE := preload("res://assets/art/world/room/paper_book_portal.svg")
const ROOM_PAPER_SHELF_TEXTURE := preload("res://assets/art/world/room/paper_shelf.svg")
const ROOM_PAPER_BED_TEXTURE := preload("res://assets/art/world/room/paper_bed.svg")
const ROOM_PAPER_WALL_STORY_TEXTURE := preload("res://assets/art/world/room/paper_wall_story.svg")
const ROOM_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/room/paper_foreground_frame.svg")
const ROOM_PAPER_DESK_CLUTTER_TEXTURE := preload("res://assets/art/world/room/paper_desk_clutter.svg")
const ROOM_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/room/paper_terrain_room.svg")

# ====================================
# OPENING PAPER CUTOUT (özel asset)
# ====================================
const OPENING_PAPER_SKY_TEXTURE := preload("res://assets/art/world/opening/paper_sky_horizon.svg")
const OPENING_PAPER_BENCHMARK_TEXTURE := preload("res://assets/art/world/opening/paper_benchmark_world.svg")
const OPENING_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/opening/paper_terrain_island.svg")
const OPENING_PAPER_PATH_TEXTURE := preload("res://assets/art/world/opening/paper_main_path.svg")
const OPENING_PAPER_VILLAGE_TEXTURE := preload("res://assets/art/world/opening/paper_village_depth.svg")
const OPENING_PAPER_BOOK_GATE_TEXTURE := preload("res://assets/art/world/opening/paper_book_gate.svg")
const OPENING_PAPER_CLUE_STATIONS_TEXTURE := preload("res://assets/art/world/opening/paper_clue_stations.svg")
const OPENING_PAPER_FOREGROUND_TEXTURE := preload("res://assets/art/world/opening/paper_foreground_frame.svg")

# ====================================
# ANKARA PAPER CUTOUT (özel asset)
# ====================================
const ANKARA_PAPER_SKY_TEXTURE := preload("res://assets/art/world/ankara/paper_sky_ankara.svg")
const ANKARA_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/ankara/paper_terrain_ankara.svg")
const ANKARA_PAPER_MAIN_PATH_TEXTURE := preload("res://assets/art/world/ankara/paper_main_path.svg")
const ANKARA_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/ankara/paper_foreground_frame.svg")
const ANKARA_PAPER_MECLIS_LANDMARK_TEXTURE := preload("res://assets/art/world/ankara/paper_meclis_landmark.svg")

# ====================================
# SAKARYA PAPER CUTOUT (özel asset)
# ====================================
const SAKARYA_PAPER_SKY_TEXTURE := preload("res://assets/art/world/sakarya/paper_sky_sakarya.svg")
const SAKARYA_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/sakarya/paper_terrain_sakarya.svg")
const SAKARYA_PAPER_MAIN_PATH_TEXTURE := preload("res://assets/art/world/sakarya/paper_main_path.svg")
const SAKARYA_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/sakarya/paper_foreground_frame.svg")
const SAKARYA_PAPER_HQ_LANDMARK_TEXTURE := preload("res://assets/art/world/sakarya/paper_hq_landmark.svg")
const SAKARYA_PAPER_VICTORY_MARKER_TEXTURE := preload("res://assets/art/world/sakarya/paper_victory_marker.svg")

# ====================================
# FINAL PAPER CUTOUT (özel asset) — Zafer/Cumhuriyet
# ====================================
const FINAL_PAPER_SKY_TEXTURE := preload("res://assets/art/world/final/paper_sky_final.svg")
const FINAL_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/final/paper_terrain_final.svg")
const FINAL_PAPER_MAIN_PATH_TEXTURE := preload("res://assets/art/world/final/paper_main_path.svg")
const FINAL_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/final/paper_foreground_frame.svg")
const FINAL_PAPER_CUMHURIYET_LANDMARK_TEXTURE := preload("res://assets/art/world/final/paper_cumhuriyet_landmark.svg")
const FINAL_PAPER_VICTORY_ARCH_TEXTURE := preload("res://assets/art/world/final/paper_victory_arch.svg")

# ====================================
# PROCEDURAL ICON GENERATORS (P2-10)
# ====================================
# Bu fonksiyonlar overlay'lerde kullanılan ok ve yıldız ikonlarını
# runtime'da Image.create ile oluşturur (kenney placeholder yedeği).

static func _make_arrow_icon() -> Texture2D:
	"""32x32'lik renkli ok icon texture'i (kenney yedeği)."""
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	for y in 32:
		for x in 32:
			var row_center: float = 16.0 - (abs(y - 16) * 0.42)
			if abs(x - 16) <= row_center and row_center > 2.0:
				image.set_pixel(x, y, Color(0.05, 0.44, 0.56, 0.90))
	return ImageTexture.create_from_image(image)

static func _make_circle_icon(color: Color) -> Texture2D:
	"""32x32'lik yuvarlak icon texture'i (kenney yedeği)."""
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center := Vector2i(16, 16)
	for y in 32:
		for x in 32:
			if center.distance_squared_to(Vector2i(x, y)) <= 196:  # radius=14
				image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)

# Procedural icon sabitleri — overlay'lerde kullanılır
static var CONTINUE_ICON := _make_arrow_icon()
static var CHOICE_ICON := _make_arrow_icon()
static var STAR_TEXTURE := _make_circle_icon(Color(0.98, 0.82, 0.20))
static var BADGE_TEXTURE := _make_circle_icon(Color(0.95, 0.75, 0.28))
