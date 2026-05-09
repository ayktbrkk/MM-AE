extends Node2D

const ARDA_TEXTURE := preload("res://assets/art/characters/arda/char_arda_world.svg")
const EDA_TEXTURE := preload("res://assets/art/characters/eda/char_eda_world.svg")
const NOTE_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/notepad.svg")
const TALK_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/pawn_table.svg")
const PORTAL_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/flag_square.svg")
const DECISION_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/hand_card.svg")
const RESOURCE_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/token_add.svg")
const SUPPORT_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/structure_watchtower.svg")
const WAVE_ICON := preload("res://kenney/kenney_board-game-icons/Vector/Icons/hourglass.svg")
const BADGE_ICON := preload("res://kenney/kenney_medals/PNG/flat_medal3.png")
const CLOUD_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/cloud3.png")
const CLOUD_TEXTURE_ALT := preload("res://kenney/kenney_background-elements/PNG/cloud7.png")
const MOON_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/moon_full.png")
const TREE_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/tree01.png")
const TREE_TEXTURE_ALT := preload("res://kenney/kenney_background-elements/PNG/tree05.png")
const HOUSE_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/house_beige_front.png")
const HOUSE_TEXTURE_ALT := preload("res://kenney/kenney_background-elements/PNG/house_grey_side.png")
const FENCE_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/fence.png")
const BG_FLAT_HILLS_1_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/hills1.png")
const BG_FLAT_HILLS_2_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/hills2.png")
const BG_FLAT_MOUNTAIN_1_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/mountain1.png")
const BG_FLAT_MOUNTAIN_2_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/mountain2.png")
const BG_FLAT_POINTY_MOUNTAINS_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/pointy_mountains.png")
const BG_FLAT_HOUSE_SHORT_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/house_front_short.png")
const BG_FLAT_HOUSE_TALL_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/house_front_tall.png")
const BG_FLAT_TREE_03_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/tree03.png")
const BG_FLAT_TREE_08_TEXTURE := preload("res://kenney/kenney_background-elements/PNG/Flat/tree08.png")
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
const BOARD_CARD_BLUE_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Cards/cardBack_blue3.png")
const BOARD_CARD_RED_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Cards/cardBack_red3.png")
const BOARD_CARD_GREEN_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Cards/cardBack_green3.png")
const BOARD_CHIP_BLUE_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Chips/chipBlueWhite.png")
const BOARD_CHIP_GREEN_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Chips/chipGreenWhite.png")
const BOARD_CHIP_RED_TEXTURE := preload("res://kenney/kenney_boardgame-pack/PNG/Chips/chipRedWhite.png")
const GAME_ARROW_RIGHT_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/arrowRight.png")
const GAME_ARROW_UP_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/arrowUp.png")
const GAME_INFO_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/information.png")
const GAME_CHECK_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/checkmark.png")
const GAME_STAR_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/star.png")
const GAME_TARGET_TEXTURE := preload("res://kenney/kenney_game-icons/PNG/White/2x/target.png")
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
const ROOM_PAPER_WALL_TEXTURE := preload("res://assets/art/world/room/paper_wall_window.svg")
const ROOM_PAPER_STUDY_NOOK_TEXTURE := preload("res://assets/art/world/room/paper_study_nook.svg")
const ROOM_PAPER_FLOOR_RUG_TEXTURE := preload("res://assets/art/world/room/paper_floor_rug.svg")
const ROOM_PAPER_BOOK_PORTAL_TEXTURE := preload("res://assets/art/world/room/paper_book_portal.svg")
const ROOM_PAPER_SHELF_TEXTURE := preload("res://assets/art/world/room/paper_shelf.svg")
const ROOM_PAPER_BED_TEXTURE := preload("res://assets/art/world/room/paper_bed.svg")
const ROOM_PAPER_WALL_STORY_TEXTURE := preload("res://assets/art/world/room/paper_wall_story.svg")
const ROOM_PAPER_FOREGROUND_FRAME_TEXTURE := preload("res://assets/art/world/room/paper_foreground_frame.svg")
const ROOM_PAPER_DESK_CLUTTER_TEXTURE := preload("res://assets/art/world/room/paper_desk_clutter.svg")
const OPENING_PAPER_SKY_TEXTURE := preload("res://assets/art/world/opening/paper_sky_horizon.svg")
const OPENING_PAPER_BENCHMARK_TEXTURE := preload("res://assets/art/world/opening/paper_benchmark_world.svg")
const OPENING_PAPER_TERRAIN_TEXTURE := preload("res://assets/art/world/opening/paper_terrain_island.svg")
const OPENING_PAPER_PATH_TEXTURE := preload("res://assets/art/world/opening/paper_main_path.svg")
const OPENING_PAPER_VILLAGE_TEXTURE := preload("res://assets/art/world/opening/paper_village_depth.svg")
const OPENING_PAPER_BOOK_GATE_TEXTURE := preload("res://assets/art/world/opening/paper_book_gate.svg")
const OPENING_PAPER_CLUE_STATIONS_TEXTURE := preload("res://assets/art/world/opening/paper_clue_stations.svg")
const OPENING_PAPER_FOREGROUND_TEXTURE := preload("res://assets/art/world/opening/paper_foreground_frame.svg")

const WORLD_SIZE := Vector2(1600, 2200)
const PLAYER_SPEED := 430.0
const INTERACT_DISTANCE := 150.0
const POP_DEEP_TURQUOISE := Color(0.02, 0.47, 0.57)
const POP_TURQUOISE := Color(0.04, 0.67, 0.76)
# Artwork analizine göre güncellendi: #B82E1F (eski: 0.86, 0.05, 0.12)
const POP_CRIMSON := Color(0.72, 0.18, 0.12)
const POP_GOLD := Color(1.0, 0.70, 0.25)
const POP_CREAM := Color(1.0, 0.90, 0.66)
const RIFT_BLUE := Color(0.22, 0.78, 1.0)
const CEL_OUTLINE := Color(0.05, 0.07, 0.12)
const DECORATIVE_LABEL_ALPHA := 0.0
const DESIGN_DEEP_NAVY := Color("#20344F")
const DESIGN_WARM_APRICOT := Color("#E89863")
const DESIGN_WEATHERED_WALNUT := Color("#7A5A42")
const DESIGN_ROOM_FOREGROUND := Color("#1A2A3A")
const DESIGN_CREAM_PAPER := Color("#F5E8D3")

# Event index sabitleri - questions.gd EVENTS dizisine referans
const EVENT_STORY_ROOM_1 := 0
const EVENT_STORY_ROOM_2 := 1
const EVENT_STORY_SHIP := 2
const EVENT_DECISION_SAMSUN := 3
const EVENT_DECISION_HAVZA := 4
const EVENT_DECISION_AMASYA := 5
const EVENT_DECISION_KONGRE := 6
const EVENT_DECISION_ANKARA := 7

@onready var _questions := preload("res://assets/data/questions.gd")

# Modül referansları — child node'lar world.tscn içinde eklenecek
@onready var _state: Node = $WorldState
@onready var _builder: Node = $WorldBuilder
@onready var _marker: Node = $WorldMarker
@onready var _wave: Node = $WorldWave

@onready var props: Node2D = $Props
@onready var markers: Node2D = $Markers
@onready var foreground_props: Node2D = $ForegroundProps
@onready var player: Node2D = $Player
@onready var player_shadow: Polygon2D = $Player/PlayerShadow
@onready var player_sprite: Sprite2D = $Player/PlayerSprite
@onready var player_camera: Camera2D = $Player/Camera2D
@onready var companion: Node2D = $Companion
@onready var companion_shadow: Polygon2D = $Companion/CompanionShadow
@onready var companion_sprite: Sprite2D = $Companion/CompanionSprite
@onready var hud_bar = $CanvasLayer/HUD/HudBar
@onready var character_panel: PanelContainer = $CanvasLayer/HUD/CharacterPanel
@onready var character_content: VBoxContainer = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent
@onready var character_title: Label = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterTitle
@onready var character_text: Label = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/CharacterText
@onready var arda_button: Button = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/ArdaButton
@onready var eda_button: Button = $CanvasLayer/HUD/CharacterPanel/CharacterMargin/CharacterContent/EdaButton
@onready var interact_button: Button = $CanvasLayer/HUD/InteractButton
@onready var dream_overlay: ColorRect = $CanvasLayer/DreamOverlay
@onready var atmosphere_top_glow: ColorRect = $CanvasLayer/AtmosphereLayer/TopGlow
@onready var atmosphere_horizon_glow: ColorRect = $CanvasLayer/AtmosphereLayer/HorizonGlow
@onready var atmosphere_bottom_fog: ColorRect = $CanvasLayer/AtmosphereLayer/BottomFog
@onready var vignette_left: ColorRect = $CanvasLayer/AtmosphereLayer/VignetteLeft
@onready var vignette_right: ColorRect = $CanvasLayer/AtmosphereLayer/VignetteRight
@onready var rift_edge_left: ColorRect = $CanvasLayer/AtmosphereLayer/RiftEdgeLeft
@onready var rift_edge_right: ColorRect = $CanvasLayer/AtmosphereLayer/RiftEdgeRight
@onready var crimson_accent: ColorRect = $CanvasLayer/AtmosphereLayer/CrimsonAccent
@onready var dialogue_panel: PanelContainer = $CanvasLayer/HUD/DialoguePanel
@onready var dialogue_title: Label = $CanvasLayer/HUD/DialoguePanel/DialogueMargin/DialogueContent/DialogueTitle
@onready var dialogue_text: Label = $CanvasLayer/HUD/DialoguePanel/DialogueMargin/DialogueContent/DialogueText
@onready var dialogue_continue: Button = $CanvasLayer/HUD/DialoguePanel/DialogueMargin/DialogueContent/DialogueContinue
@onready var decision_overlay = $CanvasLayer/HUD/DecisionOverlay
@onready var dialogue_overlay = $CanvasLayer/HUD/DialogueOverlay
@onready var info_card_overlay = $CanvasLayer/HUD/InfoCardOverlay
@onready var chapter_transition_overlay = $CanvasLayer/HUD/ChapterTransitionOverlay

var hero_name := "Arda"
var panel_mode := "character"
var target_position := Vector2.ZERO
var has_target := false
var player_velocity := Vector2.ZERO
var elapsed_time := 0.0
var nearby_marker: Node2D
var selected_build_marker: Node2D
var current_dialogue_callback: Callable
var current_overlay_kind := ""
var ambient_top_alpha := 0.12
var ambient_horizon_alpha := 0.08
var ambient_fog_alpha := 0.10
var ambient_rift_edge_alpha := 0.04
var ambient_crimson_alpha := 0.04
var player_outline: Sprite2D
var companion_outline: Sprite2D
var player_accessory: Node2D
var companion_accessory: Node2D
var minimap_panel: PanelContainer
var minimap_marker_layer: Control
var minimap_player_dot: ColorRect
var minimap_target_dot: ColorRect
var minimap_title_label: Label
var minimap_marker_dots := {}
var route_panel: PanelContainer
var route_node_dots := {}
var route_node_labels := {}
var guidance_arrow: Node2D
var guidance_arrow_icon: Sprite2D
var guidance_arrow_label: Label
var companion_reaction_label: Label
var companion_reaction_spots: Array = []
var active_companion_reaction := ""
var samsun_goal_visuals := {}
var samsun_open_world_overview_time_left := 0.0

func _ready() -> void:
	# 1. State başlangıç değerleri (tüm modüllerin bağımlı olduğu temel veriler)
	_state.set_zone_item_total("units", 3)
	_state.set_zone_item_total("ship_clues", 2)
	_state.set_zone_item_total("havza_clues", 2)
	_state.set_zone_item_total("amasya_clues", 2)
	_state.set_zone_item_total("kongre_clues", 2)
	_state.increment_item_count("units", 0)
	_state.increment_item_count("ship_clues", 0)
	_state.increment_item_count("havza_clues", 0)
	_state.increment_item_count("amasya_clues", 0)
	_state.increment_item_count("kongre_clues", 0)

	# 2. Canvas / UI temel kurulum
	$CanvasLayer.layer = 10
	_apply_ui_styles()
	_build_minimap_hud()
	_build_guidance_arrow()
	_build_route_hud()
	_build_companion_reaction_label()

	# 3. Karakter görsel kurulum
	_build_character_choice_identity_row()
	_setup_character_outlines()
	_enforce_world_character_z_index()

	# 4. Modül kurulum: builder → marker → wave
	_builder.build_world("room", self)
	_marker.spawn_markers("room", self)
	_wave.setup(self)

	# 5. Sinyal bağlantıları
	_builder.goal_visual_registered.connect(_on_builder_goal_visual_registered)
	_connect_ui()

	# 6. Oyun başlangıcı — karakter seçimi
	_reset_panel_for_character_choice()
	_set_character_choice_visible(true)
	target_position = player.position
	_state.set_goal("unit", "Karakterini seç. Sonra odada dolaşıp ünite notlarını topla ve rüya yolculuğunu başlat.")
	_update_progress()

	# 7. Ses sistemi — varsayılan ortam müziği
	if ResourceLoader.exists("res://assets/audio/room_ambient.ogg"):
		AudioManager.play_bgm("room_ambient")

func _process(delta: float) -> void:
	elapsed_time += delta
	_animate_world_fx()
	_marker.animate_feedback(markers, elapsed_time, nearby_marker, _state.current_goal_kind)
	_animate_character_feedback()
	_update_samsun_camera_focus(delta)
	_update_minimap()
	_update_guidance_arrow()
	_update_route_hud()
	_update_companion_reaction()

func _physics_process(delta: float) -> void:
	if character_panel.visible or dialogue_panel.visible or decision_overlay.visible or dialogue_overlay.visible or info_card_overlay.visible:
		return

	_move_player(delta)
	_update_companion(delta)
	_update_nearby_marker()

func _unhandled_input(event: InputEvent) -> void:
	if character_panel.visible or dialogue_panel.visible or decision_overlay.visible or dialogue_overlay.visible or info_card_overlay.visible:
		return

	if event is InputEventScreenTouch and event.pressed:
		_set_target(get_global_mouse_position())
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_target(get_global_mouse_position())

func _connect_ui() -> void:
	arda_button.pressed.connect(_on_panel_button_pressed.bind("a"))
	eda_button.pressed.connect(_on_panel_button_pressed.bind("b"))
	interact_button.pressed.connect(_interact)
	dialogue_continue.pressed.connect(_close_dialogue)
	decision_overlay.choice_selected.connect(_on_decision_overlay_choice)
	dialogue_overlay.continue_pressed.connect(_close_dialogue)
	info_card_overlay.continue_pressed.connect(_close_dialogue)
	chapter_transition_overlay.transition_finished.connect(_on_transition_finished)

func _on_panel_button_pressed(choice: String) -> void:
	if panel_mode == "character":
		_choose_hero("eda" if choice == "b" else "arda")
	elif panel_mode == "support":
		_wave.build_support(choice)

func _on_decision_overlay_choice(context: String, choice: String) -> void:
	if context == "havza":
		_answer_havza_decision(choice)
	elif context == "amasya":
		_answer_amasya_decision(choice)
	elif context == "kongreler":
		_answer_kongre_decision(choice)
	else:
		_answer_samsun_decision(choice)

func _choose_hero(choice: String) -> void:
	_state.selected_character = choice
	_state.selected_character = choice
	hero_name = "Eda" if choice == "eda" else "Arda"
	var companion_name := "Arda" if choice == "eda" else "Eda"
	player_sprite.texture = EDA_TEXTURE if choice == "eda" else ARDA_TEXTURE
	companion_sprite.texture = ARDA_TEXTURE if choice == "eda" else EDA_TEXTURE
	_remove_duplicate_character_sprites()
	_sync_character_outline_textures()
	_free_character_choice_identity_row()
	_set_character_choice_visible(false)
	_show_dialogue(
		"Sınav Gecesi",
		"%s oyun oynamayı bırakıp kitabın sayfalarına bakar. %s de yanında durup hangi ünitelerden sorumlu olduklarını hatırlatır. Odada üç ünite notunu bul." % [hero_name, companion_name],
		Callable()
	)

func _reset_panel_for_character_choice() -> void:
	panel_mode = "character"
	character_title.text = "Kimin rüyasına girelim?"
	character_text.text = "Seçtiğin öğrenci sınav gecesi kitaptaki tarih dünyasına uyanacak."
	arda_button.text = "Arda ile başla"
	eda_button.text = "Eda ile başla"

func _build_character_choice_identity_row() -> void:
	if character_content.has_node("CharacterIdentityRow"):
		return

	var row := HBoxContainer.new()
	row.name = "CharacterIdentityRow"
	row.custom_minimum_size = Vector2(0, 204)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 24)
	character_content.add_child(row)
	character_content.move_child(row, arda_button.get_index())

	row.add_child(_create_character_identity_card("ArdaIdentityCard", "ARDA", "Cesur, Meraklı", ARDA_TEXTURE, Color(0.84, 0.40, 0.29, 0.40)))
	row.add_child(_create_character_identity_card("EdaIdentityCard", "EDA", "Akıllı, Sakin", EDA_TEXTURE, Color(0.26, 0.54, 0.53, 0.40)))

func _create_character_identity_card(card_name: String, character_name: String, descriptor: String, texture: Texture2D, accent: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = card_name
	card.custom_minimum_size = Vector2(0, 204)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.set_meta("identity_accent", accent)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 6)
	margin.add_child(column)

	var circle := PanelContainer.new()
	circle.name = "IdentityCircle"
	circle.custom_minimum_size = Vector2(118, 118)
	circle.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	circle.set_meta("identity_accent", accent)
	column.add_child(circle)

	var circle_margin := MarginContainer.new()
	circle_margin.add_theme_constant_override("margin_left", 12)
	circle_margin.add_theme_constant_override("margin_top", 12)
	circle_margin.add_theme_constant_override("margin_right", 12)
	circle_margin.add_theme_constant_override("margin_bottom", 12)
	circle.add_child(circle_margin)

	var portrait := TextureRect.new()
	portrait.name = "Portrait"
	portrait.texture = texture
	portrait.custom_minimum_size = Vector2(94, 94)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.set_meta("character_choice_portrait", true)
	circle_margin.add_child(portrait)

	var name_label := Label.new()
	name_label.name = "Name"
	name_label.text = character_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(0.13, 0.15, 0.20, 0.96))
	column.add_child(name_label)

	var descriptor_label := Label.new()
	descriptor_label.name = "Descriptor"
	descriptor_label.text = descriptor
	descriptor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	descriptor_label.add_theme_font_size_override("font_size", 20)
	descriptor_label.add_theme_color_override("font_color", Color(0.20, 0.26, 0.30, 0.78))
	column.add_child(descriptor_label)

	return card

func _free_character_choice_identity_row() -> void:
	var row := character_content.get_node_or_null("CharacterIdentityRow")
	if row == null:
		return
	for portrait in row.find_children("*", "TextureRect", true, false):
		portrait.queue_free()
	row.hide()
	row.queue_free()

func _build_room() -> void:
	_add_open_world_start_depth_pass()
	_add_open_world_start_asset_layer()
	_snap_room_characters_to_floor()
	_decorate_room()

func _add_rect(pos: Vector2, size: Vector2, color: Color, label_text := "") -> void:
	if color.a > 0.58 and size.x < WORLD_SIZE.x - 8.0 and size.y < WORLD_SIZE.y - 8.0:
		var outline := Polygon2D.new()
		outline.position = pos - Vector2(7, 7)
		outline.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.24)
		outline.z_index = -5
		outline.polygon = PackedVector2Array([
			Vector2.ZERO,
			Vector2(size.x + 14, 0),
			size + Vector2(14, 14),
			Vector2(0, size.y + 14),
		])
		props.add_child(outline)

	var polygon := Polygon2D.new()
	polygon.position = pos
	polygon.color = color
	polygon.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	props.add_child(polygon)

	if label_text != "":
		var label := Label.new()
		label.position = pos + Vector2(16, 14)
		label.text = label_text
		label.add_theme_font_size_override("font_size", 24)
		var label_alpha := 0.0 if _state.current_zone == "room" else 0.42
		label.add_theme_color_override("font_color", Color(1, 1, 1, label_alpha))
		props.add_child(label)

func _add_room_depth_pass() -> void:
	var floor_top_y := _get_room_floor_top_y()
	_add_room_rect(Vector2.ZERO, WORLD_SIZE, DESIGN_DEEP_NAVY, -10, "room.depth.wall")
	_add_room_floor_rect(floor_top_y)
	_add_room_rect(Vector2(980, 1200), Vector2(280, 120), DESIGN_WEATHERED_WALNUT, -8, "room.depth.desk_zone")
	_add_room_rect(Vector2(0, 0), Vector2(80, floor_top_y), DESIGN_ROOM_FOREGROUND, -7, "room.depth.bookshelf_silhouette")
	_add_room_bottom_rounded_rect(Vector2(WORLD_SIZE.x - 140, 270), Vector2(100, 200), 20.0, Color(DESIGN_ROOM_FOREGROUND.r, DESIGN_ROOM_FOREGROUND.g, DESIGN_ROOM_FOREGROUND.b, 0.60), -7, "room.depth.window_curtain")
	_add_room_lamp_glow(Vector2(860, 1278))

func _add_open_world_start_depth_pass() -> void:
	# Artwork analizine göre sıcak tonlara güncellendi (eski: #355D78 cool sky)
	# Referans: ilk sahne.png (%52 turuncu), sahne 1.png (%73 turuncu)
	_add_room_rect(Vector2(-220, -620), Vector2(WORLD_SIZE.x + 440, 650), Color("#ecdabe"), -21, "paperopening.depth.sky_overscan")
	_add_room_rect(Vector2(-220, WORLD_SIZE.y - 10), Vector2(WORLD_SIZE.x + 440, 640), Color("#F5E8D3"), -21, "paperopening.depth.paper_overscan")
	_add_room_rect(Vector2.ZERO, WORLD_SIZE, Color("#ecdabe"), -20, "paperopening.depth.sky")
	_add_room_rect(Vector2(0, 660), Vector2(WORLD_SIZE.x, 400), Color("#d1b996"), -19, "paperopening.depth.distant_hills")
	_add_room_rect(Vector2(0, 980), Vector2(WORLD_SIZE.x, 320), Color("#9a875c"), -18, "paperopening.depth.mid_ground")
	_add_room_rect(Vector2(0, 1240), Vector2(WORLD_SIZE.x, 440), Color("#685934"), -17, "paperopening.depth.near_ground")
	_add_room_rect(Vector2(0, 1530), Vector2(WORLD_SIZE.x, 670), Color("#F5E8D3"), -17, "paperopening.depth.paper_base")
	_add_room_rect(Vector2(0, 950), Vector2(WORLD_SIZE.x, 8), Color("#F5E8D3"), -16, "paperopening.depth.horizon_cut_1")
	_add_room_rect(Vector2(0, 1220), Vector2(WORLD_SIZE.x, 8), Color("#ecdec8"), -16, "paperopening.depth.horizon_cut_2")
	_add_soft_blob(Vector2(1230, 320), Vector2(220, 220), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.18), 24, 0.02, false, -16)
	_add_soft_blob(Vector2(760, 1160), Vector2(520, 320), Color(0.96, 0.91, 0.83, 0.14), 24, 0.04, false, -16)
	_add_soft_blob(Vector2(540, 800), Vector2(300, 180), Color(0.85, 0.72, 0.52, 0.08), 24, 0.03, false, -15)

func _add_room_polygon(pos: Vector2, points: PackedVector2Array, color: Color, z_index: int, slot_id := "") -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.position = pos
	polygon.polygon = points
	polygon.color = color
	polygon.z_index = z_index
	if slot_id != "":
		polygon.set_meta("asset_slot", slot_id)
	props.add_child(polygon)
	return polygon

func _get_room_floor_top_y() -> float:
	return WORLD_SIZE.y * 0.45

func _add_room_rect(pos: Vector2, size: Vector2, color: Color, z_index: int, slot_id := "") -> Polygon2D:
	return _add_room_polygon(pos, PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		Vector2(size.x, size.y),
		Vector2(0, size.y),
	]), color, z_index, slot_id)

func _add_room_floor_rect(floor_top_y: float) -> void:
	var floor_height := WORLD_SIZE.y - floor_top_y
	_add_room_rect(Vector2(0, floor_top_y), Vector2(WORLD_SIZE.x, floor_height), DESIGN_WARM_APRICOT, -9, "room.depth.floor_rect")
	_add_room_rect(Vector2(0, floor_top_y), Vector2(WORLD_SIZE.x, 4), DESIGN_WEATHERED_WALNUT, -8, "room.depth.floor_wall_edge")

func _add_room_bottom_rounded_rect(pos: Vector2, size: Vector2, radius: float, color: Color, z_index: int, slot_id := "") -> Polygon2D:
	var r: float = min(radius, min(size.x, size.y) * 0.5)
	var points := PackedVector2Array([
		Vector2(0, 0),
		Vector2(size.x, 0),
		Vector2(size.x, size.y - r),
	])
	for step in range(1, 7):
		var t := float(step) / 6.0
		var angle: float = lerp(0.0, PI * 0.5, t)
		points.append(Vector2(size.x - r + cos(angle) * r, size.y - r + sin(angle) * r))
	points.append(Vector2(r, size.y))
	for step in range(1, 7):
		var t := float(step) / 6.0
		var angle: float = lerp(PI * 0.5, PI, t)
		points.append(Vector2(r + cos(angle) * r, size.y - r + sin(angle) * r))
	points.append(Vector2(0, 0))
	return _add_room_polygon(pos, points, color, z_index, slot_id)

func _add_room_lamp_glow(center: Vector2) -> void:
	var glow_color := Color("#F5E0A0")
	_add_room_glow_ellipse(center, Vector2(120, 120), Color(glow_color.r, glow_color.g, glow_color.b, 0.08))
	_add_room_glow_ellipse(center, Vector2(80, 80), Color(glow_color.r, glow_color.g, glow_color.b, 0.20))

func _add_room_paper_asset_layer() -> void:
	_add_paper_cutout_asset(ROOM_PAPER_WALL_TEXTURE, Vector2(800, 410), Vector2(1.0, 1.0), Color(1, 1, 1, 0.86), -6, "paperroom.wall_window", Vector2.ZERO, -2.0)
	_add_paper_cutout_asset(ROOM_PAPER_WALL_STORY_TEXTURE, Vector2(735, 605), Vector2(1.0, 1.0), Color(1, 1, 1, 0.82), -5, "paperroom.wall_story", Vector2.ZERO, -1.0)
	_add_paper_cutout_asset(ROOM_PAPER_SHELF_TEXTURE, Vector2(214, 1070), Vector2(0.98, 0.98), Color(1, 1, 1, 0.90), -5, "paperroom.shelf", Vector2.ZERO, 1.0)
	_add_paper_cutout_asset(ROOM_PAPER_BED_TEXTURE, Vector2(380, 1665), Vector2(1.0, 1.0), Color(1, 1, 1, 0.92), -3, "paperroom.bed", Vector2.ZERO, 2.0)
	_add_paper_cutout_asset(ROOM_PAPER_FLOOR_RUG_TEXTURE, Vector2(690, 1425), Vector2(1.0, 1.0), Color(1, 1, 1, 0.82), -4, "paperroom.floor_rug", Vector2.ZERO, 2.0)
	_add_paper_cutout_asset(ROOM_PAPER_STUDY_NOOK_TEXTURE, Vector2(1135, 1268), Vector2(0.94, 0.94), Color(1, 1, 1, 0.92), -1, "paperroom.study_nook", Vector2.ZERO, 3.0)
	_add_paper_cutout_asset(ROOM_PAPER_DESK_CLUTTER_TEXTURE, Vector2(1090, 1252), Vector2(0.92, 0.92), Color(1, 1, 1, 0.95), 0, "paperroom.desk_clutter", Vector2.ZERO, 4.0)
	_add_paper_cutout_asset(ROOM_PAPER_BOOK_PORTAL_TEXTURE, Vector2(1180, 1250), Vector2(0.82, 0.82), Color(1, 1, 1, 0.95), 1, "paperroom.book_portal", Vector2(1.2, 0.2), 4.0)
	_add_foreground_paper_cutout_asset(ROOM_PAPER_FOREGROUND_FRAME_TEXTURE, Vector2(800, 1810), Vector2(1.0, 1.0), Color(1, 1, 1, 0.88), 6, "paperroom.foreground_frame", 10.0)

func _add_open_world_start_asset_layer() -> void:
	_add_paper_cutout_asset(OPENING_PAPER_BENCHMARK_TEXTURE, Vector2(800, 1130), Vector2(1.09, 1.09), Color(1, 1, 1, 0.96), -14, "paperopening.benchmark_world", Vector2.ZERO, -3.0)

func _add_room_glow_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var glow := Polygon2D.new()
	glow.position = center
	glow.color = color
	glow.z_index = 11
	var points := PackedVector2Array()
	for index in range(32):
		var angle := TAU * float(index) / 32.0
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	glow.polygon = points
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.material = material
	glow.set_meta("visual_fx", true)
	glow.set_meta("base_pos", center)
	glow.set_meta("base_alpha", color.a)
	glow.set_meta("drift", Vector2(0.0, 0.0))
	glow.set_meta("phase", 0.0)
	props.add_child(glow)

func _snap_room_characters_to_floor() -> void:
	var opening_ground_y := WORLD_SIZE.y * 0.55
	player.position = Vector2(930, opening_ground_y - _get_sprite_half_height(player_sprite))
	companion.position = Vector2(800, opening_ground_y - _get_sprite_half_height(companion_sprite))
	_enforce_world_character_z_index()

func _get_sprite_half_height(sprite: Sprite2D) -> float:
	if sprite.texture == null:
		return 0.0
	return sprite.texture.get_height() * abs(sprite.scale.y) * 0.5

func _enforce_world_character_z_index() -> void:
	player.z_index = 0
	companion.z_index = 0
	player_sprite.z_index = 0
	companion_sprite.z_index = 0
	player_shadow.z_index = -1
	companion_shadow.z_index = -1
	if player_outline != null:
		player_outline.z_index = -1
	if companion_outline != null:
		companion_outline.z_index = -1
	if player_accessory != null:
		player_accessory.z_index = 1
	if companion_accessory != null:
		companion_accessory.z_index = 1

func _add_crimson_flag(pos: Vector2, scale_value := 1.0, to_foreground := true) -> void:
	var pole := Polygon2D.new()
	pole.position = pos
	pole.color = Color(0.18, 0.16, 0.14, 0.92)
	pole.z_index = 10
	pole.polygon = PackedVector2Array([
		Vector2(-4, -72) * scale_value,
		Vector2(4, -72) * scale_value,
		Vector2(4, 54) * scale_value,
		Vector2(-4, 54) * scale_value,
	])
	var flag := Polygon2D.new()
	flag.position = pos + Vector2(6, -64) * scale_value
	flag.color = Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.92)
	flag.z_index = 11
	flag.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(82, 10) * scale_value,
		Vector2(74, 52) * scale_value,
		Vector2(0, 42) * scale_value,
	])
	var shine := Polygon2D.new()
	shine.position = pos + Vector2(18, -46) * scale_value
	shine.color = Color(1.0, 0.80, 0.70, 0.34)
	shine.z_index = 12
	shine.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(34, 4) * scale_value,
		Vector2(30, 10) * scale_value,
		Vector2(-2, 7) * scale_value,
	])
	if to_foreground:
		foreground_props.add_child(pole)
		foreground_props.add_child(flag)
		foreground_props.add_child(shine)
	else:
		props.add_child(pole)
		props.add_child(flag)
		props.add_child(shine)

func _add_rift_shard(pos: Vector2, size: Vector2, color: Color, phase: float) -> void:
	var shard := Polygon2D.new()
	shard.position = pos
	shard.color = color
	shard.z_index = 12
	shard.polygon = PackedVector2Array([
		Vector2(0, -size.y * 0.5),
		Vector2(size.x * 0.44, 0),
		Vector2(0, size.y * 0.5),
		Vector2(-size.x * 0.44, 0),
	])
	shard.set_meta("visual_fx", true)
	shard.set_meta("base_pos", pos)
	shard.set_meta("base_alpha", color.a)
	shard.set_meta("drift", Vector2(12.0, 18.0))
	shard.set_meta("phase", phase)
	foreground_props.add_child(shard)

func _add_rift_shard_cluster(center: Vector2, count := 7, radius := 160.0) -> void:
	for index in range(count):
		var angle := TAU * float(index) / float(max(count, 1))
		var offset := Vector2(cos(angle) * radius, sin(angle) * radius * 0.62)
		var alpha := 0.18 + float(index % 3) * 0.04
		_add_rift_shard(center + offset, Vector2(26 + (index % 2) * 10, 70 + (index % 3) * 12), Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, alpha), float(index) * 0.61)

func _add_soft_blob(center: Vector2, radius: Vector2, color: Color, point_count := 18, wobble := 0.08, to_foreground := false, z_index := -4) -> void:
	var blob := Polygon2D.new()
	blob.position = center
	blob.color = color
	blob.z_index = z_index
	var points := PackedVector2Array()
	for index in range(point_count):
		var angle := TAU * float(index) / float(point_count)
		var wave := 1.0 + (sin(float(index) * 1.73) * wobble) + (cos(float(index) * 0.91) * wobble * 0.55)
		points.append(Vector2(cos(angle) * radius.x, sin(angle) * radius.y) * wave)
	blob.polygon = points
	if to_foreground:
		foreground_props.add_child(blob)
	else:
		props.add_child(blob)

func _add_paper_shadow(center: Vector2, radius: Vector2, alpha := 0.20, to_foreground := false) -> void:
	_add_soft_blob(center + Vector2(0, 22), radius, Color(0.03, 0.05, 0.08, alpha), 18, 0.05, to_foreground, -3)

func _add_path_ribbon(points: Array, width: float, color: Color, z_index := -2) -> void:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.z_index = z_index
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	for point in points:
		line.add_point(point)
	props.add_child(line)

func _add_light_pool(center: Vector2, radius: Vector2, color: Color, to_foreground := false) -> void:
	_add_soft_blob(center, radius, color, 20, 0.10, to_foreground, 4 if to_foreground else -1)

func _add_water_glints(start: Vector2, count: int, step: Vector2, color: Color) -> void:
	for index in range(count):
		var glint := Line2D.new()
		glint.width = 5.0 + float(index % 3)
		glint.default_color = color
		glint.z_index = -1
		var base := start + (step * index)
		glint.add_point(base)
		glint.add_point(base + Vector2(70 + (index % 2) * 34, -8 + (index % 3) * 6))
		props.add_child(glint)

func _add_story_banner(pos: Vector2, size: Vector2, fill: Color, accent: Color, text: String) -> void:
	_add_paper_shadow(pos + (size * 0.5), Vector2(size.x * 0.56, size.y * 0.40), 0.18, true)
	_add_soft_blob(pos + (size * 0.5), Vector2(size.x * 0.52, size.y * 0.36), fill, 16, 0.04, true, 8)
	var stripe := Polygon2D.new()
	stripe.position = pos + Vector2(size.x * 0.18, size.y * 0.56)
	stripe.color = accent
	stripe.z_index = 9
	stripe.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x * 0.64, 0),
		Vector2(size.x * 0.64, 10),
		Vector2.ZERO + Vector2(0, 10),
	])
	foreground_props.add_child(stripe)
	var label := Label.new()
	label.position = pos + Vector2(size.x * 0.12, size.y * 0.22)
	label.custom_minimum_size = Vector2(size.x * 0.76, size.y * 0.46)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.18, 0.18, 0.24, 0.92))
	label.z_index = 10
	foreground_props.add_child(label)

func _add_asset_slot_prop(slot_id: String, pos: Vector2, size: Vector2, fill: Color, accent: Color, label_text := "", to_foreground := false) -> Node2D:
	var root := Node2D.new()
	root.name = slot_id.replace(".", "_")
	root.position = pos
	root.set_meta("asset_slot", slot_id)
	root.set_meta("replacement_ready", true)
	root.z_index = 7 if to_foreground else -1

	var shadow := Polygon2D.new()
	shadow.position = Vector2(8, 14)
	shadow.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.24)
	shadow.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	root.add_child(shadow)

	var outline := Polygon2D.new()
	outline.position = Vector2(-5, -5)
	outline.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.54)
	outline.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x + 10, 0),
		Vector2(size.x + 10, size.y + 10),
		Vector2(0, size.y + 10),
	])
	root.add_child(outline)

	var body := Polygon2D.new()
	body.color = fill
	body.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		size,
		Vector2(0, size.y),
	])
	root.add_child(body)

	var accent_band := Polygon2D.new()
	accent_band.position = Vector2(0, size.y * 0.62)
	accent_band.color = accent
	accent_band.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0),
		Vector2(size.x, max(8.0, size.y * 0.12)),
		Vector2(0, max(8.0, size.y * 0.12)),
	])
	root.add_child(accent_band)

	var highlight := Polygon2D.new()
	highlight.position = Vector2(size.x * 0.12, size.y * 0.12)
	highlight.color = Color(1, 1, 1, 0.20)
	highlight.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x * 0.48, 0),
		Vector2(size.x * 0.42, max(8.0, size.y * 0.10)),
		Vector2(0, max(8.0, size.y * 0.12)),
	])
	root.add_child(highlight)

	if label_text != "":
		var label := Label.new()
		label.position = Vector2(size.x * 0.08, size.y * 0.24)
		label.custom_minimum_size = Vector2(size.x * 0.84, size.y * 0.34)
		label.text = label_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(0.12, 0.13, 0.17, DECORATIVE_LABEL_ALPHA))
		root.add_child(label)

	if to_foreground:
		foreground_props.add_child(root)
	else:
		props.add_child(root)
	return root

func _add_decorative_speckles(area: Rect2, color: Color, count := 14, to_foreground := false) -> void:
	for index in range(count):
		var x := area.position.x + fmod(float(index * 137), area.size.x)
		var y := area.position.y + fmod(float(index * 89), area.size.y)
		var radius := 4.0 + float(index % 3) * 2.0
		_add_soft_blob(Vector2(x, y), Vector2(radius, radius * 0.76), color, 10, 0.05, to_foreground, -1)

func _add_toy_world_frame(accent: Color, glow: Color) -> void:
	_add_soft_blob(Vector2(180, 310), Vector2(220, 160), glow, 18, 0.10)
	_add_soft_blob(Vector2(1420, 360), Vector2(190, 140), glow.darkened(0.12), 18, 0.10)
	_add_soft_blob(Vector2(230, 1900), Vector2(260, 130), accent, 18, 0.08)
	_add_soft_blob(Vector2(1360, 1840), Vector2(240, 150), accent.lightened(0.10), 18, 0.08)

func _add_sprite_prop(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, to_foreground := false) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = 5 if to_foreground else -2
	if to_foreground:
		foreground_props.add_child(sprite)
	else:
		props.add_child(sprite)

func _add_paper_cutout_asset(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, z_index: int, slot_id := "", drift := Vector2.ZERO, parallax_strength := 0.0) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = z_index
	sprite.set_meta("paperworld_asset", true)
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.011 + pos.y * 0.017, TAU))
	sprite.set_meta("bob_amount", 0.9)
	if drift != Vector2.ZERO:
		sprite.set_meta("paper_drift", drift)
	if parallax_strength != 0.0:
		sprite.set_meta("paper_parallax_strength", parallax_strength)
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("replacement_ready", true)
	props.add_child(sprite)
	return sprite

func _add_foreground_paper_cutout_asset(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, z_index: int, slot_id := "", parallax_strength := 0.0) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = z_index
	sprite.set_meta("paperworld_asset", true)
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.013 + pos.y * 0.019, TAU))
	sprite.set_meta("bob_amount", 0.55)
	if parallax_strength != 0.0:
		sprite.set_meta("paper_parallax_strength", parallax_strength)
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("replacement_ready", true)
	foreground_props.add_child(sprite)
	return sprite

func _add_backdrop_prop(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, z_index := -6, slot_id := "") -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = z_index
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.07 + pos.y * 0.03, TAU))
	sprite.set_meta("bob_amount", 1.0)
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("kenney_fallback", true)
	props.add_child(sprite)
	return sprite

func _add_backdrop_band(textures: Array, y: float, scale_value: Vector2, tint: Color, slot_prefix: String, z_index := -6) -> void:
	var x_positions := [220.0, 600.0, 980.0, 1360.0]
	for index in range(x_positions.size()):
		var texture: Texture2D = textures[index % textures.size()]
		_add_backdrop_prop(texture, Vector2(x_positions[index], y + float(index % 2) * 24.0), scale_value, tint, z_index, "%s.%02d" % [slot_prefix, index])

func _add_distant_town_band(y: float, tint: Color, slot_prefix: String) -> void:
	_add_backdrop_prop(BG_FLAT_HOUSE_SHORT_TEXTURE, Vector2(330, y), Vector2(0.78, 0.78), tint, -5, "%s.house_short_a" % slot_prefix)
	_add_backdrop_prop(BG_FLAT_HOUSE_TALL_TEXTURE, Vector2(495, y - 20), Vector2(0.82, 0.82), tint, -5, "%s.house_tall_a" % slot_prefix)
	_add_backdrop_prop(BG_FLAT_HOUSE_SHORT_TEXTURE, Vector2(1110, y + 10), Vector2(0.74, 0.74), tint, -5, "%s.house_short_b" % slot_prefix)
	_add_backdrop_prop(BG_FLAT_HOUSE_TALL_TEXTURE, Vector2(1280, y - 18), Vector2(0.80, 0.80), tint, -5, "%s.house_tall_b" % slot_prefix)
	_add_backdrop_prop(BG_FLAT_TREE_03_TEXTURE, Vector2(225, y + 28), Vector2(0.62, 0.62), tint, -4, "%s.tree_a" % slot_prefix)
	_add_backdrop_prop(BG_FLAT_TREE_08_TEXTURE, Vector2(1370, y + 30), Vector2(0.60, 0.60), tint, -4, "%s.tree_b" % slot_prefix)

func _add_kenney_prop(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint := Color.WHITE, to_foreground := false, slot_id := "") -> Sprite2D:
	var target := foreground_props if to_foreground else props
	var base_z := 8 if to_foreground else -1

	var outline := Sprite2D.new()
	outline.texture = texture
	outline.position = pos
	outline.scale = scale_value * Vector2(1.10, 1.10)
	outline.modulate = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.34)
	outline.z_index = base_z - 1
	target.add_child(outline)

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = base_z
	if slot_id != "":
		sprite.set_meta("asset_slot", slot_id)
		sprite.set_meta("kenney_fallback", true)
	target.add_child(sprite)
	return sprite

func _add_kenney_building(pos: Vector2, scale_value: Vector2, roof: Texture2D, tint := Color.WHITE) -> void:
	_add_kenney_prop(BLOCK_BUILDING_SAND_TEXTURE, pos + Vector2(0, 42) * scale_value.y, scale_value, tint)
	_add_kenney_prop(BLOCK_BUILDING_FRAME_TEXTURE, pos + Vector2(0, 2) * scale_value.y, scale_value, tint)
	_add_kenney_prop(roof, pos + Vector2(0, -42) * scale_value.y, scale_value, tint)
	_add_kenney_prop(BLOCK_DOOR_TEXTURE, pos + Vector2(-22, 52) * scale_value, scale_value * Vector2(0.72, 0.72), tint, true)
	_add_kenney_prop(BLOCK_WINDOW_TEXTURE, pos + Vector2(34, 10) * scale_value, scale_value * Vector2(0.64, 0.64), tint, true)

func _add_kenney_npc(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint := Color.WHITE, slot_id := "", label_text := "") -> Node2D:
	var root := Node2D.new()
	root.position = pos
	root.z_index = 9
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x + pos.y, 360.0) * 0.017)
	root.set_meta("bob_amount", 3.0)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var shadow := Polygon2D.new()
	shadow.position = Vector2(0, 36) * scale_value
	shadow.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.18)
	shadow.polygon = PackedVector2Array([
		Vector2(-28, -7) * scale_value,
		Vector2(28, -7) * scale_value,
		Vector2(36, 4) * scale_value,
		Vector2(-36, 4) * scale_value,
	])
	root.add_child(shadow)

	var outline := Sprite2D.new()
	outline.texture = texture
	outline.scale = scale_value * Vector2(1.12, 1.12)
	outline.modulate = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.38)
	outline.z_index = 0
	root.add_child(outline)

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = 1
	root.add_child(sprite)

	if label_text != "":
		var label_bg := Polygon2D.new()
		label_bg.position = Vector2(-66, -76) * scale_value
		label_bg.color = Color(POP_CREAM.r, POP_CREAM.g, POP_CREAM.b, 0.78)
		label_bg.polygon = PackedVector2Array([
			Vector2.ZERO,
			Vector2(132, 0) * scale_value,
			Vector2(132, 38) * scale_value,
			Vector2(0, 38) * scale_value,
		])
		root.add_child(label_bg)

		var label := Label.new()
		label.position = Vector2(-58, -73) * scale_value
		label.custom_minimum_size = Vector2(116, 34) * scale_value
		label.text = label_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(0.15, 0.15, 0.18, DECORATIVE_LABEL_ALPHA))
		root.add_child(label)

	foreground_props.add_child(root)
	return root

func _add_strategy_token(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint := Color.WHITE, slot_id := "") -> void:
	var sprite := _add_kenney_prop(texture, pos, scale_value, tint, true, slot_id)
	sprite.set_meta("ambient_bob", true)
	sprite.set_meta("base_pos", pos)
	sprite.set_meta("phase", fmod(pos.x * 0.31 + pos.y * 0.17, TAU))
	sprite.set_meta("bob_amount", 5.0)

func _add_strategy_card(texture: Texture2D, pos: Vector2, scale_value: Vector2, tint: Color, label_text: String, slot_id := "") -> void:
	_add_paper_shadow(pos, Vector2(62, 86) * scale_value, 0.16, true)
	var card := _add_kenney_prop(texture, pos, scale_value, tint, true, slot_id)
	card.rotation_degrees = -4.0 + fmod(pos.x, 9.0)
	var label := Label.new()
	label.position = pos + Vector2(-70, 66) * scale_value
	label.custom_minimum_size = Vector2(140, 36) * scale_value
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.15, 0.16, 0.22, DECORATIVE_LABEL_ALPHA))
	label.z_index = 11
	foreground_props.add_child(label)

func _add_location_sign(title: String, subtitle: String, pos: Vector2, width: float, accent: Color, slot_id := "") -> void:
	var root := Node2D.new()
	root.position = pos
	root.z_index = 10
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x + pos.y, TAU))
	root.set_meta("bob_amount", 1.4)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var shadow := Polygon2D.new()
	shadow.position = Vector2(10, 16)
	shadow.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.24)
	shadow.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width, 0),
		Vector2(width, 92),
		Vector2(0, 92),
	])
	root.add_child(shadow)

	var outline := Polygon2D.new()
	outline.position = Vector2(-6, -6)
	outline.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.44)
	outline.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width + 12, 0),
		Vector2(width + 12, 104),
		Vector2(0, 104),
	])
	root.add_child(outline)

	var plate := Polygon2D.new()
	plate.color = Color(POP_CREAM.r, POP_CREAM.g, POP_CREAM.b, 0.92)
	plate.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width, 0),
		Vector2(width, 92),
		Vector2(0, 92),
	])
	root.add_child(plate)

	var stripe := Polygon2D.new()
	stripe.position = Vector2(0, 62)
	stripe.color = accent
	stripe.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width, 0),
		Vector2(width, 16),
		Vector2(0, 16),
	])
	root.add_child(stripe)

	var title_label := Label.new()
	title_label.position = Vector2(18, 12)
	title_label.custom_minimum_size = Vector2(width - 36, 34)
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color(0.13, 0.14, 0.18, 0.92))
	root.add_child(title_label)

	var subtitle_label := Label.new()
	subtitle_label.position = Vector2(18, 45)
	subtitle_label.custom_minimum_size = Vector2(width - 36, 24)
	subtitle_label.text = subtitle
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.18, 0.19, 0.23, 0.68))
	root.add_child(subtitle_label)

	foreground_props.add_child(root)

func _add_way_arrow(pos: Vector2, rotation: float, tint: Color, label_text := "", slot_id := "") -> void:
	var root := Node2D.new()
	root.position = pos
	root.rotation = rotation
	root.z_index = 10
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x * 0.27 + pos.y * 0.13, TAU))
	root.set_meta("bob_amount", 2.2)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var plate := Polygon2D.new()
	plate.color = Color(tint.r, tint.g, tint.b, 0.72)
	plate.polygon = PackedVector2Array([
		Vector2(-54, -34),
		Vector2(34, -34),
		Vector2(58, 0),
		Vector2(34, 34),
		Vector2(-54, 34),
	])
	root.add_child(plate)

	var icon := Sprite2D.new()
	icon.texture = GAME_ARROW_RIGHT_TEXTURE
	icon.scale = Vector2(0.55, 0.55)
	icon.modulate = Color(1, 1, 1, 0.92)
	icon.z_index = 1
	root.add_child(icon)
	foreground_props.add_child(root)

	if label_text != "":
		var label := Label.new()
		label.position = pos + Vector2(-88, 42)
		label.custom_minimum_size = Vector2(176, 30)
		label.text = label_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", Color(0.12, 0.14, 0.18, DECORATIVE_LABEL_ALPHA))
		label.z_index = 11
		foreground_props.add_child(label)

func _add_discovery_badge(texture: Texture2D, pos: Vector2, tint: Color, label_text: String, slot_id := "") -> void:
	_add_soft_blob(pos, Vector2(78, 54), Color(tint.r, tint.g, tint.b, 0.16), 14, 0.04, true, 7)
	var badge := _add_kenney_prop(texture, pos, Vector2(0.58, 0.58), Color(1, 1, 1, 0.86), true, slot_id)
	badge.set_meta("ambient_bob", true)
	badge.set_meta("base_pos", pos)
	badge.set_meta("phase", fmod(pos.x + pos.y, TAU))
	badge.set_meta("bob_amount", 4.0)
	var label := Label.new()
	label.position = pos + Vector2(-82, 50)
	label.custom_minimum_size = Vector2(164, 28)
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.12, 0.14, 0.18, DECORATIVE_LABEL_ALPHA))
	label.z_index = 11
	foreground_props.add_child(label)

func _add_breadcrumb_dot(texture: Texture2D, pos: Vector2, tint: Color, scale_value: float, slot_id := "") -> void:
	var root := Node2D.new()
	root.position = pos
	root.z_index = 8
	root.set_meta("ambient_bob", true)
	root.set_meta("base_pos", pos)
	root.set_meta("phase", fmod(pos.x * 0.19 + pos.y * 0.11, TAU))
	root.set_meta("bob_amount", 2.5)
	if slot_id != "":
		root.set_meta("asset_slot", slot_id)
		root.set_meta("kenney_fallback", true)

	var glow := Polygon2D.new()
	glow.color = Color(tint.r, tint.g, tint.b, 0.18)
	glow.polygon = PackedVector2Array([
		Vector2(-28, -18) * scale_value,
		Vector2(28, -18) * scale_value,
		Vector2(36, 0) * scale_value,
		Vector2(28, 18) * scale_value,
		Vector2(-28, 18) * scale_value,
		Vector2(-36, 0) * scale_value,
	])
	root.add_child(glow)

	var outline := Sprite2D.new()
	outline.texture = texture
	outline.scale = Vector2(scale_value * 0.46, scale_value * 0.46)
	outline.modulate = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.26)
	outline.z_index = 0
	root.add_child(outline)

	var icon := Sprite2D.new()
	icon.texture = texture
	icon.scale = Vector2(scale_value * 0.38, scale_value * 0.38)
	icon.modulate = Color(1, 1, 1, 0.90)
	icon.z_index = 1
	root.add_child(icon)
	foreground_props.add_child(root)

func _add_breadcrumb_trail(points: Array, texture: Texture2D, tint: Color, slot_prefix: String, spacing := 155.0, scale_value := 0.72) -> void:
	var dot_index := 0
	for index in range(points.size() - 1):
		var start: Vector2 = points[index]
		var finish: Vector2 = points[index + 1]
		var distance: float = start.distance_to(finish)
		var steps: int = max(2, int(distance / spacing))
		for step in range(1, steps):
			var t: float = float(step) / float(steps)
			var pos: Vector2 = start.lerp(finish, t)
			_add_breadcrumb_dot(texture, pos, tint, scale_value, "%s.%02d" % [slot_prefix, dot_index])
			dot_index += 1

func _build_minimap_hud() -> void:
	minimap_panel = PanelContainer.new()
	minimap_panel.name = "MiniMapPanel"
	minimap_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap_panel.offset_left = -310
	minimap_panel.offset_top = 270
	minimap_panel.offset_right = -28
	minimap_panel.offset_bottom = 558
	_add_panel_style(minimap_panel, Color(0.98, 0.94, 0.78, 0.86), Color(0.10, 0.25, 0.30, 0.92), 16)
	$CanvasLayer/HUD.add_child(minimap_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	minimap_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	minimap_title_label = Label.new()
	minimap_title_label.text = "Rota"
	minimap_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	minimap_title_label.add_theme_font_size_override("font_size", 21)
	minimap_title_label.add_theme_color_override("font_color", Color(0.10, 0.14, 0.18, 0.88))
	content.add_child(minimap_title_label)

	var map_frame := PanelContainer.new()
	map_frame.custom_minimum_size = Vector2(246, 208)
	_add_panel_style(map_frame, Color(0.08, 0.25, 0.30, 0.64), Color(1.0, 0.84, 0.42, 0.60), 12)
	content.add_child(map_frame)

	minimap_marker_layer = Control.new()
	minimap_marker_layer.custom_minimum_size = Vector2(220, 182)
	minimap_marker_layer.clip_contents = true
	map_frame.add_child(minimap_marker_layer)

	var horizon := ColorRect.new()
	horizon.color = Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.08)
	horizon.set_anchors_preset(Control.PRESET_FULL_RECT)
	minimap_marker_layer.add_child(horizon)

	minimap_target_dot = _make_minimap_dot(Color(1.0, 0.92, 0.38, 0.88), 16.0)
	minimap_target_dot.visible = false
	minimap_marker_layer.add_child(minimap_target_dot)

	minimap_player_dot = _make_minimap_dot(Color(1.0, 1.0, 1.0, 0.96), 18.0)
	minimap_marker_layer.add_child(minimap_player_dot)
	_refresh_minimap_markers()

func _make_minimap_dot(color: Color, size_value: float) -> ColorRect:
	var dot := ColorRect.new()
	dot.color = color
	dot.size = Vector2(size_value, size_value)
	dot.custom_minimum_size = Vector2(size_value, size_value)
	return dot

func _world_to_minimap(world_pos: Vector2) -> Vector2:
	var map_size := Vector2(220, 182)
	if minimap_marker_layer != null and minimap_marker_layer.size.x > 0.0 and minimap_marker_layer.size.y > 0.0:
		map_size = minimap_marker_layer.size
	return Vector2(
		clamp(world_pos.x / WORLD_SIZE.x, 0.0, 1.0) * map_size.x,
		clamp(world_pos.y / WORLD_SIZE.y, 0.0, 1.0) * map_size.y
	)

func _clear_minimap_markers() -> void:
	for dot in minimap_marker_dots.values():
		if is_instance_valid(dot):
			dot.queue_free()
	minimap_marker_dots.clear()

func _refresh_minimap_markers() -> void:
	if minimap_marker_layer == null:
		return
	_clear_minimap_markers()
	for marker in markers.get_children():
		if bool(marker.get_meta("collected", false)):
			continue
		var kind := String(marker.get_meta("kind", ""))
		var dot := _make_minimap_dot(_minimap_color(kind), 12.0 if kind != _state.current_goal_kind else 16.0)
		var pos := _world_to_minimap(marker.position)
		dot.position = pos - (dot.size * 0.5)
		dot.set_meta("marker_ref", marker)
		minimap_marker_layer.add_child(dot)
		minimap_marker_dots[marker.get_instance_id()] = dot
	minimap_marker_layer.move_child(minimap_target_dot, minimap_marker_layer.get_child_count() - 1)
	minimap_marker_layer.move_child(minimap_player_dot, minimap_marker_layer.get_child_count() - 1)
	_update_minimap()

func _update_minimap() -> void:
	if minimap_panel == null or minimap_marker_layer == null:
		return
	var hide_panel: bool = _state.current_zone == "room" or _state.current_zone == "ship" or _state.current_zone == "samsun_rift"
	minimap_panel.visible = not hide_panel
	if not minimap_panel.visible:
		return
	if minimap_title_label != null:
		minimap_title_label.text = _minimap_title()
	var player_pos := _world_to_minimap(player.position)
	minimap_player_dot.position = player_pos - (minimap_player_dot.size * 0.5)
	minimap_player_dot.color.a = 0.82 + (0.12 * sin(elapsed_time * 3.4))
	if has_target:
		var target_pos := _world_to_minimap(target_position)
		minimap_target_dot.position = target_pos - (minimap_target_dot.size * 0.5)
		minimap_target_dot.visible = true
	else:
		minimap_target_dot.visible = false
	for marker in markers.get_children():
		var key := marker.get_instance_id()
		if not minimap_marker_dots.has(key):
			continue
		var dot: ColorRect = minimap_marker_dots[key]
		if not is_instance_valid(dot):
			continue
		dot.visible = marker.visible and not bool(marker.get_meta("collected", false))
		if marker == nearby_marker:
			dot.scale = Vector2.ONE * (1.22 + 0.10 * sin(elapsed_time * 5.0))
		else:
			dot.scale = Vector2.ONE

func _minimap_color(kind: String) -> Color:
	match kind:
		"unit", "ship_clue", "havza_clue", "amasya_clue", "kongre_clue":
			return Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.90)
		"npc":
			return Color(POP_TURQUOISE.r, POP_TURQUOISE.g, POP_TURQUOISE.b, 0.86)
		"portal", "wave_start", "havza_wave", "amasya_wave", "kongre_wave":
			return Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.90)
		"decision", "havza_decision", "amasya_decision", "kongre_decision":
			return Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.90)
		"resource":
			return Color(0.64, 1.0, 0.42, 0.88)
		"build_spot":
			return Color(1.0, 0.70, 0.24, 0.88)
		_:
			return Color(1.0, 1.0, 1.0, 0.74)

func _minimap_title() -> String:
	match _state.current_zone:
		"ship":
			return "Bandırma Rotası"
		"samsun_rift":
			return "Samsun Haritası"
		"havza":
			return "Havza Haritası"
		"amasya":
			return "Amasya Haritası"
		"kongreler":
			return "Kongre Haritası"
		_:
			return "Oda Rotası"

func _spawn_reward_burst(center: Vector2, tint: Color, slot_prefix: String) -> void:
	for index in range(7):
		var angle := TAU * float(index) / 7.0
		var distance := 50.0 + float(index % 3) * 20.0
		var pos := center + Vector2(cos(angle), sin(angle)) * distance
		var texture := GAME_STAR_TEXTURE if index % 2 == 0 else GAME_TARGET_TEXTURE
		_add_breadcrumb_dot(texture, pos, tint, 0.58 + float(index % 2) * 0.10, "%s.%02d" % [slot_prefix, index])

func _build_guidance_arrow() -> void:
	guidance_arrow = Node2D.new()
	guidance_arrow.name = "GuidanceArrow"
	guidance_arrow.position = Vector2(0, -150)
	guidance_arrow.visible = false
	guidance_arrow.z_index = 20
	player.add_child(guidance_arrow)

	var plate := Polygon2D.new()
	plate.name = "GuidancePlate"
	plate.color = Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.62)
	plate.polygon = PackedVector2Array([
		Vector2(-46, -34),
		Vector2(46, -34),
		Vector2(56, 0),
		Vector2(46, 34),
		Vector2(-46, 34),
		Vector2(-56, 0),
	])
	guidance_arrow.add_child(plate)

	guidance_arrow_icon = Sprite2D.new()
	guidance_arrow_icon.texture = GAME_ARROW_UP_TEXTURE
	guidance_arrow_icon.scale = Vector2(0.62, 0.62)
	guidance_arrow_icon.modulate = Color(1, 1, 1, 0.94)
	guidance_arrow_icon.z_index = 1
	guidance_arrow.add_child(guidance_arrow_icon)

	guidance_arrow_label = Label.new()
	guidance_arrow_label.position = Vector2(-120, 44)
	guidance_arrow_label.custom_minimum_size = Vector2(240, 34)
	guidance_arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance_arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	guidance_arrow_label.add_theme_font_size_override("font_size", 20)
	guidance_arrow_label.add_theme_color_override("font_color", Color(0.10, 0.14, 0.18, 0.80))
	guidance_arrow.add_child(guidance_arrow_label)

func _build_companion_reaction_label() -> void:
	companion_reaction_label = Label.new()
	companion_reaction_label.name = "CompanionReaction"
	companion_reaction_label.position = Vector2(-185, -150)
	companion_reaction_label.custom_minimum_size = Vector2(370, 86)
	companion_reaction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	companion_reaction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	companion_reaction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	companion_reaction_label.add_theme_font_size_override("font_size", 21)
	companion_reaction_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.78, 0.94))
	companion_reaction_label.add_theme_color_override("font_shadow_color", Color(0.03, 0.05, 0.08, 0.62))
	companion_reaction_label.add_theme_constant_override("shadow_offset_x", 2)
	companion_reaction_label.add_theme_constant_override("shadow_offset_y", 2)
	companion_reaction_label.z_index = 35
	companion_reaction_label.visible = false
	companion.add_child(companion_reaction_label)

func _update_guidance_arrow() -> void:
	if guidance_arrow == null or guidance_arrow_icon == null:
		return
	if _state.current_zone == "samsun_rift":
		guidance_arrow.visible = false
		return
	var blocked: bool = character_panel.visible or dialogue_panel.visible or decision_overlay.visible or dialogue_overlay.visible or info_card_overlay.visible
	var marker: Node2D = _marker.get_guidance_marker(markers, _state.current_goal_kind)
	if blocked or marker == null:
		guidance_arrow.visible = false
		return
	var direction := marker.global_position - player.global_position
	var distance := direction.length()
	if distance < INTERACT_DISTANCE * 1.45:
		guidance_arrow.visible = false
		return
	guidance_arrow.visible = true
	guidance_arrow.scale = Vector2.ONE * (1.0 + 0.05 * sin(elapsed_time * 4.0))
	guidance_arrow_icon.rotation = direction.angle() + (PI * 0.5)
	guidance_arrow_label.text = String(marker.get_meta("title", "Hedef"))

func _build_route_hud() -> void:
	route_panel = PanelContainer.new()
	route_panel.name = "RoutePanel"
	route_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	route_panel.offset_left = 28
	route_panel.offset_top = 270
	route_panel.offset_right = 250
	route_panel.offset_bottom = 592
	_add_panel_style(route_panel, Color(0.98, 0.94, 0.78, 0.82), Color(0.12, 0.22, 0.26, 0.90), 16)
	$CanvasLayer/HUD.add_child(route_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	route_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	margin.add_child(content)

	var title := Label.new()
	title.text = "Yolculuk"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", Color(0.10, 0.14, 0.18, 0.88))
	content.add_child(title)

	for step in _route_steps():
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 9)
		content.add_child(row)

		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(22, 22)
		dot.size = Vector2(22, 22)
		row.add_child(dot)

		var label := Label.new()
		label.text = String(step["label"])
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 18)
		row.add_child(label)

		var area_key := String(step["area"])
		route_node_dots[area_key] = dot
		route_node_labels[area_key] = label
	_update_route_hud()

func _route_steps() -> Array:
	return [
		{"area": "room", "label": "Oda"},
		{"area": "ship", "label": "Bandırma"},
		{"area": "samsun_rift", "label": "Samsun"},
		{"area": "havza", "label": "Havza"},
		{"area": "amasya", "label": "Amasya"},
		{"area": "kongreler", "label": "Kongre"},
	]

func _route_index(area_key: String) -> int:
	var steps := _route_steps()
	for index in range(steps.size()):
		if String(steps[index]["area"]) == area_key:
			return index
	return 0

func _update_route_hud() -> void:
	if route_panel == null:
		return
	var hide_panel: bool = _state.current_zone == "room" or _state.current_zone == "samsun_rift"
	route_panel.visible = not hide_panel
	if not route_panel.visible:
		return
	var active_index := _route_index(_state.current_zone)
	for step in _route_steps():
		var area_key := String(step["area"])
		var index := _route_index(area_key)
		if not route_node_dots.has(area_key):
			continue
		var dot: ColorRect = route_node_dots[area_key]
		var label: Label = route_node_labels[area_key]
		if index < active_index:
			dot.color = Color(0.58, 0.92, 0.52, 0.88)
			label.add_theme_color_override("font_color", Color(0.12, 0.24, 0.18, 0.74))
		elif index == active_index:
			dot.color = Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.86 + 0.10 * sin(elapsed_time * 3.0))
			label.add_theme_color_override("font_color", Color(0.10, 0.14, 0.18, 0.92))
		else:
			dot.color = Color(0.28, 0.34, 0.38, 0.42)
			label.add_theme_color_override("font_color", Color(0.18, 0.20, 0.24, 0.44))

func _setup_character_outlines() -> void:
	player_outline = null
	companion_outline = null
	_remove_duplicate_character_sprites()
	player_accessory = _create_period_accessory(player, true)
	companion_accessory = _create_period_accessory(companion, false)
	_sync_character_outline_textures()

func _remove_duplicate_character_sprites() -> void:
	_remove_duplicate_character_sprites_in(self)

func _remove_duplicate_character_sprites_in(root: Node) -> void:
	for child in root.get_children():
		if child is Sprite2D:
			var sprite := child as Sprite2D
			var is_gameplay_character := sprite == player_sprite or sprite == companion_sprite
			var uses_character_texture := sprite.texture == ARDA_TEXTURE or sprite.texture == EDA_TEXTURE
			if uses_character_texture and not is_gameplay_character:
				sprite.queue_free()
				continue
		_remove_duplicate_character_sprites_in(child)

func _create_character_outline(parent: Node2D, sprite: Sprite2D, scale_boost: float, alpha: float) -> Sprite2D:
	var outline := Sprite2D.new()
	outline.name = "%sOutline" % sprite.name
	outline.texture = sprite.texture
	outline.scale = sprite.scale * scale_boost
	outline.modulate = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, alpha)
	outline.z_index = sprite.z_index - 1
	parent.add_child(outline)
	parent.move_child(outline, sprite.get_index())
	return outline

func _create_period_accessory(parent: Node2D, is_player: bool) -> Node2D:
	var accessory := Node2D.new()
	accessory.name = "PeriodAccessory"
	accessory.z_index = 4
	parent.add_child(accessory)

	var cap_outline := Polygon2D.new()
	cap_outline.position = Vector2(0, -74)
	cap_outline.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.72)
	cap_outline.polygon = PackedVector2Array([
		Vector2(-26, -6),
		Vector2(18, -12),
		Vector2(34, 2),
		Vector2(4, 12),
		Vector2(-30, 8),
	])
	accessory.add_child(cap_outline)

	var cap := Polygon2D.new()
	cap.position = Vector2(0, -76)
	cap.color = Color(0.16, 0.24, 0.34, 0.96) if is_player else Color(0.18, 0.38, 0.42, 0.96)
	cap.polygon = PackedVector2Array([
		Vector2(-22, -4),
		Vector2(14, -9),
		Vector2(28, 1),
		Vector2(2, 9),
		Vector2(-26, 6),
	])
	accessory.add_child(cap)

	var scarf_outline := Polygon2D.new()
	scarf_outline.position = Vector2(0, -24)
	scarf_outline.color = Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.68)
	scarf_outline.polygon = PackedVector2Array([
		Vector2(-26, -6),
		Vector2(24, -8),
		Vector2(28, 8),
		Vector2(-20, 14),
	])
	accessory.add_child(scarf_outline)

	var scarf := Polygon2D.new()
	scarf.position = Vector2(0, -25)
	scarf.color = Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.94) if is_player else Color(POP_DEEP_TURQUOISE.r, POP_DEEP_TURQUOISE.g, POP_DEEP_TURQUOISE.b, 0.94)
	scarf.polygon = PackedVector2Array([
		Vector2(-22, -4),
		Vector2(20, -6),
		Vector2(23, 6),
		Vector2(-18, 11),
	])
	accessory.add_child(scarf)
	return accessory

func _sync_character_outline_textures() -> void:
	if player_outline != null:
		player_outline.texture = player_sprite.texture
	if companion_outline != null:
		companion_outline.texture = companion_sprite.texture

func _add_sketch_tile(texture: Texture2D, pos: Vector2, tint := Color.WHITE, scale_value := Vector2(0.72, 0.72), to_foreground := false) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = scale_value
	sprite.modulate = tint
	sprite.z_index = 6 if to_foreground else -1
	if to_foreground:
		foreground_props.add_child(sprite)
	else:
		props.add_child(sprite)

func _add_sketch_strip(texture: Texture2D, start: Vector2, count: int, step: Vector2, tint := Color.WHITE, scale_value := Vector2(0.72, 0.72), to_foreground := false) -> void:
	for index in range(count):
		_add_sketch_tile(texture, start + (step * index), tint, scale_value, to_foreground)

func _add_havza_building(origin: Vector2, columns: int, front_texture: Texture2D, fill_texture: Texture2D, accent_texture: Texture2D, tint := Color.WHITE) -> void:
	_add_sketch_tile(SKETCH_BUILDING_CORNER_TEXTURE, origin, tint, Vector2(0.88, 0.88), true)
	for column in range(columns):
		var offset := Vector2(88 * (column + 1), 0)
		var texture := fill_texture if column < columns - 1 else front_texture
		_add_sketch_tile(texture, origin + offset, tint, Vector2(0.88, 0.88), true)
	_add_sketch_tile(accent_texture, origin + Vector2(88 * max(columns - 1, 0), -56), Color(1, 1, 1, 0.92), Vector2(0.74, 0.74), true)

func _add_ship_planks(start: Vector2, count: int, step_x: float, tint := Color.WHITE, scale_value := Vector2(0.68, 0.68), to_foreground := false) -> void:
	for index in range(count):
		_add_sprite_prop(SHIP_WOOD_TEXTURE, start + Vector2(step_x * index, 0), scale_value, tint, to_foreground)

func _add_light_mote(pos: Vector2, radius: float, color: Color, drift: Vector2) -> void:
	var mote := Polygon2D.new()
	var points := PackedVector2Array()
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	mote.position = pos
	mote.color = color
	mote.polygon = points
	mote.z_index = 7
	mote.set_meta("visual_fx", true)
	mote.set_meta("base_pos", pos)
	mote.set_meta("base_alpha", color.a)
	mote.set_meta("drift", drift)
	mote.set_meta("phase", float(foreground_props.get_child_count() % 19) * 0.47)
	foreground_props.add_child(mote)

func _add_mote_cluster(center: Vector2, color: Color, count := 6) -> void:
	for index in range(count):
		var angle := TAU * float(index) / float(max(count, 1))
		var offset := Vector2(cos(angle), sin(angle)) * (70.0 + (float(index % 3) * 34.0))
		var drift := Vector2(10.0 + float(index % 2) * 8.0, 7.0 + float(index % 3) * 5.0)
		_add_light_mote(center + offset, 8.0 + float(index % 3) * 2.0, color, drift)

func add_diorama_ground_blob(center: Vector2, radius: Vector2, fill: Color, edge: Color, slot_id := "") -> void:
	_add_soft_blob(center + Vector2(0, 34), radius * Vector2(1.05, 0.94), Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.18), 24, 0.08, false, -6)
	_add_soft_blob(center, radius * Vector2(1.03, 1.02), edge, 24, 0.09, false, -5)
	_add_soft_blob(center + Vector2(0, -8), radius, fill, 24, 0.08, false, -4)
	if slot_id != "":
		props.get_child(props.get_child_count() - 1).set_meta("asset_slot", slot_id)

func add_paper_path(points: Array, width: float, fill: Color, edge: Color, slot_id := "") -> void:
	_add_path_ribbon(points, width + 26.0, Color(CEL_OUTLINE.r, CEL_OUTLINE.g, CEL_OUTLINE.b, 0.15), -3)
	_add_path_ribbon(points, width + 12.0, edge, -2)
	_add_path_ribbon(points, width, fill, -1)
	if slot_id != "":
		props.get_child(props.get_child_count() - 1).set_meta("asset_slot", slot_id)

func add_foreground_frame(side: String, tint: Color, slot_id := "") -> void:
	var x := 120.0 if side == "left" else 1480.0
	var mirror := -1.0 if side == "right" else 1.0
	_add_soft_blob(Vector2(x, 1620), Vector2(240, 520), tint, 18, 0.12, true, 18)
	_add_soft_blob(Vector2(x + (80.0 * mirror), 1320), Vector2(140, 230), tint.lightened(0.08), 18, 0.10, true, 19)
	_add_sprite_prop(TREE_TEXTURE, Vector2(x + (54.0 * mirror), 1470), Vector2(0.96 * mirror, 0.96), Color(1, 1, 1, 0.30), true)
	_add_sprite_prop(TREE_TEXTURE_ALT, Vector2(x - (38.0 * mirror), 1760), Vector2(0.82 * mirror, 0.82), Color(1, 1, 1, 0.24), true)
	if slot_id != "":
		foreground_props.get_child(foreground_props.get_child_count() - 1).set_meta("asset_slot", slot_id)

func add_prop_cluster(center: Vector2, kind: String, slot_id := "") -> void:
	match kind:
		"harbor":
			var crate_a := _add_kenney_prop(BLOCK_BOX_TEXTURE, center + Vector2(-110, 76), Vector2(0.76, 0.76), Color(0.96, 0.82, 0.58, 0.72), false, "%s.crate_a" % slot_id)
			var crate_b := _add_kenney_prop(BLOCK_BOX_WIDE_TEXTURE, center + Vector2(-34, 94), Vector2(0.76, 0.76), Color(1.0, 0.86, 0.62, 0.70), false, "%s.crate_b" % slot_id)
			var water_tile := _add_kenney_prop(BLOCK_TILE_WATER_TEXTURE, center + Vector2(92, 62), Vector2(1.08, 0.86), Color(0.58, 0.98, 1.0, 0.62), false, "%s.water" % slot_id)
			crate_a.z_index = 0
			crate_b.z_index = 0
			water_tile.z_index = 0
		"telegraph":
			var fence := _add_kenney_prop(BLOCK_FENCE_DOUBLE_TEXTURE, center + Vector2(-86, 78), Vector2(0.82, 0.82), Color(1.0, 0.88, 0.62, 0.62), false, "%s.fence" % slot_id)
			var sign_post := _add_kenney_prop(BLOCK_TILE_WOOD_TEXTURE, center + Vector2(92, 70), Vector2(0.50, 0.72), Color(1.0, 0.82, 0.56, 0.68), false, "%s.sign_post" % slot_id)
			fence.z_index = 0
			sign_post.z_index = 0
		"people":
			var citizen_a := _add_kenney_npc(BLOCK_CHARACTER_MAN_TEXTURE, center + Vector2(-112, 88), Vector2(0.74, 0.74), Color(0.96, 0.94, 0.86, 0.58), "%s.citizen_a" % slot_id, "")
			var citizen_b := _add_kenney_npc(BLOCK_CHARACTER_WOMAN_TEXTURE, center + Vector2(108, 88), Vector2(-0.72, 0.72), Color(0.94, 1.0, 0.96, 0.58), "%s.citizen_b" % slot_id, "")
			citizen_a.z_index = 0
			citizen_b.z_index = 0
		"discovery":
			_add_asset_slot_prop(slot_id, center + Vector2(-70, -46), Vector2(140, 86), Color(0.98, 0.90, 0.62, 0.82), Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.36), "İz", true)
			_add_mote_cluster(center, Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.16), 4)

func add_historical_landmark(center: Vector2, kind: String, title: String, slot_id := "") -> void:
	var fill := Color(0.96, 0.88, 0.66, 0.84)
	var accent := Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.46)
	if kind == "harbor":
		fill = Color(0.78, 0.94, 1.0, 0.72)
		accent = Color(POP_DEEP_TURQUOISE.r, POP_DEEP_TURQUOISE.g, POP_DEEP_TURQUOISE.b, 0.62)
	elif kind == "telegraph":
		fill = Color(0.78, 0.90, 1.0, 0.72)
		accent = Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.50)
	elif kind == "people":
		fill = Color(1.0, 0.87, 0.56, 0.74)
		accent = Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.46)
	_add_asset_slot_prop(slot_id, center + Vector2(-88, -78), Vector2(176, 108), fill, accent, title, true)

func add_strategy_node(center: Vector2, title: String, accent: Color, slot_id := "") -> void:
	_add_soft_blob(center, Vector2(185, 126), Color(accent.r, accent.g, accent.b, 0.18), 22, 0.10, false, 0)
	_add_soft_blob(center, Vector2(94, 62), Color(1.0, 0.96, 0.76, 0.26), 18, 0.06, false, 1)
	var label_text := title
	if _state.current_zone == "samsun_rift" and title != "Milli İrade":
		label_text = ""
	_add_asset_slot_prop(slot_id, center + Vector2(-88, -58), Vector2(176, 116), Color(accent.r, accent.g, accent.b, 0.20), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.36), label_text, true)
	_add_mote_cluster(center, Color(accent.r, accent.g, accent.b, 0.13), 5)

func add_companion_reaction_spot(center: Vector2, radius: float, text: String, slot_id := "") -> void:
	companion_reaction_spots.append({
		"center": center,
		"radius": radius,
		"text": text,
		"slot_id": slot_id,
	})
	_add_soft_blob(center, Vector2(radius * 0.42, radius * 0.20), Color(1.0, 0.95, 0.66, 0.07), 16, 0.04, false, -1)

func _build_ship() -> void:
	_add_ship_room_plates()
	_decorate_ship()

func _build_havza_world() -> void:
	_add_rect(Vector2.ZERO, WORLD_SIZE, Color(0.10, 0.17, 0.13))
	_add_rect(Vector2(90, 170), Vector2(1420, 1840), Color(0.20, 0.28, 0.18))
	_add_rect(Vector2(180, 320), Vector2(1240, 1460), Color(0.30, 0.40, 0.24))
	_add_rect(Vector2(310, 1490), Vector2(290, 230), Color(0.18, 0.30, 0.34))
	_add_rect(Vector2(1020, 1440), Vector2(270, 250), Color(0.35, 0.30, 0.20))
	_add_rift_cloud(Vector2(790, 1100), 760, Color(0.95, 0.80, 0.26, 0.12))
	_add_rift_cloud(Vector2(790, 1100), 900, Color(0.28, 0.50, 0.42, 0.12))
	_decorate_havza()

func _build_amasya_world() -> void:
	_add_rect(Vector2.ZERO, WORLD_SIZE, Color(0.12, 0.15, 0.20))
	_add_rect(Vector2(90, 170), Vector2(1420, 1840), Color(0.22, 0.24, 0.30))
	_add_rect(Vector2(180, 280), Vector2(1240, 1580), Color(0.32, 0.34, 0.40))
	_add_rect(Vector2(300, 440), Vector2(980, 340), Color(0.46, 0.36, 0.26), "Toplanti Evi")
	_add_rect(Vector2(360, 1010), Vector2(860, 540), Color(0.40, 0.32, 0.24), "Karar Salonu")
	_add_rect(Vector2(260, 1660), Vector2(1040, 120), Color(0.55, 0.48, 0.34), "Bildiri Yolu")
	_add_rift_cloud(Vector2(810, 1120), 780, Color(0.64, 0.70, 0.95, 0.12))
	_add_rift_cloud(Vector2(810, 1120), 920, Color(0.95, 0.82, 0.40, 0.10))
	_decorate_amasya()

func _build_kongreler_world() -> void:
	_add_rect(Vector2.ZERO, WORLD_SIZE, Color(0.14, 0.14, 0.18))
	_add_rect(Vector2(80, 150), Vector2(1440, 1880), Color(0.24, 0.24, 0.30))
	_add_rect(Vector2(200, 300), Vector2(1200, 1500), Color(0.36, 0.34, 0.28))
	_add_rect(Vector2(300, 430), Vector2(1000, 300), Color(0.50, 0.40, 0.26), "Kongre Salonu")
	_add_rect(Vector2(260, 940), Vector2(1080, 540), Color(0.42, 0.32, 0.22), "Temsil Meydani")
	_add_rect(Vector2(340, 1620), Vector2(920, 120), Color(0.58, 0.50, 0.34), "Ortak Hedef Yolu")
	_add_rift_cloud(Vector2(800, 1080), 760, Color(0.95, 0.70, 0.42, 0.10))
	_add_rift_cloud(Vector2(800, 1080), 920, Color(0.70, 0.72, 0.92, 0.10))
	_decorate_kongreler()

func _decorate_room() -> void:
	# Sıcak gün batımı ışığı - sahne 1.png referansı (%73 turuncu)
	_add_soft_blob(Vector2(700, 600), Vector2(600, 400), Color(1.0, 0.76, 0.42, 0.06), 24, 0.02, true, 5)
	_add_soft_blob(Vector2(1180, 1320), Vector2(240, 170), Color(1.0, 0.84, 0.46, 0.10), 24, 0.03, true, 5)
	_add_soft_blob(Vector2(360, 1470), Vector2(170, 110), Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.08), 22, 0.03, true, 5)
	_add_soft_blob(Vector2(690, 1310), Vector2(190, 120), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.08), 22, 0.03, true, 5)
	# Sıcak ışık havuzu - merkez alan aydınlatması
	_add_light_pool(Vector2(800, 1100), Vector2(360, 180), Color(1.0, 0.78, 0.42, 0.08))
	# Altın tozu parçacıkları - rüya atmosferi
	_add_mote_cluster(Vector2(1180, 1320), Color(1.0, 0.84, 0.46, 0.13), 5)
	_add_mote_cluster(Vector2(720, 1300), Color(0.72, 0.92, 1.0, 0.10), 5)
	_add_mote_cluster(Vector2(500, 900), Color(1.0, 0.80, 0.50, 0.06), 8)
	_add_mote_cluster(Vector2(1100, 800), Color(0.92, 0.88, 0.70, 0.05), 6)
	# Yumuşak kenar ışığı - sıcak atmosfer katmanı
	_add_soft_blob(Vector2(400, 500), Vector2(250, 100), Color(0.92, 0.72, 0.50, 0.04), 24, 0.01, true, 4)
	_add_soft_blob(Vector2(1200, 500), Vector2(250, 100), Color(0.92, 0.72, 0.50, 0.04), 24, 0.01, true, 4)

func _decorate_ship() -> void:
	_add_toy_world_frame(Color(0.08, 0.24, 0.32, 0.22), Color(0.72, 0.88, 1.0, 0.09))
	_add_backdrop_band([BG_FLAT_MOUNTAIN_1_TEXTURE, BG_FLAT_MOUNTAIN_2_TEXTURE, BG_FLAT_POINTY_MOUNTAINS_TEXTURE], 540.0, Vector2(1.08, 1.08), Color(0.55, 0.86, 0.94, 0.16), "ship.horizon_mountains", -8)
	_add_location_sign("Bandırma", "Rotayı oku", Vector2(535, 280), 440.0, Color(POP_DEEP_TURQUOISE.r, POP_DEEP_TURQUOISE.g, POP_DEEP_TURQUOISE.b, 0.82), "ship.location_sign")
	_add_soft_blob(Vector2(1260, 350), Vector2(150, 150), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.24), 24, 0.02, false, -6)
	_add_soft_blob(Vector2(1260, 350), Vector2(245, 190), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.10), 24, 0.06, false, -7)
	_add_path_ribbon([Vector2(120, 920), Vector2(450, 900), Vector2(820, 910), Vector2(1460, 880)], 10.0, Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.16), -4)
	_add_light_pool(Vector2(830, 1260), Vector2(340, 140), Color(1.0, 0.78, 0.42, 0.13))
	_add_light_pool(Vector2(1160, 1300), Vector2(230, 460), Color(0.42, 0.76, 0.94, 0.12))
	_add_water_glints(Vector2(1090, 1120), 8, Vector2(12, 68), Color(0.78, 0.98, 1.0, 0.26))
	_add_rift_shard_cluster(Vector2(1210, 1120), 6, 160.0)
	_add_path_ribbon([Vector2(420, 650), Vector2(700, 860), Vector2(860, 1240), Vector2(1160, 1470)], 28.0, Color(0.92, 0.68, 0.38, 0.26), -1)
	_add_story_banner(Vector2(470, 910), Vector2(390, 126), Color(0.94, 0.86, 0.66, 0.84), Color(0.52, 0.34, 0.20, 0.82), "Rotayı oku, acele etme")
	_add_asset_slot_prop("ship.map_table", Vector2(690, 1170), Vector2(330, 154), Color(0.78, 0.56, 0.30, 0.92), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.60), "Harita", true)
	_add_asset_slot_prop("ship.uniform_stand", Vector2(455, 535), Vector2(112, 154), Color(0.18, 0.32, 0.48, 0.88), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.46), "", true)
	_add_asset_slot_prop("ship.compass", Vector2(1020, 1370), Vector2(128, 96), Color(POP_CREAM.r, POP_CREAM.g, POP_CREAM.b, 0.80), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.64), "", true)
	_add_asset_slot_prop("ship.dock_glow", Vector2(1110, 1510), Vector2(180, 72), Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.20), Color(1.0, 1.0, 1.0, 0.18), "Samsun", true)
	_add_kenney_prop(BLOCK_TILE_WOOD_TEXTURE, Vector2(855, 1214), Vector2(1.60, 0.92), Color(1.0, 0.76, 0.46, 0.74), true, "ship.map_table_surface")
	_add_kenney_prop(BLOCK_BOX_TEXTURE, Vector2(420, 1460), Vector2(1.02, 1.02), Color(0.92, 0.76, 0.54, 0.70), true, "ship.deck_crate_left")
	_add_kenney_prop(BLOCK_BOX_WIDE_TEXTURE, Vector2(525, 1486), Vector2(1.05, 1.05), Color(0.96, 0.80, 0.58, 0.66), true, "ship.deck_crate_stack")
	_add_kenney_prop(BLOCK_CART_TOP_TEXTURE, Vector2(1016, 1380), Vector2(0.86, 0.86), Color(1.0, 0.90, 0.64, 0.74), true, "ship.compass_case")
	_add_kenney_prop(BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(380, 1120), Vector2(1.18, 1.18), Color(0.72, 0.92, 1.0, 0.34), true, "ship.rail_left")
	_add_kenney_prop(BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(1060, 1120), Vector2(1.18, 1.18), Color(0.72, 0.92, 1.0, 0.34), true, "ship.rail_right")
	_add_kenney_npc(BLOCK_CHARACTER_MAN_TEXTURE, Vector2(520, 1188), Vector2(0.92, 0.92), Color(0.92, 0.96, 1.0, 0.62), "ship.deck_helper", "rota")
	_add_kenney_npc(BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(1180, 1248), Vector2(0.86, 0.86), Color(0.90, 1.0, 0.96, 0.56), "ship.watch_helper", "liman")
	_add_strategy_card(BOARD_CARD_GREEN_TEXTURE, Vector2(730, 1130), Vector2(0.44, 0.44), Color(0.92, 1.0, 0.88, 0.76), "Harita", "ship.route_card")
	_add_strategy_token(BOARD_CHIP_BLUE_TEXTURE, Vector2(1114, 1390), Vector2(0.44, 0.44), Color(0.84, 0.98, 1.0, 0.80), "ship.navigation_token")
	_add_decorative_speckles(Rect2(Vector2(250, 420), Vector2(1040, 1140)), Color(1.0, 0.86, 0.55, 0.06), 20)
	_add_sprite_prop(CLOUD_TEXTURE, Vector2(300, 150), Vector2(0.96, 0.96), Color(1, 1, 1, 0.22))
	_add_sprite_prop(CLOUD_TEXTURE_ALT, Vector2(1220, 170), Vector2(0.88, 0.88), Color(1, 1, 1, 0.22))
	_add_sprite_prop(CLOUD_TEXTURE, Vector2(840, 120), Vector2(0.74, 0.74), Color(1, 1, 1, 0.18))
	_add_rect(Vector2(1030, 1015), Vector2(120, 600), Color(0.08, 0.28, 0.36))
	_add_rect(Vector2(1180, 1015), Vector2(105, 600), Color(0.10, 0.31, 0.40))
	_add_rect(Vector2(270, 1090), Vector2(980, 52), Color(0.58, 0.44, 0.30))
	_add_rect(Vector2(270, 1230), Vector2(980, 52), Color(0.58, 0.44, 0.30))
	_add_rect(Vector2(270, 1370), Vector2(980, 52), Color(0.58, 0.44, 0.30))
	_add_ship_planks(Vector2(360, 1094), 8, 102.0, Color(1, 1, 1, 0.42), Vector2(0.62, 0.62))
	_add_ship_planks(Vector2(360, 1234), 8, 102.0, Color(1, 1, 1, 0.42), Vector2(0.62, 0.62))
	_add_ship_planks(Vector2(360, 1374), 8, 102.0, Color(1, 1, 1, 0.42), Vector2(0.62, 0.62))
	_add_sprite_prop(SHIP_HULL_TEXTURE, Vector2(680, 1500), Vector2(1.30, 1.30), Color(1, 1, 1, 0.30))
	_add_sprite_prop(SHIP_HULL_ALT_TEXTURE, Vector2(950, 1515), Vector2(1.18, 1.18), Color(1, 1, 1, 0.26))
	_add_sprite_prop(SHIP_MAST_TEXTURE, Vector2(820, 900), Vector2(1.26, 1.26), Color(1, 1, 1, 0.42), true)
	_add_sprite_prop(SHIP_MAST_TEXTURE, Vector2(1040, 980), Vector2(0.92, 0.92), Color(1, 1, 1, 0.34), true)
	_add_sprite_prop(SHIP_SAIL_TEXTURE, Vector2(885, 840), Vector2(0.92, 0.92), Color(1, 1, 1, 0.30), true)
	_add_sprite_prop(SHIP_SMALL_SAIL_TEXTURE, Vector2(1080, 980), Vector2(0.72, 0.72), Color(1, 1, 1, 0.28), true)
	_add_sprite_prop(SHIP_FLAG_TEXTURE, Vector2(905, 610), Vector2(0.78, 0.78), Color(1, 1, 1, 0.88), true)
	_add_sprite_prop(SHIP_FLAG_ALT_TEXTURE, Vector2(1090, 760), Vector2(0.62, 0.62), Color(1, 1, 1, 0.78), true)
	_add_crimson_flag(Vector2(960, 650), 0.86, true)
	_add_crimson_flag(Vector2(1160, 820), 0.64, true)
	_add_sprite_prop(SHIP_NEST_TEXTURE, Vector2(820, 720), Vector2(0.78, 0.78), Color(1, 1, 1, 0.45), true)
	_add_sprite_prop(SHIP_CANNON_TEXTURE, Vector2(1140, 1320), Vector2(0.70, 0.70), Color(1, 1, 1, 0.72), true)
	_add_sprite_prop(SHIP_CANNON_TEXTURE, Vector2(420, 1330), Vector2(-0.66, 0.66), Color(1, 1, 1, 0.54), true)
	_add_sprite_prop(SHIP_CREW_TEXTURE, Vector2(1180, 980), Vector2(0.72, 0.72), Color(1, 1, 1, 0.38), true)
	_add_sprite_prop(SHIP_CREW_ALT_TEXTURE, Vector2(540, 1110), Vector2(0.60, 0.60), Color(1, 1, 1, 0.34), true)
	_add_sprite_prop(SMOKE_TEXTURE, Vector2(1010, 450), Vector2(0.78, 0.78), Color(0.85, 0.92, 1.0, 0.22))
	_add_sprite_prop(SMOKE_TEXTURE, Vector2(1180, 1460), Vector2(0.56, 0.56), Color(0.88, 0.94, 1.0, 0.18))
	_add_mote_cluster(Vector2(1140, 1160), Color(0.78, 0.92, 1.0, 0.14), 6)

func _setup_samsun_rift_after_build() -> void:
	"""Orchestrator-level setup after builder builds Samsun visuals."""
	add_strategy_node(Vector2(800, 1000), "Milli İrade", RIFT_BLUE, "samsun.rift_core")

	add_historical_landmark(Vector2(360, 820), "harbor", "Liman", "samsun.harbor_node")
	add_prop_cluster(Vector2(360, 820), "harbor", "samsun.harbor_landmark")
	add_historical_landmark(Vector2(1190, 820), "telegraph", "Telgraf", "samsun.telegraph_node")
	add_prop_cluster(Vector2(1190, 820), "telegraph", "samsun.telegraph_landmark")
	add_historical_landmark(Vector2(530, 1500), "people", "Halk", "samsun.people_node")
	add_prop_cluster(Vector2(530, 1500), "people", "samsun.people_landmark")

	add_strategy_node(Vector2(360, 820), "Destek", POP_TURQUOISE, "interactables.strategy_node")
	add_strategy_node(Vector2(1190, 820), "Haber", RIFT_BLUE, "interactables.strategy_node")
	add_strategy_node(Vector2(530, 1500), "Birlik", POP_GOLD, "interactables.strategy_node")
	add_strategy_node(Vector2(820, 1500), "Dalga", Color(0.68, 0.40, 1.0), "fx.rift_focus_ring")

	add_prop_cluster(Vector2(360, 620), "discovery", "world_props.prop_cluster")
	add_prop_cluster(Vector2(1210, 1550), "discovery", "world_props.prop_cluster")

	add_companion_reaction_spot(Vector2(360, 620), 210.0, "Eda: Önce çevredeki izleri okuyalım.", "interactables.companion_reaction_spot")
	add_companion_reaction_spot(Vector2(1190, 820), 230.0, "Eda: Telgraf, haberleri güvenli taşımak için önemli.", "interactables.companion_reaction_spot")
	add_companion_reaction_spot(Vector2(530, 1500), 230.0, "Arda: İnsanları birlikte düşünmeye çağırmak daha güçlü.", "interactables.companion_reaction_spot")
	add_companion_reaction_spot(Vector2(800, 1000), 240.0, "Eda: Gözlem ve bağlantı birlikte güç olur.", "interactables.companion_reaction_spot")
	add_companion_reaction_spot(Vector2(770, 1240), 180.0, "Eda: Yan patikalar da hikaye taşır.", "paperworld.samsun_route_beads")
	add_companion_reaction_spot(Vector2(805, 1340), 185.0, "Arda: Güvenli açıklıklar, plan yapmak için iyi duraklar.", "paperworld.samsun_safe_clearings")
	add_companion_reaction_spot(Vector2(820, 905), 190.0, "Eda: Ufuktaki bayraklar yolun devam ettiğini fısıldıyor.", "paperworld.samsun_vista_flags")

func _decorate_havza() -> void:
	_add_toy_world_frame(Color(0.34, 0.48, 0.25, 0.22), Color(0.96, 0.82, 0.42, 0.09))
	_add_backdrop_band([BG_FLAT_HILLS_1_TEXTURE, BG_FLAT_HILLS_2_TEXTURE, BG_FLAT_MOUNTAIN_2_TEXTURE], 500.0, Vector2(1.00, 1.00), Color(0.82, 0.98, 0.64, 0.16), "havza.horizon")
	_add_distant_town_band(640.0, Color(0.98, 0.92, 0.72, 0.16), "havza.distant_town")
	_add_location_sign("Havza", "Ortak ses kur", Vector2(550, 300), 460.0, Color(0.56, 0.72, 0.32, 0.82), "havza.location_sign")
	_add_soft_blob(Vector2(780, 1120), Vector2(410, 260), Color(0.50, 0.62, 0.32, 0.20), 20, 0.10)
	_add_rift_shard_cluster(Vector2(1160, 1480), 5, 140.0)
	_add_path_ribbon([Vector2(520, 1400), Vector2(700, 1120), Vector2(970, 980), Vector2(1080, 860)], 36.0, Color(0.92, 0.74, 0.42, 0.28), -1)
	_add_breadcrumb_trail([Vector2(520, 1400), Vector2(700, 1120), Vector2(970, 980), Vector2(1080, 860)], BOARD_CHIP_GREEN_TEXTURE, Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.80), "havza.breadcrumb", 150.0, 0.50)
	_add_light_pool(Vector2(700, 1120), Vector2(290, 180), Color(1.0, 0.86, 0.40, 0.11))
	_add_story_banner(Vector2(510, 420), Vector2(420, 128), Color(0.96, 0.92, 0.70, 0.86), Color(0.56, 0.72, 0.32, 0.80), "Ortak ses kur")
	_add_asset_slot_prop("havza.notice_board", Vector2(970, 622), Vector2(150, 118), Color(0.96, 0.88, 0.62, 0.86), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.42), "Genelge", true)
	_add_asset_slot_prop("havza.telegraph_table", Vector2(370, 1470), Vector2(170, 98), Color(0.80, 0.62, 0.36, 0.86), Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.38), "Telgraf", true)
	_add_asset_slot_prop("havza.town_square", Vector2(625, 1048), Vector2(178, 104), Color(0.96, 0.82, 0.48, 0.62), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.45), "Meydan", true)
	_add_kenney_prop(BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(1008, 724), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.62, 0.70), true, "havza.notice_board_legs")
	_add_kenney_prop(BLOCK_TILE_WOOD_TEXTURE, Vector2(452, 1510), Vector2(1.05, 0.82), Color(1.0, 0.80, 0.54, 0.74), true, "havza.telegraph_table_surface")
	_add_kenney_prop(BLOCK_MARKET_STALL_BLUE_TEXTURE, Vector2(710, 1086), Vector2(1.12, 1.12), Color(0.90, 1.0, 1.0, 0.82), true, "havza.square_stall")
	_add_kenney_prop(BLOCK_CART_TEXTURE, Vector2(560, 1200), Vector2(0.90, 0.90), Color(0.96, 0.82, 0.62, 0.70), true, "havza.square_cart")
	_add_kenney_prop(BLOCK_FENCE_SINGLE_TEXTURE, Vector2(868, 1210), Vector2(1.05, 1.05), Color(0.90, 0.96, 1.0, 0.52), true, "havza.square_fence")
	_add_strategy_card(BOARD_CARD_GREEN_TEXTURE, Vector2(860, 1040), Vector2(0.42, 0.42), Color(0.90, 1.0, 0.86, 0.76), "Ses", "havza.voice_card")
	_add_strategy_token(BOARD_CHIP_GREEN_TEXTURE, Vector2(990, 672), Vector2(0.42, 0.42), Color(0.86, 1.0, 0.76, 0.84), "havza.notice_token")
	_add_kenney_npc(BLOCK_CHARACTER_MAN_TEXTURE, Vector2(650, 1210), Vector2(0.82, 0.82), Color(0.96, 0.94, 0.86, 0.56), "havza.citizen_a", "oku")
	_add_kenney_npc(BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(798, 1218), Vector2(0.82, 0.82), Color(0.96, 1.0, 0.94, 0.56), "havza.citizen_b", "paylaş")
	_add_kenney_npc(BLOCK_CHARACTER_HORSE_TEXTURE, Vector2(470, 1280), Vector2(0.78, 0.78), Color(1.0, 0.92, 0.76, 0.42), "havza.carrier_horse", "")
	_add_way_arrow(Vector2(900, 820), deg_to_rad(-52), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.72), "genelge", "havza.to_notice_arrow")
	_add_way_arrow(Vector2(575, 1415), deg_to_rad(154), Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.70), "telgraf", "havza.to_telegraph_arrow")
	_add_discovery_badge(GAME_INFO_TEXTURE, Vector2(720, 940), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.86), "meydan", "havza.square_badge")
	_add_decorative_speckles(Rect2(Vector2(240, 520), Vector2(1120, 1100)), Color(1.0, 0.92, 0.54, 0.07), 22)
	_add_sprite_prop(CLOUD_TEXTURE, Vector2(310, 250), Vector2(0.98, 0.98), Color(1, 1, 1, 0.18))
	_add_sprite_prop(CLOUD_TEXTURE_ALT, Vector2(1240, 280), Vector2(0.88, 0.88), Color(1, 1, 1, 0.14))
	_add_sketch_strip(SKETCH_GRASS_TEXTURE, Vector2(260, 360), 8, Vector2(118, 0), Color(1, 1, 1, 0.70))
	_add_sketch_strip(SKETCH_GRASS_TEXTURE, Vector2(320, 470), 7, Vector2(118, 0), Color(1, 1, 1, 0.68))
	_add_sketch_strip(SKETCH_GRASS_TEXTURE, Vector2(270, 1280), 8, Vector2(118, 0), Color(1, 1, 1, 0.68))
	_add_sketch_strip(SKETCH_GRASS_TEXTURE, Vector2(340, 1380), 7, Vector2(118, 0), Color(1, 1, 1, 0.66))
	_add_sketch_strip(SKETCH_PATH_TEXTURE, Vector2(450, 1540), 6, Vector2(84, -82), Color(1, 1, 1, 0.95), Vector2(0.74, 0.74))
	_add_sketch_strip(SKETCH_PATH_TEXTURE, Vector2(920, 1040), 3, Vector2(0, -102), Color(1, 1, 1, 0.95), Vector2(0.74, 0.74))
	_add_sketch_tile(SKETCH_PATH_CROSS_TEXTURE, Vector2(960, 920), Color.WHITE, Vector2(0.82, 0.82))
	_add_sketch_tile(SKETCH_PATH_CORNER_TEXTURE, Vector2(780, 1120), Color.WHITE, Vector2(0.74, 0.74))
	_add_sketch_tile(SKETCH_PATH_END_TEXTURE, Vector2(1080, 720), Color.WHITE, Vector2(0.74, 0.74))
	_add_sketch_tile(SKETCH_RIVER_TEXTURE, Vector2(330, 1500), Color(0.92, 1.0, 1.0, 0.88), Vector2(0.78, 0.78))
	_add_sketch_tile(SKETCH_RIVER_TEXTURE, Vector2(260, 1588), Color(0.92, 1.0, 1.0, 0.88), Vector2(0.78, 0.78))
	_add_sketch_tile(SKETCH_RIVER_BEND_TEXTURE, Vector2(398, 1676), Color(0.92, 1.0, 1.0, 0.88), Vector2(0.78, 0.78))
	_add_sketch_tile(SKETCH_RIVER_BRIDGE_TEXTURE, Vector2(520, 1424), Color.WHITE, Vector2(0.78, 0.78))
	_add_havza_building(Vector2(790, 560), 4, SKETCH_BUILDING_DOOR_TEXTURE, SKETCH_BUILDING_WINDOWS_TEXTURE, SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.92))
	_add_havza_building(Vector2(300, 680), 3, SKETCH_BUILDING_WINDOW_TEXTURE, SKETCH_BUILDING_WINDOW_TEXTURE, SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.78))
	_add_havza_building(Vector2(1120, 760), 2, SKETCH_BUILDING_DOOR_TEXTURE, SKETCH_BUILDING_WINDOW_TEXTURE, SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.74))
	_add_kenney_building(Vector2(930, 620), Vector2(1.02, 1.02), BLOCK_BUILDING_ROOF_RED_TEXTURE, Color(1.0, 0.94, 0.78, 0.58))
	_add_kenney_building(Vector2(310, 790), Vector2(0.88, 0.88), BLOCK_BUILDING_ROOF_BLUE_TEXTURE, Color(0.94, 1.0, 1.0, 0.48))
	_add_kenney_prop(BLOCK_TREE_GREEN_TEXTURE, Vector2(1160, 1190), Vector2(0.96, 0.96), Color(0.86, 1.0, 0.74, 0.70), true, "havza.square_tree")
	_add_kenney_prop(BLOCK_TREE_ORANGE_TEXTURE, Vector2(250, 1180), Vector2(0.84, 0.84), Color(1.0, 0.90, 0.56, 0.56), true, "havza.warm_tree")
	_add_sprite_prop(HOUSE_TEXTURE, Vector2(350, 640), Vector2(0.82, 0.82), Color(1, 1, 1, 0.22))
	_add_sprite_prop(HOUSE_TEXTURE_ALT, Vector2(1190, 620), Vector2(0.92, 0.92), Color(1, 1, 1, 0.18))
	_add_crimson_flag(Vector2(1110, 700), 0.54, true)
	_add_sprite_prop(TREE_TEXTURE, Vector2(1040, 1220), Vector2(0.82, 0.82), Color(0.96, 1.0, 0.92, 0.50), true)
	_add_sprite_prop(TREE_TEXTURE_ALT, Vector2(260, 1290), Vector2(0.74, 0.74), Color(0.96, 1.0, 0.92, 0.46), true)
	_add_sprite_prop(TREE_TEXTURE_ALT, Vector2(1320, 1360), Vector2(0.70, 0.70), Color(0.96, 1.0, 0.92, 0.42), true)
	_add_sprite_prop(FENCE_TEXTURE, Vector2(790, 1340), Vector2(1.18, 1.18), Color(1, 1, 1, 0.26))
	_add_sprite_prop(FENCE_TEXTURE, Vector2(610, 1000), Vector2(0.92, 0.92), Color(1, 1, 1, 0.34))
	_add_sprite_prop(FENCE_TEXTURE, Vector2(1110, 1000), Vector2(0.92, 0.92), Color(1, 1, 1, 0.34))
	_add_sprite_prop(SHIP_CREW_TEXTURE, Vector2(680, 1080), Vector2(0.50, 0.50), Color(1, 1, 1, 0.30), true)
	_add_sprite_prop(SHIP_CREW_TEXTURE, Vector2(890, 1160), Vector2(0.46, 0.46), Color(1, 1, 1, 0.26), true)
	_add_mote_cluster(Vector2(780, 1100), Color(0.96, 0.86, 0.44, 0.13), 6)

func _decorate_amasya() -> void:
	_add_toy_world_frame(Color(0.42, 0.34, 0.42, 0.20), Color(0.92, 0.78, 1.0, 0.08))
	_add_backdrop_band([BG_FLAT_MOUNTAIN_1_TEXTURE, BG_FLAT_POINTY_MOUNTAINS_TEXTURE, BG_FLAT_MOUNTAIN_2_TEXTURE], 490.0, Vector2(1.02, 1.02), Color(0.86, 0.82, 1.0, 0.16), "amasya.horizon")
	_add_distant_town_band(650.0, Color(1.0, 0.90, 0.74, 0.14), "amasya.distant_town")
	_add_location_sign("Amasya", "Kararı anla", Vector2(555, 300), 460.0, Color(0.58, 0.42, 0.28, 0.82), "amasya.location_sign")
	_add_soft_blob(Vector2(800, 1240), Vector2(420, 260), Color(0.44, 0.36, 0.30, 0.18), 20, 0.08)
	_add_rift_shard_cluster(Vector2(1240, 1460), 5, 140.0)
	_add_path_ribbon([Vector2(620, 1500), Vector2(800, 1450), Vector2(980, 1180), Vector2(860, 980), Vector2(620, 620)], 34.0, Color(0.94, 0.78, 0.44, 0.28), -1)
	_add_breadcrumb_trail([Vector2(620, 1500), Vector2(800, 1450), Vector2(980, 1180), Vector2(860, 980), Vector2(620, 620)], BOARD_CHIP_RED_TEXTURE, Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.78), "amasya.breadcrumb", 150.0, 0.50)
	_add_light_pool(Vector2(800, 1180), Vector2(300, 190), Color(1.0, 0.78, 0.44, 0.11))
	_add_story_banner(Vector2(520, 820), Vector2(430, 128), Color(0.95, 0.88, 0.72, 0.86), Color(0.58, 0.42, 0.28, 0.82), "Milletin kararı")
	_add_asset_slot_prop("amasya.meeting_table", Vector2(570, 1070), Vector2(220, 110), Color(0.74, 0.50, 0.30, 0.86), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.44), "Toplantı", true)
	_add_asset_slot_prop("amasya.statement_draft", Vector2(920, 1125), Vector2(154, 96), Color(0.98, 0.92, 0.74, 0.88), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.36), "Bildiri", true)
	_add_asset_slot_prop("amasya.river_marker", Vector2(306, 1580), Vector2(220, 70), Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.18), Color(1.0, 1.0, 1.0, 0.18), "", true)
	_add_kenney_prop(BLOCK_TILE_WOOD_TEXTURE, Vector2(682, 1122), Vector2(1.32, 0.86), Color(1.0, 0.76, 0.48, 0.76), true, "amasya.meeting_table_surface")
	_add_kenney_prop(BLOCK_BOX_WIDE_TEXTURE, Vector2(958, 1160), Vector2(0.86, 0.86), Color(1.0, 0.92, 0.72, 0.74), true, "amasya.statement_stack")
	_add_kenney_prop(BLOCK_TILE_WATER_TEXTURE, Vector2(386, 1606), Vector2(1.48, 1.12), Color(0.60, 0.98, 1.0, 0.72), true, "amasya.river_water")
	_add_kenney_prop(BLOCK_TILE_BRIDGE_TEXTURE, Vector2(520, 1560), Vector2(1.05, 1.05), Color(1.0, 0.86, 0.58, 0.78), true, "amasya.river_bridge")
	_add_kenney_prop(BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(650, 1235), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.70, 0.46), true, "amasya.meeting_fence")
	_add_strategy_card(BOARD_CARD_RED_TEXTURE, Vector2(1050, 1100), Vector2(0.42, 0.42), Color(1.0, 0.88, 0.76, 0.76), "Bildiri", "amasya.statement_card")
	_add_strategy_token(BOARD_CHIP_BLUE_TEXTURE, Vector2(428, 1575), Vector2(0.42, 0.42), Color(0.82, 0.98, 1.0, 0.80), "amasya.river_token")
	_add_kenney_npc(BLOCK_CHARACTER_MAN_TEXTURE, Vector2(590, 1220), Vector2(0.82, 0.82), Color(0.98, 0.94, 0.86, 0.46), "amasya.delegate_a", "görüş")
	_add_kenney_npc(BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(980, 1265), Vector2(0.80, 0.80), Color(0.96, 1.0, 0.96, 0.44), "amasya.delegate_b", "not")
	_add_way_arrow(Vector2(725, 980), deg_to_rad(78), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.72), "toplantı", "amasya.to_meeting_arrow")
	_add_way_arrow(Vector2(900, 1495), deg_to_rad(-24), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.68), "bildiri", "amasya.to_statement_arrow")
	_add_discovery_badge(GAME_CHECK_TEXTURE, Vector2(825, 1310), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.84), "karar", "amasya.decision_badge")
	_add_decorative_speckles(Rect2(Vector2(260, 520), Vector2(1100, 1140)), Color(1.0, 0.84, 0.48, 0.06), 20)
	_add_sprite_prop(CLOUD_TEXTURE, Vector2(280, 210), Vector2(0.92, 0.92), Color(1, 1, 1, 0.16))
	_add_sprite_prop(CLOUD_TEXTURE_ALT, Vector2(1240, 250), Vector2(0.82, 0.82), Color(1, 1, 1, 0.12))
	_add_sketch_strip(SKETCH_PATH_TEXTURE, Vector2(420, 1700), 6, Vector2(94, 0), Color(1, 1, 1, 0.96), Vector2(0.78, 0.78))
	_add_sketch_tile(SKETCH_PATH_CROSS_TEXTURE, Vector2(800, 1450), Color.WHITE, Vector2(0.82, 0.82))
	_add_sketch_tile(SKETCH_PATH_END_TEXTURE, Vector2(1090, 1180), Color.WHITE, Vector2(0.76, 0.76))
	_add_havza_building(Vector2(360, 540), 5, SKETCH_BUILDING_DOOR_TEXTURE, SKETCH_BUILDING_WINDOWS_TEXTURE, SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.88))
	_add_havza_building(Vector2(980, 620), 2, SKETCH_BUILDING_WINDOW_TEXTURE, SKETCH_BUILDING_WINDOW_TEXTURE, SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.72))
	_add_kenney_building(Vector2(1130, 720), Vector2(0.92, 0.92), BLOCK_BUILDING_ROOF_RED_TEXTURE, Color(1.0, 0.94, 0.82, 0.48))
	_add_sprite_prop(HOUSE_TEXTURE, Vector2(1180, 590), Vector2(0.86, 0.86), Color(1, 1, 1, 0.18))
	_add_crimson_flag(Vector2(1010, 760), 0.50, true)
	_add_sprite_prop(TREE_TEXTURE, Vector2(260, 1260), Vector2(0.86, 0.86), Color(0.96, 1.0, 0.92, 0.34), true)
	_add_sprite_prop(TREE_TEXTURE_ALT, Vector2(1340, 1290), Vector2(0.80, 0.80), Color(0.96, 1.0, 0.92, 0.30), true)
	_add_sprite_prop(FENCE_TEXTURE, Vector2(790, 870), Vector2(1.04, 1.04), Color(1, 1, 1, 0.28))
	_add_sprite_prop(FENCE_TEXTURE, Vector2(790, 1600), Vector2(1.12, 1.12), Color(1, 1, 1, 0.24))
	_add_sprite_prop(SHIP_CREW_ALT_TEXTURE, Vector2(620, 1160), Vector2(0.48, 0.48), Color(1, 1, 1, 0.22), true)
	_add_sprite_prop(SHIP_CREW_TEXTURE, Vector2(980, 1220), Vector2(0.44, 0.44), Color(1, 1, 1, 0.20), true)
	_add_mote_cluster(Vector2(820, 1180), Color(0.96, 0.76, 0.42, 0.13), 6)

func _decorate_kongreler() -> void:
	_add_toy_world_frame(Color(0.48, 0.34, 0.26, 0.20), Color(0.98, 0.74, 0.44, 0.08))
	_add_backdrop_band([BG_FLAT_HILLS_2_TEXTURE, BG_FLAT_MOUNTAIN_2_TEXTURE, BG_FLAT_HILLS_1_TEXTURE], 500.0, Vector2(1.00, 1.00), Color(1.0, 0.78, 0.54, 0.14), "kongre.horizon")
	_add_distant_town_band(660.0, Color(1.0, 0.88, 0.66, 0.14), "kongre.distant_town")
	_add_location_sign("Kongreler", "Birlikte güçlen", Vector2(530, 292), 520.0, Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.74), "kongre.location_sign")
	_add_soft_blob(Vector2(800, 1180), Vector2(440, 280), Color(0.52, 0.40, 0.28, 0.18), 20, 0.08)
	_add_rift_shard_cluster(Vector2(1240, 1460), 5, 140.0)
	_add_path_ribbon([Vector2(620, 1500), Vector2(780, 1220), Vector2(860, 980), Vector2(980, 1500)], 34.0, Color(0.96, 0.70, 0.38, 0.26), -1)
	_add_breadcrumb_trail([Vector2(620, 1500), Vector2(780, 1220), Vector2(860, 980), Vector2(980, 1500)], BOARD_CHIP_RED_TEXTURE, Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.76), "kongre.breadcrumb", 150.0, 0.50)
	_add_light_pool(Vector2(820, 1160), Vector2(320, 200), Color(1.0, 0.74, 0.38, 0.10))
	_add_story_banner(Vector2(510, 790), Vector2(430, 128), Color(0.96, 0.86, 0.68, 0.86), Color(0.72, 0.44, 0.26, 0.82), "Birlikte güçlen")
	_add_asset_slot_prop("kongre.delegate_table", Vector2(560, 1080), Vector2(220, 110), Color(0.72, 0.48, 0.28, 0.86), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.42), "Temsil", true)
	_add_asset_slot_prop("kongre.unity_stage", Vector2(900, 1030), Vector2(176, 128), Color(0.86, 0.54, 0.30, 0.76), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.46), "Birlik", true)
	_add_asset_slot_prop("kongre.shared_goal_banner", Vector2(610, 560), Vector2(270, 84), Color(0.98, 0.88, 0.62, 0.78), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.40), "Ortak Hedef", true)
	_add_kenney_prop(BLOCK_TILE_WOOD_TEXTURE, Vector2(672, 1130), Vector2(1.36, 0.86), Color(1.0, 0.74, 0.44, 0.74), true, "kongre.delegate_table_surface")
	_add_kenney_prop(BLOCK_MARKET_STALL_RED_TEXTURE, Vector2(982, 1094), Vector2(1.08, 1.08), Color(1.0, 0.82, 0.60, 0.78), true, "kongre.unity_stage_canopy")
	_add_kenney_prop(BLOCK_BOX_WIDE_TEXTURE, Vector2(760, 610), Vector2(0.98, 0.98), Color(1.0, 0.90, 0.64, 0.72), true, "kongre.banner_base")
	_add_kenney_prop(BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(560, 1270), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.64, 0.42), true, "kongre.front_fence_left")
	_add_kenney_prop(BLOCK_FENCE_DOUBLE_TEXTURE, Vector2(980, 1270), Vector2(1.08, 1.08), Color(1.0, 0.88, 0.64, 0.42), true, "kongre.front_fence_right")
	_add_strategy_card(BOARD_CARD_GREEN_TEXTURE, Vector2(650, 1018), Vector2(0.42, 0.42), Color(0.90, 1.0, 0.86, 0.76), "Temsil", "kongre.delegate_card")
	_add_strategy_card(BOARD_CARD_RED_TEXTURE, Vector2(940, 985), Vector2(0.42, 0.42), Color(1.0, 0.88, 0.76, 0.76), "Birlik", "kongre.unity_card")
	_add_strategy_token(BOARD_CHIP_GREEN_TEXTURE, Vector2(830, 1150), Vector2(0.44, 0.44), Color(0.90, 1.0, 0.76, 0.84), "kongre.shared_goal_token")
	_add_kenney_npc(BLOCK_CHARACTER_MAN_TEXTURE, Vector2(605, 1230), Vector2(0.80, 0.80), Color(0.98, 0.94, 0.86, 0.40), "kongre.delegate_a", "temsil")
	_add_kenney_npc(BLOCK_CHARACTER_WOMAN_TEXTURE, Vector2(1025, 1230), Vector2(0.80, 0.80), Color(0.96, 1.0, 0.94, 0.40), "kongre.delegate_b", "birlik")
	_add_way_arrow(Vector2(770, 930), deg_to_rad(72), Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.72), "temsil", "kongre.to_delegate_arrow")
	_add_way_arrow(Vector2(1010, 900), deg_to_rad(105), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.70), "birlik", "kongre.to_unity_arrow")
	_add_discovery_badge(GAME_CHECK_TEXTURE, Vector2(830, 1318), Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.80), "ortak hedef", "kongre.goal_badge")
	_add_decorative_speckles(Rect2(Vector2(260, 520), Vector2(1100, 1140)), Color(1.0, 0.80, 0.44, 0.06), 22)
	_add_sprite_prop(CLOUD_TEXTURE, Vector2(300, 220), Vector2(0.94, 0.94), Color(1, 1, 1, 0.14))
	_add_sprite_prop(CLOUD_TEXTURE_ALT, Vector2(1230, 260), Vector2(0.84, 0.84), Color(1, 1, 1, 0.10))
	_add_havza_building(Vector2(360, 520), 5, SKETCH_BUILDING_DOOR_TEXTURE, SKETCH_BUILDING_WINDOWS_TEXTURE, SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.86))
	_add_havza_building(Vector2(1060, 620), 2, SKETCH_BUILDING_WINDOW_TEXTURE, SKETCH_BUILDING_WINDOW_TEXTURE, SKETCH_BUILDING_CENTER_TEXTURE, Color(1, 1, 1, 0.70))
	_add_kenney_building(Vector2(1120, 745), Vector2(0.90, 0.90), BLOCK_BUILDING_ROOF_BLUE_TEXTURE, Color(0.94, 1.0, 1.0, 0.44))
	_add_crimson_flag(Vector2(1040, 790), 0.52, true)
	_add_sketch_strip(SKETCH_PATH_TEXTURE, Vector2(430, 1660), 5, Vector2(96, 0), Color(1, 1, 1, 0.96), Vector2(0.78, 0.78))
	_add_sketch_tile(SKETCH_PATH_CROSS_TEXTURE, Vector2(780, 1220), Color.WHITE, Vector2(0.82, 0.82))
	_add_sketch_tile(SKETCH_PATH_END_TEXTURE, Vector2(1090, 980), Color.WHITE, Vector2(0.76, 0.76))
	_add_sprite_prop(TREE_TEXTURE, Vector2(250, 1290), Vector2(0.84, 0.84), Color(0.96, 1.0, 0.92, 0.32), true)
	_add_sprite_prop(TREE_TEXTURE_ALT, Vector2(1350, 1330), Vector2(0.78, 0.78), Color(0.96, 1.0, 0.92, 0.28), true)
	_add_sprite_prop(FENCE_TEXTURE, Vector2(790, 840), Vector2(1.04, 1.04), Color(1, 1, 1, 0.26))
	_add_sprite_prop(FENCE_TEXTURE, Vector2(790, 1560), Vector2(1.12, 1.12), Color(1, 1, 1, 0.22))
	_add_sprite_prop(SHIP_CREW_TEXTURE, Vector2(620, 1140), Vector2(0.46, 0.46), Color(1, 1, 1, 0.18), true)
	_add_sprite_prop(SHIP_CREW_ALT_TEXTURE, Vector2(980, 1180), Vector2(0.42, 0.42), Color(1, 1, 1, 0.16), true)
	_add_mote_cluster(Vector2(820, 1160), Color(0.98, 0.70, 0.38, 0.13), 7)

func _add_rift_cloud(center: Vector2, radius: float, color: Color) -> void:
	var ring := Polygon2D.new()
	ring.color = color
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		var wobble := 1.0 + (0.08 * sin(float(i) * 1.7))
		points.append(Vector2(cos(angle), sin(angle)) * radius * wobble)
	ring.position = center
	ring.polygon = points
	props.add_child(ring)




func _rounded_rect_points(size: Vector2, radius: float, segments := 6) -> PackedVector2Array:
	var r: float = min(radius, min(size.x, size.y) * 0.5)
	var points := PackedVector2Array()
	var corners := [
		{"center": Vector2(r, r), "from": PI, "to": PI * 1.5},
		{"center": Vector2(size.x - r, r), "from": PI * 1.5, "to": TAU},
		{"center": Vector2(size.x - r, size.y - r), "from": 0.0, "to": PI * 0.5},
		{"center": Vector2(r, size.y - r), "from": PI * 0.5, "to": PI},
	]
	for corner in corners:
		for step in range(segments + 1):
			var t := float(step) / float(segments)
			var angle: float = lerp(float(corner["from"]), float(corner["to"]), t)
			var center: Vector2 = corner["center"]
			points.append(center + Vector2(cos(angle), sin(angle)) * r)
	return points

func _move_player(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_vector.length() > 0.01:
		has_target = false
		player_velocity = input_vector * PLAYER_SPEED
		player.position += player_velocity * delta
	elif has_target:
		var direction := target_position - player.position
		if direction.length() < 18.0:
			has_target = false
			player_velocity = Vector2.ZERO
		else:
			player_velocity = direction.normalized() * PLAYER_SPEED
			player.position += player_velocity * delta
	else:
		player_velocity = Vector2.ZERO

	player.position = player.position.clamp(Vector2(120, 180), WORLD_SIZE - Vector2(120, 180))

func _set_target(world_position: Vector2) -> void:
	target_position = world_position.clamp(Vector2(120, 180), WORLD_SIZE - Vector2(120, 180))
	has_target = true


func _animate_world_fx() -> void:
	_update_samsun_goal_visuals()
	for layer in [props, foreground_props]:
		for child in layer.get_children():
			if child.has_meta("ambient_bob"):
				var base_pos: Vector2 = child.get_meta("base_pos", child.position)
				var phase: float = child.get_meta("phase", 0.0)
				var bob_amount: float = child.get_meta("bob_amount", 3.0)
				var drift: Vector2 = child.get_meta("paper_drift", Vector2.ZERO)
				var parallax_strength: float = child.get_meta("paper_parallax_strength", 0.0)
				child.position = base_pos + Vector2(
					sin((elapsed_time * 0.55) + phase) * drift.x,
					sin((elapsed_time * 1.6) + phase) * bob_amount + cos((elapsed_time * 0.45) + phase) * drift.y
				) + _paper_parallax_offset(parallax_strength)
			if child.has_meta("line_pulse") and child is Line2D:
				var phase: float = child.get_meta("phase", 0.0)
				var base_alpha: float = child.get_meta("base_alpha", child.default_color.a)
				var pulse_amount: float = child.get_meta("pulse_amount", 0.018)
				var color: Color = child.default_color
				color.a = max(0.0, base_alpha + (pulse_amount * sin((elapsed_time * 1.05) + phase)))
				child.default_color = color
	_animate_foreground_visual_fx()

func _paper_parallax_offset(strength: float) -> Vector2:
	if strength == 0.0 or _state.current_zone != "samsun_rift":
		return Vector2.ZERO
	var normalized := Vector2(
		(player.position.x - (WORLD_SIZE.x * 0.5)) / (WORLD_SIZE.x * 0.5),
		(player.position.y - (WORLD_SIZE.y * 0.5)) / (WORLD_SIZE.y * 0.5)
	)
	return Vector2(
		clamp(normalized.x, -1.0, 1.0) * strength,
		clamp(normalized.y, -1.0, 1.0) * strength * 0.42
	)

func _animate_foreground_visual_fx() -> void:
	for child in foreground_props.get_children():
		if not child.has_meta("visual_fx"):
			continue
		if child is Polygon2D:
			var base_pos: Vector2 = child.get_meta("base_pos", child.position)
			var drift: Vector2 = child.get_meta("drift", Vector2(10, 8))
			var phase: float = child.get_meta("phase", 0.0)
			var base_alpha: float = child.get_meta("base_alpha", 0.12)
			child.position = base_pos + Vector2(
				sin((elapsed_time * 0.8) + phase) * drift.x,
				cos((elapsed_time * 0.6) + phase) * drift.y
			)
			var color: Color = child.color
			color.a = base_alpha + (0.035 * sin((elapsed_time * 1.2) + phase))
			child.color = color

func _update_samsun_goal_visuals() -> void:
	if _state.current_zone != "samsun_rift":
		return
	for key in samsun_goal_visuals.keys():
		var is_active: bool = String(key) == _state.current_goal_kind
		var pulse := 0.035 + (0.018 * sin(elapsed_time * 2.4)) if is_active else 0.0
		for item in samsun_goal_visuals[key]:
			if not is_instance_valid(item):
				continue
			if item is Polygon2D:
				var polygon := item as Polygon2D
				var base_color: Color = polygon.get_meta("base_color", polygon.color)
				var color := base_color
				color.a = min(0.42, base_color.a + pulse)
				polygon.color = color
			elif item is Line2D:
				var line := item as Line2D
				var base_color: Color = line.get_meta("base_color", line.default_color)
				var color := base_color
				color.a = min(0.34, base_color.a + pulse)
				line.default_color = color

func _on_builder_goal_visual_registered(slot_id: String, node: CanvasItem) -> void:
	"""Builder'dan gelen goal visual sinyalini kategorize edip samsun_goal_visuals dict'ine ekler."""
	var key := ""
	if slot_id.contains("resource") or slot_id.contains("discovery") or slot_id.contains("leadership") or slot_id.contains("courage") or slot_id.contains("glint") or slot_id.contains("rift"):
		key = "resource"
	elif slot_id.contains("harbor") or slot_id.contains("telegraph") or slot_id.contains("people"):
		key = "build_spot"
	elif slot_id.contains("wave_start"):
		key = "wave_start"
	if key.is_empty():
		return
	if not samsun_goal_visuals.has(key):
		samsun_goal_visuals[key] = []
	samsun_goal_visuals[key].append(node)

func _animate_character_feedback() -> void:
	var bob: float = sin(elapsed_time * 4.0) * 4.0
	var move_amount: float = clamp(player_velocity.length() / PLAYER_SPEED, 0.0, 1.0)
	player_sprite.position.y = bob - (move_amount * 4.0)
	if player_outline != null:
		player_outline.position = player_sprite.position
		player_outline.scale = player_sprite.scale * 1.12
		player_outline.flip_h = player_sprite.flip_h
	if player_accessory != null:
		player_accessory.position.y = player_sprite.position.y
		player_accessory.scale.x = -1.0 if player_sprite.flip_h else 1.0
	player_shadow.scale = Vector2(1.0 + (move_amount * 0.12), 1.0 - (move_amount * 0.10))
	player_shadow.modulate.a = 0.18 + (move_amount * 0.08)
	if abs(player_velocity.x) > 4.0:
		player_sprite.flip_h = player_velocity.x < 0.0
		if player_outline != null:
			player_outline.flip_h = player_sprite.flip_h

	var companion_offset := companion.position - player.position
	companion_sprite.position.y = sin((elapsed_time * 4.0) + 0.9) * 3.0
	if companion_outline != null:
		companion_outline.position = companion_sprite.position
		companion_outline.scale = companion_sprite.scale * 1.12
		companion_outline.flip_h = companion_sprite.flip_h
	if companion_accessory != null:
		companion_accessory.position.y = companion_sprite.position.y
		companion_accessory.scale.x = -1.0 if companion_sprite.flip_h else 1.0
	companion_shadow.scale = Vector2(0.96 + (move_amount * 0.08), 0.96 - (move_amount * 0.06))
	if abs(companion_offset.x) > 8.0:
		companion_sprite.flip_h = companion_offset.x < 0.0
		if companion_outline != null:
			companion_outline.flip_h = companion_sprite.flip_h

	interact_button.scale = Vector2.ONE * (1.0 + (0.02 * sin(elapsed_time * 3.2))) if nearby_marker != null else Vector2.ONE
	atmosphere_horizon_glow.scale = Vector2(1.0 + (0.01 * sin(elapsed_time * 0.9)), 1.0 + (0.02 * sin((elapsed_time * 0.7) + 0.6)))
	if _state.current_zone == "room":
		atmosphere_top_glow.color.a = 0.0
		atmosphere_horizon_glow.color.a = 0.0
		atmosphere_bottom_fog.color.a = 0.0
		rift_edge_left.color.a = 0.0
		rift_edge_right.color.a = 0.0
		crimson_accent.color.a = 0.0
	else:
		atmosphere_top_glow.color.a = ambient_top_alpha + (0.015 * sin(elapsed_time * 0.8))
		atmosphere_horizon_glow.color.a = ambient_horizon_alpha + (0.012 * sin((elapsed_time * 0.7) + 0.4))
		atmosphere_bottom_fog.color.a = ambient_fog_alpha + (0.014 * sin((elapsed_time * 1.1) + 0.8))
		rift_edge_left.color.a = ambient_rift_edge_alpha + (0.015 * sin((elapsed_time * 1.4) + 0.3))
		rift_edge_right.color.a = ambient_rift_edge_alpha + (0.015 * sin((elapsed_time * 1.4) + 1.1))
		crimson_accent.color.a = ambient_crimson_alpha + (0.010 * sin((elapsed_time * 1.0) + 0.6))

func _update_samsun_camera_focus(delta: float) -> void:
	if player_camera == null:
		return
	var target_offset := Vector2.ZERO
	var target_zoom := Vector2(0.9, 0.9)
	if _state.current_zone == "samsun_rift" and samsun_open_world_overview_time_left > 0.0:
		samsun_open_world_overview_time_left = max(0.0, samsun_open_world_overview_time_left - delta)
		target_offset = _samsun_overview_camera_offset()
		target_zoom = Vector2(0.56, 0.56)
		player_camera.offset = player_camera.offset.lerp(target_offset, min(delta * 1.55, 1.0))
		player_camera.zoom = player_camera.zoom.lerp(target_zoom, min(delta * 1.45, 1.0))
		return
	if _state.current_zone == "samsun_rift" and not character_panel.visible and not dialogue_overlay.visible and not info_card_overlay.visible and not decision_overlay.visible:
		var focus_marker := nearby_marker
		if focus_marker == null:
			focus_marker = _marker.get_guidance_marker(markers, _state.current_goal_kind)
		if focus_marker != null:
			var direction := focus_marker.global_position - player.global_position
			if direction.length() > 1.0:
				target_offset = direction.limit_length(120.0) * 0.22
				target_zoom = Vector2(0.92, 0.92)
	player_camera.offset = player_camera.offset.lerp(target_offset, min(delta * 3.0, 1.0))
	player_camera.zoom = player_camera.zoom.lerp(target_zoom, min(delta * 2.0, 1.0))

func _start_samsun_open_world_overview() -> void:
	samsun_open_world_overview_time_left = 4.2

func _samsun_overview_camera_offset() -> Vector2:
	var diorama_center := Vector2(800, 1110)
	return diorama_center - player.position

func _set_goal(kind: String, text: String) -> void:
	_state.set_goal(kind, text)
	_update_objective(text)
	_refresh_minimap_markers()

func _samsun_intro_goal_text() -> String:
	return "Samsun Rüyası açıldı. Önce 2 liderlik izi topla, sonra Liman, Telgraf ve Halk çevresindeki 2 destek noktası kur."

func _play_dream_transition(callback: Callable) -> void:
	dream_overlay.visible = true
	dream_overlay.color = Color(0.91, 0.89, 1.0, 0.0)
	var tween := create_tween()
	tween.tween_property(dream_overlay, "color:a", 0.62, 0.22)
	tween.tween_callback(callback)
	tween.tween_interval(0.08)
	tween.tween_property(dream_overlay, "color:a", 0.0, 0.28)
	tween.tween_callback(Callable(self, "_hide_dream_overlay"))

func _hide_dream_overlay() -> void:
	dream_overlay.visible = false

func _update_companion(delta: float) -> void:
	var facing_direction := Vector2(1, 0)
	if player_velocity.length() > 4.0:
		facing_direction = player_velocity.normalized()
	elif has_target and player.position.distance_to(target_position) > 8.0:
		facing_direction = (target_position - player.position).normalized()
	var follow_offset := Vector2(-facing_direction.x * 95.0, 92.0)
	var desired_position := player.position + follow_offset
	var distance := companion.position.distance_to(desired_position)
	if distance > 520.0:
		companion.position = player.position + Vector2(105, 96)
	else:
		var speed_factor: float = clamp(distance / 160.0, 0.35, 1.0)
		companion.position = companion.position.lerp(desired_position, min(delta * (3.0 + speed_factor * 3.4), 1.0))

func _update_companion_reaction() -> void:
	if companion_reaction_label == null:
		return
	var selected_text := ""
	for spot in companion_reaction_spots:
		var center: Vector2 = spot["center"]
		var radius := float(spot["radius"])
		if player.position.distance_to(center) <= radius:
			selected_text = String(spot["text"])
			break
	active_companion_reaction = selected_text
	if active_companion_reaction == "":
		companion_reaction_label.visible = false
		return
	companion_reaction_label.text = active_companion_reaction
	companion_reaction_label.visible = not (character_panel.visible or dialogue_panel.visible or decision_overlay.visible or dialogue_overlay.visible or info_card_overlay.visible)
	companion_reaction_label.modulate.a = 0.86 + (0.10 * sin(elapsed_time * 3.0))

func _update_nearby_marker() -> void:
	nearby_marker = _marker.update_nearby(player.position, markers, INTERACT_DISTANCE)
	if nearby_marker == null:
		interact_button.disabled = true
		interact_button.text = "Yaklaş"
	else:
		interact_button.disabled = false
		interact_button.text = _marker.get_interact_text(nearby_marker)

func _interact() -> void:
	if nearby_marker == null:
		return

	var kind := String(nearby_marker.get_meta("kind"))
	if kind == "unit":
		_collect_unit(nearby_marker)
	elif kind == "ship_clue":
		_collect_ship_clue(nearby_marker)
	elif kind == "havza_clue":
		_collect_havza_clue(nearby_marker)
	elif kind == "npc":
		_show_dialogue(String(nearby_marker.get_meta("title")), _marker.format_marker_text(String(nearby_marker.get_meta("text")), hero_name), Callable())
	elif kind == "portal":
		if _state.get_item_count("units") >= _state.get_zone_item_total("units"):
			_show_dialogue(String(nearby_marker.get_meta("title")), _marker.format_marker_text(String(nearby_marker.get_meta("text")), hero_name), Callable(self, "_enter_bandirma"))
		else:
			_show_dialogue("Kitap Henüz Açılmadı", "Bandırma Vapuru'na geçmeden önce üç ünite notunu da toplamalısın.", Callable())
	elif kind == "decision":
		if _state.get_item_count("ship_clues") >= _state.get_zone_item_total("ship_clues"):
			_show_samsun_decision()
		else:
			_show_dialogue("Karar İçin Hazır Değilsin", "Önce kamaradaki üniformayı ve harita masasını incele.", Callable())
	elif kind == "havza_decision":
		if _state.get_item_count("havza_clues") >= _state.get_zone_item_total("havza_clues"):
			_show_havza_decision()
		else:
			_show_dialogue("Çağrı İçin Hazır Değilsin", "Önce genelge metnini ve telgraf defterini incele.", Callable())
	elif kind == "amasya_decision":
		if _state.get_item_count("amasya_clues") >= _state.get_zone_item_total("amasya_clues"):
			_show_amasya_decision()
		else:
			_show_dialogue("Bildiri İçin Hazır Değilsin", "Önce toplantı notunu ve bildiri taslağını incele.", Callable())
	elif kind == "amasya_clue":
		_collect_amasya_clue(nearby_marker)
	elif kind == "kongre_decision":
		if _state.get_item_count("kongre_clues") >= _state.get_zone_item_total("kongre_clues"):
			_show_kongre_decision()
		else:
			_show_dialogue("Kongre İçin Hazır Değilsin", "Önce temsil listesini ve ortak karar taslağını incele.", Callable())
	elif kind == "kongre_clue":
		_collect_kongre_clue(nearby_marker)
	elif kind == "resource":
		_collect_leadership_resource(nearby_marker)
	elif kind == "build_spot":
		_wave.show_support_panel(nearby_marker)
	elif kind == "wave_start":
		_wave.start_confusion_wave()
	elif kind == "havza_wave":
		_wave.start_havza_wave()
	elif kind == "amasya_wave":
		_wave.start_amasya_wave()
	elif kind == "kongre_wave":
		_wave.start_kongre_wave()

func _collect_unit(marker: Node2D) -> void:
	if bool(marker.get_meta("collected")):
		return

	_marker.mark_collected(marker)
	_state.increment_item_count("units")
	_spawn_reward_burst(marker.position, Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.92), "reward.unit")
	_marker.hide_nearby_collection_visuals(marker.position, true, props, foreground_props)
	_update_progress()
	_refresh_minimap_markers()
	_show_info_card(String(marker.get_meta("title")), _marker.format_marker_text(String(marker.get_meta("text")), hero_name), "Yeni tarih notu bulundu", Callable(), "unit")

	if _state.get_item_count("units") >= _state.get_zone_item_total("units"):
		_set_goal("portal", "Tüm üniteler toplandı. Çalışma masasındaki Tarih Kitabı'na git.")

func _collect_ship_clue(marker: Node2D) -> void:
	if bool(marker.get_meta("collected")):
		return

	_marker.mark_collected(marker)
	_state.increment_item_count("ship_clues")
	_spawn_reward_burst(marker.position, Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.86), "reward.ship")
	_marker.hide_nearby_collection_visuals(marker.position, true, props, foreground_props)
	_update_progress()
	_refresh_minimap_markers()
	_show_info_card(String(marker.get_meta("title")), _marker.format_marker_text(String(marker.get_meta("text")), hero_name), "Yeni gemi ipucu bulundu", Callable(), "ship")

	if _state.get_item_count("ship_clues") >= _state.get_zone_item_total("ship_clues"):
		_set_goal("decision", "Gemi ipuçları tamamlandı. Güvertedeki Samsun Kararı işaretine git.")

func _collect_havza_clue(marker: Node2D) -> void:
	if bool(marker.get_meta("collected")):
		return

	_marker.mark_collected(marker)
	_state.increment_item_count("havza_clues")
	_spawn_reward_burst(marker.position, Color(POP_GOLD.r, POP_GOLD.g, POP_GOLD.b, 0.86), "reward.havza")
	_marker.hide_nearby_collection_visuals(marker.position, true, props, foreground_props)
	_update_progress()
	_refresh_minimap_markers()
	_show_info_card(String(marker.get_meta("title")), _marker.format_marker_text(String(marker.get_meta("text")), hero_name), "Yeni genelge ipucu bulundu", Callable(), "havza")

	if _state.get_item_count("havza_clues") >= _state.get_zone_item_total("havza_clues"):
		_set_goal("havza_decision", "Havza ipuçları tamamlandı. Şimdi Havza Çağrısı noktasına git.")

func _collect_amasya_clue(marker: Node2D) -> void:
	if bool(marker.get_meta("collected")):
		return

	_marker.mark_collected(marker)
	_state.increment_item_count("amasya_clues")
	_spawn_reward_burst(marker.position, Color(1.0, 0.74, 0.34, 0.86), "reward.amasya")
	_marker.hide_nearby_collection_visuals(marker.position, true, props, foreground_props)
	_update_progress()
	_refresh_minimap_markers()
	_show_info_card(String(marker.get_meta("title")), _marker.format_marker_text(String(marker.get_meta("text")), hero_name), "Yeni bildiri ipucu bulundu", Callable(), "amasya")

	if _state.get_item_count("amasya_clues") >= _state.get_zone_item_total("amasya_clues"):
		_set_goal("amasya_decision", "Amasya ipuçları tamamlandı. Şimdi Amasya Kararı noktasına git.")

func _collect_kongre_clue(marker: Node2D) -> void:
	if bool(marker.get_meta("collected")):
		return

	_marker.mark_collected(marker)
	_state.increment_item_count("kongre_clues")
	_spawn_reward_burst(marker.position, Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.76), "reward.kongre")
	_marker.hide_nearby_collection_visuals(marker.position, true, props, foreground_props)
	_update_progress()
	_refresh_minimap_markers()
	_show_info_card(String(marker.get_meta("title")), _marker.format_marker_text(String(marker.get_meta("text")), hero_name), "Yeni kongre ipucu bulundu", Callable(), "kongre")

	if _state.get_item_count("kongre_clues") >= _state.get_zone_item_total("kongre_clues"):
		_set_goal("kongre_decision", "Kongre ipuçları tamamlandı. Şimdi Kongre Kararı noktasına git.")

func _collect_leadership_resource(marker: Node2D) -> void:
	if bool(marker.get_meta("collected")):
		return

	_marker.mark_collected(marker)
	_state.add_leadership(1)
	_spawn_reward_burst(marker.position, Color(0.70, 1.0, 0.48, 0.86), "reward.resource")
	_marker.hide_nearby_collection_visuals(marker.position, true, props, foreground_props)
	_update_progress()
	_refresh_minimap_markers()
	_show_info_card(String(marker.get_meta("title")), _marker.format_marker_text(String(marker.get_meta("text")), hero_name), "Liderlik puani +1", Callable(), "support")


func _enter_bandirma() -> void:
	_play_dream_transition(Callable(self, "_setup_bandirma"))

func _setup_bandirma() -> void:
	_builder.clear_world(self)
	_builder.build_world("ship", self)
	_marker.spawn_markers("ship", self)
	_state.reset_item_count("ship_clues")
	player.position = Vector2(520, 760)
	companion.position = Vector2(660, 820)
	target_position = player.position
	has_target = false
	_set_goal("ship_clue", "Bandırma Vapuru'nda uyan. Üniformayı ve harita masasını incele.")
	_update_progress()
	_show_chapter_transition("Bandırma Vapuru", "Gece yolculugu basliyor")
	_show_dialogue(
		"Bandırma Vapuru",
		"%s gözlerini açtığında küçük bir kamaradadır. Başucunda ona uygun bir üniforma vardır. Güverteye çıkmadan önce kamaradaki ipuçlarını incele." % hero_name,
		Callable()
	)

func _clear_world() -> void:
	_builder.clear_world(self)
	companion_reaction_spots.clear()
	samsun_goal_visuals.clear()
	active_companion_reaction = ""
	if companion_reaction_label != null:
		companion_reaction_label.visible = false
	_clear_minimap_markers()

func _show_event_decision(event_index: int, context: String) -> void:
	var event: Dictionary = _questions.EVENTS[event_index]
	panel_mode = "decision"
	decision_overlay.present({
		"context": context,
		"chapter": event.get("chapter", "Karar Anı"),
		"title": event.get("chapter", "Karar Anı") + " - Karar",
		"prompt": event.get("story", ""),
		"option_a": event.get("option_a", ""),
		"option_b": event.get("option_b", ""),
	})
	interact_button.visible = false
	character_panel.visible = false

func _show_samsun_decision() -> void:
	_show_event_decision(EVENT_DECISION_SAMSUN, "samsun")

func _answer_samsun_decision(choice: String) -> void:
	var event: Dictionary = _questions.EVENTS[EVENT_DECISION_SAMSUN]
	interact_button.visible = true
	panel_mode = "character"

	if choice == event.get("correct", ""):
		_show_info_card(
			"Doğru Karar",
			event.get("info", ""),
			"Tarih yildizi kazandin",
			Callable(self, "_enter_samsun_rift"),
			"decision"
		)
	else:
		_show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)

func _show_havza_decision() -> void:
	_show_event_decision(EVENT_DECISION_HAVZA, "havza")

func _show_amasya_decision() -> void:
	_show_event_decision(EVENT_DECISION_AMASYA, "amasya")

func _show_kongre_decision() -> void:
	_show_event_decision(EVENT_DECISION_KONGRE, "kongreler")

func _answer_havza_decision(choice: String) -> void:
	var event: Dictionary = _questions.EVENTS[EVENT_DECISION_HAVZA]
	interact_button.visible = true
	panel_mode = "character"

	if choice == event.get("correct", ""):
		_set_goal("build_spot", "Havza çağrısı doğru yapıldı. En az iki destek kur ve Sessizlik Dalgası'nı başlat.")
		_show_info_card(
			"Doğru Çağrı",
			event.get("info", ""),
			"Halk destegi acildi",
			Callable(),
			"decision"
		)
	else:
		_show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)

func _answer_amasya_decision(choice: String) -> void:
	var event: Dictionary = _questions.EVENTS[EVENT_DECISION_AMASYA]
	interact_button.visible = true
	panel_mode = "character"

	if choice == event.get("correct", ""):
		_set_goal("build_spot", "Amasya kararı doğru kuruldu. En az iki destek kur ve Tereddüt Çemberi'ni başlat.")
		_show_info_card(
			"Doğru Bildiri",
			event.get("info", ""),
			"Bildiri guclendi",
			Callable(),
			"decision"
		)
	else:
		_show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)

func _answer_kongre_decision(choice: String) -> void:
	var event: Dictionary = _questions.EVENTS[EVENT_DECISION_KONGRE]
	interact_button.visible = true
	panel_mode = "character"

	if choice == event.get("correct", ""):
		_set_goal("build_spot", "Kongre kararı doğru kuruldu. En az iki destek kur ve Dağınıklık Dalgası'nı başlat.")
		_show_info_card(
			"Doğru Birleşim",
			event.get("info", ""),
			"Birlesik hedef acildi",
			Callable(),
			"decision"
		)
	else:
		_show_dialogue(
			"Bir Daha Düşünelim",
			event.get("retry", ""),
			Callable()
		)

func _enter_samsun_rift() -> void:
	_play_dream_transition(Callable(self, "_setup_samsun_rift"))

func _setup_samsun_rift() -> void:
	_builder.clear_world(self)
	_builder.build_world("samsun_rift", self)
	_setup_samsun_rift_after_build()
	_marker.spawn_markers("samsun_rift", self)
	_state.set_leadership(3)
	_state.reset_supports()
	_state.reset_wave_attempts()
	player.position = Vector2(800, 1070)
	companion.position = Vector2(930, 1160)
	target_position = player.position
	has_target = false
	_start_samsun_open_world_overview()
	_set_goal("resource", _samsun_intro_goal_text())
	_update_progress()
	_show_chapter_transition("Samsun Ruyasi", "Kararlarini stratejiyle destekle")
	_show_dialogue(
		"Samsun Rüyası",
		"Ekranın kenarları bulutlanır. %s Samsun kıyısında küçük bir rüya haritasına iner. Liman, Telgraf ve Halk noktaları parlıyor: önce izleri oku, sonra iki destek kur." % hero_name,
		Callable()
	)

func _enter_havza() -> void:
	_play_dream_transition(Callable(self, "_setup_havza"))

func _setup_havza() -> void:
	_builder.clear_world(self)
	_builder.build_world("havza", self)
	_marker.spawn_markers("havza", self)
	_state.reset_item_count("havza_clues")
	_state.set_leadership(2)
	_state.reset_supports()
	_state.reset_wave_attempts()
	player.position = Vector2(760, 1180)
	companion.position = Vector2(900, 1260)
	target_position = player.position
	has_target = false
	_set_goal("havza_clue", "Havza açıldı. İpuçlarını topla, doğru çağrıyı seç ve sessizlik dalgasını aş.")
	_update_progress()
	_show_chapter_transition("Havza Genelgesi", "Halkin ortak sesini bul")
	_show_dialogue(
		"Havza Genelgesi",
		"%s bu kez sakin ama gergin bir kasaba meydanında belirir. İnsanlar ne yapacaklarını bilmiyor gibidir. Onları ortak ve bilinçli tepkiye hazırlamak gerekir." % hero_name,
		Callable()
	)

func _enter_amasya() -> void:
	_play_dream_transition(Callable(self, "_setup_amasya"))

func _setup_amasya() -> void:
	_builder.clear_world(self)
	_builder.build_world("amasya", self)
	_marker.spawn_markers("amasya", self)
	_state.reset_item_count("amasya_clues")
	_state.set_leadership(2)
	_state.reset_supports()
	_state.reset_wave_attempts()
	player.position = Vector2(780, 1220)
	companion.position = Vector2(920, 1300)
	target_position = player.position
	has_target = false
	_set_goal("amasya_clue", "Amasya açıldı. İpuçlarını topla, doğru bildiriyi seç ve tereddüt çemberini aş.")
	_update_progress()
	_show_chapter_transition("Amasya Genelgesi", "Milletin kararini cümleye dönüştür")
	_show_dialogue(
		"Amasya Genelgesi",
		"%s şimdi loş bir toplantı evindedir. Fikirler havada asılı gibidir. Burada doğru iş, ortak iradeyi açık ve cesur bir bildiride birleştirmektir." % hero_name,
		Callable()
	)

func _enter_kongreler() -> void:
	_play_dream_transition(Callable(self, "_setup_kongreler"))

func _setup_kongreler() -> void:
	_builder.clear_world(self)
	_builder.build_world("kongreler", self)
	_marker.spawn_markers("kongreler", self)
	_state.reset_item_count("kongre_clues")
	_state.set_leadership(2)
	_state.reset_supports()
	_state.reset_wave_attempts()
	player.position = Vector2(780, 1220)
	companion.position = Vector2(920, 1300)
	target_position = player.position
	has_target = false
	_set_goal("kongre_clue", "Kongreler açıldı. İpuçlarını topla, doğru birleşimi seç ve dağınıklık dalgasını aş.")
	_update_progress()
	_show_chapter_transition("Kongreler", "Farklı sesleri ortak hedefte buluştur")
	_show_dialogue(
		"Kongreler",
		"%s şimdi büyük bir kongre salonundadır. Herkesin sesi farklıdır ama doğru iş, bu sesleri tek bir amaçta buluşturmaktır." % hero_name,
		Callable()
	)

func _finish_prototype() -> void:
	_update_objective("Prototip tamamlandı: sıradaki geliştirme Ankara ve Meclis dünyaları.")
	_show_dialogue(
		"İlk Dikey Dilim Tamamlandı",
		"%s sınav gecesinden Bandırma Vapuru'na, oradan Samsun Rüyası'na, Havza'nın örgütlenme alanına, Amasya'nın karar evine ve şimdi de Kongreler salonuna geçti. Sonraki bölümde Ankara ve Meclis için yeni dünyalar açılacak." % hero_name,
		Callable()
	)

func _show_dialogue(title: String, text: String, callback: Callable, expression: String = "idle") -> void:
	current_dialogue_callback = callback
	current_overlay_kind = "dialogue"
	dialogue_overlay.present({
		"chapter": _current_chip_text(),
		"speaker": title,
		"text": text,
		"speaker_side": _speaker_side_for_title(title),
		"expression": expression,
	})
	interact_button.disabled = true

func _show_info_card(title: String, text: String, reward_text: String, callback: Callable, card_kind := "resource") -> void:
	current_dialogue_callback = callback
	current_overlay_kind = "info"
	info_card_overlay.present({
		"tag_text": _info_tag_text(card_kind),
		"title": title,
		"text": text,
		"reward_text": reward_text,
		"icon_texture": _info_icon(card_kind),
		"accent_color": _info_accent(card_kind)
	})
	interact_button.disabled = true

func _close_dialogue() -> void:
	if current_overlay_kind == "dialogue":
		dialogue_overlay.hide_overlay()
	elif current_overlay_kind == "info":
		info_card_overlay.hide_overlay()
	else:
		dialogue_panel.visible = false
	current_overlay_kind = ""
	interact_button.disabled = false
	if current_dialogue_callback.is_valid():
		var callback := current_dialogue_callback
		current_dialogue_callback = Callable()
		callback.call()

func _speaker_side_for_title(title: String) -> String:
	if title.contains("Eda"):
		return "right"
	if title.contains("Arda"):
		return "left"
	return "right" if _state.selected_character == "eda" else "left"

func _info_tag_text(card_kind: String) -> String:
	match card_kind:
		"unit":
			return "Ünite Notu"
		"ship":
			return "Bandırma İpucu"
		"havza":
			return "Genelge İpucu"
		"amasya":
			return "Bildiri İpucu"
		"kongre":
			return "Kongre İpucu"
		"decision":
			return "Doğru Karar"
		"support":
			return "Liderlik Kaynağı"
		_:
			return "Tarih Kartı"

func _info_icon(card_kind: String) -> Texture2D:
	match card_kind:
		"unit":
			return NOTE_ICON
		"ship":
			return PORTAL_ICON
		"havza":
			return TALK_ICON
		"amasya":
			return NOTE_ICON
		"kongre":
			return TALK_ICON
		"decision":
			return DECISION_ICON
		"support":
			return BADGE_ICON
		_:
			return RESOURCE_ICON

func _info_accent(card_kind: String) -> Color:
	match card_kind:
		"unit":
			return Color(0.95, 0.75, 0.28, 0.18)
		"ship":
			return Color(0.34, 0.63, 0.95, 0.18)
		"havza":
			return Color(0.80, 0.88, 0.36, 0.18)
		"amasya":
			return Color(0.92, 0.84, 0.44, 0.18)
		"kongre":
			return Color(0.90, 0.70, 0.38, 0.18)
		"decision":
			return Color(0.95, 0.55, 0.28, 0.18)
		"support":
			return Color(0.74, 0.95, 0.38, 0.18)
		_:
			return Color(0.95, 0.75, 0.28, 0.18)

func _show_chapter_transition(title: String, subtitle: String) -> void:
	chapter_transition_overlay.present(title, subtitle)
	# Ses: bölüme göre bgm değiştir (asset yoksa sessizce başarısız olur)
	AudioManager.play_bgm(_bgm_for_chapter(title))


func _bgm_for_chapter(chapter_title: String) -> String:
	"""Bölüm başlığına göre bgm asset adını döndürür."""
	match chapter_title:
		"Bandırma Vapuru":
			return "bgm_bandirma"
		"Samsun Rüyası":
			return "bgm_samsun"
		"Havza Genelgesi":
			return "bgm_havza"
		"Amasya Genelgesi":
			return "bgm_amasya"
		"Kongreler":
			return "bgm_kongre"
		_:
			return "bgm_default"

func _on_transition_finished() -> void:
	pass

func _current_chip_text() -> String:
	match _state.current_zone:
		"ship":
			return "Bandırma Vapuru"
		"samsun_rift":
			return "Samsun Rüyası"
		"havza":
			return "Havza Genelgesi"
		"amasya":
			return "Amasya Genelgesi"
		"kongreler":
			return "Kongreler"
		_:
			return "Sınav Gecesi"

func _set_character_choice_visible(visible: bool) -> void:
	if visible:
		_build_character_choice_identity_row()
		_apply_character_identity_styles()
		_reset_panel_for_character_choice()
	else:
		_free_character_choice_identity_row()
	character_panel.visible = visible
	interact_button.visible = not visible

func _update_objective(text: String) -> void:
	var title := "Zaman Yolcuları: Sınav Gecesi"
	var chip := "Sınav Gecesi"

	match _state.current_zone:
		"ship":
			title = "Zaman Yolcuları: Bandırma"
			chip = "Bandırma Vapuru"
		"samsun_rift":
			title = "Zaman Yolcuları: Samsun Rüyası"
			chip = "Samsun Rüyası"
		"havza":
			title = "Zaman Yolcuları: Havza"
			chip = "Havza Genelgesi"
		"amasya":
			title = "Zaman Yolcuları: Amasya"
			chip = "Amasya Genelgesi"
		"kongreler":
			title = "Zaman Yolcuları: Kongreler"
			chip = "Kongreler"

	hud_bar.set_title(title)
	hud_bar.set_chip(chip)
	hud_bar.set_objective(text)
	_update_area_theme()

func _update_progress() -> void:
	var progress := ""
	var star_count := 0

	if _state.current_zone == "ship":
		progress = "Gemi ipuçları: %d/%d" % [_state.get_item_count("ship_clues"), _state.get_zone_item_total("ship_clues")]
		star_count = _state.get_item_count("units") + _state.get_item_count("ship_clues")
	elif _state.current_zone == "samsun_rift":
		progress = "Liderlik: %d | Destek: %d/%d | Dalga: %d" % [_state.leadership_points, _state.built_supports, _state.required_supports, _state.wave_attempts]
		star_count = _state.get_item_count("units") + _state.get_item_count("ship_clues") + _state.built_supports
	elif _state.current_zone == "havza":
		progress = "Havza ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [_state.get_item_count("havza_clues"), _state.get_zone_item_total("havza_clues"), _state.leadership_points, _state.built_supports, _state.required_supports]
		star_count = _state.get_item_count("units") + _state.get_item_count("ship_clues") + _state.get_item_count("havza_clues") + _state.built_supports
	elif _state.current_zone == "amasya":
		progress = "Amasya ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [_state.get_item_count("amasya_clues"), _state.get_zone_item_total("amasya_clues"), _state.leadership_points, _state.built_supports, _state.required_supports]
		star_count = _state.get_item_count("units") + _state.get_item_count("ship_clues") + _state.get_item_count("havza_clues") + _state.get_item_count("amasya_clues") + _state.built_supports
	elif _state.current_zone == "kongreler":
		progress = "Kongre ipuçları: %d/%d | Liderlik: %d | Destek: %d/%d" % [_state.get_item_count("kongre_clues"), _state.get_zone_item_total("kongre_clues"), _state.leadership_points, _state.built_supports, _state.required_supports]
		star_count = _state.get_item_count("units") + _state.get_item_count("ship_clues") + _state.get_item_count("havza_clues") + _state.get_item_count("amasya_clues") + _state.get_item_count("kongre_clues") + _state.built_supports
	else:
		progress = "Ünite notları: %d/%d" % [_state.get_item_count("units"), _state.get_zone_item_total("units")]
		star_count = _state.get_item_count("units")

	hud_bar.set_progress(progress)
	hud_bar.set_star_count(star_count)

func _update_area_theme() -> void:
	var top_fill := Color(0.97, 0.95, 0.86)
	var top_border := Color(0.32, 0.24, 0.16)
	var chip_fill := Color(0.20, 0.42, 0.38)
	var chip_border := Color(0.15, 0.24, 0.20)
	var action_fill := Color(0.20, 0.42, 0.38)
	var top_glow := Color(0.96, 0.72, 0.42, ambient_top_alpha)
	var horizon_glow := Color(0.78, 0.86, 1.0, ambient_horizon_alpha)
	var bottom_fog := Color(0.94, 0.96, 1.0, ambient_fog_alpha)
	var vignette := Color(0.04, 0.05, 0.08, 0.16)
	var rift_edge := Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, ambient_rift_edge_alpha)
	var crimson_line := Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, ambient_crimson_alpha)

	match _state.current_zone:
		"room":
			# Artwork analizine göre sıcak atmosfer (eski: tümü 0.0)
			# Referans: sahne 1.png (%73 turuncu, krem ağırlıklı)
			ambient_top_alpha = 0.06
			ambient_horizon_alpha = 0.05
			ambient_fog_alpha = 0.04
			ambient_rift_edge_alpha = 0.0
			ambient_crimson_alpha = 0.0
			top_glow = Color(1.0, 0.78, 0.42, ambient_top_alpha)
			horizon_glow = Color(0.92, 0.82, 0.60, ambient_horizon_alpha)
			bottom_fog = Color(0.96, 0.92, 0.84, ambient_fog_alpha)
			vignette = Color(0.04, 0.05, 0.08, 0.12)
			rift_edge = Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, 0.0)
			crimson_line = Color(POP_CRIMSON.r, POP_CRIMSON.g, POP_CRIMSON.b, 0.0)
		"ship":
			top_fill = Color(0.90, 0.98, 1.0)
			top_border = Color(0.02, 0.36, 0.46)
			chip_fill = POP_DEEP_TURQUOISE
			chip_border = Color(0.02, 0.18, 0.24)
			action_fill = Color(0.03, 0.48, 0.60)
			ambient_top_alpha = 0.14
			ambient_horizon_alpha = 0.13
			ambient_fog_alpha = 0.14
			ambient_rift_edge_alpha = 0.055
			ambient_crimson_alpha = 0.060
			top_glow = Color(1.0, 0.70, 0.30, ambient_top_alpha)
			horizon_glow = Color(0.18, 0.86, 1.0, ambient_horizon_alpha)
			bottom_fog = Color(0.84, 0.98, 1.0, ambient_fog_alpha)
		"samsun_rift":
			top_fill = Color(0.90, 0.97, 1.0)
			top_border = Color(0.04, 0.42, 0.56)
			chip_fill = Color(0.08, 0.48, 0.62)
			chip_border = Color(0.04, 0.22, 0.32)
			action_fill = Color(0.08, 0.48, 0.62)
			ambient_top_alpha = 0.12
			ambient_horizon_alpha = 0.13
			ambient_fog_alpha = 0.10
			ambient_rift_edge_alpha = 0.070
			ambient_crimson_alpha = 0.045
			top_glow = Color(1.0, 0.68, 0.30, ambient_top_alpha)
			horizon_glow = Color(RIFT_BLUE.r, RIFT_BLUE.g, RIFT_BLUE.b, ambient_horizon_alpha)
			bottom_fog = Color(0.84, 0.94, 1.0, ambient_fog_alpha)
		"havza":
			top_fill = Color(0.95, 0.97, 0.88)
			top_border = Color(0.28, 0.40, 0.22)
			chip_fill = Color(0.39, 0.54, 0.26)
			chip_border = Color(0.22, 0.31, 0.14)
			action_fill = Color(0.39, 0.54, 0.26)
			ambient_top_alpha = 0.11
			ambient_horizon_alpha = 0.09
			ambient_fog_alpha = 0.10
			ambient_rift_edge_alpha = 0.040
			ambient_crimson_alpha = 0.030
			top_glow = Color(0.94, 0.82, 0.46, ambient_top_alpha)
			horizon_glow = Color(0.74, 0.92, 0.76, ambient_horizon_alpha)
			bottom_fog = Color(0.96, 1.0, 0.90, ambient_fog_alpha)
		"amasya":
			top_fill = Color(0.95, 0.93, 0.88)
			top_border = Color(0.56, 0.22, 0.16)
			chip_fill = Color(0.68, 0.30, 0.20)
			chip_border = Color(0.34, 0.22, 0.14)
			action_fill = Color(0.68, 0.30, 0.20)
			ambient_top_alpha = 0.10
			ambient_horizon_alpha = 0.08
			ambient_fog_alpha = 0.09
			ambient_rift_edge_alpha = 0.046
			ambient_crimson_alpha = 0.044
			top_glow = Color(0.96, 0.74, 0.42, ambient_top_alpha)
			horizon_glow = Color(0.82, 0.76, 0.96, ambient_horizon_alpha)
			bottom_fog = Color(0.96, 0.92, 0.88, ambient_fog_alpha)
		"kongreler":
			top_fill = Color(0.95, 0.92, 0.86)
			top_border = Color(0.56, 0.22, 0.16)
			chip_fill = Color(0.74, 0.24, 0.18)
			chip_border = Color(0.40, 0.22, 0.14)
			action_fill = Color(0.74, 0.24, 0.18)
			ambient_top_alpha = 0.11
			ambient_horizon_alpha = 0.08
			ambient_fog_alpha = 0.08
			ambient_rift_edge_alpha = 0.044
			ambient_crimson_alpha = 0.052
			top_glow = Color(0.98, 0.72, 0.38, ambient_top_alpha)
			horizon_glow = Color(0.90, 0.76, 0.58, ambient_horizon_alpha)
			bottom_fog = Color(0.98, 0.92, 0.84, ambient_fog_alpha)

	hud_bar.apply_theme(top_fill, top_border, chip_fill, chip_border)
	_add_button_style(interact_button, Color("#F2BE63"))
	_add_button_style(dialogue_continue, action_fill)
	atmosphere_top_glow.color = top_glow
	atmosphere_horizon_glow.color = horizon_glow
	atmosphere_bottom_fog.color = bottom_fog
	vignette_left.color = vignette
	vignette_right.color = vignette
	rift_edge.a = ambient_rift_edge_alpha
	crimson_line.a = ambient_crimson_alpha
	rift_edge_left.color = rift_edge
	rift_edge_right.color = rift_edge
	crimson_accent.color = crimson_line


func _apply_ui_styles() -> void:
	_add_panel_style(character_panel, Color(0.97, 0.95, 0.88), Color(0.20, 0.42, 0.38), 18)
	_apply_character_identity_styles()
	_add_panel_style(dialogue_panel, Color(0.98, 0.96, 0.88), Color(0.30, 0.22, 0.16), 18)
	_add_button_style(arda_button, Color(0.80, 0.34, 0.24))
	_add_button_style(eda_button, Color(0.17, 0.51, 0.48))
	_add_button_style(interact_button, Color("#F2BE63"))
	_add_button_style(dialogue_continue, Color(0.20, 0.42, 0.38))

func _apply_character_identity_styles() -> void:
	var row := character_content.get_node_or_null("CharacterIdentityRow")
	if row == null:
		return
	for card_node in row.get_children():
		if card_node is PanelContainer:
			var card := card_node as PanelContainer
			var accent: Color = card.get_meta("identity_accent", Color(1, 1, 1, 0.35))
			var card_style := StyleBoxFlat.new()
			card_style.bg_color = Color(1.0, 0.96, 0.86, 0.70)
			card_style.border_color = Color(accent.r, accent.g, accent.b, 0.68)
			card_style.set_border_width_all(3)
			card_style.set_corner_radius_all(18)
			card.add_theme_stylebox_override("panel", card_style)

			var circle := card.find_child("IdentityCircle", true, false)
			if circle is PanelContainer:
				var circle_style := StyleBoxFlat.new()
				circle_style.bg_color = accent
				circle_style.border_color = Color(accent.r, accent.g, accent.b, 0.86)
				circle_style.set_border_width_all(4)
				circle_style.set_corner_radius_all(999)
				(circle as PanelContainer).add_theme_stylebox_override("panel", circle_style)

func _add_panel_style(panel: PanelContainer, fill: Color, border: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(4)
	style.set_corner_radius_all(radius)
	panel.add_theme_stylebox_override("panel", style)

func _add_button_style(button: Button, fill: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = fill
	normal.set_corner_radius_all(16)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = fill.darkened(0.14)
	pressed.set_corner_radius_all(16)
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(0.42, 0.42, 0.42, 0.55)
	disabled.set_corner_radius_all(16)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.62))

