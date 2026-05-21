extends Node3D

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

@onready var item_1_button: Button = $ScreenQuad/ScreenViewport/VBoxContainer/HBoxContainer/Button

func _ready() -> void:
	
	# =========================
	# SUBVIEWPORT SCREEN SETUP
	# =========================

	#screen_viewport.size = Vector2i(512, 512)
	screen_viewport.transparent_bg = false
	screen_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	screen_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS

	color_rect.position = Vector2.ZERO
	#color_rect.size = Vector2(512, 512)

	await RenderingServer.frame_post_draw

	var screen_mat := ShaderMaterial.new()
	screen_mat.shader = preload("res://crt_screen_3d.gdshader")

	screen_mat.set_shader_parameter(
		"screen_texture",
		screen_viewport.get_texture()
	)

	screen_quad.material_override = screen_mat


	# =========================
	# VENDOR SPRITE SETUP
	# =========================

	var vendor_mat := ShaderMaterial.new()
	vendor_mat.shader = preload("res://crt_screen_3d.gdshader")

	vendor_mat.set_shader_parameter(
		"screen_texture",
		vendor_sprite.texture
	)

	vendor_sprite.material_override = vendor_mat
	vendor_anim.pause = true
	vendor_anim.current_frame = 3
	
	#shop camera vv
	
	shop_ui.visible = false

	camera.global_position = camera_start.global_position
	camera.global_rotation = camera_start.global_rotation
	camera.current = true

	await get_tree().create_timer(0.5).timeout
	enter_shop()

func enter_shop() -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(camera, "global_position", camera_shop_view.global_position, 2.5)
	tween.parallel().tween_property(camera, "global_rotation", camera_shop_view.global_rotation, 2.5)

	await tween.finished
	await play_vendor_intro()
	shop_ui.visible = true

func play_vendor_intro() -> void:
	await get_tree().create_timer(0.2).timeout

	vendor_anim.current_frame = 3
	vendor_anim.pause = false

	vendor_voice_intro.play()
	
	await get_tree().create_timer(1.0).timeout
	
	
	vendor_anim.pause = true
	vendor_anim.current_frame = 3
	
	await get_tree().create_timer(1.1).timeout
	
	vendor_anim.current_frame = 3
	vendor_anim.pause = false

	await get_tree().create_timer(1.3).timeout
	
	
	vendor_anim.pause = true
	vendor_anim.current_frame = 3
	item_1_button.grab_focus()
	
