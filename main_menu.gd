extends Node2D

@onready var start_button = $CanvasLayer/CenterContainer/VBoxContainer/Button
@onready var title = $CanvasLayer/RichTextLabel
@onready var panel = $CanvasLayer/Panel
@onready var slide_panel = $CanvasLayer/Panel3
@onready var start_timer = $Timer
@onready var color_rect = $CanvasLayer/ColorRect
@onready var shader_mat = color_rect.material
@onready var button_1 = $CanvasLayer/CenterContainer/VBoxContainer/Button
@onready var button_2 = $CanvasLayer/CenterContainer/VBoxContainer/Button2
@onready var menu_music = $AudioStreamPlayer
@onready var return_button = $ControlsPopup/VBoxContainer/ReturnButton
@onready var keyboard_button = $ControlsPopup/VBoxContainer/KeyboardButton
@onready var controls_pop = $ControlsPopup
@onready var cyborg_head = $CanvasLayer/AnimatedSprite2D
@onready var difficulty_select = $CanvasLayer/CenterContainer/DifficultySelect
@onready var difficulty_select_title = $CanvasLayer/CenterContainer/DifficultySelect/RichTextLabel
@onready var v_box_1 = $CanvasLayer/CenterContainer/VBoxContainer
@onready var how_to_play_button = $CanvasLayer/CenterContainer/DifficultySelect/HBoxContainer/HowToPlayButton
@onready var start_game_button = $CanvasLayer/CenterContainer/DifficultySelect/HBoxContainer/StartGameButton
@onready var close_htp_button = $CanvasLayer/CenterContainer/DifficultySelect/HBoxContainer/CloseHTPButton
@onready var bgnd = $CityBgnd
@onready var wires = $CanvasLayer/Sprite2D2
@onready var speak = $NeuroballSpoken
@onready var codex_popup = $CodexPopup
@onready var back_button = $CodexPopup/BackButton

@onready var loading_cover: ColorRect = $CanvasLayer/LoadingCover
@onready var loading_icon: AnimatedSprite2D = $CanvasLayer/LoadingIcon

#controls panel sub-items

@onready var controller_pic = $ControlsPopup/Sprite2D
@onready var controller_text1 = $ControlsPopup/RichTextLabel
@onready var controller_text2 = $ControlsPopup/RichTextLabel2
@onready var controller_text3 = $ControlsPopup/RichTextLabel3
@onready var controller_text4 = $ControlsPopup/RichTextLabel4
@onready var controller_text5 = $ControlsPopup/RichTextLabel5
@onready var controller_text6 = $ControlsPopup/RichTextLabel6
@onready var controller_text7 = $ControlsPopup/RichTextLabel7

@onready var click_sound = $AudioStreamPlayer3

@onready var keyboard_pic = $ControlsPopup/Sprite2D2
@onready var keyboard_text1 = $ControlsPopup/RichTextLabel8
@onready var keyboard_text2 = $ControlsPopup/RichTextLabel9
@onready var keyboard_text3 = $ControlsPopup/RichTextLabel10
@onready var keyboard_text4 = $ControlsPopup/RichTextLabel11
@onready var keyboard_text5 = $ControlsPopup/RichTextLabel12

@onready var audio_click = $AudioStreamPlayer2
# ball and table select

@onready var loadout_overlay: Control = $CanvasLayer/LoadoutOverlay

@onready var ball_carousel: Control = (
	$CanvasLayer/LoadoutOverlay/BallCarousel
)

@onready var ball_preview: AnimatedSprite2D = (
	$CanvasLayer/LoadoutOverlay/BallCarousel/PreviewRow/BallPreview
)

@onready var ball_name_label: Label = (
	$CanvasLayer/LoadoutOverlay/BallCarousel/BallName
)

@onready var ball_status_label: Label = (
	$CanvasLayer/LoadoutOverlay/BallCarousel/BallStatus
)

@onready var ball_left_arrow: AnimatedSprite2D = (
	$CanvasLayer/LoadoutOverlay/BallCarousel/PreviewRow/LeftArrow
)

@onready var ball_right_arrow: AnimatedSprite2D = (
	$CanvasLayer/LoadoutOverlay/BallCarousel/PreviewRow/RightArrow
)

@onready var board_carousel: Control = (
	$CanvasLayer/LoadoutOverlay/BoardCarousel
)

@onready var board_preview: AnimatedSprite2D = (
	$CanvasLayer/LoadoutOverlay/BoardCarousel/PreviewRow/BoardPreview
)

@onready var board_name_label: Label = (
	$CanvasLayer/LoadoutOverlay/BoardCarousel/BoardName
)

@onready var board_left_arrow: AnimatedSprite2D = (
	$CanvasLayer/LoadoutOverlay/BoardCarousel/PreviewRow/LeftArrow
)

@onready var board_right_arrow: AnimatedSprite2D = (
	$CanvasLayer/LoadoutOverlay/BoardCarousel/PreviewRow/RightArrow
)

@onready var start_loadout_button: Button = (
	$CanvasLayer/LoadoutOverlay/StartLoadoutButton
)

@onready var ball_left_arrow_area: Area2D = (
	$CanvasLayer/LoadoutOverlay/BallCarousel/PreviewRow/LeftArrow/Area2D
)

@onready var ball_right_arrow_area: Area2D = (
	$CanvasLayer/LoadoutOverlay/BallCarousel/PreviewRow/RightArrow/Area2D
)

# HOW TO PLAY

@onready var how_to_play: Control = $CanvasLayer/HowToPlay
@onready var htp_video: AnimatedSprite2D = $CanvasLayer/HowToPlay/Video

@onready var htp_step_title: RichTextLabel = (
	$CanvasLayer/HowToPlay/StepTitle
)

@onready var htp_step_title_2: RichTextLabel = (
	$CanvasLayer/HowToPlay/StepTitle2
)

@onready var htp_step_description: RichTextLabel = (
	$CanvasLayer/HowToPlay/StepDescription
)

@onready var htp_return_button: Button = (
	$CanvasLayer/HowToPlay/ReturnButton
)

@onready var htp_next_button: Button = (
	$CanvasLayer/HowToPlay/NextButton
)

@onready var htp_back_button: Button = (
	$CanvasLayer/HowToPlay/BackButton
)

enum LoadoutFocus {
	BALL,
	BOARD,
	START
}

enum MenuInputMode {
	MOUSE,
	CONTROLLER
}

var menu_input_mode: MenuInputMode = MenuInputMode.MOUSE

const BOARD_IDS: Array[String] = [
	"classic"
]

const BOARD_NAMES: Dictionary = {
	"classic": "NEUROBALL CLASSIC"
}

const HTP_STEP_COUNT: int = 5

var htp_current_step: int = 0

const HTP_STEPS: Array[Dictionary] = [
	{
		"title": "[center]Keep the Neuroball inside the arena.",
		"subtitle": "",
		"description":
			"[center]Move the paddles with the mouse/crosshair.\n"
			+ "[center]Opposite paddles move together.\n"
			+ "[center]The Neuroball gets faster as the round continues"
			
	},
	{
		"title": "[center]Rotate the paddles to control the ricochet",
		"subtitle": "",
		"description":
			"[center]Use A / D keys to rotate all four paddles.\n"
			+ "[center]Change the angle of impact to redirect the Neuroball\n"
			+ "[center]and line up your next target."
	},
	{
		"title": "[center]Every 3 crystals charges your LASER",
		"subtitle": "",
		"description":
			"[center]When charged, the crosshair glows and begins spinning.\n"
			+ "[center]Left-click to fire a laser blast at the crosshair position.\n"
	},
	{
		"title": "[center]Destroy Enemy Objects",
		"subtitle": "",
		"description":
			"[center]Floating 'enemy' objects can be destroyed for extra points.\n"
			+ "[center]Hit them twice with the Neuroball, or once with your laser."
	},
	{
		"title": "[center]Grab power-ups to change the odds",
		"subtitle": "",
		"description":
			"[center]Special Objects will temporarily alter the Neuroball and\n"
			+ "[center]boost your run. These Buffs can increase your score\n"
			+ "[center]multiplier, slow the Neuroball down, and more."
	},
]


var loadout_is_open: bool = false
var loadout_focus: LoadoutFocus = LoadoutFocus.BALL

var owned_ball_ids: Array[String] = []
var selected_ball_index: int = 0
var selected_board_index: int = 0

var selected_difficulty: String = "normal"


const ButtonClick = preload("res://Assets/SFX/sfx_button_click_1.tscn")
const MAIN_TWO_PATH := "res://main_two.tscn"
#const MAIN_TWO_PATH := "res://shop.tscn"
var texture = load("res://Assets/Sprites/gdb-playstation-2 triangle flat.png")

var panel_sliding: bool = false
var cyborg_head_zoom: bool = false
var cyborg_head_fade: bool = false

var menu_buttons: Array[Button] = []

func _process(_delta: float) -> void:
	if panel_sliding:
		slide_panel.global_position.y += 3
		title.self_modulate.a -= .005
		if cyborg_head.frame > 8:
			cyborg_head.stop()
			#print_debug("frame 8")
	if cyborg_head_zoom:
		cyborg_head.scale.x += 0.2
		cyborg_head.scale.y += 0.2
		panel.scale.x += 0.07
		panel.scale.y += 0.1
		panel.global_position.x -= 6
		panel.global_position.y -= 2
		wires.self_modulate.a -= .05
		#bgnd.scale.x += .3
		#bgnd.scale.y += .8
		cyborg_head.global_position.y -= 2.8
		#bgnd.global_position.y += 10
	if cyborg_head_fade:
		cyborg_head.self_modulate.a -= .01
		
	
		

func _ready() -> void:
	SaveManager.owned_balls = [
		BallCatalog.DEFAULT_BALL_ID, "saturn", "burger_ball"
	]

	SaveManager.equipped_ball_id = BallCatalog.DEFAULT_BALL_ID
	SaveManager.rounds_played = 0
	SaveManager.neurobits = 200
	SaveManager.xp_toward_next_neurobit = 0

	SaveManager.save()
	
	var returning_from_shop: bool = (
		SaveManager.returning_to_main_menu_from_shop
	)

	SaveManager.returning_to_main_menu_from_shop = false

	if returning_from_shop:
		loading_cover.hide()
		loading_icon.hide()
	else:
		show_loading_screen()
	
	#show_loading_screen()
	
	board_carousel.hide()
	
	how_to_play.hide()

	htp_next_button.pressed.connect(_on_htp_next_pressed)
	htp_back_button.pressed.connect(_on_htp_back_pressed)
	htp_return_button.pressed.connect(_on_htp_return_pressed)
	htp_return_button.mouse_entered.connect(_play_click_sound)
	#htp_next_button.mouse_entered.connect(_play_click_sound)
	#htp_back_button.mouse_entered.connect(_play_click_sound)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	ball_left_arrow_area.input_event.connect(
		_on_ball_left_arrow_input
	)

	ball_right_arrow_area.input_event.connect(
		_on_ball_right_arrow_input
	)
	get_tree().paused = false
	
	menu_input_mode = MenuInputMode.MOUSE
	_enable_mouse_menu_mode()
	start_title_glow()
	cyborg_head.play("normal")
	v_box_1.show()
	difficulty_select.hide()
	cyborg_head.scale.x = 3.0
	cyborg_head.scale.y = 3.0
	
	loadout_overlay.hide()

	start_loadout_button.focus_mode = Control.FOCUS_NONE
	start_loadout_button.pressed.connect(_confirm_loadout_and_start)
	
	ResourceLoader.load_threaded_request(MAIN_TWO_PATH)
	
	if not returning_from_shop:
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		await hide_loading_screen()
	
	await get_tree().create_timer(1.0).timeout
	speak.play()
	
	menu_buttons = [
		start_button,
		button_2,
		return_button,
		keyboard_button,
		how_to_play_button,
		start_game_button,
		close_htp_button,
		back_button,
		start_loadout_button
	]
	
	

func _on_button_pressed() -> void:
	v_box_1.hide()
	difficulty_select.show()
	#normal_button.grab_focus()
	audio_click.play()

func start_title_glow() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(title, "self_modulate:g", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.10, 2.0)
	tween.tween_property(title, "self_modulate:g", 0.95, 2.0)
	tween.tween_property(title, "self_modulate:b", 0.95, 2.0)
	
	


func _on_timer_timeout() -> void:
	#print_debug("timed")

	var status := ResourceLoader.load_threaded_get_status(MAIN_TWO_PATH)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene := ResourceLoader.load_threaded_get(MAIN_TWO_PATH) as PackedScene
		if packed_scene:
			get_tree().change_scene_to_packed(packed_scene)
	else:
		# Fallback if somehow not ready yet
		get_tree().change_scene_to_file(MAIN_TWO_PATH)


func _on_audio_stream_player_finished() -> void:
	menu_music.play()


func _on_button_2_pressed() -> void:
	controls_pop.popup()
	return_button.grab_focus()
	audio_click.play()
	#print_debug("controls")


func _on_return_button_pressed() -> void:
	controls_pop.hide()
	audio_click.play()
	
func _initiate_visor() -> void:
	var clicked = ButtonClick.instantiate()
	get_parent().add_child(clicked)
	#_initiate_visor()
	cyborg_head_zoom = true
	fade_out_static()
	await get_tree().create_timer(1.0).timeout
	panel_sliding = true
	start_timer.start()
	var tween := create_tween()
	tween.tween_property(menu_music, "volume_db", -50.0, 5.0)
	bgnd.hide()
	panel.hide()
	difficulty_select.hide()
	title.hide()
	
	await get_tree().create_timer(2.5).timeout
	cyborg_head_fade = true


func _on_easybutton_pressed() -> void:
	audio_click.play()
	open_how_to_play()
	

func _on_normalbutton_pressed() -> void:
	open_loadout_menu("normal")

func _on_hardbutton_pressed() -> void:
	difficulty_select.hide()
	v_box_1.show()


	
func fade_out_static():
	var mat := color_rect.material as ShaderMaterial
	if mat == null:
		print("No shader material!")
		return

	var tween := create_tween()
	tween.tween_method(
		func(value):
			mat.set_shader_parameter("opacity", value),
		1.0,
		0.0,
		1.0
	)


func _on_keyboard_button_pressed() -> void:
	if controller_pic.visible:
		controller_pic.hide()
		controller_text1.hide()
		controller_text2.hide()
		controller_text3.hide()
		controller_text4.hide()
		controller_text5.hide()
		controller_text6.hide()
		controller_text7.hide()
		
		keyboard_pic.show()
		keyboard_text1.show()
		keyboard_text2.show()
		keyboard_text3.show()
		keyboard_text4.show()
		keyboard_text5.show()
		
		keyboard_button.text = "Keyboard"
	else:
		controller_pic.show()
		controller_text1.show()
		controller_text2.show()
		controller_text3.show()
		controller_text4.show()
		controller_text5.show()
		controller_text6.show()
		controller_text7.show()
		
		keyboard_pic.hide()
		keyboard_text1.hide()
		keyboard_text2.hide()
		keyboard_text3.hide()
		keyboard_text4.hide()
		keyboard_text5.hide()
		keyboard_button.text = "Controller"
		


func _on_codex_button_pressed() -> void:
	codex_popup.show()
	back_button.grab_focus()
	audio_click.play()


func _on_back_button_pressed() -> void:
	codex_popup.hide()
	audio_click.play()
	
func open_loadout_menu(difficulty_id: String) -> void:
	selected_difficulty = difficulty_id

	difficulty_select.hide()
	loadout_overlay.show()
	loadout_is_open = true

	owned_ball_ids.clear()

	for ball_id: String in SaveManager.owned_balls:
		if BallCatalog.has_ball(ball_id):
			owned_ball_ids.append(ball_id)

	if owned_ball_ids.is_empty():
		owned_ball_ids.append(BallCatalog.DEFAULT_BALL_ID)

	selected_ball_index = owned_ball_ids.find(
		SaveManager.equipped_ball_id
	)

	if selected_ball_index < 0:
		selected_ball_index = 0

	selected_board_index = 0
	loadout_focus = LoadoutFocus.BALL

	_refresh_loadout_menu()
	
func _unhandled_input(event: InputEvent) -> void:
	if not loadout_is_open:
		return

	if event.is_action_pressed("ui_up"):
		_move_loadout_focus(-1)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_down"):
		_move_loadout_focus(1)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_left"):
		_move_active_carousel(-1)
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_right"):
		_move_active_carousel(1)
		get_viewport().set_input_as_handled()

	#elif event.is_action_pressed("ui_accept"):
		#if loadout_focus == LoadoutFocus.START:
			#_confirm_loadout_and_start()
		#else:
			## Optional convenience:
			## Accept while viewing a carousel moves down.
			#_move_loadout_focus(1)
#
		#get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("ui_accept"):
		if loadout_focus == LoadoutFocus.START:
			_confirm_loadout_and_start()
		else:
			loadout_focus = LoadoutFocus.START
			_refresh_loadout_focus()

		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_cancel"):
		close_loadout_menu()
		get_viewport().set_input_as_handled()
		
#func _move_loadout_focus(direction: int) -> void:
	#var next_focus: int = int(loadout_focus) + direction
#
	#next_focus = clamp(
		#next_focus,
		#int(LoadoutFocus.BALL),
		#int(LoadoutFocus.START)
	#)
#
	#loadout_focus = next_focus as LoadoutFocus
	#_refresh_loadout_focus()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.relative.length_squared() > 0.0:
			_set_menu_input_mode(MenuInputMode.MOUSE)
			var focused_control := get_viewport().gui_get_focus_owner()

			if focused_control != null:
				focused_control.release_focus()

	elif event is InputEventMouseButton:
		_set_menu_input_mode(MenuInputMode.MOUSE)

	elif event is InputEventJoypadButton:
		if event.pressed:
			_set_menu_input_mode(MenuInputMode.CONTROLLER)

	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.5:
			_set_menu_input_mode(MenuInputMode.CONTROLLER)
	
func _move_loadout_focus(direction: int) -> void:
	if direction > 0:
		loadout_focus = LoadoutFocus.START
	else:
		loadout_focus = LoadoutFocus.BALL

	_refresh_loadout_focus()
	
func _move_active_carousel(direction: int) -> void:
	audio_click.play()
	match loadout_focus:
		LoadoutFocus.BALL:
			if owned_ball_ids.is_empty():
				return

			selected_ball_index = wrapi(
				selected_ball_index + direction,
				0,
				owned_ball_ids.size()
			)

			_refresh_ball_carousel()

		LoadoutFocus.BOARD:
			if BOARD_IDS.is_empty():
				return

			selected_board_index = wrapi(
				selected_board_index + direction,
				0,
				BOARD_IDS.size()
			)

			_refresh_board_carousel()

		LoadoutFocus.START:
			pass
			
func _refresh_loadout_menu() -> void:
	_refresh_ball_carousel()
	_refresh_board_carousel()
	_refresh_loadout_focus()


func _refresh_ball_carousel() -> void:
	if owned_ball_ids.is_empty():
		ball_name_label.text = "NO NEUROBALLS"
		ball_status_label.text = ""
		return

	var ball_id: String = owned_ball_ids[selected_ball_index]
	var ball_data: Dictionary = BallCatalog.get_ball(ball_id)

	var display_name: String = str(
		ball_data.get("display_name", "NEUROBALL")
	)

	var sprite_frames: SpriteFrames = ball_data.get(
		"sprite_frames"
	) as SpriteFrames

	ball_name_label.text = display_name
	ball_status_label.text = "SELECTED"

	if sprite_frames == null:
		ball_preview.stop()
		ball_preview.sprite_frames = null
		return

	ball_preview.sprite_frames = sprite_frames

	if sprite_frames.has_animation("spin"):
		ball_preview.play("spin")
	elif sprite_frames.has_animation("default"):
		ball_preview.play("default")
	else:
		var animations: PackedStringArray = (
			sprite_frames.get_animation_names()
		)

		if not animations.is_empty():
			ball_preview.play(animations[0])
			
func _refresh_board_carousel() -> void:
	if BOARD_IDS.is_empty():
		board_name_label.text = "NO BOARDS"
		return

	var board_id: String = BOARD_IDS[selected_board_index]

	board_name_label.text = str(
		BOARD_NAMES.get(board_id, "BOARD")
	)

	if not board_preview.is_playing():
		if board_preview.sprite_frames != null:
			var animations: PackedStringArray = (
				board_preview.sprite_frames.get_animation_names()
			)

			if not animations.is_empty():
				board_preview.play(animations[0])
				
#func _refresh_loadout_focus() -> void:
	#var active_color := Color.WHITE
	#var inactive_color := Color(
		#0.32,
		#0.32,
		#0.32,
		#0.65
	#)
#
	#ball_carousel.modulate = (
		#active_color
		#if loadout_focus == LoadoutFocus.BALL
		#else inactive_color
	#)
#
	#board_carousel.modulate = (
		#active_color
		#if loadout_focus == LoadoutFocus.BOARD
		#else inactive_color
	#)
#
	#if loadout_focus == LoadoutFocus.START:
		#start_loadout_button.modulate = Color(
			#1.0,
			#0.667,
			#0.0,
			#1.0
		#)
	#else:
		#start_loadout_button.modulate = inactive_color
#
	#ball_left_arrow.visible = (
		#loadout_focus == LoadoutFocus.BALL
	#)
#
	#ball_right_arrow.visible = (
		#loadout_focus == LoadoutFocus.BALL
	#)
#
	#board_left_arrow.visible = (
		#loadout_focus == LoadoutFocus.BOARD
	#)
#
	#board_right_arrow.visible = (
		#loadout_focus == LoadoutFocus.BOARD
	#)
	
func _refresh_loadout_focus() -> void:
	var active_color := Color.WHITE
	var inactive_color := Color(
		0.32,
		0.32,
		0.32,
		0.65
	)

	ball_carousel.modulate = (
		active_color
		if loadout_focus == LoadoutFocus.BALL
		else inactive_color
	)

	board_carousel.hide()

	#if loadout_focus == LoadoutFocus.START:
		#start_loadout_button.modulate = Color(
			#1.0,
			#0.667,
			#0.0,
			#1.0
		#)
	#else:
		#start_loadout_button.modulate = Color(
			#1.0,
			#0.667,
			#0.0,
			#1.0
		#)

	ball_left_arrow.visible = (
		loadout_focus == LoadoutFocus.BALL
	)

	ball_right_arrow.visible = (
		loadout_focus == LoadoutFocus.BALL
	)
	
	
func _confirm_loadout_and_start() -> void:
	if owned_ball_ids.is_empty():
		return

	if BOARD_IDS.is_empty():
		return

	var selected_ball_id: String = owned_ball_ids[
		selected_ball_index
	]

	var selected_board_id: String = BOARD_IDS[
		selected_board_index
	]

	print(
		"Confirming loadout | Ball index: %d | Ball: %s"
		% [selected_ball_index, selected_ball_id]
	)

	var equipped: bool = SaveManager.equip_ball(
		selected_ball_id
	)

	if not equipped:
		push_warning(
			"Could not equip selected Neuroball: %s"
			% selected_ball_id
		)
		return

	print(
		"Starting game | Difficulty: %s | Ball: %s | Board: %s"
		% [
			selected_difficulty,
			selected_ball_id,
			selected_board_id
		]
	)

	loadout_is_open = false
	loadout_overlay.hide()

	_initiate_visor()
	
func close_loadout_menu() -> void:
	loadout_is_open = false
	loadout_overlay.hide()

	difficulty_select.show()
	#normal_button.grab_focus()


func _on_neon_alley_pressed() -> void:
	SaveManager.enter_shop_from_arcade = true
	audio_click.play()
	get_tree().change_scene_to_file("res://shop.tscn")
	
func _on_ball_left_arrow_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not loadout_is_open:
		return

	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		loadout_focus = LoadoutFocus.BALL
		_move_active_carousel(-1)
		_refresh_loadout_focus()
		_flash_loadout_arrow(ball_left_arrow)


func _on_ball_right_arrow_input(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if not loadout_is_open:
		return

	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		loadout_focus = LoadoutFocus.BALL
		_move_active_carousel(1)
		_refresh_loadout_focus()
		_flash_loadout_arrow(ball_right_arrow)

func _set_menu_input_mode(new_mode: MenuInputMode) -> void:
	if menu_input_mode == new_mode:
		return

	menu_input_mode = new_mode

	match menu_input_mode:
		MenuInputMode.MOUSE:
			_enable_mouse_menu_mode()

		MenuInputMode.CONTROLLER:
			_enable_controller_menu_mode()
			
func _enable_mouse_menu_mode() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()

	if focus_owner != null:
		focus_owner.release_focus()

	for button in menu_buttons:
		if is_instance_valid(button):
			button.focus_mode = Control.FOCUS_NONE
			
			
func _enable_controller_menu_mode() -> void:
	for button in menu_buttons:
		if is_instance_valid(button):
			button.focus_mode = Control.FOCUS_ALL

	_grab_contextual_menu_focus()
	
	
func _grab_contextual_menu_focus() -> void:
	if controls_pop.visible:
		return_button.grab_focus()

	elif codex_popup.visible:
		back_button.grab_focus()

	elif difficulty_select.visible:
		start_game_button.grab_focus()

	elif v_box_1.visible:
		start_button.grab_focus()


func _on_button_mouse_entered() -> void:
	click_sound.play()


func _on_button_2_mouse_entered() -> void:
	click_sound.play()


func _on_codex_button_mouse_entered() -> void:
	click_sound.play()


func _on_neon_alley_mouse_entered() -> void:
	click_sound.play()


#func _on_boot_timer_timeout() -> void:
	#if difficulty_select_title.text == "[center]Booting Up...":
		#difficulty_select_title.text = "[center]Booting Up.."
	#else:
		#difficulty_select_title.text = "[center]Booting Up..."

func open_how_to_play() -> void:
	htp_current_step = 0

	difficulty_select.hide()
	how_to_play.show()

	_refresh_how_to_play_step()
	
func _refresh_how_to_play_step() -> void:
	if htp_current_step < 0:
		htp_current_step = 0

	if htp_current_step >= HTP_STEP_COUNT:
		htp_current_step = HTP_STEP_COUNT - 1

	var step_data: Dictionary = HTP_STEPS[htp_current_step]

	htp_step_title.text = str(
		step_data.get("title", "")
	)

	htp_step_title_2.text = str(
		step_data.get("subtitle", "")
	)

	htp_step_description.text = str(
		step_data.get("description", "")
	)

	var animation_name := "step_%d" % (
		htp_current_step + 1
	)

	if htp_video.sprite_frames.has_animation(animation_name):
		htp_video.play(animation_name)
	else:
		push_warning(
			"Missing How To Play animation: %s"
			% animation_name
		)

	# Back unavailable on step 1.
	htp_back_button.disabled = (
		htp_current_step == 0
	)

	# Step 5 changes NEXT to DONE.
	if htp_current_step == HTP_STEP_COUNT - 1:
		htp_next_button.text = "DONE"
	else:
		htp_next_button.text = "NEXT"
		
func _on_htp_next_pressed() -> void:
	audio_click.play()

	if htp_current_step >= HTP_STEP_COUNT - 1:
		close_how_to_play()
		return

	htp_current_step += 1
	_refresh_how_to_play_step()
	
func _on_htp_back_pressed() -> void:
	audio_click.play()

	if htp_current_step <= 0:
		return

	htp_current_step -= 1
	_refresh_how_to_play_step()
	
func _on_htp_return_pressed() -> void:
	audio_click.play()
	close_how_to_play()
	
func close_how_to_play() -> void:
	htp_video.stop()
	how_to_play.hide()

	difficulty_select.show()


func _on_how_to_play_button_pressed() -> void:
	audio_click.play()
	open_how_to_play()


func _on_start_game_button_pressed() -> void:
	open_loadout_menu("normal")


func _on_close_htp_button_pressed() -> void:
	difficulty_select.hide()
	v_box_1.show()


func _on_how_to_play_button_mouse_entered() -> void:
	cyborg_head.play("easy")
	difficulty_select_title.text = "[center]Learn the basics"
	click_sound.play()


func _on_start_game_button_mouse_entered() -> void:
	cyborg_head.play("normal")
	difficulty_select_title.text = "[center]Start Playing..."
	click_sound.play()


func _on_close_htp_button_mouse_entered() -> void:
	cyborg_head.play("hard")
	difficulty_select_title.text = "[center]Go back..."
	click_sound.play()


func _on_back_button_mouse_entered() -> void:
	click_sound.play()


func _on_return_button_mouse_entered() -> void:
	click_sound.play()

func _play_click_sound() -> void:
	click_sound.play()
	
func show_loading_screen() -> void:
	loading_cover.show()
	loading_cover.modulate.a = 1.0

	loading_icon.show()
	loading_icon.modulate.a = 1.0
	loading_icon.play("loading")


func hide_loading_screen() -> void:
	# Ensures the loading image isn't just a one-frame flash.
	await get_tree().create_timer(
		1.9,
		false,
		false,
		true
	).timeout

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	tween.tween_property(
		loading_cover,
		"modulate:a",
		0.0,
		2.0
	)

	tween.tween_property(
		loading_icon,
		"modulate:a",
		0.0,
		2.0
	)

	await tween.finished

	loading_icon.stop()
	loading_icon.hide()
	loading_cover.hide()

func _flash_loadout_arrow(
	arrow: AnimatedSprite2D
) -> void:
	arrow.modulate = Color(
		0.35,
		0.75,
		1.0,
		1.0
	)

	var tween := create_tween()

	tween.tween_property(
		arrow,
		"modulate",
		Color.WHITE,
		0.18
	)


func _on_loadout_back_button_pressed() -> void:
	difficulty_select.show()
	loadout_overlay.hide()
	loadout_is_open = false
