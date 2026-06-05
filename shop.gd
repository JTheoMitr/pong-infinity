extends Node3D

enum CameraZone {
	SHOP,
	GAME,
	PATIO,
	CABINET
}

@onready var camera: Camera3D = $Camera3D
@onready var camera_start: Marker3D = $CameraStart
@onready var camera_shop_view: Marker3D = $CameraShopView
@onready var shop_ui: CanvasLayer = $CanvasLayer

@onready var screen_quad: MeshInstance3D = $ScreenQuad
@onready var screen_viewport: SubViewport = $ScreenQuad/ScreenViewport
@onready var color_rect: ColorRect = $ScreenQuad/ScreenViewport/ColorRect
@onready var vendor_sprite: Sprite3D = $Monitor/Vendor
@onready var vendor_anim: AnimatedTexture = vendor_sprite.texture
@onready var vendor_voice_intro: AudioStreamPlayer = $VendorVoiceIntro

@onready var camera_corner: Marker3D = $CameraCorner
@onready var camera_game_view: Marker3D = $CameraGameView
@onready var camera_cabinet: Marker3D = $CameraCabinet
@onready var camera_smoker: Marker3D = $CameraSmoker

@onready var fade_cover: ColorRect = $CanvasLayer/FadeCover
@onready var loading_icon: RichTextLabel = $CanvasLayer/LoadingIcon

@onready var button_1: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer/Label
@onready var button_2: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer2/Label
@onready var button_3: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer3/Label
@onready var button_4: Label = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer4/Label

var camera_moving: bool = false
var camera_zone: CameraZone = CameraZone.SHOP

var selected_index := 0
var row_labels: Array[Label] = []


func _ready() -> void:
	show_loading_cover()

	row_labels = [
		button_1,
		button_2,
		button_3,
		button_4
	]
	_update_selection()

	screen_viewport.transparent_bg = false
	screen_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	screen_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS

	color_rect.position = Vector2.ZERO

	await RenderingServer.frame_post_draw

	var screen_mat := ShaderMaterial.new()
	screen_mat.shader = preload("res://crt_screen_3d.gdshader")
	screen_mat.set_shader_parameter("screen_texture", screen_viewport.get_texture())
	screen_quad.material_override = screen_mat

	var vendor_mat := ShaderMaterial.new()
	vendor_mat.shader = preload("res://crt_screen_3d.gdshader")
	vendor_mat.set_shader_parameter("screen_texture", vendor_sprite.texture)
	vendor_sprite.material_override = vendor_mat

	vendor_anim.pause = true
	vendor_anim.current_frame = 3

	camera.global_position = camera_start.global_position
	camera.global_rotation = camera_start.global_rotation
	camera.current = true

	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	await hide_loading_cover()

	await get_tree().create_timer(0.5).timeout
	await enter_shop()


func _unhandled_input(event: InputEvent) -> void:
	if camera_moving:
		return

	if event.is_action_pressed("ui_paddle_rotate_clockwise"):
		await rotate_clockwise()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_paddle_rotate_counterclockwise"):
		await rotate_counterclockwise()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_down"):
		selected_index = min(selected_index + 1, row_labels.size() - 1)
		_update_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_up"):
		selected_index = max(selected_index - 1, 0)
		_update_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept"):
		if camera_zone == CameraZone.GAME:
			await launch_game_from_cabinet()
			get_viewport().set_input_as_handled()


func rotate_clockwise() -> void:
	match camera_zone:
		CameraZone.SHOP:
			await move_to_game_view()

		CameraZone.GAME:
			await move_to_patio()

		CameraZone.PATIO:
			pass


func rotate_counterclockwise() -> void:
	match camera_zone:
		CameraZone.PATIO:
			await move_back_to_game_view_from_patio()

		CameraZone.GAME:
			await move_back_to_shop()

		CameraZone.SHOP:
			pass


func enter_shop() -> void:
	camera_moving = true

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(camera, "global_position", camera_shop_view.global_position, 2.5)
	tween.parallel().tween_property(camera, "global_rotation", camera_shop_view.global_rotation, 2.5)

	await tween.finished

	camera_zone = CameraZone.SHOP
	camera_moving = false

	await play_vendor_intro()
	shop_ui.visible = true


func move_to_game_view() -> void:
	camera_moving = true
	set_screen_animation_active(false)

	await tween_camera_to_marker(camera_corner, 1.4)
	await tween_camera_to_marker(camera_game_view, 2.5)

	camera_zone = CameraZone.GAME
	camera_moving = false


func move_to_patio() -> void:
	camera_moving = true

	await tween_camera_to_marker(camera_smoker, 3.0)

	camera_zone = CameraZone.PATIO
	camera_moving = false


func move_back_to_game_view_from_patio() -> void:
	camera_moving = true

	await tween_camera_to_marker(camera_game_view, 3.0)

	camera_zone = CameraZone.GAME
	camera_moving = false


func move_back_to_shop() -> void:
	camera_moving = true

	await tween_camera_to_marker(camera_corner, 2.5)
	await tween_camera_to_marker(camera_shop_view, 1.4)

	camera_zone = CameraZone.SHOP
	camera_moving = false
	set_screen_animation_active(true)


func move_into_cabinet() -> void:
	camera_moving = true

	await tween_camera_to_marker(camera_cabinet, 5.0)

	camera_moving = false
	camera_zone = CameraZone.CABINET


func launch_game_from_cabinet() -> void:
	var scene_path := "res://main_menu.tscn"

	ResourceLoader.load_threaded_request(scene_path)

	await move_into_cabinet()

	set_screen_animation_active(false)

	var status := ResourceLoader.load_threaded_get_status(scene_path)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene := ResourceLoader.load_threaded_get(scene_path) as PackedScene
		get_tree().change_scene_to_packed(packed_scene)
	else:
		get_tree().change_scene_to_file(scene_path)


func tween_camera_to_marker(marker: Marker3D, duration: float) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(camera, "global_position", marker.global_position, duration)
	tween.parallel().tween_property(camera, "global_rotation", marker.global_rotation, duration)

	await tween.finished


func _update_selection() -> void:
	for i in range(row_labels.size()):
		if i == selected_index:
			row_labels[i].text = "> " + row_labels[i].text.trim_prefix("> ")
			row_labels[i].modulate = Color(1.0, 0.667, 0.0, 1.0)
		else:
			row_labels[i].text = row_labels[i].text.trim_prefix("> ")
			row_labels[i].modulate = Color(0.0, 0.918, 1.0, 1.0)

	#screen_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func play_vendor_intro() -> void:
	await get_tree().create_timer(0.2).timeout

	vendor_anim.current_frame = 3
	vendor_anim.pause = false

	vendor_voice_intro.play()
	set_screen_animation_active(true)

	await get_tree().create_timer(1.0).timeout

	vendor_anim.pause = true
	vendor_anim.current_frame = 3

	await get_tree().create_timer(1.1).timeout

	vendor_anim.current_frame = 3
	vendor_anim.pause = false

	await get_tree().create_timer(1.3).timeout

	vendor_anim.pause = true
	vendor_anim.current_frame = 3


func set_screen_animation_active(active: bool) -> void:
	if active:
		screen_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	else:
		screen_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func show_loading_cover() -> void:
	fade_cover.visible = true
	fade_cover.modulate.a = 1.0

	loading_icon.visible = true
	loading_icon.modulate.a = 1.0


func hide_loading_cover() -> void:
	await get_tree().create_timer(0.75, false, false, true).timeout

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)

	tween.tween_property(fade_cover, "modulate:a", 0.0, 0.8)
	tween.tween_property(loading_icon, "modulate:a", 0.0, 0.8)

	await tween.finished

	loading_icon.visible = false
	fade_cover.visible = false
