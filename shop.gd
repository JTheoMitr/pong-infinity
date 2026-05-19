extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var camera_start: Marker3D = $CameraStart
@onready var camera_shop_view: Marker3D = $CameraShopView
@onready var shop_ui: CanvasLayer = $CanvasLayer

@onready var screen_quad: MeshInstance3D = $ScreenQuad
@onready var screen_viewport: SubViewport = $ScreenQuad/ScreenViewport
@onready var color_rect: ColorRect = $ScreenQuad/ScreenViewport/ColorRect

func _ready() -> void:
	
	screen_viewport.size = Vector2i(512, 256)
	screen_viewport.transparent_bg = false
	screen_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	screen_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS

	color_rect.position = Vector2.ZERO
	color_rect.size = Vector2(512, 256)


	await RenderingServer.frame_post_draw

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_texture = screen_viewport.get_texture()

	screen_quad.material_override = mat

	print("Viewport texture:", screen_viewport.get_texture())
	print("Viewport size:", screen_viewport.size)
	
	
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
	shop_ui.visible = true
